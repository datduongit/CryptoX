import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignalsPage extends StatefulWidget {
  const SignalsPage({super.key});

  @override
  State<SignalsPage> createState() => _SignalsPageState();
}

class _SignalsPageState extends State<SignalsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tín hiệu giao dịch'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(text: 'Ngắn hạn'),
            Tab(text: 'Dài hạn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SignalList(type: 'short_term'),
          SignalList(type: 'long_term'),
        ],
      ),
    );
  }
}

class SignalList extends StatelessWidget {
  final String type;

  const SignalList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('signals')
          .where('type', isEqualTo: type)
          // .orderBy('created_at', descending: true) // load tín hiệu mới nhất lên trước
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Chưa có tín hiệu nào.'));
        }

        final signals = snapshot.data!.docs;

        return ListView.builder(
          itemCount: signals.length,
          itemBuilder: (context, index) {
            final signal = signals[index];
            return SignalItem(signal: signal);
          },
        );
      },
    );
  }
}

class SignalItem extends StatelessWidget {
  final QueryDocumentSnapshot signal;

  const SignalItem({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final status = signal['status'] as String;
    final color = status == 'sell' ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            signal['coin_symbol'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${signal['coin_name']} (${signal['coin_symbol']})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giá mua: \$${signal['entry_price']}'),
              Text('Chốt lời: \$${signal['target_price']}'),
              Text('Kỳ vọng: ${signal['profit_percent']}%'),
              Text('Trạng thái: ${status == 'sell' ? 'Bán' : 'Nắm giữ'}'),
            ],
          ),
        ),
        trailing: Icon(
          status == 'sell' ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 32,
        ),
      ),
    );
  }
}