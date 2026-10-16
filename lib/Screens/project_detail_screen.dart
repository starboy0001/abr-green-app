import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';
import '../Utils/utils.dart';
import 'applicant_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String? description;
  final String? projectDetailImage;
  final String? projectBrochure;
  final String? projectPaymentPlan;
  final String? locationMap;
  final int? projectId;
  final String? projectStatus;

  const ProjectDetailScreen({
    super.key,
    required this.description,
    required this.projectDetailImage,
    required this.projectBrochure,
    required this.projectPaymentPlan,
    required this.locationMap,
    required this.projectId,
    required this.projectStatus,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    final statusStr =
        widget.projectStatus?.toString().toLowerCase().trim() ?? '';
    bool isSoldOut = statusStr == '3' || statusStr == 'sold out';
    bool isUpcoming = statusStr == '2' ||
        statusStr == 'upcoming' ||
        statusStr == 'up coming';
    bool isApplyAvailable = !isSoldOut && !isUpcoming;

    String buttonText = isSoldOut
        ? "SOLD OUT"
        : isUpcoming
            ? "UP COMING"
            : "APPLY";

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Project Detail',
          style: appThemeTextWhiteC,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Image Card
              Container(
                height: 230,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CachedNetworkImage(
                    width: width,
                    imageUrl: widget.projectDetailImage ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Description Card
              Container(
                width: width,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview & Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      widget.description?.toString() ?? 'No description available.',
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28.0),

              // Single Prominent APPLY Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isApplyAvailable
                          ? appBarGradient
                          : const LinearGradient(
                              colors: [
                                Color(0xFFB0BEC5),
                                Color(0xFF90A4AE),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: isApplyAvailable
                              ? const Color(0xFFF06326).withOpacity(0.35)
                              : Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (isApplyAvailable) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApplicantFormScreen(
                                projectId: widget.projectId,
                              ),
                            ),
                          );
                        } else {
                          Utils.flushBarErrorMessage(
                            isUpcoming
                                ? "This project is upcoming soon."
                                : "This project is currently sold out.",
                            context,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isApplyAvailable) ...[
                            const Icon(
                              Icons.assignment_turned_in_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35.0),
            ],
          ),
        ),
      ),
    );
  }
}
