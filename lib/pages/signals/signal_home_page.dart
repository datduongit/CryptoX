import 'package:cryptox/pages/signals/signal_card.dart' show SignalCard;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignalHomeScreen extends StatefulWidget {
  const SignalHomeScreen({super.key});

  @override
  State<SignalHomeScreen> createState() => _SignalHomeScreenState();
}

class _SignalHomeScreenState extends State<SignalHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tabs = ['Short Term', 'Long Term', 'VIP Signals'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
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
        title: const Text('Tín hiệu đầu tư'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((type) => SignalList(signalType: type)).toList(),
      ),
    );
  }
}

class SignalList extends StatelessWidget {
  final String signalType;

  const SignalList({super.key, required this.signalType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('signals')
          .where('category', isEqualTo: signalType.toLowerCase()) // 'short_term', 'long_term', 'vip'
          .orderBy('createdAt', descending: true)
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
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: signals.length,
          itemBuilder: (context, index) {
            final data = signals[index].data() as Map<String, dynamic>;

            return SignalCard(
              expertName: data['expertName'] ?? '',
              expertAvatarUrl: data['expertAvatarUrl'] ?? '',
              coinSymbol: data['coinSymbol'] ?? '',
              coinName: data['coinName'] ?? '',
              signalType: data['signalType'] ?? 'buy',
              entryPrice: (data['entryPrice'] ?? 0).toDouble(),
              takeProfit: (data['takeProfit'] ?? 0).toDouble(),
              stopLoss: (data['stopLoss'] ?? 0).toDouble(),
              status: data['status'] ?? 'open',
              updatedAt: _formatTimestamp(data['createdAt']),
              riskReward: data['riskReward'] ?? '',
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${diff.inDays} ngày trước';
    }
  }
}