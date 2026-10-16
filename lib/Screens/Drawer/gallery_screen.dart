import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:property_project/Constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:property_project/res/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:property_project/Utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';

class GalleryScreen extends StatefulWidget {
  String item;
  GalleryScreen({super.key, required this.item});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

// List<dynamic> responseData = [];
List<dynamic> videos = [];
int currentPage = 1;
int totalPages = 1;

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchData(1);
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Gallery',
          style: appThemeTextWhiteC,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: _buildScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: whiteC,
        unselectedItemColor: dividerC,
        backgroundColor: appBarColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call_outlined),
            label: 'Videos',
          ),
        ],
      ),
    );
  }
}

Widget _buildScreen(int index) {
  switch (index) {
    case 0:
      return ImageScreen();
    case 1:
      return VideoScreen();
    default:
      return Container();
  }
}

class ImageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ImageScreenState();
    // throw UnimplementedError();
  }
}

class ImageScreenState extends State<ImageScreen> {
  int currentPage = 1;
  List<dynamic> responseDataImages = [];
  bool imageDataFound = true;
  Future<void> fetchData(int page) async {
    String url = AppUrl.displayImagesInGallery + "?page=${page.toString()}";
    print("image url is " + url);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }); // Replace with your API endpoint
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        responseDataImages.addAll(data['items']['data']);
      });
      if (responseDataImages.length == 0) {
        imageDataFound = false;
      }
    } else {
      print('Error fetching data');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData(1);
  }

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: !imageDataFound
          ? Center(
              child: Text("Images Not Found"),
            )
          : Column(children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 12.0,
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    // mainAxisSpacing: 30,
                  ),
                  itemCount: responseDataImages.length,
                  itemBuilder: (context, index) {
                    final item = responseDataImages[index];
                    final imageUrl = item['image'];
                    return Container(
                      width: 120,
                      height: 120,
                      child: GridTile(
                        child: Column(children: [
                          CachedNetworkImage(
                            height: 135,
                            fit: BoxFit.cover,
                            imageUrl: AppUrl.imageBaseUrl + imageUrl,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 135.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(item['image_title'].toString()),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              MaterialButton(
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                onPressed: () {
                  setState(() {
                    currentPage++; // Increment the current page number
                  });
                  fetchData(currentPage);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: appBarGradient, // Existing gradient
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: const Text(
                      "Load More",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  int currentPage = 1;
  List<dynamic> responseDataVideos = [];
  bool videoDataFound = true;
  Future<void> fetchDataVideos([int? page]) async {
    String url = AppUrl.displayVideosInVideos;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        videos = data['items']['data'] ?? [];

        totalPages = data['pagination']['last_page'];
      });
    } else {
      // Handle the error response
      print('Failed to fetch videos. Error: ${response.statusCode}');
    }
  }

  String getThumbnailUrl(String videoUrl) {
    if (videoUrl.contains("https://youtu.be/")) {
      final videoId = videoUrl.replaceAll('https://youtu.be/', '');
      // Construct the thumbnail URL using the video ID
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    } else if (videoUrl.contains("https://www.youtube.com/watch?v=")) {
      final videoId =
          videoUrl.replaceAll('https://www.youtube.com/watch?v=', '');
      // Construct the thumbnail URL using the video ID
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    } else {
      // Invalid YouTube URL format
      return '';
    }
  }

  void _launchYouTube(String videoUrl) async {
    Uri? url = Uri.parse(videoUrl);
    if (!await launchUrl(url)) {
      Utils.flushBarErrorMessage('Video Link Not Working', context);
      throw Exception("could not launch url");
    }
    // print(videoUrl);
    // Uri uri = Uri.parse(videoUrl);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // } else {
    //   print('Could not launch YouTube: $videoUrl');
    // }
  }

  @override
  void initState() {
    super.initState();
    fetchDataVideos(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: !videoDataFound
          ? Center(
              child: Text("Videos Not Found"),
            )
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: responseDataVideos.length,
                  itemBuilder: (context, index) {
                    final item = responseDataVideos[index];
                    final videoUrl = item['video'];
                    return Container(
                      // width: 120,
                      // height: 120,
                      child: GridTile(
                        child: Column(children: [
                          GestureDetector(
                            onTap: () {
                              _launchYouTube(videoUrl);
                            },
                            child: Image.network(
                              height: 200,
                              fit: BoxFit.cover,
                              getThumbnailUrl(videoUrl),
                              errorBuilder: (context, obj, stateTrace) {
                                return Container(
                                  height: 200.0,
                                  color: Colors.grey,
                                );
                              },
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(item['video_title'].toString()),
                          SizedBox(
                            height: 10,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              MaterialButton(
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                onPressed: () {
                  setState(() {
                    currentPage++; // Increment the current page number
                  });
                  fetchDataVideos(currentPage);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: appBarGradient, // Existing gradient
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: const Text(
                      "Load More",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      itemCount: videos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Display two videos per row
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () {
            String videoUrl = video['video'];
            _launchYouTube(videoUrl); // Open YouTube with the video URL
          },
          child: Container(
            // Customize the grid item here, such as the size and shape of the container
            child: Image.network(
              getThumbnailUrl(video['video']),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String videoUrl) async {
    if (await canLaunch(videoUrl)) {
      await launch(videoUrl);
    } else {
      print('Failed to launch video');
    }
  }
}
