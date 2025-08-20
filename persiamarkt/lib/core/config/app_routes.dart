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
  static const String settings = '/settings';
  // ۱۰. افزودن مسیر جدید برای صفحه پشتیبانی کاربر
  static const String userSupport = '/support';

  // مسیرهای داینامیک (فرزندان مسیر خانه)
  static const String storeDetail = 'store/:storeId';
  static const String categoryDetail = 'category/:categoryId';

  // متدهای کمکی
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
