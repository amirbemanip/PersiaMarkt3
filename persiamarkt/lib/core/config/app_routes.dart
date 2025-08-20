// مسیر: lib/core/config/app_routes.dart

class AppRoutes {
  // مسیرهای اصلی Shell
  static const String home = '/';
  static const String map = '/map';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // مسیرهای خارج از Shell اصلی (صفحات کامل)
  static const String search = '/search';
  static const String login = '/login';
  static const String register = '/register';
  static const String sellerPanel = '/seller-panel';
  // ۸. افزودن مسیر جدید برای صفحه تنظیمات
  static const String settings = '/settings';

  // مسیرهای داینامیک (فرزندان مسیر خانه)
  static const String storeDetail = 'store/:storeId';
  static const String categoryDetail = 'category/:categoryId';

  // متدهای کمکی برای ساخت مسیرهای پیچیده به صورت امن و خوانا
  static String storeDetailPath(String storeId, {String? productId}) {
    String path = '/store/$storeId';
    if (productId != null) {
      path += '?productId=$productId';
    }
    return path;
  }

  static String categoryDetailPath(String categoryId) {
    return '/category/$categoryId';
  }
}
