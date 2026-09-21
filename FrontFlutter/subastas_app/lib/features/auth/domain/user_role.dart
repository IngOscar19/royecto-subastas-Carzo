import 'package:freezed_annotation/freezed_annotation.dart';

enum UserRole {
  @JsonValue('seller')
  seller,
  @JsonValue('bidder')
  bidder;

  String get label => switch (this) {
        UserRole.seller => 'Vendedor',
        UserRole.bidder => 'Comprador',
      };

  String get homeRoute => switch (this) {
        UserRole.seller => '/seller',
        UserRole.bidder => '/bidder',
      };
}