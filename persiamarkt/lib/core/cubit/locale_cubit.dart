// مسیر: lib/core/cubit/locale_cubit.dart

import 'package:flutter/material.dart'; // <<<--- مشکل اصلی اینجا بود و برطرف شد
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  // زبان پیش‌فرض را فارسی قرار می‌دهیم
  LocaleCubit() : super(const Locale('fa')) {
    _loadLocale();
  }

  // این متد در ابتدای کار، زبان ذخیره شده را از حافظه می‌خواند
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    // اگر زبانی ذخیره نشده بود، همان فارسی باقی می‌ماند
    final languageCode = prefs.getString('language_code') ?? 'fa';
    emit(Locale(languageCode));
  }

  // این متد زبان برنامه را تغییر داده و در حافظه ذخیره می‌کند
  void changeLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    emit(Locale(languageCode));
  }
}