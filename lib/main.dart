import 'package:flutter/material.dart';
import 'package:flutter_application_1/onboarding/splashscreen.dart';
import 'package:flutter_application_1/providers/location_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()), // LocationProvider'ı burada kullanıma sunuyoruz
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Canlı Konum Takibi',
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.indigo,
            centerTitle: true,
            foregroundColor: Colors.white,
          )),
      home: SplashScreen(), // Ana ekranımız MapScreen
    );
  }
}
