/**
 * The file has been modified for MISP Orbeon modification
 * MISP changes referred with <misp-change> tag in comments
 */
(function() {
  var $, Connect, Events, Globals, LoadingIndicator, OD, Overlay, Properties, Utils, YD;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = ORBEON.jQuery;
  Globals = ORBEON.xforms.Globals;
  YD = YAHOO.util.Dom;
  OD = ORBEON.util.Dom;
  Utils = ORBEON.util.Utils;
  Overlay = YAHOO.widget.Overlay;
  Properties = ORBEON.util.Properties;
  Connect = YAHOO.util.Connect;
  Events = ORBEON.xforms.Events;
  // <misp-change comment="Add custom DEFAULT_LOADING_TEXT">
  var DEFAULT_LOADING_TEXT = "";
  // </misp-change>
  LoadingIndicator = (function() {
    function LoadingIndicator(form) {
      var requestEnded;
      this.form = form;
      this.shownCounter = 0;
      this.loadingSpan = (f$.children('.xforms-loading-loading', $(this.form)))[0];
      this.loadingSpan.style.display = "none";
      this.loadingOverlay = null;
      Overlay.windowScrollEvent.subscribe(__bind(function() {
        return this._updateLoadingPosition();
      }, this));
      Overlay.windowResizeEvent.subscribe(__bind(function() {
        return this._updateLoadingPosition();
      }, this));
      Connect.startEvent.subscribe(__bind(function() {
        var afterDelay;
        if (this.nextConnectShow) {
          if (this.shownCounter === 0) {
            afterDelay = __bind(function() {
              this.shownCounter++;
              if (this.shownCounter === 1) {
                return this.show(this.nextConnectMessage);
              }
            }, this);
            return _.delay(afterDelay, Properties.delayBeforeDisplayLoading.get());
          } else {
            return this.shownCounter++;
          }
        }
      }, this));
      requestEnded = __bind(function() {
        if (this.nextConnectShow) {
          _.defer(__bind(function() {
            this.shownCounter--;
            if (this.shownCounter === 0) {
              return this.hide();
            }
          }, this));
          this.nextConnectShow = true;
          return this.nextConnectMessage = DEFAULT_LOADING_TEXT;
        }
      }, this);
      Events.ajaxResponseProcessedEvent.subscribe(requestEnded);
      Connect.failureEvent.subscribe(requestEnded);
    }
    LoadingIndicator.prototype.setNextConnectProgressShown = function(shown) {
      return this.nextConnectShow = shown;
    };
    LoadingIndicator.prototype.setNextConnectProgressMessage = function(message) {
      return this.nextConnectMessage = message;
    };
    LoadingIndicator.prototype.runShowing = function(f) {
      this.shownCounter++;
      this.show();
      return _.defer(__bind(function() {
        f();
        this.shownCounter--;
        if (this.shownCounter === 0) {
          return this.hide();
        }
      }, this));
    };
    LoadingIndicator.prototype.show = function(message) {
      this._initLoadingOverlay();
      message != null ? message : message = DEFAULT_LOADING_TEXT;
      OD.setStringValue(this.loadingOverlay.element, message);
      this.loadingOverlay.show();
      return this._updateLoadingPosition();
    };
    LoadingIndicator.prototype.hide = function() {
      if (!Globals.loadingOtherPage) {
        return this.loadingOverlay.cfg.setProperty("visible", false);
      }
    };
    LoadingIndicator.prototype._initLoadingOverlay = function() {
      if (!(this.loadingOverlay != null)) {
        this.loadingSpan.style.display = "block";
        this.initialRight = YD.getViewportWidth() - YD.getX(this.loadingSpan);
        this.initialTop = YD.getY(this.loadingSpan);
        this.loadingOverlay = new YAHOO.widget.Overlay(this.loadingSpan, {
          visible: false,
          monitorresize: true
        });
        Utils.overlayUseDisplayHidden(this.loadingOverlay);
        return this.loadingSpan.style.right = "auto";
      }
    };
    LoadingIndicator.prototype._updateLoadingPosition = function() {
      this._initLoadingOverlay();
      this.loadingOverlay.cfg.setProperty("x", __bind(function() {
        var scrollX;
        scrollX = YD.getDocumentScrollLeft();
        return scrollX + YD.getViewportWidth() - this.initialRight;
      }, this)());
      return this.loadingOverlay.cfg.setProperty("y", __bind(function() {
        var scrollY;
        scrollY = YD.getDocumentScrollTop();
        if (scrollY + Properties.loadingMinTopPadding.get() > this.initialTop) {
          return scrollY + Properties.loadingMinTopPadding.get();
        } else {
          return this.initialTop;
        }
      }, this)());
    };
    return LoadingIndicator;
  })();
  ORBEON.xforms.LoadingIndicator = LoadingIndicator;
}).call(this);
