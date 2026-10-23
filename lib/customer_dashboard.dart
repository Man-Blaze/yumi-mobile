import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'book_delivery_screen.dart';

class CustomerDashboard extends StatefulWidget {
  final int customerId;
  final String customerName;
  final String area;

  const CustomerDashboard({
    super.key, 
    required this.customerId, 
    required this.customerName,
    required this.area,
  });

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://127.0.0.1:1000/api/orders/customer/${widget.customerId}');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFFD100),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchOrders),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${widget.customerName}!', style: const TextStyle(color: Color(0xFFFFD100), fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('Account Area: ${widget.area}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // BOOK BUTTON
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookDeliveryScreen(customerId: widget.customerId)),
                );
                if (result == true) fetchOrders();
              },
              icon: const Icon(Icons.add_box),
              label: const Text('BOOK NEW DELIVERY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFFFD100),
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ),

          // ORDERS LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text('No deliveries booked yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              leading: const Icon(Icons.inventory, color: Colors.black),
                              title: Text('Order #${order['id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Meet At: ${order['exactPickupLocation']}'),
                                  Text('Status: ${order['status']}', style: TextStyle(fontWeight: FontWeight.bold, color: order['status'] == 'DELIVERED' ? Colors.green : Colors.orange)),
                                ],
                              ),
                              trailing: order['rider'] != null && order['status'] != 'DELIVERED'
                                ? const Icon(Icons.directions_bike, color: Colors.green, size: 30)
                                : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}