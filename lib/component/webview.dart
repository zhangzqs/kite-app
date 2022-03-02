import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kite/util/logger.dart';
import 'package:kite/util/rule.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'unsupported_platform_launch.dart';

/*
 * 上应小风筝  便利校园，一步到位
 * Copyright (C) 2022 上海应用技术大学 上应小风筝团队
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

class InjectJsRuleItem {
  Rule<String> rule;

  /// 若为空，则表示不注入
  String? javascript;

  /// 异步js字符串，若为空，则表示不注入
  Future<String?>? asyncJavascript;
  InjectJsRuleItem({
    required this.rule,
    this.javascript,
    this.asyncJavascript,
  });
}

class MyWebView extends StatefulWidget {
  final String? initialUrl;

  /// js注入规则，判定某个url需要注入何种js代码
  final List<InjectJsRuleItem>? injectJsRules;
  final WebViewCreatedCallback? onWebViewCreated;
  final PageStartedCallback? onPageStarted;
  final PageFinishedCallback? onPageFinished;
  final JavascriptMode javascriptMode;
  const MyWebView({
    Key? key,
    this.initialUrl,
    this.injectJsRules,
    this.onWebViewCreated,
    this.onPageStarted,
    this.onPageFinished,
    this.javascriptMode = JavascriptMode.unrestricted, // js支持默认启用
  }) : super(key: key);

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final _controllerCompleter = Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return UniversalPlatform.isDesktopOrWeb
        ? UnsupportedPlatformUrlLauncher(widget.initialUrl ?? '')
        : WebView(
            initialUrl: widget.initialUrl,
            javascriptMode: widget.javascriptMode,
            onWebViewCreated: (WebViewController webViewController) {
              Log.info('WebView已创建，已获取到controller');
              _controllerCompleter.complete(webViewController);
              if (widget.onWebViewCreated != null) {
                widget.onWebViewCreated!(webViewController);
              }
            },
            onPageStarted: (String url) {
              Log.info('开始加载url: $url');
              if (widget.onPageStarted != null) {
                widget.onPageStarted!(url);
              }
            },
            onPageFinished: (String url) async {
              Log.info('url加载完毕: $url');

              final rules = widget.injectJsRules
                  ?.where((injectJsRule) => injectJsRule.rule.accept(url));
              if (rules != null) {
                for (final injectJsRule in rules) {
                  Log.info('执行js注入');
                  final controller = await _controllerCompleter.future;
                  // 同步获取js代码
                  if (injectJsRule.javascript != null) {
                    controller.runJavascript(injectJsRule.javascript!);
                  }
                  // 异步获取js代码
                  if (injectJsRule.asyncJavascript != null) {
                    String? js = await injectJsRule.asyncJavascript;
                    if (js != null) {
                      controller.runJavascript(js);
                    }
                  }
                }
              }

              if (widget.onPageFinished != null) {
                widget.onPageFinished!(url);
              }
            },
          );
  }
}