$ ->

  if isMobile.apple.device
    startView = "iosAppLink"

  else if isMobile.android.device
    startView = "androidAppLink"

  else 
    startView = "signupHome"


  window.addEventListener "load", ->
      FastClick.attach(document.body)
  , false

  $.ajax 
    url: "json/country-phone-data.json"
    cache: false
  .done ( data ) ->
    App.countryData = data

  # Set up the ViewSwitcher and change views on clicks.
  viewSwitcheroptions = {}
  viewSwitcheroptions.views = ".view-wrapper"
  viewSwitcheroptions.container = $ ".view-wrapper-inner"
  viewSwitcheroptions.defaultView = startView

  App.switcher = switcher = new ViewSwitcher( viewSwitcheroptions )

  doSwitch = ->
    viewName = ( location.hash.substr(1) or viewSwitcheroptions.defaultView )
    switcher.switchTo( viewName );

  # Set up the confirm code countdown
  tockOptions =
    countdown: true,
    interval: 500
    callback: ->
      $( ".code-countdown" ).html tockFormat timer.msToTime timer.lap()

  tockFormat = ( rawTime ) ->
    return rawTime.split( "." )[0].substring( 1 )

  App.timer = timer = new Tock( tockOptions )

  $( window ).on "hashchange", ( event ) ->
    doSwitch()

  $( window ).on "hashchange", ->
    timer.stop()

  switcher.on "renderComplete", ( event, data ) ->
    if data.view.attr( "id" ) is "confirmCode"
      $(".tel-num").html( App.phoneData.componentById( "phoneNumberInput" ).value() )

  switcher.on "renderComplete", ( event, data ) ->
    if data.view.attr( "id" ) is "confirmCode"
      timer.start( 120500 )

  # switcher.on "renderComplete", ( event, data ) ->
  #   console.log data

  do ->
    InputCollection = InputJS.InputCollection
    InputFactory = InputJS.InputFactory

    # Read the forms on the first page.
    accountData = []
    accountData.push document.querySelector "#firstNameInput"
    accountData.push document.querySelector "#lastNameInput"
    accountData.push document.querySelector "#emailInput"
    App.accountData = accountData = new InputCollection( accountData )
    App.signupRadio = signupRadio = new InputCollection document.querySelectorAll "[name='signupOptions']"
    
    signupRadio.isValid = ->
      return this.values().length > 0

    sendCodeButton = new InputJS.ButtonComponent document.querySelector "#sendCodeButton"
    sendCodeButton.disable()

    App.firstPage = firstPage = new InputCollection [ accountData, signupRadio ]
    firstPage.addEventListener "keyup", ( event ) ->
      if this.isValid()
        sendCodeButton.enable()
      else
        sendCodeButton.disable()


    sendCodeButton.addEventListener "click", ( event ) ->
      event.preventDefault()
      location.hash = "#" + signupRadio.value()[0]


    # Attach event handlers to all buttons.
    buttons = document.querySelectorAll( "button[data-hash]" )
    Array.prototype.forEach.call buttons, ( button ) ->
      return if button is sendCodeButton.el
      button.addEventListener "click", ( event ) ->
        event.preventDefault()
        location.hash = this.attributes["data-hash"].value

    sendTextButton = new InputJS.ButtonComponent document.querySelector "#confirmCodeButton"
    sendTextButton.disable()

    # Read forms on the country/phone page
    phoneData = []
    countrySelect = InputFactory "#countrySelect"
    phoneNumberInput = InputFactory "#phoneNumberInput"
    
    App.phoneData = phoneData = new InputCollection( [countrySelect, phoneNumberInput] )

    countrySelect.addEventListener "change", ( event ) ->
      console.log ( value = this.value()[0] )
      match = App.countryData.filter ( country ) ->
        return country.englishName is value
      if match.length
        phoneNumberInput.placeholder( match[0].example )
        document.querySelector( "#phoneNumberCountryCode" ).innerHTML = "+#{match[0].phoneCode}"

    phoneNumberInput.addEventListener "keyup", ( event ) ->
      if phoneData.isValid()
        sendTextButton.enable()
      else
        sendTextButton.disable()
    
    confirmCode = InputFactory( "#confirmCodeInput" )
  
    

