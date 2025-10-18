import 'package:flutter/material.dart';
import 'package:projet_flutter/screens/auth/sign_up_page.dart';
import 'package:provider/provider.dart';

import 'models/ride.dart';
import 'services/ride_service.dart';
import 'screens/view/splash_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/view/profile_page.dart';
import 'screens/view/chat_page.dart';
import 'screens/view/rating_page.dart';
import 'screens/view/home_map_page.dart';
import 'screens/view/publish_ride_page.dart';
import 'screens/view/ride_details_page.dart';
import 'screens/view/ride_list_page.dart';

class AppState extends ChangeNotifier {
  final RideService rideService = RideService();
  LocationPoint? origin;
  LocationPoint? destination;
  double pricePerKm = 0.25; // DT per km
  bool isLoggedIn = false;
  String? currentUserId;
}

class RideShareApp extends StatelessWidget {
  const RideShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CAR BOOKING',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2), // Bleu principal
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50), // Vert
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            surfaceTintColor: const Color(0xFFE3F2FD),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        routes: {
          '/': (_) => const SplashPage(),
          '/login': (_) => const LoginPage(),
          '/signup': (_) => const SignUpPage(),
          '/chat': (_) => const ChatPage(),
          '/rating': (_) => const RatingPage(),
          '/home': (_) => const HomeMapPage(),
          ProfilePage.routeName: (_) => const ProfilePage(),
          RideListPage.routeName: (_) => const RideListPage(),
          PublishRidePage.routeName: (_) => const PublishRidePage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == RideDetailsPage.routeName) {
            final ride = settings.arguments as Ride;
            return MaterialPageRoute(
              builder: (_) => RideDetailsPage(ride: ride),
            );
          }
          return null;
        },
      ),
    );
  }
}
