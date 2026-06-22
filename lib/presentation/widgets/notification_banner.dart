import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../design_tokens/design_tokens.dart';
import '../../domain/entities/notification.dart';
import '../blocs/notification/notification_bloc.dart';
import '../blocs/notification/notification_state.dart';

class NotificationBanner extends StatefulWidget {
  final Widget child;

  const NotificationBanner({super.key, required this.child});

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  AppNotification? _latestNotification;
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
          final latest = state.notifications.first;
          if (latest != _latestNotification && !latest.isRead) {
            setState(() {
              _latestNotification = latest;
              _dismissed = false;
            });
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() => _dismissed = true);
              }
            });
          }
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_latestNotification != null && !_dismissed)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _dismissed = true);
                    context.go('/notifications');
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: DesignTokens.tealGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.tealGlow.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _latestNotification!.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _latestNotification!.message,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _dismissed = true),
                          child: Icon(
                            Icons.close,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
