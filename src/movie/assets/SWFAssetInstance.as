package movie.assets
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.getQualifiedClassName;
	
	import movie.movie.Movie;
	import movie.movie.MovieEvent;
	
	import mx.core.Application;
	import mx.events.*;
	
	public class SWFAssetInstance extends AssetInstance
	{
		
		protected var _isPlaying:Boolean;
		protected var movieIsControllable:Boolean;
		
		/**
		 * If there should only be one copy of this swf on the stage at any time, set this
		 * to false. This will prevent the swf from being duplicated when another instance 
		 * from the same class is made.
		 */
		protected var allowMultipleInstancesOfSWF:Boolean = true;
		
		public var text; 	// dummy variable so the widget binding works
		
		protected var useLoadedData:Boolean; // if the asset can be instantiated multiple times, this 
									// should be set to false, otherwise the same swf will be used
									// for multiple assets, which will lead to only one asset visible
									
		protected var theLoader:URLLoader;	// loads the url swf into a bytearray so we can copy it for 
											// multiple instance if need be
		protected var convertByteArrayLoader:Loader;	// loads the bytearray into an swf for the assetCmpnt
		
		public function SWFAssetInstance(name:String, properties:Object, assetClass:AssetClass)
		{
			this.type = "SWF";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			useLoadedData = true;
			
			widgetControls = ["width", "height", "rotation", "text"];
			
			super(name, properties, assetClass);
			
			setAssetComponent(new SWFAssetInstanceCmpnt());
		}
		
		
		protected override function _initCCHandler(event:FlexEvent)
		{
			
			/* If the swf is already loaded, finish the asset initialization, and then
				add the swf to the assetComponent in the assetLoadedHandler
			*/
			if (_constructorProperties.loadedData) {
				
				theLoader = _constructorProperties.loadedData;
				addEventListener(AssetEvent.ASSET_INITIALIZED, assetInitHandler);
				
			} else {
				
				// first, load the swf into a loader so that we can save it to the loaded
				// data for reloading later if needed
				theLoader = new URLLoader();
				theLoader.dataFormat = URLLoaderDataFormat.BINARY;
				theLoader.addEventListener(Event.COMPLETE, assetInitHandler);
				Application.application.showProgressBar(theLoader, "loading asset");
				theLoader.load(new URLRequest(_constructorProperties.assetPath));
			}
			
			super._initCCHandler(event);
		}
		
		
		
		protected function assetInitHandler(event:Event=null)
		{
			convertByteArrayLoader = new Loader();
			convertByteArrayLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, assetInit2Handler);
			//Application.application.showProgressBar(convertByteArrayLoader.contentLoaderInfo, "loading asset");
			convertByteArrayLoader.loadBytes(theLoader.data);
			
			if (assetClass) {
				//assetClass.loadedData = assetCmpnt;
				assetClass.loadedData = theLoader;
			}
		}
		
		
		protected function assetInit2Handler(event:Event=null) {
			
			assetCmpnt.addEventListener(FlexEvent.UPDATE_COMPLETE, assetLoadedHandler);
			assetCmpnt.load(convertByteArrayLoader.content);
		}
		
		
		protected override function assetLoadedHandler(event:Event=null) {
			
			//trace("frame rate post swf load: " + Movie.movie.frameRate);
			
			assetCmpnt.removeEventListener(FlexEvent.UPDATE_COMPLETE, assetLoadedHandler);
			
			var movieType:String = getQualifiedClassName(assetCmpnt.content);
			
			if (movieType!="flash.display::AVM1Movie") {
				movieIsControllable = true;
			} else {
				movieIsControllable = false;
			}
			
			if (movieIsControllable) {
				Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			}
			
			assetCmpnt.width = assetCmpnt.content.width;
			assetCmpnt.height = assetCmpnt.content.height;
			
			super.assetLoadedHandler(event);
		}
		
		
		protected function _stopHandler(event:MovieEvent)
		{
			this.assetCmpnt.content.gotoAndStop(getRelativeFrame(event.currentFrame));
			this._isPlaying = false;
		}
		
		
		public override function get duration():Number {
			
			if (assetLoaded && assetCmpnt.content.totalFrames) {
				return assetCmpnt.content.totalFrames / Movie.movie.frameRate;
			} else {
				return 0;
			}
		}
		
		
		/** 
		 * loop the swf, with a pause in between, so the relative is the frame of the
		 *  looped swf, relative to the main movie frame
		 */
		protected function getRelativeFrame(currentFrame:int)
		{
			var pause:int = 48;
			var relativeCurrentFrame:int;
			if (currentFrame > (assetCmpnt.content.totalFrames + pause)) {
				relativeCurrentFrame = currentFrame % (assetCmpnt.content.totalFrames + pause); 
			} else {
				relativeCurrentFrame = currentFrame; 
			}
			return relativeCurrentFrame;
		}
		
		
		public override function setProperties(properties:Object, currentFrame:int=undefined) 
		{
			
			if (this.theMovie && movieIsControllable) {		
				
				if (this.theMovie.isPlaying) 
				{
					// we need the isPlaying flag, because we don't want to start the sound again if it's already playing
					if (! this._isPlaying)
					//if (true)
					{
						this.assetCmpnt.content.gotoAndPlay(getRelativeFrame(currentFrame));
						this._isPlaying = true;
						
					} else {
						if (currentFrame > assetCmpnt.content.totalFrames) {
							assetCmpnt.content.gotoAndPlay(getRelativeFrame(currentFrame));
						}
					}
					
				} else {
					this.assetCmpnt.content.gotoAndStop(getRelativeFrame(currentFrame))
					
				}
			}
			
			super.setProperties(properties, currentFrame);
		}
		
		
				
		public override function setWidth(inWidth:Number) {
			assetCmpnt.content.width = inWidth;
			//trace("setting width : "+inWidth);
			super.setWidth(inWidth);
		}
		
		
		public override function setHeight(inHeight:Number) {
			assetCmpnt.content.height = inHeight;
			super.setHeight(inHeight);
		}
		
		
		
		/*public override function setWidth(inWidth:Number) {
			super.setWidth(inWidth);
			assetCmpnt.content.width=700;
			assetCmpnt.width=700;
			width=700;
			
		}
		
		public override function setHeight(inHeight:Number) {
			super.setHeight(inHeight);
			assetCmpnt.content.height = 700;
			assetCmpnt.height = 700;
			height = 700;
			
		}*/
		
		
		/*protected override function _mouseDownHandler(event:MouseEvent):void {
			
			event.stopImmediatePropagation();
			super._mouseDownHandler(event);
			
		}*/
	}
}