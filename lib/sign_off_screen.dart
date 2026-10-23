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

  // --- 1. FUNCTION TO DELIVER THE PARCEL (GREEN BUTTON) ---
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
          // Wait a second so the rider can see the success message, then go back
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context, true); // Return true to refresh dashboard
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

  // --- 2. FUNCTION TO FAIL THE DELIVERY (RED BUTTON) ---
  Future<void> _processFailedAttempt() async {
    setState(() => isProcessing = true);

    // Call the Java backend to update status to FAILED_ATTEMPT
    final url = Uri.parse('http://127.0.0.1:1000/api/orders/${widget.orderId}/status?status=FAILED_ATTEMPT');
    
    try {
      final response = await http.put(url);
      
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Parcel returned to warehouse.'), backgroundColor: Colors.orange),
          );
          Navigator.pop(context, true); // Go back to dashboard and refresh
        }
      } else {
        throw Exception('Server returned error: ${response.statusCode}');
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
        // 3. ADDED MAXWIDTH: Stops the white box from stretching across the whole desktop screen
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500), 
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
          ),
          // 4. ADDED SCROLLVIEW: If the screen is small, the user can scroll down to see the red button
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Confirm Receipt', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text('Hello ${widget.customerName}!', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Order #${widget.orderId} | Tracking: ${widget.trackingId}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20), // Reduced from 40 to 20
                
                // 5. THE SIGNATURE BOX (Reduced height to 80)
                Container(
                  height: 80, 
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
                
                const SizedBox(height: 20), // Reduced from 40 to 20
                
                // 6. GREEN DELIVERY BUTTON
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

                const SizedBox(height: 15),
                
                // 7. RED FAILED ATTEMPT BUTTON
                ElevatedButton(
                  onPressed: isProcessing ? null : _processFailedAttempt, // Calls the new function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('RETURN TO WAREHOUSE (Failed Attempt)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}