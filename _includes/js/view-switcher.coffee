# only called when container is bound to "this"
defaultTransitions = 
  exit : ( exitingView, callback ) ->
    this.height( this.height() )
    exitingView.fadeOut 250, ->
      callback()
  prepare : ( exitingView, enteringView, callback ) ->
    newHeight = enteringView.outerHeight() + parseInt(this.css("padding-top"), 10) + parseInt(this.css("padding-bottom"), 10)
    this.animate
      height : newHeight
    , 250, ->
      callback()
    callback()
  enter : ( enteringView, callback ) ->
    enteringView.fadeIn 250, ->
      callback()

do ( $ = jQuery, root = do ->
  if typeof exports isnt "undefined"
    return exports
  else
    return window
) ->

  class ViewSwitcher

    constructor : ( options ) ->
      this.views = {}
      this.hub = $({})
      {@timedOffsets, @container, @defaultView} = options
      this.identifyingAttr = options.identifyingAttr or "id"
      this.inTransition = false
      this.queue = []

      this.state =       
        activeView : $("")
        pastViews : []

      this.exit = options.exit or defaultTransitions.exit
      this.prepare = options.prepare or defaultTransitions.prepare
      this.enter = options.enter or defaultTransitions.enter

      # Build the views object
      switcher = this
      addAllViews = ( param ) ->
        if typeof param is "string"
          addAllViews( $( param ) )
          return
        else if param instanceof Node
          switcher.addView( param )
          return
        else if typeof param.length isnt "undefined"
          [].forEach.call param, ( e ) ->
            addAllViews( e )
          return
        else
          console.warn "View add fall-through."
          return

      addAllViews( options.views )

      initialView = this.views[(location.hash.substr(1) or this.defaultView)]

      console.log (location.hash.substr(1) or this.defaultView)

      this.prepare.bind( this.container, this.state.activeView, initialView, this.enter.bind( this.container, initialView, this.finishRender.bind(this, initialView ) ) )()

    addView : ( view ) ->
      view = $( view )
      name = view.attr( this.identifyingAttr )
      if this.views[name]
        console.error( "A view or method named #{name} is already registered on this ViewSwitcher")
      else
        this.views[name] = view

    removeView : ( name ) ->
      this.views[name] = undefined

    selectView : ( name ) ->
      return ( this.views[name] or $( "" ) )

    switchTo : ( incomingViewName ) ->
      incomingView = this.views[incomingViewName]
      if incomingView is this.state.activeView
        return false

      if this.inTransition
        this.queue.push( incomingViewName )
        return false

      this.inTransition = true

      boundCleanup = this.finishRender.bind(this, incomingView )
      boundEnter = this.enter.bind( this.container, incomingView, boundCleanup )
      boundPrepare = this.prepare.bind( this.container, this.state.activeView, incomingView, boundEnter )
      this.exit.bind( this.container, this.state.activeView, boundPrepare )()

      return true

    finishRender : ( incomingView ) ->
      this.state.pastViews.push( this.state.activeView )
      this.state.activeView = incomingView
      this.trigger( "renderComplete", view: this.state.activeView )
      this.inTransition = false
      if this.queue.length
        this.switchTo( this.queue.shift() )

    on : ->
      this.hub.on.apply( this.hub, arguments )
    off : ->
      this.hub.off.apply( this.hub, arguments )
    trigger : ->
      this.hub.trigger.apply( this.hub, arguments )


  return root.ViewSwitcher = ViewSwitcher
