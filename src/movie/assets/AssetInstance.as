package movie.assets
{
	import com.joelconnett.geom.FlexMatrixTransformer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import movie.movie.*;
	
	import mx.core.Application;
	import mx.events.*;
	
	/**
	 * This is an abstract class and needs to be extended.
	 * assetCmpnt needs to be created by the subclass in the constructor.
	 * The subclass also needs to set controlWidget if there is to be a control widget.
	 * 
	 * Assets initialize in the constructor. _initCCHandler is called when the asset is added to the stage. This is where the
	 * child asset should begin loading its content. When the asset is done loading content, 
	 * the child asset should dispatch the assetLoaded event.
	 * Then, when the asset is read to display, this class dispatches the asset_complete event.
	 * 
	 * PROPERTIES:
	 * 
	 * There are two types of properties, state properties and initialize properties. State properties change over the 
	 * course of the movie and are stored by the stateManager. Initialize properties are what the asset is initialized with
	 * upon start - these are saved with the movie. 
	 * 
	 * All state and initialize properties should be set via setProperties(), this will call corresponding set*Property*()
	 * or this[*property*] functions. These functions will manage the state of the asset, and then call setStateProperty
	 * or setInitializeProperty to enable the property to be saved to the state manager or with the movie.
	 * 
	 * statePropertiesList also needs to be set up with a list of properties to be sent to the stateManager - maybe we
	 * should deprecate this. Using setStateProperty should render the statePropertiesList useless.
	 */
	public class AssetInstance 
	{		
		//protected var _controlsOn:Boolean = false;
		//protected var _controls:Array = ["Width", "Height"];
		
		public var theMovie:Movie;
		public var type:String
		public var name:String;
		public var firstFrame:int;			// the frame the asset is added onto - used mainly by audio & video
											// to sync to the current frame
		public var stageName:String;		//unique name given by the assetManager;
		public var assetClassName:String;	// name of the asset class this was create from - this is not a classname, but the name
											// property of the assetClass object that created this instance
		protected var _properties:Object;		// holds all the properties that will be sent and retrieved from the movie
		public var assetCmpnt:*;			// the asset itself
		public var controlWidget:*;
		
		protected var _highlighted:Boolean;
		protected var _selected:Boolean;
		protected var _preUnSelectFlag:Boolean;		// flag to control selecting funtionality - this is set to true after a 
													// mousedown if the asset is selected. If it's true on mouseUp, then the asset
													// is unselected
		protected var _ignoreHighlightRollout:Boolean;
		
		protected var _tweenPropertiesList:Array	// list of properties enabled for tweening
		//protected var _initPropertiesList:Array			// list of properties used for initializing the object
		protected var _statePropertiesList:Array;		// list of properties for managing the state of the object
														// these are the properties sent to the state manager
		
		protected var _constructorProperties:Object;	// holds the constructor properties values until the cc handler is called
		protected var _initializeProperties:Object;		// holds the initial state properties that aren't recorded by the state manager
														// so that we save/restore the initial state
		
		protected var _draggable:Boolean;
		
		[Bindable]
		public var theRotation:Number;	// need to use this since rotation is not bindable
		[Bindable]
		public var zIndex:Number;
		[Bindable]
		public var theSize:Number;		// same as the width, but set as a different property so that we 
										// can set the height at the same time, using the size & aspect ratio
		
		
		protected var defaultWidgetControls:Array = ["width", "height", "rotation", "zIndex"];
		protected var fullscreenControlsToDisable:Array = ["width", "height", "rotation", "zIndex"];
		
		protected var _fullscreen:Boolean = false;
		protected var _maintainAspectRatio = false;
		protected var _floater:Boolean = false;
		protected var _hardcodedZIndex:int = -1;	// if this number is set, this asset will replace anything at this zIndex and not be 
										// moved from this index; if this number is set...
										
		public var assetLoaded = false;		// used for assets who's content has been sent in via the properties
											// the movie can check this and know not to add an assetLoaded handler
											// because the assetLoaded event has already fired.
		public var assetEnabled = true;			// if the asset is disabled, it won't play/display in the movie	
										
										
		protected var widgetControls:Array;
		
		protected var assetClass:AssetClass;
		
		protected var aspectRatio:Number;		// used in the set size() function

			
		public function AssetInstance(name:String, incomingProperties:Object, assetClass:AssetClass=null)
		{
			theMovie = Movie.movie;
			
			this.assetClassName = name;
			this.assetClass = assetClass;
			this._properties = new Object();
			_constructorProperties = incomingProperties;
			
			// right now the intialize properties just store the assetPath
			this._initializeProperties = {assetPath:_constructorProperties.assetPath};
			
			//BindingUtils.bindProperty(this, "width", this, "properties.width");
			
			if (_constructorProperties.fullscreen) {
				_fullscreen = true;
			}
			
			if (_constructorProperties.hasOwnProperty("hardcodedZIndex")) {
				_hardcodedZIndex = _constructorProperties.hardcodedZIndex;
			}
			
			
			// this currently doesn't do anything
			/*if (properties.maintainAspectRatio) {
				_maintainAspectRatio = true;
			}*/
					
			//assetCmpnt.addEventListener(FlexEvent.CREATION_COMPLETE, this._initCCHandler);
			//this.addEventListener(Event.ADDED, this.addedHandler);
			
			this._highlighted = false;
			this._selected = false;
			
			if (! _fullscreen) {
				this._draggable = true;
			}
			
			if (! widgetControls) widgetControls = defaultWidgetControls;
			if (_fullscreen) {
				for each (var controlName:String in fullscreenControlsToDisable) {
					// commenting these out because removing the properties from the state property
					// list will prevent the asset from being intialized correctly when the movie
					// is loaded
					//delete _tweenPropertiesList[_tweenPropertiesList.indexOf(controlName)];
					//delete _statePropertiesList[_statePropertiesList.indexOf(controlName)];
					delete widgetControls[widgetControls.indexOf(controlName)];
				}
			}
			
			/* OLD WIDGET CODE - changing the way the widget works - instead of having a widget object
			for each asset, the assets should share the object, and the object will get initialized with 
			the assets properties every time the asset/widget become active.
			
			this.controlWidget = new AssetInstanceWidget();	 
			this.controlWidget.constructor(this, widgetControls);*/
			
			super();
		}
		
		
		protected function setAssetComponent(inCmpnt:*)
		{
			
			assetCmpnt = inCmpnt;
			assetCmpnt.addEventListener(FlexEvent.CREATION_COMPLETE, _initCCHandler);
			assetCmpnt.asset = this;
		}

		
		protected function _initCCHandler(event:FlexEvent)
		{
			//this.x = properties.x;
			//this.y = properties.y;
			assetCmpnt.visible = false;
			
			if (assetCmpnt.hasOwnProperty("horizontalScrollPolicy")) {
				assetCmpnt.horizontalScrollPolicy = 'off';
				assetCmpnt.verticalScrollPolicy = 'off';
			}
			
			//this.addChild(this.assetCmpnt);
			
			assetCmpnt.addEventListener(MouseEvent.MOUSE_DOWN, this._mouseDownHandler);
			assetCmpnt.addEventListener(MouseEvent.MOUSE_UP, this._mouseUpHandler);
			assetCmpnt.addEventListener(MouseEvent.ROLL_OVER, this._mouseRollOverHandler);
			assetCmpnt.addEventListener(MouseEvent.ROLL_OUT, this._mouseRollOutHandler);
			assetCmpnt.addEventListener(MouseEvent.DOUBLE_CLICK, this._doubleClickHandler);
			
			assetCmpnt.addEventListener(Event.REMOVED_FROM_STAGE, this.removeFromStageHandler);
			
			assetCmpnt.addEventListener(DragEvent.DRAG_ENTER, _dragTest, true);
			assetCmpnt.addEventListener(MouseEvent.CLICK, _mouseClick, true);
			//this.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, this.assetAddedHandler);
			
			// this trigger is called whenever an asset is selected on the stage
			this.theMovie.stage.addEventListener(MovieEvent.ASSET_SELECTED, this._assetSelectedHandler, true);
			
			dispatchEvent(new AssetEvent(AssetEvent.ASSET_INITIALIZED));
		}
		
		
		public function _dragTest(event:Event) {
			//trace("hello");
			event.stopImmediatePropagation();
		}
		
		public function _mouseClick(event:Event) {
			//trace("click");
			event.stopImmediatePropagation();
		}
		
		
		protected function assetLoadedHandler(event:Event=null) {
			
			//this.addEventListener(ChildExistenceChangedEvent.CHILD_ADD, assetAddedHandler);
			//this.addChild(this.assetCmpnt);
			// calling set properties again just so the after cc sets get called
			
			// remove this so it doesn't get called again
			//assetCmpnt.removeEventListener(FlexEvent.UPDATE_COMPLETE, assetLoadedHandler);
			assetCmpnt.removeEventListener(Event.COMPLETE, assetLoadedHandler);
	
			// set the initial view properties unless this is being loaded by the movie loader, because then 
			// the initial view has already been stored in the state manager
			//if (! _constructorProperties.createdByMovieLoader) {
			
			// never mind the above - we should still keep these - if the state manager has stored
			// the initial view - it will change these anyway. And for some assets, the state manager
			// doesn't store anything more - so they need to get the correct properties here
			if (true) {
				if (_fullscreen) {
					assetCmpnt.width = Application.application.stageWidth;
					assetCmpnt.height = Application.application.stageHeight;
					_constructorProperties.centerX = Application.application.stageWidth/2;
					_constructorProperties.centerY = Application.application.stageHeight/2;
				}
				
				// set the width and height for the state properties
				this._constructorProperties.width = assetCmpnt.width;
				this._constructorProperties.height = assetCmpnt.height;
				this._constructorProperties.rotation = assetCmpnt.rotation;
				this._constructorProperties.visible = true;
				
				// DEPRECATED
				/*aspectRatio = assetCmpnt.width/assetCmpnt.height;
				// set the size to the biggest dimension
				if (assetCmpnt.width > assetCmpnt.height) {
					theSize = assetCmpnt.width
					//theSizeDimension = 'width';
				} else {
					theSize = assetCmpnt.height;
					//theSizeDimension = 'height';
				}*/
				//this._initializeProperties.
			}
			
			assetLoaded = true;
			
			this.setProperties(this._constructorProperties);
			
			this._select();
			
			this.dispatchEvent(new AssetEvent(AssetEvent.ASSET_COMPLETE));
			
		}
		
		
		/**
		 * Just a place holder right now so that audioAsset can override
		 */
		public function deleteAsset()
		{
		}
		
		/***************************** GET/SET PROPERTIES ******************************/
		
		
		
		/**
		 * I'm not using a set function here so it is clear this is more
		 * functional than just setting a value.
		 * 
		 * For each property, set the object's property by calling set*Property*()
		 * If this function doesn't exist, set the property directly, which might call
		 * the property's set() function. 
		 * 
		 * Look for the set*Property*() function first, because many properties, like
		 * width and height, are inherited properties and therefore set() functions cannot
		 * be created for them.
		 */
		public function setProperties(incomingProperties:Object, currentFrame:int=undefined) 
		{
			//doInvalidate = false;		// flag to invalidate only if something has changed
										// save this for future implementation
			
			var doRotation:Boolean = false;
			
			// temp
			if (incomingProperties.x) {
				setXY(incomingProperties.x, incomingProperties.y);
				delete incomingProperties.x;
				delete incomingProperties.y;
			}
			
			for (var propertyName:String in incomingProperties)
			{
				if (propertyName=="rotation") {
					// do the rotation last
					doRotation = true;
					continue;
				}
				setProperty(propertyName, incomingProperties[propertyName]);
			}
			
			if (doRotation) setProperty("rotation", incomingProperties.rotation);
			theRotation = assetCmpnt.rotation;
			
			if (!assetEnabled) assetCmpnt.visible = false;
			
			assetCmpnt.invalidateProperties();
			assetCmpnt.invalidateDisplayList();
		}
		
		
		protected function setProperty(propertyName:String, value:*) {
			
			var functionName:String = "set"+ucfirst(propertyName);
			
			if (functionName in this) {
				this[functionName](value);
			} else {
				try {
					//trace("calling set on " + propertyName + " on " + stageName);
					assetCmpnt[propertyName] = value;
				} catch (e:Error) {
					//trace("can't set property " + propertyName + " on " + stageName);
				}
			}
	}
	
	
	/**
	 * Add properties to the constructor properties before the asset is loaded.
	 */
		public function setConstructorProperties(constructorProperties:Object)
		{
			for (var key:String in constructorProperties) {
				_constructorProperties[key] = constructorProperties[key];
			}
		}
	
		
		public function setStateProperty(propertyName:String, value:*) {
			// if the statePropertiesList is set, only set the property if it is
			// included in the list
			if (_statePropertiesList.length > 0) {
				if (this._statePropertiesList.indexOf(propertyName) > -1) {
					this._properties[propertyName] = value;
				}
			} else {
				_properties[propertyName] = value;
			}
		}
		
		
		public function getStateProperty(propertyName:String)
		{
			return _properties[propertyName];
		}
		
		
		public function setInitializeProperty(propertyName:String, value:*) {
			//if (this._statePropertiesList.indexOf(propertyName) > -1) {
			//		this._properties[propertyName] = incomingProperties[propertyName];
			//	}
			_initializeProperties[propertyName] = value;
		}
		
		
		public function getInitializeProperty(propertyName:String)
		{
			return _initializeProperties[propertyName];
		}
		
		
		public function setWidth(inWidth:Number) {
			//trace("setwidth getting called: "+inWidth);
			assetCmpnt.width = inWidth;
			var coords:Object = getCoordsFromCenter();
			
			assetCmpnt.x = coords.x;
			assetCmpnt.y = coords.y;
			
			//if (theSizeDimension=='width') theSize = assetCmpnt.width;
			theSize = assetCmpnt.width;
			
			setStateProperty("width", assetCmpnt.width);
		}
		
		public function setHeight(inHeight:Number) {
			assetCmpnt.height = inHeight;
			var coords:Object = getCoordsFromCenter();
			
			assetCmpnt.x = coords.x;
			assetCmpnt.y = coords.y;
			
			//if (theSizeDimension=='height') theSize = inHeight;
			
			//setStateProperty("height", assetCmpnt.height);
		}
		
		
		public function setXY(inX:Number, inY:Number) {
			assetCmpnt.x = inX;
			assetCmpnt.y = inY;
			
			var centerCoords:Object = getCenterCoordsFromPosition();
			
			setStateProperty("centerX", centerCoords.centerX);
			setStateProperty("centerY", centerCoords.centerY);
			
		}
		
		
		public function setCenterX(inCenterX:Number) {
			
			// compute the x from the center x 
			assetCmpnt.x = inCenterX - assetCmpnt.width/2;
			
			setStateProperty("centerX", inCenterX);
		}
		
		
		public function setCenterY(inCenterY:Number) {
			
			// compute the yfrom the center y 
			assetCmpnt.y = inCenterY - assetCmpnt.height/2;
			
			setStateProperty("centerY", inCenterY);
		}
		
		
		//public function getXFromCenter() {
			
		//}
		
		
		public function setRotation(degrees:Number) {
			
			// first thing to do, remove any current rotation so that we start from 0
			doUnrotate();
			
			// now set x & y back to where they should be in relation to centerX&Y
			assetCmpnt.x = _properties.centerX - assetCmpnt.width/2;
			assetCmpnt.y = _properties.centerY - assetCmpnt.height/2;
			
			doRotate(degrees);
			//properties.x = x;
			//properties.y = y;
			setStateProperty("rotation", degrees);
		}
		
		
		public function doUnrotate() {
			if (assetCmpnt.rotation) {
				var mat:Matrix = assetCmpnt.transform.matrix;
				FlexMatrixTransformer.rotateAroundInternalPoint(mat, assetCmpnt.width/2, assetCmpnt.height/2, -assetCmpnt.rotation);
				assetCmpnt.transform.matrix = mat;
			}
		}
		
		
		public function doRotate(degrees:Number=0) {
			if (degrees) {
				var oldRotation:Number = assetCmpnt.rotation;
				var mat2:Matrix = assetCmpnt.transform.matrix;
				FlexMatrixTransformer.rotateAroundInternalPoint(mat2, assetCmpnt.width/2, assetCmpnt.height/2, degrees);
				assetCmpnt.transform.matrix = mat2;
				
				//theRotation = rotation; // update the binding property
				
				// dispatch the rotation property change event manually
				//dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "rotation", rotation, oldRotation));
			}
		}
		
		
		/*public function setRotation(degrees:Number) {
			
			// first, rotate back any degrees we've already rotated, otherwise the rotations will 
			// add up with each other and rotate too much
			var mat:Matrix = transform.matrix;
			if (_rotate) {
				FlexMatrixTransformer.rotateAroundInternalPoint(mat, width/2, height/2, -_rotate);
				transform.matrix = mat;
				
			}
			
			FlexMatrixTransformer.rotateAroundInternalPoint(mat, width/2, height/2, degrees);
			transform.matrix = mat;
			//properties.x = x;
			//properties.y = y;
			
			_rotate = degrees;
		}*/
		
	
		
		public function get properties()
		{
			return this._properties;
		}
		

		public function set assetPath(assetPath:String) {
			// right now this is just being used to set the asset path so that it is saved with the 
			// asset when saving the movie. Setting the assetPath doesn't change the content of the asset.
			
			_initializeProperties.assetPath = assetPath;
		}
		
		// the above really should be setAssetPath - don't know if the above ever gets called
		public function setAssetPath(assetPath:String) {
			// right now this is just being used to set the asset path so that it is saved with the 
			// asset when saving the movie. Setting the assetPath doesn't change the content of the asset.
			
			_initializeProperties.assetPath = assetPath;
		}
			
		
		
		public function set removeFromStage(value:int) {
			assetCmpnt.visible = 0;
		}
		
		
		public function changeZIndex(newZIndex:Number) {
			theMovie.changeZIndex(assetCmpnt, zIndex, newZIndex);
		}
		
		
		public function get highlighted()
		{
			return this._highlighted;
		}
		
		public function get selected() 
		{
			return this._selected;
		}
		
		public function get statePropertiesList()
		{
			return this._statePropertiesList;
		}
		
		
		public function get initializeProperties() {
			return _initializeProperties;
		}
		
		
		public function get duration():Number {
			return 0;
		}
		
		
		/**
		 * Set the largest dimension to the size, and scale the other dimension to
		 * keep the same aspect ratio.
		 */
		public function setSize(size:Number) {
			theSize = size;
			setWidth(size);
			setHeight(assetCmpnt.width / aspectRatio);
			
			/*if (assetCmpnt.width > assetCmpnt.height) {
				setWidth(size);
				setHeight(assetCmpnt.width / aspectRatio);
			} else {
				setHeight(size);
				setWidth(assetCmpnt.height * aspectRatio);
			}*/
		}
		
		
		/*public function setSize(newSize:int) {
			var diff:Number = theSize - newSize;
			setWidth(assetCmpnt.width-diff);
			setHeight(assetCmpnt.height - diff);
			theSize = newSize;
		}*/
		
		
		public function get size():int {
			return theSize;
		}
		
		
		/*************************** UTILITIES ************************/
		
		/**
		 * Calculates the deltas between the center coords and the object's x & y/
		 */
		public function getCoordDeltas():Object {
		
			//x = _properties.centerX - width/2;
			var a:Number = assetCmpnt.height/2;
			var b:Number = assetCmpnt.width/2;
			var c:Number = Math.sqrt(a*a + b*b);
			
			// if you divide the canvas into 4 quads, we are dealing with the
			// upper left quad and the bottom triangle of that quad
			
			// now, find the interior angle
			var interiorAngle:Number = Math.atan(a/b) * 180/Math.PI
			
			// now use the triangle created by the interiorAngle and the rotation angle
			// this triangle contains the distances to the center
			var totalAngle:Number = interiorAngle + assetCmpnt.rotation;
			var totalRadians:Number = totalAngle * Math.PI/180;
			
			var dy:Number = Math.sin(totalRadians) * c;
			var dx:Number = Math.cos(totalRadians) * c;
			
			return {dx:dx, dy:dy};
			
			//var centerX:Number = Math.round(x + dx);
			//var centerY:Number = Math.round(y + dy);
			//x = Math.round(_properties.centerX - dx);
			//y = Math.round(_properties.centerY - dy);
		}
		
		
		/**
		 * Returns the center coords calculated from x & y
		 */
		public function getCenterCoordsFromPosition():Object {
			
			var deltas:Object = getCoordDeltas();
			
			var centerX:Number = Math.round(assetCmpnt.x + deltas.dx);
			var centerY:Number = Math.round(assetCmpnt.y + deltas.dy);
			
			return {centerX:centerX, centerY:centerY};	
		}
		
		
		/**
		 * Returns the coords calculated from the center
		 */
		public function getCoordsFromCenter():Object {
			
			var deltas:Object = getCoordDeltas();
			
			var returnX:Number = Math.round(_properties.centerX - deltas.dx);
			var returnY:Number = Math.round(_properties.centerY - deltas.dy);
			
			return {x:returnX, y:returnY};	 
		}
		
		
		
		/***************************** HANDLERS ******************************/
		
		/**
		 * When this is added to the stage, get its index.
		 */
		/*protected function addedHandler(event:Event):void {
			zIndex = parent.getChildIndex(this);
		}*/
		
		
		protected function removeFromStageHandler(event:Event) {
			
		}
		
		
		protected function _mouseDownHandler(event:MouseEvent):void
		{
			//trace("mousedown");
			if (this._draggable) {
				this._startDragging(event); 
				theMovie.stop();
			}
			
			if (! this.selected) {
				this._preUnSelectFlag = false;
				this._select();
			} else {
				//this._preUnSelectFlag = true;
			}
			assetCmpnt.setFocus();
		}
		
		
		protected function _mouseUpHandler(event:Event):void
		{
			//trace("mouseup");
			if (this._draggable) this._stopDragging(event);
			
			if (this._preUnSelectFlag) {
				this._unSelect();
				this._highlight();
				this._ignoreHighlightRollout = true;
			}
			
			this._preUnSelectFlag = false;
			
			this.setProperties({x:assetCmpnt.x, y:assetCmpnt.y});
			this.theMovie.captureAssetAtCurrentFrame(this);
		}
		
		
		protected function _mouseRollOverHandler(event:MouseEvent)
		{
			//trace("rollover");
			if (! this.selected) this._highlight(); 
		}
		
		
		protected function _mouseRollOutHandler(event:MouseEvent) 
		{
			//trace("rollout");
			if (this.highlighted && ! this._ignoreHighlightRollout) this._unHighlight();
			
			this._ignoreHighlightRollout = false;
		
		}
		
		
		protected function _assetSelectedHandler(event:MovieEvent)
		{
			if (this.selected && event.target.asset!=this)
			{
				this._unSelect();
			}
		}
		
		
		protected function _doubleClickHandler(event:MouseEvent) 
		{
			if (selected) {
				_unSelect();
			}
		}

		
		// This function is called when the mouse button is pressed.
		protected function _startDragging(event:MouseEvent):void
		{
			if (theMovie.mode=="preview" || theMovie.mode=="player") return;
			assetCmpnt.addEventListener(MouseEvent.MOUSE_MOVE, this._moveCancelUnSelect);
			
			// listen for any mouseUpEvent in the application - because the asset may get dragged
			// off the stage, and then the mouseUp won't register with the asset
			Application.application.stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler, true);
			Application.application.stage.addEventListener(Event.MOUSE_LEAVE, _mouseUpHandler);
			
		    assetCmpnt.startDrag();
		}
		
		
		protected function _draggingMouseMoveHandler(event:MouseEvent)
		{
			if (! event.buttonDown) { 
				_stopDragging(event);
			}
		}
		
		
		// This function is called when the mouse button is released.
		protected function _stopDragging(event:Event):void
		{
			assetCmpnt.removeEventListener(MouseEvent.MOUSE_MOVE, this._moveCancelUnSelect);
			
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler, true);
			Application.application.stage.removeEventListener(Event.MOUSE_LEAVE, _mouseUpHandler);
			
		    assetCmpnt.stopDrag();
		}
		
		
		protected function _moveCancelUnSelect(event:MouseEvent)
		{
			this._preUnSelectFlag = false;
		}
		
		
		protected function _highlight()
		{
			if (theMovie.mode=="preview" || theMovie.mode=="player") return;
			//trace("highlight");
			/*this.setStyle("borderStyle", "solid");
			this.setStyle("borderThickness", "2");
			this.setStyle("borderColor", "#2980BC");*/
			
			this._highlighted = true;
		}
		
		
		protected function _unHighlight()
		{
			if (theMovie.mode=="preview" || theMovie.mode=="player") return;
			//trace("unhighlight");
			/*//this.setStyle("borderStyle", "solid");
			this.setStyle("borderThickness", "0");
			//this.setStyle("borderColor", "#2980BC");*/
			
			this._highlighted = false;
		}
		
		
		protected function _select()
		{
			if (theMovie.mode=="preview" || theMovie.mode=="player") return;
			
			//trace("select");
			if (this.highlighted) this._unHighlight();
			
			/*this.setStyle("borderStyle", "solid");
			this.setStyle("borderThickness", "2");
			this.setStyle("borderColor", "#DDDDDD");*/
			
			this._selected = true;
			this._preUnSelectFlag = false;
			
			
			// add the widget regardless if there is one. If there isn't a widget, the movie will just
			// remove the current widget, if there is one.
			//if (this.controlWidget) {
				//try {
					// CHECK:
					// throwing an error because with the now, the asset doesn't get added
					// to the movie until it's loaded, so this is getting called incorrectly now
					if (controlWidget) {
						controlWidget.widget.addEventListener(FlexEvent.UPDATE_COMPLETE, controlWidgetReadyHandler);
						this.theMovie.setControlWidget(this.controlWidget.widget);
					} else {
						theMovie.setControlWidget();
					}
				//} catch (e:Error) {
				//}
			//}
			
			/*if (controlWidget) {
				controlWidget.initializeControls(this, widgetControls);
			}*/
			
			assetCmpnt.dispatchEvent(new MovieEvent(MovieEvent.ASSET_SELECTED));
			
			// get z index from parent
			// causing an error on pre-loaded assets through the loadData property
			try {
				zIndex = assetCmpnt.parent.getChildIndex(assetCmpnt);
			} catch (e:Error) {
			}
			
			assetCmpnt.setFocus();
		}
		
		protected function controlWidgetReadyHandler(event:Event) {
			controlWidget.initializeControls(this, widgetControls);
			controlWidget.widget.removeEventListener(FlexEvent.UPDATE_COMPLETE, controlWidgetReadyHandler);
		}
		
		
		protected function _unSelect()
		{
			//trace("unselect");
			/*this.setStyle("borderThickness", "0");*/
			this._selected = false;
			
				
			//if (controlWidget) {	
			//	theMovie.setControlWidget();
			//}
			
			this.dispatchEvent(new MovieEvent(MovieEvent.ASSET_DESELECTED));
		}
		
		
		public function unSelect()
		{
			_unSelect();
		}
		

		/*protected function _toggleControls(event:MouseEvent):void {
			
			if (_controlsOn) {
				for each (var controlName:String in _controls) {
					this[controlName].visible = false;
				}
				_controlsOn = false;
			} else {
				for each (var controlName:String in _controls) {
					this[controlName].visible = true;
				}
				_controlsOn = true;
			}
		}*/

		
		protected function _makeUndraggable() 
		{
			this._draggable = false;
			//this.removeEventListener(MouseEvent.MOUSE_DOWN, this._mouseDownHandler);
			//this.removeEventListener(MouseEvent.MOUSE_UP, this._mouseUpHandler);
		}
		
		
		public function get tweenPropertiesList():Array{
				return this._tweenPropertiesList;
		}
		
		public function get fullscreen():Boolean {
			return _fullscreen;
		}
		
		public function get floater():Boolean {
			return _floater;
		}
		
		public function get hardcodedZIndex():int {
			return _hardcodedZIndex;
		}
		
		
		

	
	}
}