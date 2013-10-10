import 'dart:html';

main() {
//  $ = document.querySelector.bind(document);
//
//  somethingCheck = function() {
//    $('#confirmation').active = (event.target.value == 'something');
//  }
//
//  changeOpening = function(e) {
//    var s = e.target.selectedOptions[0];
//    if (s) {
//      dialog.className = dialog.className.replace(/polymer-[^\s]*/, '')
//          dialog.classList.add(s.textContent);
//      }
//      }

//      modalChange = function(e, d) {
//        if (!d) {
//          d = dialog;
//        }
//        d.modal = e.target.checked;
//      }
//
//      backdropChange = function(e) {
//        dialog.backdrop = e.target.checked;
//      }
//
//      zindexChange = function(e) {
//        dialog.style.zIndex = e.target.value;
//      }

      List<ButtonElement> overlays = queryAll('button[overlay]');
      overlays.forEach((overlay) {
        // TODO click -> tap
        overlay.onClick.listen((e) => e.target.toggle());
      });
//      Array.prototype.forEach.call(overlayButtons, function(b) {
//        b.addEventListener('tap', function(e) {
//          document.querySelector(e.target.getAttribute('overlay')).toggle();
//        })
//      });
}
