import 'dart:html';
import 'package:polymer/polymer.dart';

//// track overlays for z-index and focus managemant
//var overlays = [];
//var trackOverlays = function(inOverlay) {
//  if (inOverlay.opened) {
//    //var overlayZ = window.getComputedStyle(inOverlay.target).zIndex;
//    //var z0 = Math.max(currentOverlayZ(), overlayZ);
//    var z0 = currentOverlayZ();
//    overlays.push(inOverlay);
//    var z1 = currentOverlayZ();
//    if (z1 <= z0) {
//      applyOverlayZ(inOverlay, z0);
//    }
//  } else {
//    var i = overlays.indexOf(inOverlay);
//    if (i >= 0) {
//      overlays.splice(i, 1);
//      setZ(inOverlay, null);
//    }
//  }
//}
//
//var applyOverlayZ = function(inOverlay, inAboveZ) {
//  setZ(inOverlay.target, inAboveZ + 2);
//}
//
//var setZ = function(inNode, inZ) {
//  inNode.style.zIndex = inZ;
//}
//
//var currentOverlay = function() {
//  return overlays[overlays.length-1];
//}
//
//var DEFAULT_Z = 10;
//
//var currentOverlayZ = function() {
//  var z;
//  var current = currentOverlay();
//  if (current) {
//    var z1 = window.getComputedStyle(current.target).zIndex;
//    if (!isNaN(z1)) {
//      z = Number(z1);
//    }
//  }
//  return z || DEFAULT_Z;
//}
//
//var focusOverlay = function() {
//  var current = currentOverlay();
//  if (current) {
//    current.applyFocus();
//  }
//}
//
//
//
//@CustomTag('polymer-overlay')
//class PolymerOverlay extends PolymerElement {
//  // The target element.
//  @published var target = null;
//  /**
//   * Set opened to true to show an overlay and to false to hide it.
//   * A polymer-overlay may be made intially opened by setting its
//   * opened attribute.
//   */
//  @published bool opened = false;
//  /**
//   * By default an overlay will close automatically if the user
//   * taps outside it or presses the escape key. Disable this
//   * behavior by setting the autoCloseDisabled property to true.
//   */
//  @published bool autoCloseDisabled = false;
//
//  int timeout = 1000;
//  // TODO
//  var captureEventType = 'tap';
//
//  created: function() {
//    if (this.tabIndex === undefined) {
//      this.tabIndex = -1;
//    }
//    this.setAttribute('touch-action', 'none');
//  },
//  enteredView: function() {
//    this.installControllerStyles();
//  },
//  /**
//   * Toggle the opened state of the overlay.
//   * @method toggle
//   */
//  toggle: function() {
//    this.opened = !this.opened;
//  },
//  targetChanged: function(old) {
//    if (this.target) {
//      if (this.target.tabIndex === undefined) {
//        this.target.tabIndex = -1;
//      }
//      this.target.classList.add('polymer-overlay');
//      this.addListeners(this.target);
//    }
//    if (old) {
//      old.classList.remove('polymer-overlay');
//      this.removeListeners(this.target);
//    }
//  },
//  listeners: {
//    'webkitAnimationStart': 'openedAnimationStart',
//    'animationStart': 'openedAnimationStart',
//    'webkitAnimationEnd': 'openedAnimationEnd',
//    'animationEnd': 'openedAnimationEnd',
//    'webkitTransitionEnd': 'openedTransitionEnd',
//    'transitionEnd': 'openedTransitionEnd',
//    'tap': 'tapHandler',
//    'keydown': 'keydownHandler'
//  },
//  addListeners: function(node) {
//    for (e in this.listeners) {
//      node.addEventListener(e, this[this.listeners[e]].bind(this));
//    }
//  },
//  removeListeners: function(node) {
//    for (e in this.listeners) {
//      node.removeEventListener(e, this[this.listeners[e]].bind(this));
//    }
//  },
//  openedChanged: function() {
//    this.renderOpened();
//    trackOverlays(this);
//    this.async(function() {
//      if (!this.autoCloseDisabled) {
//        this.enableCaptureHandler(this.opened);
//      }
//    });
//    this.enableResizeHandler(this.opened);
//    this.fire('polymer-overlay-open', this.opened);
//  },
//  enableHandler: function(inEnable, inMethodName, inNode, inEventName, inCapture) {
//    var m = 'bound' + inMethodName;
//    this[m] = this[m] || this[inMethodName].bind(this);
//
//    inNode[inEnable ? 'addEventListener' : 'removeEventListener'](
//        inEventName, this[m], inCapture);
//  },
//  enableResizeHandler: function(inEnable) {
//    this.enableHandler(inEnable, 'resizeHandler', window,
//    'resize');
//  },
//  enableCaptureHandler: function(inEnable) {
//    this.enableHandler(inEnable, 'captureHandler', document,
//        this.captureEventType, true);
//  },
//  getFocusNode: function() {
//    return this.target.querySelector('[autofocus]') || this.target;
//  },
//  // TODO(sorvell): nodes stay focused when they become un-focusable
//  // due to an ancestory becoming display: none; file bug.
//  applyFocus: function() {
//    var focusNode = this.getFocusNode();
//    if (this.opened) {
//      focusNode.focus();
//    } else {
//      focusNode.blur();
//      focusOverlay();
//    }
//  },
//  renderOpened: function() {
//    this.target.classList.remove('closing');
//    this.target.classList.add('revealed');
//    // continue styling after delay so display state can change
//    // without aborting transitions
//    this.asyncMethod('continueRenderOpened');
//  },
//  continueRenderOpened: function() {
//    this.target.classList.toggle('opened', this.opened);
//    this.target.classList.toggle('closing', !this.opened);
//    this.animating = this.asyncMethod('completeOpening', null, this.timeout);
//  },
//  completeOpening: function() {
//    clearTimeout(this.animating);
//    this.animating = null;
//    this.target.classList.remove('closing');
//    this.target.classList.toggle('revealed', this.opened);
//    this.applyFocus();
//  },
//  openedAnimationEnd: function(e) {
//    if (!this.opened) {
//      this.target.classList.remove('animation');
//    }
//    // same steps as when a transition ends
//    this.openedTransitionEnd(e);
//  },
//  openedTransitionEnd: function(e) {
//    // TODO(sorvell): Necessary due to
//    // https://bugs.webkit.org/show_bug.cgi?id=107892
//    // Remove when that bug is addressed.
//    if (e.target == this.target) {
//      this.completeOpening();
//      e.stopPropagation();
//      e.cancelBubble = true;
//    }
//  },
//  openedAnimationStart: function(e) {
//    this.target.classList.add('animation');
//    e.stopPropagation();
//    e.cancelBubble = true;
//  },
//  tapHandler: function(e) {
//    if (e.target && e.target.hasAttribute('overlay-toggle')) {
//      this.toggle();
//    } else {
//      if (this.autoCloseJob) {
//        this.autoCloseJob.stop();
//        this.autoCloseJob = null;
//      }
//    }
//  },
//  // TODO(sorvell): This approach will not work with modal. For
//  // this we need a scrim.
//  captureHandler: function(e) {
//    if (!this.autoCloseDisabled && (currentOverlay() == this) && (this
//        != e.target) && !(this.contains(e.target))) {
//      this.autoCloseJob = this.job(this.autoCloseJob, function() {
//        this.opened = false;
//      });
//    }
//  },
//  keydownHandler: function(e) {
//    if (!this.autoCloseDisabled && (e.keyCode == this.$.keyHelper.ESCAPE_KEY)) {
//      this.opened = false;
//      e.stopPropagation();
//      e.cancelBubble = true;
//    }
//  },
//  /**
//   * Extensions of polymer-overlay should implement the resizeHandler
//   * method to adjust the size and position of the overlay when the
//   * browser window resizes.
//   * @method resizeHandler
//   */
//  resizeHandler: function() {
//  }
//});
//})();
//
//}
//
