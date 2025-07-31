import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class GmailService {
  static const String senderEmail = 'mutoni2222@gmail.com';
  static const String appPassword = 'bjyv nevr nfyp wqye';

  static Future<void> sendOTP({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    try {
      // Configure Gmail SMTP
      final smtpServer = gmail(senderEmail, appPassword);

      // Create message
      final message = Message()
        ..from = Address(senderEmail, 'MyRights App')
        ..recipients.add(email)
        ..subject = _getSubject(purpose)
        ..html = _getEmailHTML(otp, purpose);

      // Send email
      final sendReport = await send(message, smtpServer);
      print('✅ Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('❌ Gmail error: $e');
      throw Exception('Failed to send email: $e');
    }
  }

  static String _getSubject(String purpose) {
    return purpose == 'email_verification'
        ? 'Verify your MyRights account'
        : 'Reset your MyRights password';
  }

  static String _getEmailHTML(String otp, String purpose) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
    .container { max-width: 600px; margin: 0 auto; }
    .header { background: #FF6B35; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
    .otp { font-size: 32px; font-weight: bold; color: #FF6B35; text-align: center; margin: 20px 0; padding: 15px; border: 2px solid #FF6B35; border-radius: 8px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>MyRights</h1>
    </div>
    <div class="content">
      <h2>Your verification code</h2>
      <p>Hi there,</p>
      <p>Your verification code is:</p>
      <div class="otp">$otp</div>
      <p>This code will expire in 10 minutes.</p>
      <p>If you didn't request this code, please ignore this email.</p>
      <br>
      <p>Best regards,<br>The MyRights Team</p>
    </div>
  </div>
</body>
</html>
    ''';
  }
}
