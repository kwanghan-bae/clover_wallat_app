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
        ..style.minWidth = '300px' // Ensure minimum width prevents 0 width error
        ..style.display = 'block'
        ..style.overflow = 'hidden'; // Prevent overflow

      // Create the <ins> tag
      final html.Element ins = html.Element.tag('ins')
        ..classes.add('adsbygoogle')
        ..style.display = 'block'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute('data-ad-client', 'ca-pub-2084827050289409')
        ..setAttribute('data-ad-format', 'auto')
        ..setAttribute('data-full-width-responsive', 'true');

      adContainer.append(ins);

      // Trigger adsbygoogle push with a slight delay to ensure DOM is ready
      // Using a microtask or small timeout in JS logic if possible, 
      // but here we just append the script. 
      // Safe to wrap in setTimeout in JS.
      final html.ScriptElement script = html.ScriptElement()
        ..text = '''
          setTimeout(function() {
            try {
              (adsbygoogle = window.adsbygoogle || []).push({});
            } catch (e) {
              console.error("AdSense push error:", e);
            }
          }, 500);
        ''';
      
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
