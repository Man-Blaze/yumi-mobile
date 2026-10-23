import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'customer_dashboard.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool isLoading = false;

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;
    setState(() => isLoading = true);

    // Calls the new API endpoint in AuthApiController
    final url = Uri.parse('http://127.0.0.1:1000/api/auth/verify-otp');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'phoneNumber': widget.phoneNumber,
          'otpCode': _otpController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // SAVE THEM TO PHONE MEMORY (So they don't login next time)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', data['id']);
        await prefs.setString('role', data['role']);
        await prefs.setString('fullName', data['fullName']);
        await prefs.setString('area', data['area'] ?? 'Port Vila');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Account Verified!'), backgroundColor: Colors.green),
          );
          
          // Go to Dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDashboard(
                customerId: data['id'],
                customerName: data['fullName'], 
                area: data['area'] ?? 'Port Vila',
              ),
            ),
            (route) => false, 
          );
        }
      } else {
        throw Exception('Invalid Code');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD100),
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFFD100),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter Confirmation Code', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('We sent a 4-digit code to ${widget.phoneNumber}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                // SIMULATED SMS BOX
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green[50], border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(5)),
                  child: const Column(
                    children: [
                      Text('📱 SMS SIMULATION:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      SizedBox(height: 5),
                      Text('YumiExpress code is 1234. Enter it to verify.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10),
                  decoration: const InputDecoration(hintText: '0000', border: OutlineInputBorder(), counterText: ""),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    foregroundColor: const Color(0xFFFFD100), 
                    minimumSize: const Size(double.infinity, 50)
                  ),
                  child: isLoading ? const CircularProgressIndicator(color: Color(0xFFFFD100)) : const Text('VERIFY & CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}