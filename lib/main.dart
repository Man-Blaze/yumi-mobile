import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rider_dashboard.dart';
import 'customer_dashboard.dart'; // Make sure you created this file!

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
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController(); // ADDED: Need National ID
  bool isLoading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final nationalId = _idController.text.trim();
    
    if (phone.isEmpty || nationalId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Phone and National ID')),
      );
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
          "nationalId": nationalId
        }), 
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final role = data['role']; // CUSTOMER or RIDER
        final userId = data['id'];
        final fullName = data['fullName'];

        if (!mounted) return;

        // ROUTE THE USER BASED ON THEIR ROLE
        if (role == 'CUSTOMER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDashboard(
                customerId: userId,
                customerName: fullName,
                area: data['area'] ?? 'Port Vila',
              ),
            ),
          );
        } else if (role == 'RIDER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RiderDashboard(
                riderId: userId, 
                token: "dummy-token" // Riders don't use tokens in this version
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin must use the Web Portal.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Check Phone or National ID.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('YumiExpress', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              
              // PHONE FIELD
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              
              // NATIONAL ID FIELD (Acts as password)
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'National ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFFFFD100),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading 
                    ? const CircularProgressIndicator(color: Color(0xFFFFD100))
                    : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}