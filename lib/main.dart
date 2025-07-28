import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:univox/PAGES/setup_account.dart';

import 'PROVIDERS/bottom_navbar.dart';
import 'PROVIDERS/post_comments_providers.dart';
import 'PROVIDERS/post_form_provider.dart';
import 'PROVIDERS/post_provider.dart';
import 'SCREENS/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');

    runApp(MyApp(token: token));
  } catch (e, st) {
    print("Error initializing app: $e\n$st");

    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text("Something went wrong while launching the app."),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => PostFormProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommentsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: AccountSetupPage(token: token),
        home: Authgate(token: token),
      ),
    );
  }
}
