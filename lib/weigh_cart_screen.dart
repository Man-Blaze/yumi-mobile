import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeighCartScreen extends StatefulWidget {
  final String customerName;
  final String phone;
  final int riderId;
  final int orderId; // <--- MUST BE HERE

  const WeighCartScreen({
    super.key,
    required this.customerName,
    required this.phone,
    required this.riderId,
    required this.orderId, // <--- MUST BE HERE
  });

  @override
  State<WeighCartScreen> createState() => _WeighCartScreenState();
}

class _WeighCartScreenState extends State<WeighCartScreen> {
  final TextEditingController _weightController = TextEditingController();
  double? _weight;
  double? _price;
  bool isProcessing = false;

  double _calculatePrice(double weight) {
    if (weight <= 0.5) return 500.0;
    if (weight <= 3.0) return 950.0;
    if (weight <= 5.0) return 1200.0;
    if (weight <= 10.0) return 1800.0;
    if (weight <= 20.0) return 2500.0;
    return 3500.0;
  }

  void _weighParcel() {
    final w = double.tryParse(_weightController.text);
    if (w == null || w <= 0) return;
    if (w > 20.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Max weight is 20kg. Please use a truck for heavier items.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _weight = w;
      _price = _calculatePrice(w);
    });
  }

  Future<void> _processAndGenerateQR() async {
    if (_weight == null || _price == null) return;
    setState(() => isProcessing = true);

    // FIXED: Calling weigh-and-pay instead of book-bulk
    final url = Uri.parse(
        'http://127.0.0.1:1000/api/orders/weigh-and-pay/${widget.orderId}');

    final payload = [
      {'weight': _weight}
    ];

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 200 &&
          !response.body.toLowerCase().contains('error')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Success'),
            content: Text(
                'Order #${widget.orderId} weighed: ${_weight}kg\nTotal: ${_price} VT\nQR is ready to print.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);       // close dialog
                  Navigator.pop(context, true); // signal success to dashboard
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${response.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD100),
      appBar: AppBar(
        title: Text('Weighing: ${widget.customerName}'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFFD100),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Enter Weight (kg)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _weighParcel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: const Color(0xFFFFD100),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('+ WEIGH PARCEL'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_weight != null && _price != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text('Order #${widget.orderId}'),
                  subtitle: Text('$_weight kg'),
                  trailing: Text('$_price VT',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${_price ?? 0} VT',
                    style: const TextStyle(
                        color: Color(0xFFFFD100),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: (isProcessing || _weight == null)
                        ? null
                        : _processAndGenerateQR,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD100),
                        foregroundColor: Colors.black),
                    child: isProcessing
                        ? const CircularProgressIndicator()
                        : const Text('PAY & GENERATE QR'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}