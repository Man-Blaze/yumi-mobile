import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeighCartScreen extends StatefulWidget {
  final String customerName;
  final String phone;
<<<<<<< HEAD
  final int riderId;
  final int orderId; // <--- MUST BE HERE

  const WeighCartScreen({
    super.key,
    required this.customerName,
    required this.phone,
    required this.riderId,
    required this.orderId, // <--- MUST BE HERE
=======
  final int riderId; // <--- ADDED THIS

  const WeighCartScreen({
    super.key, 
    required this.customerName, 
    required this.phone,
    required this.riderId, // <--- ADDED THIS
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
  });

  @override
  State<WeighCartScreen> createState() => _WeighCartScreenState();
}

class _WeighCartScreenState extends State<WeighCartScreen> {
  final TextEditingController _weightController = TextEditingController();
<<<<<<< HEAD
  double? _weight;
  double? _price;
  bool isProcessing = false;

=======
  List<Map<String, dynamic>> _cart = [];
  bool isProcessing = false;

  void _addParcelToCart() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) return;

    setState(() {
      _cart.add({'weight': weight, 'price': _calculatePrice(weight)});
      _weightController.clear();
    });
  }

>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
  double _calculatePrice(double weight) {
    if (weight <= 0.5) return 500.0;
    if (weight <= 3.0) return 950.0;
    if (weight <= 5.0) return 1200.0;
    if (weight <= 10.0) return 1800.0;
    if (weight <= 20.0) return 2500.0;
    return 3500.0;
  }

<<<<<<< HEAD
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
=======
  double get _totalPrice => _cart.fold(0, (sum, item) => sum + item['price']);

  Future<void> _processAndGenerateQR() async {
    if (_cart.isEmpty) return;
    setState(() => isProcessing = true);

    final url = Uri.parse('http://127.0.0.1:1000/api/orders/book-bulk');
    
    // Add customer info AND riderId to each parcel
    final payload = _cart.map((p) => {
      'weight': p['weight'],
      'customerName': widget.customerName,
      'phone': widget.phone,
      'riderId': widget.riderId, // <--- SEND THIS
    }).toList();
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

<<<<<<< HEAD
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
=======
      if (response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('✅ Success'),
              content: Text('${_cart.length} parcels processed. Total: ${_totalPrice} VT.\nQR Codes are ready to print.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to dashboard
                  },
                  child: const Text('OK'),
                )
              ],
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isProcessing = false);
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
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
<<<<<<< HEAD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
=======
            // WEIGH INPUT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
              child: Column(
                children: [
                  TextField(
                    controller: _weightController,
<<<<<<< HEAD
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
=======
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Enter Weight (kg)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addParcelToCart,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: const Color(0xFFFFD100), minimumSize: const Size(double.infinity, 45)),
                    child: const Text('+ ADD PARCEL TO BAG'),
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
<<<<<<< HEAD
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
=======
            
            // CART LIST
            Expanded(
              child: ListView.builder(
                itemCount: _cart.length,
                itemBuilder: (context, index) {
                  final parcel = _cart[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text('Parcel ${index + 1}'),
                      subtitle: Text('${parcel['weight']} kg'),
                      trailing: Text('${parcel['price']} VT', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  );
                },
              ),
            ),
            
            // TOTAL & CHECKOUT
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: ${_totalPrice} VT', style: const TextStyle(color: Color(0xFFFFD100), fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: isProcessing ? null : _processAndGenerateQR,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD100), foregroundColor: Colors.black),
                    child: isProcessing ? const CircularProgressIndicator() : const Text('PAY & GENERATE QR'),
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
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