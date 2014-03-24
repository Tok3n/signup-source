// Generated by CoffeeScript 1.7.1
(function() {
  window.Signup = (function() {
    var appInitialView, cache, initialViewName, switcher, timer, tockFormat, tockOptions, viewSwitcheroptions;
    appInitialView = "#signupHome";
    if (location.hash === "" || location.hash === "#") {
      initialViewName = appInitialView;
    } else {
      initialViewName = location.hash;
    }
    viewSwitcheroptions = {};
    viewSwitcheroptions.views = ".view-wrapper";
    viewSwitcheroptions.container = ".view-wrapper-inner";
    viewSwitcheroptions.initialView = initialViewName;
    switcher = ViewSwitcher(viewSwitcheroptions);
    cache = {
      hashAnchors: []
    };
    $(window).on("hashchange", function(event) {
      var name, view;
      if (location.hash === "" || location.hash === "#") {
        name = appInitialView.substring(1);
      } else {
        name = location.hash.substring(1);
      }
      view = switcher.selectView(name);
      if (view) {
        return switcher(name);
      }
    });
    tockOptions = {
      countdown: true,
      interval: 500,
      callback: function() {
        return $(".code-countdown").html(tockFormat(timer.msToTime(timer.lap())));
      },
      complete: function() {
        return console.log("Tock complete");
      }
    };
    tockFormat = function(rawTime) {
      return rawTime.split(".")[0].substring(1);
    };
    timer = new Tock(tockOptions);
    $(window).on("hashchange", function() {
      return timer.stop();
    });
    return switcher.on("renderComplete", function(event, name, view) {
      if (name === "confirmCode") {
        return timer.start(120000);
      }
    });
  })();

}).call(this);