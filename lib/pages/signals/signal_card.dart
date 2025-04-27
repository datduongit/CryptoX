import 'package:flutter/material.dart';

class SignalCard extends StatelessWidget {
  final String expertName;
  final String expertAvatarUrl;
  final String coinSymbol;
  final String coinName;
  final String signalType; // "buy" or "sell"
  final double entryPrice;
  final double takeProfit;
  final double stopLoss;
  final String status; // "open", "closed", "stopped"
  final String updatedAt;
  final String riskReward;

  const SignalCard({
    super.key,
    required this.expertName,
    required this.expertAvatarUrl,
    required this.coinSymbol,
    required this.coinName,
    required this.signalType,
    required this.entryPrice,
    required this.takeProfit,
    required this.stopLoss,
    required this.status,
    required this.updatedAt,
    required this.riskReward,
  });

  @override
  Widget build(BuildContext context) {
    final signalColor = signalType == 'buy' ? Colors.green : Colors.red;
    final statusColor = {
      'open': Colors.blue,
      'closed': Colors.green,
      'stopped': Colors.red,
    }[status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expert and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(expertAvatarUrl),
                      radius: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      expertName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Coin name and type
            Row(
              children: [
                Text(
                  '$coinSymbol ($coinName)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: signalColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    signalType.toUpperCase(),
                    style: TextStyle(
                      color: signalColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Entry - TP - SL
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow('Entry Price', entryPrice),
                _buildPriceRow('Take Profit', takeProfit),
                _buildPriceRow('Stop Loss', stopLoss),
              ],
            ),

            const SizedBox(height: 12),

            // Risk Reward and Updated time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Risk/Reward: $riskReward',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  updatedAt,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}