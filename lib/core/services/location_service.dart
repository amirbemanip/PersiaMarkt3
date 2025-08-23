// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// موقعیت فعلی دستگاه را با بررسی کامل دسترسی‌ها مشخص می‌کند.
  Future<Position> getCurrentPosition() async {
    // 1. بررسی فعال بودن سرویس موقعیت‌یاب دستگاه
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('سرویس موقعیت مکانی غیرفعال است.');
    }

    // 2. بررسی و درخواست دسترسی موقعیت مکانی از کاربر
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('دسترسی به موقعیت مکانی رد شد.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('دسترسی به موقعیت مکانی برای همیشه رد شده است.');
    }

    // 3. در صورت تایید دسترسی، موقعیت فعلی را برمی‌گرداند
    return await Geolocator.getCurrentPosition();
  }

  /// یک موقعیت جغرافیایی را به یک آدرس خوانا تبدیل می‌کند.
  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first; 
        
        // بخش‌های مختلف آدرس را استخراج می‌کند
        final city = placemark.locality ?? ''; 
        final street = placemark.thoroughfare ?? ''; 
        
        // آدرس را به صورت خوانا ترکیب می‌کند
        final addressParts = [city, street].where((part) => part.isNotEmpty).toList();
        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        }
      }
      // اگر هیچ آدرسی یافت نشد
      return 'موقعیت نامعلوم'; 
    } catch (e) {
      // دستور print برای محیط نهایی (production) حذف شد.
      // در صورت بروز خطا، یک پیام مناسب به کاربر نمایش داده می‌شود.
      return 'خطا در تبدیل موقعیت';
    }
  }
}