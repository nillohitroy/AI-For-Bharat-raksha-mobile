import 'package:flutter/material.dart';

class ThreatDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> threat;

  const ThreatDetailsScreen({super.key, required this.threat});

  @override
  State<ThreatDetailsScreen> createState() => _ThreatDetailsScreenState();
}

class _ThreatDetailsScreenState extends State<ThreatDetailsScreen> {
  bool _isBlocked = false;

  void _blockSender() {
    setState(() {
      _isBlocked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Number ${widget.threat['sender']} has been blocked."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sender = widget.threat['sender'] ?? 'Unknown Sender';
    final content = widget.threat['content'] ?? 'No content';
    final severity = widget.threat['severity'] ?? 'HIGH';
    final contextFlag = widget.threat['cultural_context_flag'] ?? '';

    final isHighRisk = severity == 'HIGH' || severity == 'CRITICAL';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Threat Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Risk Level Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHighRisk
                    ? Colors.redAccent.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHighRisk ? Colors.red : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isHighRisk ? Icons.gpp_bad_rounded : Icons.warning_amber_rounded,
                    color: isHighRisk ? Colors.red : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level: $severity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isHighRisk ? Colors.red : Colors.orange,
                        ),
                      ),
                      if (contextFlag.isNotEmpty)
                        Text(
                          contextFlag,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Sender Information
            Text('Sender', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey)),
            const SizedBox(height: 4),
            Text(sender, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 24),

            // 3. The Actual Message Content
            Text('Message Content', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$content"',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 40),

            // 4. Conditional Block Button
            if (isHighRisk)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isBlocked ? null : _blockSender,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(_isBlocked ? Icons.check_circle : Icons.block),
                  label: Text(
                    _isBlocked ? 'Sender Blocked' : 'Block Sender Automatically',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}