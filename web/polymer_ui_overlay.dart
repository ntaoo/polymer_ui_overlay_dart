import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('polymer-ui-overlay')
class PolymerUiOverlay extends PolymerElement {
  @published bool active = false;
  @published bool modal = false;
  @published bool backdrop = false;

  void created() {
    super.created();
//    this.$.overlay.target = this;
  }

  void toggle() {
    this.active = !this.active;
  }
}


