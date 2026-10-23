import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/views/login_view.dart';

/// Root Application Widget configuring theme and home route.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth MVC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginView(),
    );
  }
}
