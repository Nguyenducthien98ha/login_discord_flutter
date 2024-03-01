import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:discord_api/discord_api.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'webview_page.dart';

const clientId = '1163762400701468784';
const clientSecret = 'irgBBEY1p3wnMMy450279i4invxQBU6S';
const redirectUri =
    'https://vip.maubuifinance.com/process-login-with-discord-app';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discord API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Discord API Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _discordClient = DiscordClient(
    clientId: clientId,
    clientSecret: clientSecret,
    redirectUri: redirectUri,
    discordHttpClient:
        DiscordDioProvider(clientId: clientId, clientSecret: clientSecret),
  );

  String token = '';
  InAppWebViewController? _webViewController;
  Future<DiscordToken?> _openConnectionPage(
      {List<DiscordApiScope> scopes = const []}) {
    final url = _discordClient.authorizeUri(scopes);
    final GlobalKey webViewKey = GlobalKey();

    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(url.toString())),
            initialSettings: InAppWebViewSettings(
                isInspectable: kDebugMode,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllow: "camera; microphone",
                iframeAllowFullscreen: true),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {});
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT);
            },
            onLoadStop: (controller, url) async {
              final htmlContent = await controller.evaluateJavascript(
                  source:
                      "window.document.getElementsByTagName('html')[0].outerHTML;");

              setState(() {
                token = parseTokenFromHtml(htmlContent);
              });

              log('Token Token Token Token: $token');
              if (token == 'error') {
              } else {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            onCloseWindow: (controller) {},
            onReceivedError: (controller, request, error) {},
            onConsoleMessage: (controller, consoleMessage) {
              if (kDebugMode) {
                print(consoleMessage);
              }
            },
          ),
        ),
      ),
    ).then((_) {
      if (_discordClient.discordHttpClient.discordToken != null) {
        Navigator.pop(context);
        return _discordClient.discordHttpClient.discordToken;
      }
      return null;
    });
  }

  String parseTokenFromHtml(String htmlContent) {
    try {
      const startTag =
          '<pre style="word-wrap: break-word; white-space: pre-wrap;">';
      const endTag = '</pre>';

      final startIndex = htmlContent.indexOf(startTag) + startTag.length;
      final endIndex = htmlContent.indexOf(endTag);

      final jsonString = htmlContent.substring(startIndex, endIndex);

      final jsonData = json.decode(jsonString);
      final token = jsonData['token'] as String;

      return token;
    } catch (e) {
      log('Error parsing JSON: $e');
      return 'error';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  // void _displayDataAlert(
  //     {String? method, String? data, bool isImg = false, bool? isOnline}) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(method ?? ''),
  //         content: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             if (isOnline != null)
  //               Text(
  //                 isOnline ? 'Online' : 'Offline',
  //                 style: TextStyle(
  //                   color: isOnline ? Colors.green : Colors.red,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             if (!isImg && data != null) Text(data),
  //             if (isImg && data != null)
  //               Image.network(
  //                 data,
  //                 loadingBuilder: (_, __, ___) =>
  //                     const CircularProgressIndicator(),
  //               ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: <Widget>[
          Text(
            'Welcome user: ${_discordClient.discordHttpClient.discordToken?.accessToken}',
          ),
          Text(
            'Your Discord access token is: $token',
          ),
          ElevatedButton(
            onPressed: () async {
              // final user = await _discordClient.getCurrentUser();
              // _displayDataAlert(
              //   method: 'getCurrentUser',
              //   data: user.toString(),
              // );
              WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
                _openConnectionPage(
                  scopes: [
                    DiscordApiScope.identify,
                    DiscordApiScope.email,
                    DiscordApiScope.guilds
                  ],
                ).then((value) => setState(() {}));
              });
            },
            child: const Text('Get Me'),
          ),
        ],
      ),
    );
  }
}
