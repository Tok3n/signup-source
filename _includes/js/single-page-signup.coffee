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

  switcher = ViewSwitcher( viewSwitcheroptions )

  cache = 
    hashAnchors : []

  # need to add ability to recognize "#viewName" and "viewName" as the same thing.
  $( window ).on "hashchange", ( event ) ->
    if location.hash is "" or location.hash is "#"
      name = appInitialView.substring( 1 )
    else
      name = location.hash.substring( 1 )
    
    view = switcher.selectView( name )
    if view
      switcher( name )

  # $( "a" ).each ->
  #   if this.hash and this.hostname is location.hostname
  #     cache.hashAnchors.push( this )

  # cache.hashAnchors = $( cache.hashAnchors )
  # cache.hashAnchors.bind "click", ( event ) ->
  #   event.preventDefault()
  #   switcher( this.hash.substring( 1) )

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

  timer = new Tock( tockOptions )

  $( window ).on "hashchange", ->
    timer.stop()

  switcher.on "renderComplete", ( event, name, view ) ->
    if name is "confirmCode"
      timer.start( 120000 )


