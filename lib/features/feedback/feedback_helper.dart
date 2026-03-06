import 'dart:convert';
import 'dart:io';

import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/feedback/data/feedback_api_service.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Shows the feedback overlay, then sends feedback to both email and backend.
void showFeedbackOverlay(BuildContext context, WidgetRef ref) {
  BetterFeedback.of(context).show((feedback) async {
    final deviceInfo = _buildDeviceInfo();

    // Save screenshot to temp file for email attachment
    final tempDir = await getTemporaryDirectory();
    final screenshotFile = File('${tempDir.path}/feedback_screenshot.png');
    await screenshotFile.writeAsBytes(feedback.screenshot);

    // Send email (user-visible)
    _sendEmail(feedback.text, screenshotFile.path);

    // POST to backend (silent, fire-and-forget)
    _submitToBackend(
      ref,
      feedbackText: feedback.text,
      screenshotBytes: feedback.screenshot,
      deviceInfo: deviceInfo,
    );
  });
}

String _buildDeviceInfo() {
  return 'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
}

void _sendEmail(String feedbackText, String screenshotPath) {
  final email = Email(
    body: feedbackText,
    subject: '[Agricola Bug Report] ${feedbackText.length > 50 ? '${feedbackText.substring(0, 50)}...' : feedbackText}',
    recipients: ['developer@agricola-app.com'],
    attachmentPaths: [screenshotPath],
  );

  FlutterEmailSender.send(email);
}

void _submitToBackend(
  WidgetRef ref, {
  required String feedbackText,
  required List<int> screenshotBytes,
  required String deviceInfo,
}) {
  try {
    final dio = ref.read(httpClientProvider);
    final service = FeedbackApiService(dio);
    service.submitFeedback(
      feedbackText: feedbackText,
      screenshotBase64: base64Encode(screenshotBytes),
      deviceInfo: deviceInfo,
    );
  } catch (_) {
    // Silent failure — email is the primary channel
  }
}
