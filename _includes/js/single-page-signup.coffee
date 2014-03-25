window.Signup = do ->

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
      timer.start( 120000 )

do ->
  InputCollection = InputJS.InputCollection

  inputs = []
  inputs.push document.querySelector "#firstNameInput"
  inputs.push document.querySelector "#lastNameInput"
  inputs.push document.querySelector "#emailInput"
  inputs.push document.querySelector "#countrySelect"
  inputs.push document.querySelector "#phoneNumberInput"

  App.signupRadio = signupRadio = new InputCollection document.querySelectorAll "[name='signupOptions']"

  App.userData = userData = new InputCollection inputs

  App.userData.addEventListener "change", ( event ) ->
    console.log JSON.stringify this.hashValues()

  App.signupRadio.addEventListener "change", ( event ) ->
    console.log this.value()
