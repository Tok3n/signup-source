# only called when container is bound to "this"
defaultTransitions = 
  exit : ( exitingView, callback ) ->
    this.height( this.height() )
    exitingView.fadeOut 500, ->
      callback()

  prepare : ( exitingView, enteringView, callback ) ->
    newHeight = enteringView.outerHeight() + parseInt(this.css("padding-top"), 10) + parseInt(this.css("padding-bottom"), 10)
    this.animate
      height : newHeight
    , 500, ->
      callback()

  enter : ( enteringView, callback ) ->
    enteringView.fadeIn 500, ->
      callback()

do ( root = do ->
  if typeof exports isnt "undefined"
    return exports
  else
    return window
) ->

  root.ViewSwitcher = ( options ) ->

    rawViews = options.views
    container = $( options.container )
    attrIdentifier = options.attrIdentifier or "id"
    initialView = options.initialView
    initialViewName = $( options.initialView ).attr( attrIdentifier )
    useHistory = options.useHistory
    timedOffsets = options.timedOffsets 

    exit = options.exit or defaultTransitions.exit
    prepare = options.prepare or defaultTransitions.prepare
    enter = options.enter or defaultTransitions.enter

    views = {}
    views.selectView = ( name ) ->
      if this[name]
        return this[name]
      else 
        console.error( "A view named #{name} is not registered on this ViewSwitcher" )
        return false
        
    views.addView = ( view ) ->
      view = $( view )
      name = view.attr( attrIdentifier )
      if this[name]
        console.error( "A view or method named #{name} is already registered on this ViewSwitcher")
      else
        views[name] = view

    views.removeView = ( name ) ->
      this[name] = undefined

    # use same on/off/trigger syntax that you would with a jQuery object.
    hub = $({})
    _on = ->
      hub.on.apply( hub, arguments )
    _off = ->
      hub.off.apply( hub, arguments )
    _trigger = ->
      hub.trigger.apply( hub, arguments )

    switchView = ( incomingViewName ) ->

      incomingView = views.selectView( incomingViewName )

      # Not sure if this exactly works.
      if timedOffsets
        setTimeout exit.bind( container, incomingView, $.noop ), 0
        setTimeout prepare.bind( container, state.activeView, incomingView, $.noop ), options.exitDelay
        setTimeout enter.bind( container, incomingView, $.noop ), options.exitDelay + options.prepareDelay
        setTimeout finishRender.bind(null, incomingView ), options.exitDelay + options.prepareDelay + options.enterDelay

      else
        boundCleanup = finishRender.bind(null, incomingViewName )
        boundEnter = enter.bind( container, incomingView, boundCleanup )
        boundPrepare = prepare.bind( container, state.activeView, incomingView, boundEnter )
        exit.bind( container, state.activeView, boundPrepare )()

    switchView.on = _on
    switchView.off = _off
    switchView.trigger = _trigger

    switchView.views = ->
      return views

    switchView.addView = ( view ) ->
      return views.addView( view )

    switchView.selectView = ( name ) ->
      return views.selectView( name )

    switchView.removeView = ( name ) ->
      return views.removeView( name )
    
    state =
      activeView : $("")
      pastViews : []

    finishRender = ( incomingViewName ) ->

      incomingView = views.selectView( incomingViewName )
      state.pastViews.push( state.activeView )
      state.activeView = incomingView
      _trigger( "renderComplete", incomingViewName, state.activeView )

    
    addAllViews = ( rawViews ) ->
      if rawViews instanceof jQuery
        rawViews.each ->
          views.addView( this )
      else if rawViews instanceof Array
        rawViews.forEach ( el ) ->
          views.addView( el )
      else if rawViews.substr
        addAllViews( $( rawViews ) )

    # Starting here is what actually gets run when the function is first called.
    addAllViews( rawViews )

    # render the initial view
    prepare.bind( container, state.activeView, views.selectView( initialViewName ), enter.bind( container, views.selectView( initialViewName ), finishRender.bind(null, initialViewName ) ) )()

    return switchView