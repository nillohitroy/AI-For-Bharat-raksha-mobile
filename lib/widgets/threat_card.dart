import 'package:flutter/material.dart';
import '../screens/threat_details_screen.dart'; // <-- Add this import

class ThreatCard extends StatelessWidget {
  final Map<String, dynamic> threatData;

  const ThreatCard({super.key, required this.threatData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String sender = threatData['sender'] ?? 'Unknown Sender';
    final String content = threatData['content'] ?? 'No content available';
    final String severity = threatData['severity'] ?? 'HIGH';
    
    final bool isHighRisk = severity == 'HIGH' || severity == 'CRITICAL';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell( // <-- WRAP IN INKWELL
        onTap: () {
          // <-- ADD NAVIGATION HERE
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreatDetailsScreen(threat: threatData),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          // ... your existing Container code stays exactly the same ...
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            // ... existing ListTile code ...
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? (isHighRisk ? const Color(0xFF7F1D1D).withOpacity(0.4) : Colors.orange.withOpacity(0.2))
                    : (isHighRisk ? const Color(0xFFFEE2E2) : Colors.orange.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isHighRisk ? Icons.warning_rounded : Icons.info_outline_rounded,
                color: isDark 
                    ? (isHighRisk ? const Color(0xFFF87171) : Colors.orangeAccent) 
                    : (isHighRisk ? const Color(0xFFDC2626) : Colors.orange),
              ),
            ),
            title: Text(
              isHighRisk ? 'High Risk SMS Blocked' : 'Suspicious SMS Detected',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: $sender',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"$content"',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }
}