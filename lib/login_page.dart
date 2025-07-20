import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'home_page.dart'; // Assuming you have a home_page.dart to navigate to

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), // Trim whitespace
        password: passwordController.text.trim(), // Trim whitespace
      );
      // If login is successful, navigate to the HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided for that user.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is not valid.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700], // Error specific background color
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50], // Very light orange background
      appBar: AppBar(
        title: const Text(
          "Sargam Ticketing",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange, // A nice vibrant orange for the app bar
        elevation: 0, // No shadow for a flatter design
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or illustration could go here
              Icon(
                Icons.lock_open,
                size: 100,
                color: Colors.deepOrangeAccent, // Accent color for the icon
              ),
              const SizedBox(height: 40),

              // Email TextField
              _buildTextField(
                controller: emailController,
                labelText: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password TextField
              _buildTextField(
                controller: passwordController,
                labelText: "Password",
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () => login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // A bold red accent
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 5, // A subtle shadow
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign Up TextButton
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage())),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepOrange, // Matches the app bar color
                ),
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build polished TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: Colors.grey[800]), // Text color inside the field
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.deepOrange), // Label color
        prefixIcon: Icon(icon, color: Colors.deepOrangeAccent), // Icon color
        filled: true,
        fillColor: Colors.white, // White background for the input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners for the border
          borderSide: BorderSide.none, // No visible border initially
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange.shade200, width: 1.5), // Subtle border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.redAccent, width: 2), // Stronger accent border when focused
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}