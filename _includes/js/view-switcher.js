// Generated by CoffeeScript 1.7.1
(function() {
  var defaultTransitions;

  defaultTransitions = {
    exit: function(exitingView, callback) {
      this.height(this.height());
      return exitingView.fadeOut(250, function() {
        return callback();
      });
    },
    prepare: function(exitingView, enteringView, callback) {
      var newHeight;
      newHeight = enteringView.outerHeight() + parseInt(this.css("padding-top"), 10) + parseInt(this.css("padding-bottom"), 10);
      this.animate({
        height: newHeight
      }, 250, function() {
        return callback();
      });
      return callback();
    },
    enter: function(enteringView, callback) {
      return enteringView.fadeIn(250, function() {
        return callback();
      });
    }
  };

  (function($, root) {
    var ViewSwitcher;
    ViewSwitcher = (function() {
      function ViewSwitcher(options) {
        var addAllViews, initialView, switcher;
        this.views = {};
        this.hub = $({});
        this.timedOffsets = options.timedOffsets, this.container = options.container, this.defaultView = options.defaultView;
        this.identifyingAttr = options.identifyingAttr || "id";
        this.inTransition = false;
        this.queue = [];
        this.state = {
          activeView: $(""),
          pastViews: []
        };
        this.exit = options.exit || defaultTransitions.exit;
        this.prepare = options.prepare || defaultTransitions.prepare;
        this.enter = options.enter || defaultTransitions.enter;
        switcher = this;
        addAllViews = function(param) {
          if (typeof param === "string") {
            addAllViews($(param));
          } else if (param instanceof Node) {
            switcher.addView(param);
          } else if (typeof param.length !== "undefined") {
            [].forEach.call(param, function(e) {
              return addAllViews(e);
            });
          } else {
            console.warn("View add fall-through.");
          }
        };
        addAllViews(options.views);
        initialView = this.views[location.hash.substr(1) || this.defaultView];
        console.log(location.hash.substr(1) || this.defaultView);
        this.prepare.bind(this.container, this.state.activeView, initialView, this.enter.bind(this.container, initialView, this.finishRender.bind(this, initialView)))();
      }

      ViewSwitcher.prototype.addView = function(view) {
        var name;
        view = $(view);
        name = view.attr(this.identifyingAttr);
        if (this.views[name]) {
          return console.error("A view or method named " + name + " is already registered on this ViewSwitcher");
        } else {
          return this.views[name] = view;
        }
      };

      ViewSwitcher.prototype.removeView = function(name) {
        return this.views[name] = void 0;
      };

      ViewSwitcher.prototype.selectView = function(name) {
        return this.views[name] || $("");
      };

      ViewSwitcher.prototype.switchTo = function(incomingViewName) {
        var boundCleanup, boundEnter, boundPrepare, incomingView;
        incomingView = this.views[incomingViewName];
        if (incomingView === this.state.activeView) {
          return false;
        }
        if (this.inTransition) {
          this.queue.push(incomingViewName);
          return false;
        }
        this.inTransition = true;
        boundCleanup = this.finishRender.bind(this, incomingView);
        boundEnter = this.enter.bind(this.container, incomingView, boundCleanup);
        boundPrepare = this.prepare.bind(this.container, this.state.activeView, incomingView, boundEnter);
        this.exit.bind(this.container, this.state.activeView, boundPrepare)();
        return true;
      };

      ViewSwitcher.prototype.finishRender = function(incomingView) {
        this.state.pastViews.push(this.state.activeView);
        this.state.activeView = incomingView;
        this.trigger("renderComplete", {
          view: this.state.activeView
        });
        this.inTransition = false;
        if (this.queue.length) {
          return this.switchTo(this.queue.shift());
        }
      };

      ViewSwitcher.prototype.on = function() {
        return this.hub.on.apply(this.hub, arguments);
      };

      ViewSwitcher.prototype.off = function() {
        return this.hub.off.apply(this.hub, arguments);
      };

      ViewSwitcher.prototype.trigger = function() {
        return this.hub.trigger.apply(this.hub, arguments);
      };

      return ViewSwitcher;

    })();
    return root.ViewSwitcher = ViewSwitcher;
  })(jQuery, (function() {
    if (typeof exports !== "undefined") {
      return exports;
    } else {
      return window;
    }
  })());

}).call(this);
