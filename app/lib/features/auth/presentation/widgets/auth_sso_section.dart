import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../ui_kit/ui_kit.dart';
import 'github_sign_in_button.dart';
import 'google_sign_in_button.dart';

/// Khối đăng nhập mạng xã hội SSO (Google & GitHub).
class AuthSsoSection extends StatelessWidget {
  const AuthSsoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Row(
          children: [
            Expanded(child: AppDivider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Hoặc tiếp tục với',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            Expanded(child: AppDivider()),
          ],
        ),
        SizedBox(height: 16),
        GoogleSignInButton(label: 'Tiếp tục với Google'),
        SizedBox(height: 10),
        GitHubSignInButton(label: 'Tiếp tục với GitHub'),
      ],
    );
  }
}
