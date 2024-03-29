import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage(this.url, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(),
      url: url,
      javascriptChannels:  <JavascriptChannel>{
        JavascriptChannel(
          name: 'Print',
          onMessageReceived: (JavascriptMessage message) {
            log(message.message);
          },

        ),
      }
    );
  }
}
