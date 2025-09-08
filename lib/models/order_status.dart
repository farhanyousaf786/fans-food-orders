import 'package:fans_food_order/translations/translate.dart';

enum OrderStatus {
  pending,
  preparing,
  delivering,
  delivered,
  cancelled;

  String toTranslatedString() {
    switch (this) {
      case OrderStatus.pending:
        return Translate.get('pending');
      case OrderStatus.preparing:
        return Translate.get('preparing');
      case OrderStatus.delivering:
        return Translate.get('delivering');
      case OrderStatus.delivered:
        return Translate.get('delivered');
      case OrderStatus.cancelled:
        return Translate.get('cancelled');
    }
  }
}
