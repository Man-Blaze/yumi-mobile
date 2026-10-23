import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_dashboard.dart';
import 'rider_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  bool isProcessing = false;

  Future<void> _login() async {
    if (_phoneController.text.isEmpty || _idController.text.isEmpty) return;
    setState(() => isProcessing = true);

    final url = Uri.parse('http://127.0.0.1:1000/api/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'phoneNumber': _phoneController.text,
          'nationalId': _idController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (!mounted) return;

        // Route based on Role
        if (data['role'] == 'CUSTOMER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDashboard(
                customerId: data['id'],
                customerName: data['fullName'],
                area: data['area'] ?? 'Port Vila',
              ),
            ),
          );
        } else if (data['role'] == 'RIDER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RiderDashboard(
                riderId: data['id'],
                token: "dummy-token",
              ),
            ),
          );
        }
      } else {
        throw Exception('Invalid Phone or National ID');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isProcessing = false);
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('YumiExpress Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'National ID (Password)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: isProcessing ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: const Color(0xFFFFD100),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isProcessing ? const CircularProgressIndicator(color: Color(0xFFFFD100)) : const Text('LOGIN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}