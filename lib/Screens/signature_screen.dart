import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/utils.dart';
import '../res/app_urls.dart';

class SignatureScreen extends StatefulWidget {
  SignatureScreen(this.customerId, {super.key});
  String customerId;

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8,
        Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatermarkPaint &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

class _SignatureScreenState extends State<SignatureScreen> {
  ByteData _img = ByteData(0);
  var color = Colors.red;
  var strokeWidth = 5.0;
  final _sign = GlobalKey<SignatureState>();
  String accessToken = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startXeeProcesses();
  }

  startXeeProcesses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = (await prefs.getString('accessToken'))!;
    print(">>> signature page access token is $accessToken");
  }

  void downloadImage(String imageUrl) async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.0),
              Text("Downloading..."),
            ],
          ),
        );
      },
    );
    var response = await http.post(Uri.parse(imageUrl), headers: {
      'Authorization': 'Bearer $accessToken',
    }, body: {
      "id": widget.customerId
    });
    Navigator.pop(context); // Close the
    if (response.statusCode == 200) {
      // Image downloaded successfully
      var bytes = response.bodyBytes;
      // Save the image locally or use it as needed
      // For example, you can save it to a file using the following code:
      var directory = await getApplicationDocumentsDirectory();
      var filePath = '${directory.path}/letter.pdf';
      File pdfFile = await File(filePath).writeAsBytes(bytes);
      // Utils.flushBarSuccessMessage("File Downloaded", context);
      OpenFilex.open(pdfFile.path);
    } else {
      print(response.statusCode);
      Utils.flushBarErrorMessage("Cannot Download", context);
      // Failed to download image
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Signature(
                  color: color,
                  key: _sign,
                  onSign: () {
                    final sign = _sign.currentState;
                    debugPrint(
                        '${sign!.points.length} points in the signature');
                  },
                  backgroundPainter: _WatermarkPaint("2.0", "2.0"),
                  strokeWidth: strokeWidth,
                ),
              ),
              color: Colors.black12,
            ),
          ),
          _img.buffer.lengthInBytes == 0
              ? Container()
              : LimitedBox(
                  maxHeight: 200.0,
                  child: Image.memory(_img.buffer.asUint8List())),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                      color: Colors.green,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Prevent dismissing the dialog by tapping outside
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 16.0),
                                  Text("Uploading..."),
                                ],
                              ),
                            );
                          },
                        );
                        final sign = _sign.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image = await sign!.getData();
                        var data = await image.toByteData(
                            format: ui.ImageByteFormat.png);
                        sign!.clear();
                        final encoded =
                            base64.encode(data!.buffer.asUint8List());
                        setState(() {
                          _img = data;
                        });
                        debugPrint("onPressed " + encoded);

                        // Replace 'your_upload_url' with the actual URL where you want to upload the image
                        var uploadUrl =
                            Uri.parse(AppUrl.customerSignatureUpload);

                        var request = http.MultipartRequest('POST', uploadUrl);
                        request.fields['id'] = widget.customerId;
                        request.files.add(http.MultipartFile.fromBytes(
                          'image',
                          data!.buffer.asUint8List(),
                          filename: 'image.png',
                        ));
                        Map<String, String> headers = {
                          // "Accept": "application/json",
                          "Authorization": "Bearer " + accessToken!
                        }; //
                        request.headers.addAll(headers);

                        var response = await request.send();
                        print(response.statusCode);

                        if (response.statusCode == 200) {
                          print(">>> 200");
                          // Image uploaded successfully
                          response.stream
                              .transform(utf8.decoder)
                              .listen((value1) {
                            print(value1);
                            final jsonData = json.decode(value1);
                            print(jsonData);
                            if (jsonData["success"] == true) {
                              Utils.flushBarSuccessMessage(
                                  "Uploaded Successfully", context);
                              Timer(Duration(seconds: 1), () {
                                downloadImage(AppUrl.allotmentletter);
                              });
                            } else {
                              Utils.flushBarSuccessMessage(
                                  "Some Error Occured", context);
                            }
                          });
                        } else {
                          print("failed");
                          Utils.flushBarSuccessMessage(
                              "Some Error Occured", context);
                          // Failed to upload image
                          // Handle the error
                        }
                      },
                      child: Text("Save")),
                  MaterialButton(
                      color: Colors.grey,
                      onPressed: () {
                        final sign = _sign.currentState;
                        sign!.clear();
                        setState(() {
                          _img = ByteData(0);
                        });
                        debugPrint("cleared");
                      },
                      child: Text("Clear")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                      onPressed: () {
                        setState(() {
                          color =
                              color == Colors.blue ? Colors.red : Colors.blue;
                        });
                        debugPrint("change color");
                      },
                      child: Text("Change color")),
                  MaterialButton(
                      onPressed: () {
                        setState(() {
                          int min = 1;
                          int max = 10;
                          int selection = min + (Random().nextInt(max - min));
                          strokeWidth = selection.roundToDouble();
                          debugPrint("change stroke width to $selection");
                        });
                      },
                      child: Text("Change stroke width")),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
