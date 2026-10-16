import 'package:flutter/material.dart';

import 'applicant_form_screen.dart';

class LuckyDrawApplyScreen extends StatelessWidget {
  const LuckyDrawApplyScreen({super.key});

  static const _headerColors = [
    Color(0xFF9A3EB0),
    Color(0xFFE51F35),
    Color(0xFFFF9F1C),
  ];

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.sizeOf(context).width - 60;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E9),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Lucky Draw',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _headerColors),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8D69D), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A765C1B),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/unnati_greens_project.jpg',
                        width: imageWidth,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: SizedBox(
                          height: 58,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ApplicantFormScreen(
                                    projectId: 1,
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE51F35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
