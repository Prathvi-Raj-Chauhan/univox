import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'PROVIDERS/bottom_navbar.dart';
import 'PROVIDERS/post_comments_providers.dart';
import 'PROVIDERS/post_form_provider.dart';
import 'PROVIDERS/post_provider.dart';
import 'SCREENS/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env");
  var token = await pref.getString('token');
  runApp(MyApp(token: token)); // token can be null, and it's okay
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({super.key, this.token});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=> BottomNavProvider()),
        ChangeNotifierProvider(create: (context)=>PostFormProvider()),
        ChangeNotifierProvider(create: (context)=>PostProvider()),
        ChangeNotifierProvider(create: (context) =>CommentsProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: mainScreeWithNavBar(),
        // home: loginPage(),
        home: Authgate(token: token),
      ),
    );
  }
}

