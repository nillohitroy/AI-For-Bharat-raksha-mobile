import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/threat_card.dart';
import 'settings_screen.dart';
import '../services/sms_service.dart';
import '../services/api_service.dart'; // <-- ADD THIS IMPORT

class LiveThreatFeedScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const LiveThreatFeedScreen({super.key, required this.themeNotifier});

  @override
  State<LiveThreatFeedScreen> createState() => _LiveThreatFeedScreenState();
}

class _LiveThreatFeedScreenState extends State<LiveThreatFeedScreen>
    with WidgetsBindingObserver {
  bool _isDeviceSecure = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSecurityStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSecurityStatus();
    }
  }

  Future<void> _checkSecurityStatus() async {
    final status = await Permission.sms.status;
    setState(() {
      _isDeviceSecure = status.isGranted;
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    final smsService = SmsService();
    await smsService.initializeAndRequestPermissions();
    await _checkSecurityStatus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const String userFirstName = "Guardian";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            stretch: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Builder(
              builder: (context) {
                final hour = DateTime.now().hour;
                String greeting = hour < 12
                    ? 'Good morning'
                    : hour < 17
                    ? 'Good afternoon'
                    : 'Good evening';
                return Text(
                  '$greeting, $userFirstName',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                );
              },
            ),
            actions: [
              // ... Theme toggle and profile avatar code stays exactly the same ...
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark
                      ? const Color(0xFF00F0FF)
                      : const Color(0xFF2563EB),
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  widget.themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 4.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: isDark
                        ? const Color(0xFF00F0FF).withOpacity(0.15)
                        : const Color(0xFF1E293B),
                    child: Text(
                      userFirstName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: isDark ? const Color(0xFF00F0FF) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : InkWell(
                      onTap: _isDeviceSecure ? null : _requestPermissions,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isDeviceSecure
                                ? (isDark
                                      ? [
                                          const Color(0xFF005A61),
                                          const Color(0xFF00A2AA),
                                        ]
                                      : [
                                          const Color(0xFF1E3A8A),
                                          const Color(0xFF2563EB),
                                        ])
                                : [
                                    Colors.red.shade800,
                                    Colors.redAccent.shade400,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _isDeviceSecure
                                  ? (isDark
                                        ? const Color(
                                            0xFF00F0FF,
                                          ).withOpacity(0.1)
                                        : const Color(
                                            0xFF2563EB,
                                          ).withOpacity(0.3))
                                  : Colors.redAccent.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isDeviceSecure
                                    ? Icons.check_circle
                                    : Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isDeviceSecure
                                        ? 'Device Secure'
                                        : 'Action Required',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isDeviceSecure
                                        ? 'Background SMS scanning active'
                                        : 'Tap here to enable SMS protection',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Text(
                'Recent Detections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ),

          // THIS IS THE NEW DYNAMIC SECTION
          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService().fetchRecentThreats(),
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // 2. Error State
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text("Unable to load threats right now."),
                    ),
                  );
                }

                final threats = snapshot.data ?? [];

                // 3. Empty State
                if (threats.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        "No threats detected. Your inbox is safe!",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                // 4. Success State (Dynamic List)
                return ListView.builder(
                  shrinkWrap: true, // Prevents layout errors inside ScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Let CustomScrollView handle scrolling
                  padding: EdgeInsets.zero,
                  itemCount: threats.length,
                  itemBuilder: (context, index) {
                    return ThreatCard(threatData: threats[index]);
                  },
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
