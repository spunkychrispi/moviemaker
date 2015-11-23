package movie.movie
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	
	import movie.assets.*;
	
	import mx.core.Application;
	import mx.core.UIComponent;
		
	public class Movie extends EventDispatcher
	{
		public const MOVIE_STOPPED:String = "stopped";
		public const MOVIE_PLAYING:String = "playing";
		public const MOVIE_FINISHED:String = "finished";
		public var status:String;
		

		protected var _stage:UIComponent;
		protected var _controlPanel:UIComponent;
		protected var _frameStateManager:FrameStateManager;
		protected var _assetManager:AssetManager;
		protected var _numberOfFrames:int;
		protected var _currentFrame:int;
		protected var _nextFrame:int;			// used when playing the movie
		protected var _frameInterval:int;		// time to wait between frames, in ms
		protected var _isPlaying:Boolean;		// deprecating this over the use of the status property
		protected var _frameRate:int;
		
		[Bindable]
		public var thumbnail:ByteArray;		
		public var thumbnailURL:String;			// set by the movieSaveLoad class on saving the movie
												// after it gets the movieID from the server
		
		[Bindable]
		public var numFloaters:int;			// keeps track of how many floater assets are in the movie
		
		protected var _selectedAsset:*;
		
		[Bindable]
		public var numChildren:int;
		
		protected var _mode:String;
		
		//protected var disabledAssets:Array;
	
		public var stageWidth:int;
		public var stageHeight:int;
		
		public static var movie:Movie;
		
		
		public function get stage()
		{
			return this._stage;
		}
		
		public function Movie(stage:UIComponent, controlPanel:UIComponent, numberOfFrames:int, frameRate:int)
		{
			status = MOVIE_STOPPED;
			this._stage = stage;
			this._controlPanel = controlPanel;
			this._numberOfFrames = numberOfFrames;
			this._currentFrame = 1;
			this._frameInterval = 500;
			this._frameRate = frameRate;
			numFloaters = 0;
			
			stageWidth = _stage.width;
			stageHeight = _stage.height;
			
			this._assetManager = new AssetManager();
			this._frameStateManager = new FrameStateManager(this._numberOfFrames);
			
			this._stage.addEventListener(MovieEvent.MOVIE_STOP, this.stopHandler);
			this._stage.addEventListener(MovieEvent.ASSET_SELECTED, this._assetSelectedHandler, true);
			this._stage.addEventListener(MovieEvent.ASSET_DESELECTED, this._assetDeselectedHandler, true);
			
			Application.application.stage.addEventListener(KeyboardEvent.KEY_DOWN, this._keyDownHandler);
			Movie.movie = this;
		}
		
		
		public function resetState() {
				
			// remove each asset from the stage
			trace("removing "+_stage.numChildren+" kids");
			var numChildren:int = _stage.numChildren;
			for (var x:int=0; x<numChildren; x++) {
				trace("remove x");
				_stage.removeChildAt(0);
			}
			
			_assetManager.resetState();
			_frameStateManager.resetState();
			 
            numFloaters = 0;
			
			goToFrame(0);
			
		}
		
		
		public function addAssetToMovie(assetName:String, asset:AssetInstance) {
			addAssetToCurrentFrame(assetName, asset);
		}
		
		
		/**
		 * Adds the asset to the movie, and places it on the stage according to the asset properties.
		 */
		public function addAssetToCurrentFrame(assetName:String, asset:AssetInstance) {
			
			var assetStageName:String = this._assetManager.addAsset(assetName, asset);
			
			// maybe add all these together in an asset.initializeStage() or something...
			asset.firstFrame = this._currentFrame;
			asset.stageName = assetStageName;
			//asset.theMovie = this;
			
			this._selectedAsset = asset;
			if (asset.assetLoaded) {
				onAssetComplete(asset);
			} else {
				asset.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteHandler);
			}
			
			// add child to different indices, depending on its properties
			if (asset.floater) {
				numFloaters++;
				addAsset(asset)
				
			} else if (asset.hardcodedZIndex >= 0) {
				if (_stage.numChildren > 0) {
					// delete the previous asset
					
					// depending on what the display list is like, an asset hardcoded for a z-index
					// could be at a different z-index - so go through all the assets and remove
					// any hardcoded for this z-index
					var assetToDelete:AssetInstance;
					var assetCmpnt:*;
					for (var x=0; x<_stage.numChildren; x++) {
						assetCmpnt = _stage.getChildAt(x);
						assetToDelete = assetCmpnt.asset;
						if (assetToDelete.hardcodedZIndex == asset.hardcodedZIndex) {
							removeAsset(assetToDelete);
						}
					}
					
					// now get the real z-index we'll put this asset at
					if (stage.numChildren < (asset.hardcodedZIndex+numFloaters)) {
						addAssetAt(asset, _stage.numChildren-numFloaters);
					} else {
						addAssetAt(asset, asset.hardcodedZIndex);
					}
					
				} else {
					addAssetAt(asset, _stage.numChildren-numFloaters);
				}
			} else {	
				addAssetAt(asset, _stage.numChildren-numFloaters);
			}
			
			rectifyAssets();
			trace(_stage.numChildren);
		}
		
		
		protected function rectifyAssets() {
			
			// go through the assets again and add any who need to be updated because of their
			// hardcoded z-index
			var assetToCheck:AssetInstance;
			var assetCmpnt:*;
			for (var y=0; y<_stage.numChildren; y++) {
				assetCmpnt = _stage.getChildAt(y);
				assetToCheck = assetCmpnt.asset;
				if (assetToCheck.floater && y<_stage.numChildren-numFloaters) {
					_stage.setChildIndex(assetToCheck.assetCmpnt, _stage.numChildren-1);
				}
				
				if (assetToCheck.hardcodedZIndex >= 0 && assetToCheck.hardcodedZIndex != y) {
					// now get the real z-index we'll put this asset at
					if (stage.numChildren <= (assetToCheck.hardcodedZIndex+numFloaters)) {
						_stage.setChildIndex(assetToCheck.assetCmpnt, _stage.numChildren-numFloaters-1);
					} else {
						_stage.setChildIndex(assetToCheck.assetCmpnt, assetToCheck.hardcodedZIndex);
					}
				}
			}
			
			// finally, go through all the assets one last time and update their zIndex property
			for (var y=0; y<_stage.numChildren; y++) {
				assetCmpnt = _stage.getChildAt(y);
				assetToCheck = assetCmpnt.asset;
				assetToCheck.zIndex = y;
			}
			
			numChildren = _stage.numChildren;
		}
		
		
	
		protected function getAssets() {
		
			var assets = new Array();
			for (var x:int=0; x<_stage.numChildren; x++) {
				var assetCmpnt:* = _stage.getChildAt(x);
				assets.push(assetCmpnt.asset);
			}
			return assets;
		}
		
		
		/**
		 * Call the addChild method of the stage
		 */
		protected function addAsset(asset:AssetInstance) {
			
			if (_stage.numChildren==0) addAssetAt(asset);
			else addAssetAt(asset, _stage.numChildren-1);
		}
		
		
		/**
		 * Call the addChild method of the stage
		 */
		protected function addAssetAt(asset:AssetInstance, index:int=0) {
			
			// if the index is out of bounds because of an error somewhere (this could very well happen
			// with the ScionFX2 load/unload fix for the animations we can't scrub and stop) - then
			// just set the index to the last one
			
			if (index > _stage.numChildren) index = _stage.numChildren;
			
			_stage.addChildAt(asset.assetCmpnt, index);
			//asset.zIndex = index;
		}
		

		protected function setAssetIndex(asset:AssetInstance, index) {
			_stage.setChildIndex(asset.assetCmpnt, index);
			//asset.zIndex = index;
		}
		
		
		/**
		 * Prevent the asset from playing in the movie
		 */
		protected function disableAsset(asset) {
			asset.assetEnabled = false;
		}
		
		protected function enableAsset(asset) {
			asset.assetEnabled = true;
		}
		
		
		protected function onAssetCompleteHandler(event:Event) {
			
			var asset:AssetInstance = event.target as AssetInstance;
			
			// now remove this handler, otherwise it will get called in more than just the 
			// first time this asset is added
			asset.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteHandler);
			
			onAssetComplete(asset);
		}
		
		
		protected function onAssetComplete(asset:AssetInstance) {	
		
			
			// send the asset's initialize properties to the asset manager
			//var initializeProperties:Object = asset.initializeProperties;
			//_assetManager.addAssetsInitializeProperties(asset.stageName, initializeProperties);

			captureAssetAtCurrentFrame(asset);
		}
		
		
		/**
		 * Captures the assets state for the current frame
		 */
		// asset parameter is really an assetWidget - need to fix the parameter typing
		public function captureAssetAtCurrentFrame(asset:AssetInstance) {
			this._frameStateManager.setAssetsFrameProperties(this._currentFrame, asset.stageName, asset.properties, asset.tweenPropertiesList);
		}
		
		
		public function goToFrame(frame:int)
		{
			this._currentFrame = frame; 
			
			dispatchEvent(new MovieEvent(MovieEvent.MOVIE_FRAME_CHANGE));
			//Application.application.theTimeline.value=frame;
		}
		
		
		public function playCurrentFrame() 
		{
			// go through the list of objects
			// if there is a state for the object in the current frame, update the object
			// or find the most recent state for the object and update it
			// if there is no recent state, then make sure the object is invisible
			
			var assets:Array = this._assetManager.assets;
			var frame:int = this._currentFrame;
			
			for (var stageName:String in assets)
			{
				if (assets[stageName].firstFrame <= frame)
				{
					var assetProperties = this._frameStateManager.getAssetsMostRecentState(stageName, assets[stageName].statePropertiesList, frame);
					if (assetProperties)
					{
						assets[stageName].assetCmpnt.visible = true;
						assets[stageName].setProperties(assetProperties, this._currentFrame);
						continue;
						
					} 
				}
				
				assets[stageName].assetCmpnt.visible = false;
			}
			//this._stage.validateNow();
			//this._stage.invalidateDisplayList();
			
		}
		
		
		public function play(playFromBeginning:Boolean=false)
		{
			this._isPlaying = true;
			status = MOVIE_PLAYING;
			
			if (playFromBeginning) 
			{
				this.goToFrame(1);
			}
			
			this._nextFrame = this._currentFrame;
			
			this._stage.addEventListener(Event.ENTER_FRAME, this.playHandler);
			this.dispatchEvent(new MovieEvent(MovieEvent.MOVIE_START, _currentFrame));
			//this._stage.addListener();
		}
		
		
		public function playHandler(event:Event)
		{
			//Alert.show(String(this._currentFrame));
			if (this._isPlaying)
			{
				if (this._nextFrame <= this._numberOfFrames)
				{
					this.goToFrame(this._nextFrame);
					this.playCurrentFrame();
					this._nextFrame++;
					
				} else {
					// movie is finished
					this.stop();
					status = MOVIE_FINISHED;
					dispatchEvent(new MovieEvent(MovieEvent.MOVIE_FINISHED));
					
					/*this._isPlaying = false;
					this.stop();
					this.goToFrame(1);
					this.playCurrentFrame();
					this._stage.removeEventListener(Event.ENTER_FRAME, this.playHandler);*/
					//this._stage.removeListener();
				}
			} else
			{
				this._stage.removeEventListener(Event.ENTER_FRAME, this.playHandler);
			}
		}
		
		
		public function stop()
		{
			this._stage.dispatchEvent(new MovieEvent(MovieEvent.MOVIE_STOP, _currentFrame));
			this.dispatchEvent(new MovieEvent(MovieEvent.MOVIE_STOP, _currentFrame));
		}
		
		
		public function stopHandler(event:Event)
		{
			this._isPlaying = false;
			status = MOVIE_STOPPED;
		}
		
		
		public function get isPlaying()
		{
			return this._isPlaying;
		}
		
		
		public function get numberOfFrames()
		{
			return this._numberOfFrames;
		}
		
		public function get frameRate() {
			return _frameRate;
		}
		
		
		public function set numberOfFrames(numberOfFrames:int) {
			if (_numberOfFrames != numberOfFrames) {
				_numberOfFrames = numberOfFrames;
				dispatchEvent(new MovieEvent(MovieEvent.MOVIE_DURATION_CHANGE));
			}
		}
		
		public function get currentFrame() {
			return this._currentFrame;
		}
		
		
		public function get selectedAsset()
		{
			return this._selectedAsset;
		}
		
		
		public function set mode(mode:String) 
		{
			_mode = mode;
		}
		
		public function get mode()
		{
			return _mode;
		}
		
		
		public function removeAsset(asset:*, frame:int=0, userRequestedDelete:Boolean=false) 
		{
			
			// hardcode to delete the entire asset as opposed to just deleting it from the proceeding frames
			frame = 0;
			
			// if this is the first frame of the movie, remove the entire asset && delete
			if (frame<=asset.firstFrame)
			{
				this._frameStateManager.deleteAsset(asset.stageName);
				this._assetManager.removeAsset(asset.stageName);
				
				try {
					this._stage.removeChild(asset.assetCmpnt);
				} catch (err:Error) {
				}
				
			} else
			{
				this._frameStateManager.removeAssetsFrameProperties(asset.stageName, frame, true);
				
				// otherwise, add a delete property at frame
				var properties:Object = {"removeFromStage":1};
				this._frameStateManager.setAssetsFrameProperties(frame, asset.stageName, properties);
				asset.setProperties(properties, this._currentFrame);
				
				playCurrentFrame();
			}
			
			if (asset.floater) numFloaters--;
		}
		
		
		public function setControlWidget(widget:*=null)
		{
			// remove any current widget, if there is one
			if (_controlPanel.numChildren > 0) {
				_controlPanel.removeChildAt(0);
			}			

			if (widget) {
				this._controlPanel.addChild(widget);
			}
		}
		
		
		/*public function removeControlWidget(widget:*)
		{
			try {
				this._controlPanel.removeChild(widget);
			} catch(e:Error) {
				trace("error removing control widget: Movie.as");
			}
		}*/
		
		/*protected function _createStandardWidget(asset:*)
		{
			var widget:StandardAssetWidget = new StandardAssetWidget();
			widget.constructor(asset);
			return widget;
		}*/
		
		protected function _assetSelectedHandler(event:MovieEvent)
		{
			this._selectedAsset = event.target.asset;
			//trace("selected asset = " + this._selectedAsset.stageName);
		}
		
		protected function _assetDeselectedHandler(event:MovieEvent)
		{
			if (this._selectedAsset == event.target) {
				//trace("deselecting asset: " + this._selectedAsset.stageName);
				this._selectedAsset = null;
				
			}
		}
		
		protected function _keyDownHandler(event:KeyboardEvent):void
		{
		   if ((event.charCode==8 || event.charCode==127) && this._selectedAsset)
		    {
		    	this.removeAsset(this._selectedAsset, this._currentFrame, true);
		    }
		}
		
		
		public function changeZIndex(assetCmpnt, oldIndex, newIndex) {
			
			_stage.setChildIndex(assetCmpnt, newIndex);
			rectifyAssets();
		}
		
		
		/********************************** SAVING/LOADING ********************************/
	
		
		public function saveToByteArray():ByteArray {
			
			// serialize the asset manager and state manager states
			var saveObject:Object = new Object();
			
			// save the initialize properties for the assets
			var assetsDataToSave:Object = new Object();
			var asset:AssetInstance;
			for (var assetStageName:String in _assetManager.assets) {
				asset = _assetManager.assets[assetStageName]
				assetsDataToSave[assetStageName] = new Object();
				assetsDataToSave[assetStageName].type = asset.type;
				assetsDataToSave[assetStageName].assetClassName = asset.assetClassName;
				assetsDataToSave[assetStageName].zIndex = asset.zIndex;
				assetsDataToSave[assetStageName].firstFrame = asset.firstFrame;
				
				assetsDataToSave[assetStageName].initializeProperties = asset.initializeProperties;
				// merge the initializeProperties with the first frame properties so the asset
				// will have its state set before the movie starts
				
				if (_frameStateManager.frames[assetStageName]!=null) {
					var firstFrameProps:Object = _frameStateManager.frames[assetStageName][asset.firstFrame];
					for (var key:String in _frameStateManager.frames[assetStageName][asset.firstFrame]) {
						assetsDataToSave[assetStageName].initializeProperties[key] = _frameStateManager.frames[assetStageName][asset.firstFrame][key];
					}
				}
				
				
				
				if (asset.type=="ScionImage") {
					assetsDataToSave[assetStageName].initializeProperties.height=408;
					assetsDataToSave[assetStageName].initializeProperties.width=745;
				}
				
				// probably not the best way to pass this flag
				assetsDataToSave[assetStageName].initializeProperties.createdByMovieLoader = true;
			}
			
			saveObject.assets = assetsDataToSave;
			saveObject.frames = _frameStateManager.frames;
			saveObject.keyFrames = _frameStateManager.keyFrames;
			saveObject.numberOfFrames = _numberOfFrames;
			if (thumbnailURL) {
				saveObject.thumbnailURL = thumbnailURL;
			}
			
			var stringRep:String = saveObject.toString();
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeObject(saveObject);
			
			return byteArray;
		}
		
		
		public function reset() {
			// re-initialize the movie
            // remove the old movie assets
            
            stop();
            
            var numChildren:int = stage.numChildren;
            for (var x:int=0; x<numChildren; x++) {
            	_stage.removeChildAt(0);
            }
            
            _numberOfFrames = 1;
            goToFrame(1);
            
            _assetManager = new AssetManager();
            _frameStateManager = new FrameStateManager(_numberOfFrames);
            
            numFloaters = 0;
  		}
		
		
		protected var assetsToLoad:Array;
		protected var assetClasses:Object;	// stores any loaded data that can be shared among instances of the same class
		protected var currentlyLoadingAsset:AssetInstance;
		
		
		public function loadMovie(saveObject:Object) {
			
			// first, make the stage invisible, just in case
			_stage.visible = false;
		
			assetClasses = new Object();
           var assets:Object = saveObject.assets;
           var frames:Object = saveObject.frames;
           var keyFrames:Object = saveObject.keyFrames;
           numberOfFrames = saveObject.numberOfFrames;
            
            var assetInstance:*;
            var assetData:Object;
            var theAssets:Array = new Array();
            for (var assetStageName:String in assets) {
            	assetData = assets[assetStageName];
            	
            	// make an asset class for this asset if there isn't one already - this is just os that 
            	// we can store any loaded data shared by the class instances
            	var assetClassKey = assetData.assetClassName + assetData.type;
            	if (assetClasses[assetClassKey]==null) {
            		assetClasses[assetClassKey] = new AssetClass(assetData.assetClassName, assetData.type);
            	}
            	
                //assetInstance = AssetInstanceCreator.createAssetInstance(assetData.type, assetData.assetClassName, assetData.initializeProperties);
            	// adding assetStageName just so to compile for right now
            	assetInstance = AssetInstanceCreator.createAssetInstance(assetData.type, assetData.assetClassName, assetData.initializeProperties, assetClasses[assetClassKey]);
            	assetInstance.stageName = assetStageName;
            	assetInstance.zIndex = assetData.zIndex;
            	assetInstance.firstFrame = assetData.firstFrame;
            	assetInstance.theMovie = this;
            	
            	
            	// make invisible to begin with
            	//assetInstance.visible = false;
            	
            	_assetManager.addAsset(assetInstance.assetClassName, assetInstance);
            	
            	theAssets.push(assetInstance);
            	//addAssetToCurrentFrame(assetData.name, assetInstance);
            	//_stage.addChild(assetInstance);
            } 
            
            //_assetManager.assets = assets as Array;
            _frameStateManager.frames = frames;
            _frameStateManager.keyFrames = keyFrames;
            
            // add the assets to the stage in order of their zIndex
            // we need to do this recursively, added the next asset only after the
            // previous asset has fired its assetComplete event.
            assetsToLoad = theAssets.sortOn("zIndex");
            
            loadAsset();
		}
		
		
		protected function loadAsset(event:Event=null) {
			
			if (currentlyLoadingAsset) {
				currentlyLoadingAsset.removeEventListener(AssetEvent.ASSET_COMPLETE, loadAsset);
			}
			
			if (assetsToLoad.length) {
				currentlyLoadingAsset = assetsToLoad.shift();
				
				// get the asset's assetClass, find out if there's any loadedData, and send 
				// that to the asset before it loads
				var assetClassKey = currentlyLoadingAsset.assetClassName + currentlyLoadingAsset.type;
            	if (assetClasses[assetClassKey]!=null) {
            		currentlyLoadingAsset.setConstructorProperties(assetClasses[assetClassKey].properties);
            	}
				
            	currentlyLoadingAsset.addEventListener(AssetEvent.ASSET_COMPLETE, loadAsset);
            	
            	// This should be integrated with onAssetComplete/Loaded, so that any child
            	// class that overrides that function will have their code called as opposed
            	// to having to work it in here as well
				_stage.addChild(currentlyLoadingAsset.assetCmpnt);
			} else {
				initializeLoadedAssets();
			}
		}
		
		
		protected function initializeLoadedAssets() {
			// play the first frame of the movie to send the intitial state to all of the assets
			_stage.addEventListener(Event.EXIT_FRAME, loadedAssetsInitializedHandler);
			goToFrame(1);
			playCurrentFrame();
			//trace("whatever");
		}
		
		protected function loadedAssetsInitializedHandler(event:Event) {
			goToFrame(1);
			_stage.visible = true;
			_stage.removeEventListener(Event.EXIT_FRAME, loadedAssetsInitializedHandler);
			dispatchEvent(new MovieEvent(MovieEvent.MOVIE_LOADED));
		}
	
	}
}