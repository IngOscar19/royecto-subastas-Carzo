import 'package:freezed_annotation/freezed_annotation.dart';

part 'outbid_notification.freezed.dart';
part 'outbid_notification.g.dart';

/// Notificación en tiempo real cuando la oferta del usuario ha sido superada.
@freezed
abstract class OutbidNotification with _$OutbidNotification {
  const factory OutbidNotification({
    required String auctionId,
    required double amount,
    required String newBidderName,
    required String message,
  }) = _OutbidNotification;

  factory OutbidNotification.fromJson(Map<String, dynamic> json) =>
      _$OutbidNotificationFromJson(json);
}
