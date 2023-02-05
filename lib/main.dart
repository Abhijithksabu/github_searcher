import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/repos_provider.dart';
import 'providers/user_provider.dart';
import 'screens/homepage.dart';
import 'screens/splashScreen.dart';
import 'screens/user_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReposProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Github Searcher',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: SplashScreen(),
        routes: {
          SplashScreen.routeName: (context) => SplashScreen(),
          HomePage.routeName: (context) => HomePage(),
          UserDetailsPage.routeName: (context) => UserDetailsPage(),
        },
      ),
    );
  }
}
