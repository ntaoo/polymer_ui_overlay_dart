import 'dart:html';
import 'package:polymer/polymer.dart';



//// track overlays for z-index and focus managemant
var overlays = [];
var trackOverlays = (inOverlay) {
  if (inOverlay.opened) {
    //var overlayZ = window.getComputedStyle(inOverlay.target).zIndex;
    //var z0 = Math.max(currentOverlayZ(), overlayZ);
    var z0 = currentOverlayZ();
    overlays.push(inOverlay);
    var z1 = currentOverlayZ();
    if (z1 <= z0) {
      applyOverlayZ(inOverlay, z0);
    }
  } else {
    var i = overlays.indexOf(inOverlay);
    if (i >= 0) {
      overlays.splice(i, 1);
      setZ(inOverlay, null);
    }
  }
};

var applyOverlayZ = (inOverlay, inAboveZ) {
  setZ(inOverlay.target, inAboveZ + 2);
};

var setZ = (inNode, inZ) {
  inNode.style.zIndex = inZ;
};

var currentOverlay = () {
  return overlays[overlays.length-1];
};

var DEFAULT_Z = 10;

var currentOverlayZ = () {
  var z;
  var current = currentOverlay();
  if (current) {
    var z1 = window.getComputedStyle(current.target).zIndex;
    if (!(z1.isNaN)) {
      z = int.parse(z1);
    }
  }
  return z || DEFAULT_Z;
};

var focusOverlay = () {
  var current = currentOverlay();
  if (current) {
    current.applyFocus();
  }
};



@CustomTag('polymer-overlay')
class PolymerOverlay extends PolymerElement {
  // The target element.
  @published Element target = null;
  /**
   * Set opened to true to show an overlay and to false to hide it.
   * A polymer-overlay may be made intially opened by setting its
   * opened attribute.
   */
  @published bool opened = false;
  /**
   * By default an overlay will close automatically if the user
   * taps outside it or presses the escape key. Disable this
   * behavior by setting the autoCloseDisabled property to true.
   */
  @published bool autoCloseDisabled = false;

  int timeout = 1000;
  // TODO
  var captureEventType = 'tap';

  List subscriptions = [];


  created() {
    super.created();
    if (this.attributes['tabIndex'] == null) {
      this.attributes['tabIndex'] = '-1';
    }
    this.attributes['touch-action'] = 'none';
  }

  // TODO rename to enteredView when available
  inserted() {
    super.inserted();
    // This probably hasnn't implemented yet?
//    this.installControllerStyles();
  }

  /**
   * Toggle the opened state of the overlay.
   */
  toggle() {
    this.opened = !this.opened;
  }

  targetChanged(old) {
    if (this.target) {
      if (this.attributes['tabIndex'] == null) {
        this.attributes['tabIndex'] = '-1';
      }
      this.target.classes.add('polymer-overlay');
      // TODO https://code.google.com/p/dart/issues/detail?id=14065&can=6&colspec=ID%20Type%20Status%20Priority%20Area%20Milestone%20Owner%20Summary
      subscriptions.add(Window.animationStartEvent.forTarget(this.target).listen(openedAnimationStart)); // webkit only for now
      subscriptions.add(Window.animationEndEvent.forTarget(this.target).listen(openedAnimationEnd)); // webkit only for now
      subscriptions.add(this.target.onTransitionEnd.listen(openedTransitionEnd));
      subscriptions.add(this.target.onClick.listen(clickHandler)); // TODO click -> tap event
      subscriptions.add(this.target.onKeyDown.listen(keydownHandler));
    }
    if (old) {
      old.classes.remove('polymer-overlay');
      subscriptions.forEach((s) => s.cancel());
     }
  }

  openedChanged() {
    this.renderOpened();
    trackOverlays(this);
    this.async(() {
      if (!this.autoCloseDisabled) {
        this.enableCaptureHandler(this.opened);
      }
    });
    this.enableResizeHandler(this.opened);
    this.fire('polymer-overlay-open', this.opened);
  }

  enableHandler(inEnable, inMethodName, inNode, inEventName, inCapture) {
    var m = 'bound' + inMethodName;
    this[m] = this[m] || this[inMethodName].bind(this);

    inNode[inEnable ? 'addEventListener' : 'removeEventListener'](
        inEventName, this[m], inCapture);
  }

  enableResizeHandler(inEnable) {
    this.enableHandler(inEnable, 'resizeHandler', window,
    'resize');
  }

  enableCaptureHandler(inEnable) {
    this.enableHandler(inEnable, 'captureHandler', document,
        this.captureEventType, true);
  }

  getFocusNode() {
    return this.target.query('[autofocus]') || this.target;
  }

  // TODO(sorvell): nodes stay focused when they become un-focusable
  // due to an ancestory becoming display: none; file bug.
  applyFocus() {
    var focusNode = this.getFocusNode();
    if (this.opened) {
      focusNode.focus();
    } else {
      focusNode.blur();
      focusOverlay();
    }
  }

  renderOpened() {
    this.target.classes.remove('closing');
    this.target.classes.add('revealed');
    // continue styling after delay so display state can change
    // without aborting transitions
    this.asyncMethod('continueRenderOpened');
  }

  continueRenderOpened() {
    this.target.classes.toggle('opened', this.opened);
    this.target.classes.toggle('closing', !this.opened);
    this.animating = this.asyncMethod('completeOpening', null, this.timeout);
  }

  completeOpening() {
    clearTimeout(this.animating);
    this.animating = null;
    this.target.classList.remove('closing');
    this.target.classclassList.toggle('revealed', this.opened);
    this.applyFocus();
  }

  openedAnimationEnd(e) {
    if (!this.opened) {
      this.target.classes.remove('animation');
    }
    // same steps as when a transition ends
    this.openedTransitionEnd(e);
  }

  openedTransitionEnd(e) {
    // TODO(sorvell): Necessary due to
    // https://bugs.webkit.org/show_bug.cgi?id=107892
    // Remove when that bug is addressed.
    if (e.target == this.target) {
      this.completeOpening();
      e.stopPropagation();
      e.cancelBubble = true;
    }
  }
  openedAnimationStart(e) {
    this.target.classes.add('animation');
    e.stopPropagation();
    e.cancelBubble = true;
  }

  tapHandler(e) {
    if (e.target && e.target.hasAttribute('overlay-toggle')) {
      this.toggle();
    } else {
      if (this.autoCloseJob) {
        this.autoCloseJob.stop();
        this.autoCloseJob = null;
      }
    }
  }

  // TODO(sorvell): This approach will not work with modal. For
  // this we need a scrim.
  captureHandler(e) {
    if (!this.autoCloseDisabled && (currentOverlay() == this) && (this
        != e.target) && !(this.contains(e.target))) {
      this.autoCloseJob = this.job(this.autoCloseJob, (_) {
        this.opened = false;
      });
    }
  }

  keydownHandler(e) {
    if (!this.autoCloseDisabled && (e.keyCode == this.$.keyHelper.ESCAPE_KEY)) {
      this.opened = false;
      e.stopPropagation();
      e.cancelBubble = true;
    }
  }
  /**
   * Extensions of polymer-overlay should implement the resizeHandler
   * method to adjust the size and position of the overlay when the
   * browser window resizes.
   * @method resizeHandler
   */
  resizeHandler() {
  }


}

