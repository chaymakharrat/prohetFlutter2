import 'package:flutter/material.dart';
import 'package:projet_flutter/screens/auth/sign_up_page.dart';
import 'package:provider/provider.dart';

import 'models/app_ride_models.dart';
import 'screens/home/splash_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/chat/chat_page.dart';
import 'screens/profile/rating_page.dart';
import 'screens/home/home_map_page.dart';
import 'screens/ride/publish_ride_page.dart';
import 'screens/ride/ride_details_page.dart';
import 'screens/ride/ride_list_page.dart';
import 'screens/ride/booking_page.dart';
import 'screens/ride/user_rides_page.dart';
import 'screens/notification/notifications_page.dart';

import 'state/app_state.dart';

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
          BookingPage.routeName: (_) => const BookingPage(),
          UserRidesPage.routeName: (BuildContext context) =>
              const UserRidesPage(),
          NotificationsPage.routeName: (_) => const NotificationsPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == RideDetailsPage.routeName) {
            final rideDTO = settings.arguments as RideDTO;

            return MaterialPageRoute(
              builder: (_) => RideDetailsPage(rideDTO: rideDTO),
            );
          }
          return null;
        },
      ),
    );
  }
}
