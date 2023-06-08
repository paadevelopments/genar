import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'utils.dart';
import 'screen_vm.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ super.key, });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  late Map<String, dynamic> configData;
  double progress = 0;
  bool showSplash = true;
  bool showProgress = true;
  InAppWebViewController? webViewController;
  InAppWebViewOptions settings = InAppWebViewOptions(mediaPlaybackRequiresUserGesture: false,);
  bool pullToRefreshSupport = false;
  bool pullRefreshState = false;
  bool initialSuccess = false;
  bool loadFoundError = false;
  bool isRefreshingPg = true;
  String errorMessage = "Load Failed\nTap On The Above Logo To Retry";

  void onSetupReady(InAppWebViewController controller) async {
    webViewController = controller;
    String jsonString = await rootBundle.loadString('assets/raw/config.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    configData = jsonMap.map((key, value) { return MapEntry(key, value); });
    if (configData['pullToRefresh']) {
      pullToRefreshSupport = !(kIsWeb || ![ TargetPlatform.iOS, TargetPlatform.android ].contains(defaultTargetPlatform));
    }
    webViewController?.addJavaScriptHandler(handlerName: 'GENAR{set_pull_to_refresh}', callback: (args) {
      if (!pullToRefreshSupport) return false;
      setState(() { pullRefreshState = args[0]; });
      return true;
    });
    webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse( configData['baseUrl'] )));
  }

  @override
  void initState() { super.initState(); }

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    double screenW = SizeConfig.safeBlockHorizontal * 100;
    double screenH = SizeConfig.safeBlockVertical * 100;

    return WillPopScope(
      onWillPop: () async {
        bool? canGoBack = await webViewController?.canGoBack();
        if (canGoBack!) { webViewController?.goBack(); return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, backgroundColor: colorPrimary,
        body: SafeArea(
          child: Stack(children: [ Container(),
            // WebView
            Positioned(
              width: screenW + (screenW * 0.0005), height: screenH, left: -(screenW * 0.0005),
              child: RefreshIndicator(
                onRefresh: () async { webViewController?.reload(); },
                color: colorAccent,
                child: SingleChildScrollView(
                  physics: pullToRefreshSupport ?
                  pullRefreshState ? const AlwaysScrollableScrollPhysics() : null
                      :
                  null,
                  child: SizedBox(
                    width: screenW + (screenW * 0.0005), height: screenH,
                    child: InAppWebView(
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      onWebViewCreated: (controller) async => onSetupReady(controller),
                      onLoadStart: (controller, url) async {
                        isRefreshingPg = true; loadFoundError = false;
                        progress = 0; showProgress = true; pullRefreshState = false;
                        setState(() { });
                      },
                      onLoadError: (controller, url, code, message) async { loadFoundError = true; },
                      onLoadStop: (controller, url) async {
                        isRefreshingPg = false; progress = 0; showProgress = false;
                        if (!loadFoundError) { initialSuccess = true; }
                        if (initialSuccess) {
                          showSplash = false;
                          if (loadFoundError) { pullRefreshState = true; }
                        }
                        setState(() {  });
                      },
                      onScrollChanged: (controller, int x, int y) { },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;
                        var schemes = [ 'http', 'https', 'file', 'chrome', 'data', 'javascript', 'about' ];

                        debugPrint( (!schemes.contains(uri.scheme)).toString() );

                        if (!schemes.contains(uri.scheme)) { if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,); return NavigationActionPolicy.CANCEL;
                        } }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onProgressChanged: (controller, progs) { setState(() { progress = progs / 100; }); },
                      onUpdateVisitedHistory: (controller, url, isReload) { },
                      onConsoleMessage: (controller, consoleMessage) { },
                    ),
                  ),
                ),
              ),
            ),
            // Progress Indication
            progressWidget(showProgress, progress, screenW, screenH),
            // Splash
            splashWidget(showSplash, isRefreshingPg, errorMessage, screenW, screenH, () {
              if (!showSplash || isRefreshingPg || initialSuccess || (webViewController == null)) return;
              webViewController?.reload();
            })
          ]),
        ),
      ),
    );
  }
}
