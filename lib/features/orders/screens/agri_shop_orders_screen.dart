export 'orders_screen.dart' show OrdersScreen;

// AgriShopOrdersScreen is kept as a named alias so existing imports don't break.
import 'orders_screen.dart';

class AgriShopOrdersScreen extends OrdersScreen {
  const AgriShopOrdersScreen({super.key}) : super(showSalesTab: true);
}
