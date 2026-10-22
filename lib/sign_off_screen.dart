import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignOffScreen extends StatefulWidget {
  final int orderId;
  final String customerName;
  final String trackingId;

  const SignOffScreen({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.trackingId,
  });

  @override
  State<SignOffScreen> createState() => _SignOffScreenState();
}

class _SignOffScreenState extends State<SignOffScreen> {
  bool isProcessing = false;

  Future<void> _processSignOff() async {
    setState(() => isProcessing = true);

    // Call the Java backend to mark the order as DELIVERED
    final url = Uri.parse('http://127.0.0.1:1000/receiver/sign-off/${widget.orderId}');
    
    try {
      final response = await http.post(url);

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Parcel Signed & Delivered!'), backgroundColor: Colors.green),
          );
          // Wait a second, then go back to the dashboard
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to sign off');
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
      backgroundColor: const Color(0xFFFFD100),
      appBar: AppBar(
        title: const Text('Receiver Sign-Off'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFFD100),
      ),
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
              const Text('Confirm Receipt', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('Hello ${widget.customerName}!', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Order #${widget.orderId} | Tracking: ${widget.trackingId}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              // THE SIGNATURE BOX
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                ),
                child: const Center(
                  child: Text('✍️ Tap below to sign', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isProcessing ? null : _processSignOff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SIGN & ACCEPT PARCEL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}