do ( root = do ->
  if typeof exports isnt "undefined"
    return exports
  else
    return window
) ->

  camelize = (str) ->
    camel = str.replace /(?:^|[-_ ])(\w)/g, (_, c) ->
      return if c then c.toUpperCase() else ""
    return camel.charAt(0).toLowerCase() + camel.slice(1)

  class Base
    constructor : ( el ) ->
      this.el = el
      this.id = el.id
      this.listeners = []
      return this

    value : ->
      if arguments.length
        this._setValue( arguments )
        return this
      else
        return if this._hasValue() and this.isValid() then this._getValue() else false

    values : ->
      return this.value( arguments )

    isValid : ->
      return this.el.checkValidity()

    isFocused : ->
      return document.activeElement is this.el

    isDisabled : ->
      return this.el.disabled

    disable : ->
      this.el.disabled = true
      return this

    enable : ->
      this.el.disabled = false
      return this

    _hasValue : ->
      return !!this.el.value

    _setValue : ( value ) ->
      this.dispatchEvent new Event "change"
      return ( this.el.value = value )

    _getValue : ->
      return this.el.value

    _checkable : ->
      return "checked" of this.el

    addEventListener : ( type, listener, useCapture = false ) ->
      listener = listener.bind( this )
      this.el.addEventListener( type, listener, useCapture )
      this.listeners.push
        type: type
        listener: listener
      return this


    removeEventListener : ( type, listener, useCapture = false ) ->
      this.el.removeEventListener( type, listener, useCapture )
      return this

    dispatchEvent : ( event ) ->
      this.el.dispatchEvent( event )
      return this




  class ButtonComponent extends Base
    constructor : ( el ) ->
      super( el )


  class InputComponent extends Base
    constructor : ( el ) ->
      super( el )

    placeholder : ( param ) ->
      if param
        this.el.placeholder = param
        return this
      else
        return this.el.placeholder 

 
  class CheckableComponent extends Base

    constructor : ( el ) ->
      super( el )

    check : -> 
      this._switch( true )
      return this

    uncheck : ->
      this._switch( false )
      return this

    isChecked : ->
      return this.el.checked

    _switch : ( bool ) ->
      if typeof bool is "undefined" or this.isChecked() isnt bool
        this.el.checked = !this.el.checked
        this.dispatchEvent new Event "change"
      return this.isChecked()

    value : ->
      if arguments.length
        this._setValue( arguments )
      else
        return if this.isChecked() then super() else return false




  class SelectComponent extends Base
    constructor : ( el ) ->
      super( el ) 

    value : ->
      return ( option.value for option in this.selected() )

    selected : ->
      options = this.el.querySelectorAll( "option" )
      Array.prototype.filter.call options, ( option ) ->
        return option.selected and not option.disabled



  # Array-like class that holds a group of inputs that should be logically connected
  class InputCollection extends Array
    constructor : ( selector ) ->
      if selector
        this.add( selector )
      return this

    add : ( el ) ->

      unless el
        console.warn "Nothing passed to InputCollection::add"
        return false

      self = this

      # If it's a string, assume it's a selector
      if typeof el is "string"
        return self.add document.querySelectorAll( el )

      if el instanceof InputCollection
        return self.push el

      # If it's an array-like object (jQuery, NodeList), iterate over it
      if el.length
        return Array.prototype.forEach.call el, ( e ) ->
          self.add e

      if el instanceof Node
        return self.push InputFactory( el )

      if el instanceof Base
        return self.push el

      console.warn "Improper param passed to InputCollection::add"
      console.log el
      return false

    value : ->
      results = ( val for component in this when val = component.value() )
      return if results.length then results else false

    values : ->
      return this.value( arguments )

    hashValue : ->
      results = {}
      for component in this  
        val = component.value()
        results[camelize(component.id)] = val or ""
      return if Object.keys(results).length then results else false

    hashValues : ->
      return this.hashValue( arguments )

    isValid : ->
      for component in this
        return false unless component.isValid()
      return true

    addEventListener : ( type, listener, useCapture = false ) ->
      component.addEventListener( type, listener.bind( this ), useCapture ) for component in this
    
    dispatchEvent : ( type ) ->
      component.dispatchEvent( type ) for component in this

    componentById : ( id ) ->
      if id.charAt( 0 ) is "#"
        id = id.slice( 1 )
      for component in this
        return component if component.id is id
      return false

    check : ( param ) ->
      return this._changeCheck( true, param )

    uncheck : ( param ) ->
      return this._changeCheck( false, param )

    _changeCheck : ( onOff, param ) ->
      if typeof param is "undefined"
        for input in this when input instanceof CheckableComponent
          input[if onOff then "check" else "uncheck"]()
      else if typeof param is "number" and this[param] and this[param]._switch
        this[param][if onOff then "check" else "uncheck"]()
      else if typeof param is "string"
        if ( input = this.inputById( param ) )
          if input instanceof CheckableComponent
            input[if onOff then "check" else "f"]




  InputFactory = ( el ) ->
     
    # matchedClass = ( el ) ->

    #   lookup =       
    #     "button" : ButtonComponent
    #     "select" : SelectComponent
    #     "input[type='radio']" : CheckableComponent
    #     "input[type='checkbox']" : CheckableComponent

    #   matchAgainst = ( el, selector ) ->
    #     return ( el.matches or el.matchesSelector or el.msMatchesSelector or el.mozMatchesSelector or el.webkitMatchesSelector or el.oMatchesSelector ).call( el, selector )

    #   for selector, cl of lookup
    #     if matchAgainst( el, selector ) is true
    #       return cl

    #   return false

    classMatcher =
      input :
        checkbox : CheckableComponent
        radio : CheckableComponent
      select : SelectComponent
      button : ButtonComponent

    if typeof el is "string"
      el = document.querySelectorAll( el )

    if el.length > 1
      return new InputCollection( el )
    else 
      if el.item
        el = el.item( 0 )
      switch el.tagName.toLowerCase()
        when "input" or "textarea"       
          constructor = ( classMatcher.input[ el.type ] or InputComponent )
          return new constructor( el )
        when "select"
          constructor = classMatcher.select
          return new constructor( el )
        when "button"
          constructor = classMatcher.button
          return new constructor( el )
        else
          console.warn( "Invalid element passed to InputFactory" ) 
          return false


  # InputBuilder = ( opts ) ->

  #   parent = do ->
  #     if opts.parent instanceof Node
  #       return opts.parent
  #     else if window.jQuery and opts.parent instanceof jQuery
  #       return opts.parent[0]
  #     else if typeof opts.parent is "string"
  #       return document.querySelector( opts.parent )

  #   nodes = []
    
  #   collection = new InputCollection()

  #   for el in opts.els
  #     do ->
  #       e = document.createElement( el.tagName )
  #       e.id = el.id or ""
  #       e.name = el.name or ""
  #       e.textContent = el.textContent or ""

  #       if el.classList
  #         e.classList.add( cl ) for cl in el.classList

  #       if el.attrs
  #         e.setAttribute( attr.name, attr.value ) for attr in el.attrs
            

  #       nodes.push( e )

  #       if e.tagName is "INPUT"
  #         collection.push( e )

  #   for node in nodes
  #     parent.appendChild( node )

  #   return collection 

  root.InputJS =
    Base : Base
    InputComponent : InputComponent
    SelectComponent : SelectComponent
    CheckableComponent : CheckableComponent
    ButtonComponent : ButtonComponent
    InputCollection : InputCollection
    InputFactory : InputFactory
