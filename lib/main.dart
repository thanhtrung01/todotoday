import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todotoday/screen/theme.dart';
import 'package:todotoday/services/Auth_Service.dart';
import 'package:todotoday/pages/AddTodo.dart';
import 'package:todotoday/pages/HomePage.dart';
import 'package:todotoday/pages/SignUpPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todotoday/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthClass authClass = AuthClass();
  Widget currentPage = SignUpPage();

  @override
  void initState() {
    super.initState();
    // authClass.signOut();
    checkLogin();
  }

  checkLogin() async {
    String token = await authClass.getToken();
    // ignore: avoid_print
    print("token");
    if (token != null)
      // ignore: curly_braces_in_flow_control_structures
      setState(() {
        currentPage = HomePage();
      });
  }

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    runApp(const MyApp());
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
      home: SignUpPage(),
    );
  }
}
