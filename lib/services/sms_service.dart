import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =========================================================================
// 1. TOP-LEVEL BACKGROUND HANDLER
// This function MUST remain outside of any class.
// It allows Android to wake up your Flutter code even if the app is closed.
// =========================================================================
@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  print("Background SMS received from: ${message.address}");
  await _sendToRakshaBackend(message);
}

// Helper function that actually makes the HTTP request to your FastAPI
Future<void> _sendToRakshaBackend(SmsMessage message) async {
  // Replace this with your actual FastAPI server URL when deployed
  // If using Android Emulator for local testing, use http://10.0.2.2:8000
  final String apiUrl = "http://10.0.2.2:8000/api/guardian/analyze";

  try {
    // Retrieve stored IDs (Using dummy data for now until auth is fully hooked up)
    final prefs = await SharedPreferences.getInstance();
    final guardianId =
        prefs.getString('guardian_id') ?? "c2e79516-6d10-406f-a3c8-709ffb51a50f";
    final peerId = prefs.getString('peer_id'); // It's okay if this is null

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender": message.address ?? "Unknown",
        "content": message.body ?? "",
        "guardian_id": guardianId,
        "peer_id": peerId,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Successfully analyzed SMS via Raksha AI Engine");
    } else {
      print("❌ Failed to send SMS: ${response.body}");
    }
  } catch (e) {
    print("❌ Network error sending SMS to backend: $e");
  }
}

// =========================================================================
// 2. THE SERVICE CLASS
// This handles the permissions and binds the listeners when the app is open.
// =========================================================================
class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<void> initializeAndRequestPermissions() async {
    // 1. Explicitly request the SMS permission using permission_handler
    PermissionStatus status = await Permission.sms.request();

    if (status.isGranted) {
      print("SMS Permissions Granted. Starting listener...");

      // 2. Start listening to incoming SMS
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // This fires when the app is OPEN and active on the screen
          print("Foreground SMS received from: ${message.address}");
          _sendToRakshaBackend(message);
        },
        onBackgroundMessage: backgroundMessageHandler,
      );
    } else if (status.isPermanentlyDenied) {
      print(
        "SMS permissions permanently denied. User must enable in settings.",
      );
      openAppSettings();
    } else {
      print("User denied SMS permissions.");
    }
  }
}
