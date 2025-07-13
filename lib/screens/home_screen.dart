import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top Last Measurements
            Positioned(
              top: 20,
              left: 20,
              right: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last Measurement",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "❤️ Heart Rate: 78 bpm",
                    style: TextStyle(fontSize: 16, color: Colors.greenAccent),
                  ),
                  Text(
                    "💓 HRV: 65 ms",
                    style: TextStyle(fontSize: 16, color: Colors.amber),
                  ),
                  Text(
                    "🩺 BP: 120/80",
                    style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                  ),
                ],
              ),
            ),

            // Profile Button
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.person, size: 28),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ),

            // Center Buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildMeasureButton(
                    context,
                    "Check Heart Rate",
                    Icons.favorite,
                    Colors.redAccent,
                  ),
                  const SizedBox(height: 20),
                  buildMeasureButton(
                    context,
                    "Check HRV",
                    Icons.show_chart,
                    Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  buildMeasureButton(
                    context,
                    "Check Blood Pressure",
                    Icons.bloodtype,
                    Colors.lightBlue,
                  ),
                ],
              ),
            ),

            // Bottom Action Button
            Positioned(
              bottom: 40,
              left: 50,
              right: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Start Measurement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/measure');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMeasureButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/measure');
      },
    );
  }
}
