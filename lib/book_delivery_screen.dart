import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookDeliveryScreen extends StatefulWidget {
  final int customerId;
  const BookDeliveryScreen({super.key, required this.customerId});

  @override
  State<BookDeliveryScreen> createState() => _BookDeliveryScreenState();
}

class _BookDeliveryScreenState extends State<BookDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _addressDetailsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _timeController = TextEditingController();
  
  String _selectedWeight = "1.0"; 
  bool isProcessing = false;

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isProcessing = true);

    final url = Uri.parse('http://127.0.0.1:1000/submit-booking');
    
    final body = {
      'userId': widget.customerId.toString(),
      'exactPickupLocation': _locationController.text,
      'specificAddressDetails': _addressDetailsController.text,
      'pickupTime': _timeController.text,
      'recipientPhone': _phoneController.text,
      'weight': _selectedWeight,
      'lat': '-17.73', // Simulated GPS
      'lng': '168.31', // Simulated GPS
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Delivery Booked Successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); 
        }
      } else {
        throw Exception('Failed to book');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Delivery'), backgroundColor: Colors.black, foregroundColor: const Color(0xFFFFD100)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Meet At (Exact Location)', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _addressDetailsController,
                  decoration: const InputDecoration(labelText: 'Address Details (Blue house, etc.)', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Recipient Phone Number', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedWeight,
                  decoration: const InputDecoration(labelText: 'Estimated Weight', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: "1.0", child: Text('Small (Up to 1 kg) - 500 VT')),
                    DropdownMenuItem(value: "2.5", child: Text('Standard (Up to 3 kg) - 950 VT')),
                    DropdownMenuItem(value: "4.0", child: Text('Medium (Up to 5 kg) - 1200 VT')),
                    DropdownMenuItem(value: "8.0", child: Text('Heavy (Up to 10 kg) - 1800 VT')),
                  ],
                  onChanged: (val) => setState(() => _selectedWeight = val!),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Pickup Time', border: OutlineInputBorder()),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) _timeController.text = time.format(context);
                  },
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: isProcessing ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: const Color(0xFFFFD100), minimumSize: const Size(double.infinity, 60)),
                  child: isProcessing ? const CircularProgressIndicator(color: Color(0xFFFFD100)) : const Text('CONFIRM BOOKING'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}