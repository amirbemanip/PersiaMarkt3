// مسیر: lib/features/seller_panel/view/seller_panel_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ۱. پکیج GoRouter برای بازگشت امن اضافه شد
import 'package:webview_flutter/webview_flutter.dart';
// ۲. مسیر import فایل ترجمه به مسیر صحیح و استاندارد تغییر یافت
import 'package:persia_markt/l10n/app_localizations.dart';

class SellerPanelView extends StatefulWidget {
  const SellerPanelView({super.key});

  @override
  State<SellerPanelView> createState() => _SellerPanelViewState();
}

class _SellerPanelViewState extends State<SellerPanelView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // شما می‌توانید در اینجا یک پیام خطا به کاربر نمایش دهید
          },
        ),
      )
      // آدرس پنل شما که ارسال کردید، اینجا استفاده شده است
      ..loadRequest(Uri.parse('https://persia-market-panel.vercel.app/'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sellerPanel),
        leading: IconButton(
          icon: const Icon(Icons.close),
          // ۳. دستور بازگشت برای سازگاری کامل با GoRouter اصلاح شد
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}