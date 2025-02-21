import 'package:flutter/material.dart';
import 'package:new_igeo/models/point_list.dart';
import 'package:new_igeo/screens/new_point_form_screen.dart';
import 'package:new_igeo/screens/point_details_screen.dart';
import 'package:new_igeo/screens/start_screen.dart';
import 'package:new_igeo/screens/tabs_screen.dart';
import 'package:new_igeo/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PointList(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iGeo',
        theme: ThemeData(
          primaryColor: const Color(0xFF4CAF50),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFF8D6E63),
          ),
          scaffoldBackgroundColor: const Color(0xFFE0F7FA),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: Color(0xFF004D40),
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(color: Color(0xFF004D40)),
          ),
          buttonTheme: const ButtonThemeData(
            buttonColor: Color(0xFF4CAF50),
            textTheme: ButtonTextTheme.primary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 0, 77, 64),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StartScreen(),
        routes: {
          AppRoutes.HOME2: (ctx) => TabsScreen(),
          AppRoutes.NEW_POINT: (ctx) => NewPointFormScreen(),
          AppRoutes.POINT_DETAILS: (ctx) => PointDetailScreen(),
        },
      ),
    );
  }
}
