import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/socket_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/formatters.dart';
import 'features/auth/presentation/auth_controller.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SubastasApp()));
}

class SubastasApp extends ConsumerStatefulWidget {
  const SubastasApp({super.key});

  @override
  ConsumerState<SubastasApp> createState() => _SubastasAppState();
}

class _SubastasAppState extends ConsumerState<SubastasApp> {
  StreamSubscription? _outbidSub;

  @override
  void initState() {
    super.initState();
    final socket = ref.read(socketClientProvider);
    _outbidSub = socket.outbidNotifications.listen((notif) {
      final user = ref.read(authControllerProvider).valueOrNull;
      if (user == null) return;

      rootScaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.tertiary,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.trending_down_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Tu oferta ha sido superada!',
                        style: TextStyle(
                          fontFamily: AppFonts.headline,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${notif.newBidderName} ofreció ${formatCurrency(notif.amount)}',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          color: Colors.white.withAlpha(220),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'VER',
              textColor: Colors.white,
              onPressed: () {
                ref
                    .read(appRouterProvider)
                    .push('/bidder/auction/${notif.auctionId}');
              },
            ),
          ),
        );
    });
  }

  @override
  void dispose() {
    _outbidSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Subastas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
