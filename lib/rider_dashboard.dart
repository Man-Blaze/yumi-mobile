import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'weigh_cart_screen.dart';
import 'sign_off_screen.dart';

class RiderDashboard extends StatefulWidget {
  final int riderId;
  final String token;

  const RiderDashboard({super.key, required this.riderId, required this.token});

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  List<dynamic> tasks = [];
  bool isLoading = true;
  Timer? _pollingTimer;
  int _lastTaskCount = 0;

  @override
  void initState() {
    super.initState();
    fetchTasks();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      checkForNewTasks();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchTasks() async {
    final url = Uri.parse('http://127.0.0.1:1000/api/orders/rider/${widget.riderId}/tasks');
    try {
      final response = await http.get(url, headers: {"Authorization": "Bearer ${widget.token}"});
      if (response.statusCode == 200) {
        setState(() {
          tasks = jsonDecode(response.body);
          isLoading = false;
          _lastTaskCount = tasks.length;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void checkForNewTasks() async {
    final url = Uri.parse('http://127.0.0.1:1000/api/orders/rider/${widget.riderId}/tasks');
    try {
      final response = await http.get(url, headers: {"Authorization": "Bearer ${widget.token}"});
      if (response.statusCode == 200) {
        List<dynamic> newTasks = jsonDecode(response.body);
        if (newTasks.length != _lastTaskCount) {
          setState(() {
            tasks = newTasks;
            _lastTaskCount = newTasks.length;
          });
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🔔 New Task Added!'), backgroundColor: Colors.orange),
            );
          }
        }
      }
    } catch (e) {
      print('Polling error: $e');
    }
  }

  double get _totalActiveWeight {
    return tasks
<<<<<<< HEAD
        .where((t) => t['status'] == 'PICKED_UP')
=======
        .where((t) => t['status'] == 'ASSIGNED' || t['status'] == 'PICKED_UP')
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
        .fold(0.0, (sum, t) => sum + (t['weightInKg'] ?? 0));
  }

  Map<String, dynamic>? get _nextStop {
    try {
      return tasks.firstWhere((t) => t['status'] == 'ASSIGNED' || t['status'] == 'PICKED_UP');
    } catch (e) {
      return null;
    }
  }

  void _showStatsDialog() {
    int completed = tasks.where((t) => t['status'] == 'DELIVERED').length;
    int active = tasks.where((t) => t['status'] == 'ASSIGNED' || t['status'] == 'PICKED_UP').length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Rider Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Completed: $completed', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('⏳ Active: $active', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('⚖️ Bag Weight: ${_totalActiveWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextStop = _nextStop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('YumiExpress Rider'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFFD100),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'stats') _showStatsDialog();
              if (value == 'refresh') { setState(() => isLoading = true); fetchTasks(); }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'stats', child: Text('My Stats')),
              const PopupMenuItem(value: 'refresh', child: Text('Refresh Tasks')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // STATUS BANNER
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CURRENT BAG', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('${_totalActiveWeight.toStringAsFixed(1)} kg', style: const TextStyle(color: Color(0xFFFFD100), fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('CAPACITY', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('${(15 - _totalActiveWeight).toStringAsFixed(1)} kg left', style: TextStyle(color: _totalActiveWeight > 15 ? Colors.red : Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                // NEXT STOP BANNER
                if (nextStop != null)
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    color: const Color(0xFFFFD100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📍 NEXT STOP', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(nextStop['pickupAddress'] ?? 'Unknown', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(nextStop['exactPickupLocation'] ?? 'No details', style: const TextStyle(color: Colors.black87, fontSize: 14)),
                      ],
                    ),
                  ),

                // TASK LIST
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text('No tasks assigned yet.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                onTap: () async {
                                  // B2C Flow: No Tracking ID -> Go to Weigh Cart
<<<<<<< HEAD
                                                                    // B2C Flow: No Tracking ID -> Go to Weigh Cart
                                  if (task['status'] == 'ASSIGNED' && task['trackingId'] == null) {
                                    final result = await Navigator.push(
=======
                                  if (task['status'] == 'ASSIGNED' && task['trackingId'] == null) {
                                    Navigator.push(
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WeighCartScreen(
                                          customerName: task['pickupAddress'],
                                          phone: task['recipientPhone'] ?? 'N/A',
                                          riderId: widget.riderId,
<<<<<<< HEAD
                                          orderId: task['id'], // <--- MUST BE HERE
                                        ),
                                      ),
                                    );
                                    if (result == true) fetchTasks();
                                  }
=======
                                        ),
                                      ),
                                    ).then((_) => fetchTasks());
                                  } 
>>>>>>> 709820ef9f80b493d6fda640426b6567a9b31aec
                                  
                                  // B2B Flow: Has Tracking ID -> Mark as Loaded
                                  else if (task['status'] == 'ASSIGNED' && task['trackingId'] != null) {
                                    // Call the backend to mark it as PICKED_UP
                                    final url = Uri.parse('http://127.0.0.1:1000/rider/update-status/${task['id']}?status=PICKED_UP');
                                    await http.get(url).then((_) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('✅ B2B Parcel Loaded into Bag!')),
                                      );
                                      fetchTasks(); // Refresh the list
                                    });
                                  }
                                  // NEW: PICKED_UP Flow -> Go to Sign-Off Screen
                                  else if (task['status'] == 'PICKED_UP') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignOffScreen(
                                          orderId: task['id'],
                                          customerName: task['pickupAddress'],
                                          trackingId: task['trackingId'] ?? 'N/A',
                                        ),
                                      ),
                                    ).then((_) => fetchTasks());
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Order #${task['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 5),
                                      Text('Customer: ${task['pickupAddress']}'),
                                      Text('Meet At: ${task['exactPickupLocation']}'),
                                      Text('Recipient: ${task['recipientPhone'] ?? 'N/A'}'),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFFFD100), borderRadius: BorderRadius.circular(20)),
                                        child: Text(task['status'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
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