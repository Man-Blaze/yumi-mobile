import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // ADD THIS
import 'rider_dashboard.dart';
import 'customer_dashboard.dart';
import 'otp_screen.dart'; // Make sure this file exists!

void main() {
  runApp(const YumiExpressApp());
}

class YumiExpressApp extends StatelessWidget {
  const YumiExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YumiExpress',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD100),
        scaffoldBackgroundColor: const Color(0xFFFFD100),
        fontFamily: 'Arial',
      ),
      home: const AuthCheckScreen(), // Checks if they are already logged in
    );
  }
}

// ==========================================
// 1. THE BOUNCER: CHECKS IF THEY ARE LOGGED IN
// ==========================================
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? role = prefs.getString('role');
    String? fullName = prefs.getString('fullName');
    String? area = prefs.getString('area');

    if (userId != null && role != null) {
      if (role == 'CUSTOMER') {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => CustomerDashboard(customerId: userId, customerName: fullName ?? "Customer", area: area ?? "Port Vila"),
        ));
      } else if (role == 'RIDER') {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => RiderDashboard(riderId: userId, token: "dummy-token"),
        ));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ==========================================
// 2. THE LOGIN SCREEN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool isLoading = false;

  // SAVE TO MEMORY AND GO TO DASHBOARD
  Future<void> _saveUserAndGoToDashboard(int userId, String role, String fullName, String area) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('role', role);
    await prefs.setString('fullName', fullName);
    await prefs.setString('area', area);

    if (!mounted) return;

    if (role == 'CUSTOMER') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) => CustomerDashboard(customerId: userId, customerName: fullName, area: area),
      ), (route) => false);
    } else if (role == 'RIDER') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) => RiderDashboard(riderId: userId, token: "dummy-token"),
      ), (route) => false);
    }
  }

  // LOGIN FUNCTION
  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final nationalId = _idController.text.trim();
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Phone Number')));
      return;
    }

    setState(() => isLoading = true);
    final url = Uri.parse('http://127.0.0.1:1000/api/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNumber": phone, 
          "nationalId": nationalId.isEmpty ? "OTP_VERIFIED" : nationalId 
        }), 
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveUserAndGoToDashboard(data['id'], data['role'], data['fullName'], data['area'] ?? 'Port Vila');
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed. Check Phone or ID.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // SEND OTP FUNCTION (For New Users)
  // SEND OTP FUNCTION (For New Users)
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your Phone Number')));
      return;
    }

    setState(() => isLoading = true);
    // Calls your WebController /send-otp
    final url = Uri.parse('http://127.0.0.1:1000/send-otp');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"phoneNumber": phone}, 
      );

      // The backend now returns "OTP_SENT", so status 200 means success
      if (response.statusCode == 200) {
        if (mounted) {
          // THIS AUTOMATICALLY SLIDES TO THE OTP SCREEN
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => OtpScreen(phoneNumber: phone)
            )
          );
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Failed to send OTP. Try again.'))
           );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('YumiExpress', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Welcome', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 30),
                
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'National ID (Optional for Customers)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: const Color(0xFFFFD100), minimumSize: const Size(double.infinity, 50)),
                  child: isLoading ? const CircularProgressIndicator(color: Color(0xFFFFD100)) : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                const Text('New to YumiExpress?', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),

                OutlinedButton(
                  onPressed: isLoading ? null : _sendOtp,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.black), minimumSize: const Size(double.infinity, 50)),
                  child: const Text('REGISTER WITH OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}