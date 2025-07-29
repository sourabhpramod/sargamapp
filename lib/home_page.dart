import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Import your LoginPage
// Placeholder pages for navigation
import 'scan_ticket_page.dart';
import 'export_participant_info_page.dart';
import 'get_participant_info_page.dart';

class HomePage extends StatelessWidget {
  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // After successful sign out, navigate to the LoginPage and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false, // This ensures all previous routes are removed
      );
    } catch (e) {
      // Handle any potential errors during logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out: ${e.toString()}"),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.orange[50], // Very light orange background
      appBar: AppBar(
        title: const Text(
          "Dashboard", // Changed title to reflect more functionality
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange, // Vibrant orange for the app bar
        elevation: 0, // No shadow for a flatter design
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout, color: Colors.white), // White icon for contrast
            tooltip: 'Logout', // Add a tooltip for better UX
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView( // Added SingleChildScrollView for better responsiveness
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
            children: [
              // Welcome text
              Text(
                "Welcome, ${user?.email ?? 'User'}!",
                style: TextStyle(
                  fontSize: 28, // Larger font size
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange[700], // Darker orange for emphasis
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Scan Ticket Button
              _buildActionButton(
                context: context,
                text: "Scan Ticket",
                icon: Icons.qr_code_scanner,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ScanTicketPage()));
                },
              ),
              const SizedBox(height: 20),

              // Export Participant Info Button
              _buildActionButton(
                context: context,
                text: "Export Participant Info",
                icon: Icons.cloud_download,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ExportParticipantInfoPage()));
                },
              ),
              const SizedBox(height: 20),

              // Get Participant Info Button
              _buildActionButton(
                context: context,
                text: "Get Participant Info",
                icon: Icons.info,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GetParticipantInfoPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent action buttons
  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 28), // Icon inside button
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent, // Consistent red accent for buttons
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20), // More padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
        ),
        elevation: 5, // Subtle shadow
      ),
    );
  }
}
