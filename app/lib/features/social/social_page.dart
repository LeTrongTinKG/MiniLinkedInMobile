import 'package:flutter/material.dart';
import 'presentation/providers/social_providers.dart';
import 'presentation/screens/social_feed_screen.dart';

/// Tab "Mạng xã hội": bọc provider (giống Context.Provider) rồi hiện màn bảng tin.
class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SocialProviders(child: SocialFeedScreen());
  }
}
