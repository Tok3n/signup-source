// Generated by CoffeeScript 1.7.1
(function() {
  $(function() {
    var doSwitch, startView, switcher, timer, tockFormat, tockOptions, viewSwitcheroptions;
    if (isMobile.apple.device) {
      startView = "iosAppLink";
    } else if (isMobile.android.device) {
      startView = "androidAppLink";
    } else {
      startView = "signupHome";
    }
    window.addEventListener("load", function() {
      return FastClick.attach(document.body);
    }, false);
    $.ajax({
      url: "{{ site.baseurl }}json/country-phone-data.json",
      cache: false
    }).done(function(data) {
      return App.countryData = data;
    });
    viewSwitcheroptions = {};
    viewSwitcheroptions.views = ".view-wrapper";
    viewSwitcheroptions.container = $(".view-wrapper-inner");
    viewSwitcheroptions.defaultView = startView;
    App.switcher = switcher = new ViewSwitcher(viewSwitcheroptions);
    doSwitch = function() {
      var viewName;
      viewName = location.hash.substr(1) || viewSwitcheroptions.defaultView;
      return switcher.switchTo(viewName);
    };
    tockOptions = {
      countdown: true,
      interval: 500,
      callback: function() {
        return $(".code-countdown").html(tockFormat(timer.msToTime(timer.lap())));
      }
    };
    tockFormat = function(rawTime) {
      return rawTime.split(".")[0].substring(1);
    };
    App.timer = timer = new Tock(tockOptions);
    $(window).on("hashchange", function(event) {
      return doSwitch();
    });
    $(window).on("hashchange", function() {
      return timer.stop();
    });
    switcher.on("renderComplete", function(event, data) {
      if (data.view.attr("id") === "confirmCode") {
        return $(".tel-num").html(App.phoneData.componentById("phoneNumberInput").value());
      }
    });
    switcher.on("renderComplete", function(event, data) {
      if (data.view.attr("id") === "confirmCode") {
        return timer.start(120500);
      }
    });
    return (function() {
      var InputCollection, InputFactory, accountData, buttons, confirmCode, countrySelect, firstPage, phoneData, phoneNumberInput, sendCodeButton, sendTextButton, signupRadio;
      InputCollection = InputJS.InputCollection;
      InputFactory = InputJS.InputFactory;
      accountData = [];
      accountData.push(document.querySelector("#firstNameInput"));
      accountData.push(document.querySelector("#lastNameInput"));
      accountData.push(document.querySelector("#emailInput"));
      App.accountData = accountData = new InputCollection(accountData);
      App.signupRadio = signupRadio = new InputCollection(document.querySelectorAll("[name='signupOptions']"));
      signupRadio.isValid = function() {
        return this.values().length > 0;
      };
      sendCodeButton = new InputJS.ButtonComponent(document.querySelector("#sendCodeButton"));
      sendCodeButton.disable();
      App.firstPage = firstPage = new InputCollection([accountData, signupRadio]);
      firstPage.addEventListener("keyup", function(event) {
        if (this.isValid()) {
          return sendCodeButton.enable();
        } else {
          return sendCodeButton.disable();
        }
      });
      sendCodeButton.addEventListener("click", function(event) {
        event.preventDefault();
        return location.hash = "#" + signupRadio.value()[0];
      });
      buttons = document.querySelectorAll("button[data-hash]");
      Array.prototype.forEach.call(buttons, function(button) {
        if (button === sendCodeButton.el) {
          return;
        }
        return button.addEventListener("click", function(event) {
          event.preventDefault();
          return location.hash = this.attributes["data-hash"].value;
        });
      });
      sendTextButton = new InputJS.ButtonComponent(document.querySelector("#confirmCodeButton"));
      sendTextButton.disable();
      phoneData = [];
      countrySelect = InputFactory("#countrySelect");
      phoneNumberInput = InputFactory("#phoneNumberInput");
      App.phoneData = phoneData = new InputCollection([countrySelect, phoneNumberInput]);
      countrySelect.addEventListener("change", function(event) {
        var match, value;
        console.log((value = this.value()[0]));
        match = App.countryData.filter(function(country) {
          return country.englishName === value;
        });
        if (match.length) {
          return document.querySelector("#phoneNumberCountryCode").innerHTML = "+" + match[0].phoneCode;
        }
      });
      phoneNumberInput.addEventListener("keyup", function(event) {
        if (phoneData.isValid()) {
          return sendTextButton.enable();
        } else {
          return sendTextButton.disable();
        }
      });
      return confirmCode = InputFactory("#confirmCodeInput");
    })();
  });

}).call(this);
