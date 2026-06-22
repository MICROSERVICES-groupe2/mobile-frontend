import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/notifications/notification_usecases.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.getUnreadCountUseCase,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationRead>(_onMarkAsRead);
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await getNotificationsUseCase.execute(userId: event.userId);
    final countResult = await getUnreadCountUseCase.execute(userId: event.userId);
    
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        final unread = countResult.fold((_) => 0, (count) => count);
        emit(NotificationsLoaded(notifications: notifications, unreadCount: unread));
      },
    );
  }

  Future<void> _onMarkAsRead(MarkNotificationRead event, Emitter<NotificationState> emit) async {
    await markNotificationReadUseCase.execute(event.notificationId);
    add(const LoadNotifications()); // Reload; userId not needed here because backend filters by auth token in a real setup
  }

  Future<void> _onLoadUnreadCount(LoadUnreadCount event, Emitter<NotificationState> emit) async {
    final result = await getUnreadCountUseCase.execute(userId: event.userId);
    if (state is NotificationsLoaded) {
      final current = state as NotificationsLoaded;
      result.fold(
        (_) {},
        (count) => emit(NotificationsLoaded(notifications: current.notifications, unreadCount: count)),
      );
    }
  }
}
