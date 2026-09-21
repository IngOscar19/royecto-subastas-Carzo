import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auctions/presentation/auction_detail_screen.dart';
import '../../features/auctions/presentation/seller_home_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/user_profile_screen.dart';
import '../../features/bids/presentation/bidder_home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/seller',
        name: 'sellerHome',
        builder: (context, state) => const SellerHomeScreen(),
      ),
      GoRoute(
        path: '/seller/profile',
        name: 'sellerProfile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/seller/auction/:auctionId',
        name: 'sellerAuctionDetail',
        builder: (context, state) => AuctionDetailScreen(
          auctionId: state.pathParameters['auctionId']!,
        ),
      ),
      GoRoute(
        path: '/bidder',
        name: 'bidderHome',
        builder: (context, state) => const BidderHomeScreen(),
      ),
      GoRoute(
        path: '/bidder/profile',
        name: 'bidderProfile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/bidder/auction/:auctionId',
        name: 'auctionDetail',
        builder: (context, state) => AuctionDetailScreen(
          auctionId: state.pathParameters['auctionId']!,
        ),
      ),
    ],
    redirect: (context, state) {
      final auth = ref.watch(authControllerProvider);
      final location = state.matchedLocation;

      // Restaurando sesión: bloquear la app en el splash.
      if (auth.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final user = auth.valueOrNull;

      // La raíz nunca se renderiza: siempre redirige según sesión.
      if (location == '/') {
        return user == null ? '/login' : user.role.homeRoute;
      }

      if (user == null) {
        return (location == '/login' || location == '/register')
            ? null
            : '/login';
      }

      final homeRoute = user.role.homeRoute;
      if (location == homeRoute) return null;

      // Autenticado: fuera de auth/splash.
      if (location == '/login' ||
          location == '/register' ||
          location == '/splash') {
        return homeRoute;
      }

      // Nunca fuera del flujo del propio rol.
      if (!location.startsWith(homeRoute)) {
        return homeRoute;
      }
      return null;
    },
  );

  ref.onDispose(router.dispose);
  return router;
});