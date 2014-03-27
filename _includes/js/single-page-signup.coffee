$ ->

  $.ajax 
    url: "json/country-phone-data.json"
    cache: false
  .done ( data ) ->
    App.countryData = data

  appInitialView = "#signupHome"

  if location.hash is "" or location.hash is "#"
    initialViewName = appInitialView
  else
    initialViewName = location.hash

  # Set up the ViewSwitcher and change views on clicks.
  viewSwitcheroptions = {}
  viewSwitcheroptions.views = ".view-wrapper"
  viewSwitcheroptions.container = ".view-wrapper-inner"
  viewSwitcheroptions.initialView = initialViewName

  App.switcher = switcher = ViewSwitcher( viewSwitcheroptions )

  # need to add ability to recognize "#viewName" and "viewName" as the same thing.
  $( window ).on "hashchange", ( event ) ->
    if location.hash is "" or location.hash is "#"
      name = appInitialView.substring( 1 )
    else
      name = location.hash.substring( 1 )
    
    view = switcher.selectView( name )
    if view
      switcher( name )

    # specific instructions for rendering specific pages
    if name is "confirmCode"
      $(".tel-num").html( App.phoneData.componentById( "phoneNumberInput" ).value() )

  # Set up the confirm code countdown
  tockOptions =
    countdown: true,
    interval: 500
    callback: ->
      $( ".code-countdown" ).html tockFormat timer.msToTime timer.lap()
    complete: ->
      console.log "Tock complete"

  tockFormat = ( rawTime ) ->
    return rawTime.split( "." )[0].substring( 1 )

  App.timer = timer = new Tock( tockOptions )

  $( window ).on "hashchange", ->
    timer.stop()

  switcher.on "renderComplete", ( event, name, view ) ->
    if name is "confirmCode"
      timer.start( 120500 )

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
  firstPage.addEventListener "change", ( event ) ->
    if this.isValid()
      sendCodeButton.enable()

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
    console.log ( value = this.value() )
    match = App.countryData.filter ( country ) ->
      return country.englishName is value

    console.log match

    if match
      phoneNumberInput.placeholder( match[0].example )
      document.querySelector( "#phoneNumberCountryCode" ).innerHTML = "+#{match[0].phoneCode}"

  # Read form on the 

  
  confirmCode = InputFactory( "#confirmCodeInput" )
  
    

