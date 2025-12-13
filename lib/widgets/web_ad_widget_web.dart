import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebAdWidget extends StatefulWidget {
  const WebAdWidget({super.key});

  @override
  State<WebAdWidget> createState() => _WebAdWidgetState();
}

class _WebAdWidgetState extends State<WebAdWidget> {
  final String _viewId = 'adsense-banner-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    // Register the div which will contain the ad
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final html.Element adContainer = html.DivElement()
        ..id = 'ad-container-$viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center';

      // Create the <ins> tag
      final html.Element ins = html.Element.tag('ins')
        ..classes.add('adsbygoogle')
        ..style.display = 'block'
        ..setAttribute('data-ad-client', 'ca-pub-XXXXXXXXXXXXXXXX') // Replace with real ID later or use env
        ..setAttribute('data-ad-slot', '1234567890') // Placeholder slot
        ..setAttribute('data-ad-format', 'auto')
        ..setAttribute('data-full-width-responsive', 'true');

      adContainer.append(ins);

      // Trigger adsbygoogle push
      final html.ScriptElement script = html.ScriptElement()
        ..text = '(adsbygoogle = window.adsbygoogle || []).push({});';
      
      adContainer.append(script);

      return adContainer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100, // Fixed height for banner
      color: Colors.transparent,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
