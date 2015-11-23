package movie.assets
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import movie.movie.MovieEvent;
	
	import mx.core.Application;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import movie.util.ErrorHandler;
	
	import nl.flexcoders.controls.YouTubePlayer;
	
	
			
	/**
	 * There are two loading stages: the loading of the youtube player, and then the loading of the youtube flv.
	 * The asset should not be considered loaded until both stages are done. The flv is considered loaded when the
	 * state of the player is 5/cued. To load the flv, either playVideo or seekTo have to be called on the player.
	 */
	public class YouTubeAssetInstance extends AssetInstance
	{
		
		//protected var _isPlaying:Boolean;	//become unreliable to manage play state, so now just check the youtube 
											//player to see if it's playing
		protected var youtubeLoader:Loader;
		protected var youtubePlayer:Object;
		
		protected var dummy:YouTubePlayer;
	
		public function YouTubeAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "YouTube";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			
			//this._isPlaying = false;	
			
			Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			
			properties.fullscreen = true;
			properties.hardcodedZIndex = 0;
			
			super(name, properties, assetClass);
			
			width = 320;	// default size from youtube
			height = 240;
			
			
			assetCmpnt = new YouTubePlayer();
			assetCmpnt.loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
			assetCmpnt.videoID = properties.assetPath;
			assetCmpnt.width = width;
			assetCmpnt.height = height;
			
			addEventListener(DragEvent.DRAG_ENTER, _dragTest, true);
			addEventListener(MouseEvent.CLICK, _mouseClick, true);
			addEventListener(MouseEvent.MOUSE_MOVE, _mouseClick, true);
			addEventListener(MouseEvent.MOUSE_OVER, _mouseClick, true);
		}
		
		public override function _dragTest(event:Event) {
			trace("cmpnt hello");
			event.stopImmediatePropagation();
		}
		
		public override function _mouseClick(event:Event) {
			trace("cmpnt " + event.type);
			event.stopImmediatePropagation();
		}
		
	
		
		protected function onLoaderInit(event:Event) {
			assetCmpnt.loader.content.addEventListener("onReady", assetLoadedHandler);
			assetCmpnt.loader.content.addEventListener("onError", assetErrorHandler);
			
			// commented out for demo
			/*assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_DOWN, this._mouseDownHandler);
			assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_UP, this._mouseUpHandler);
			assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OVER, this._mouseRollOverHandler);
			assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OUT, this._mouseRollOutHandler);*/
			
			/*assetCmpnt.loader.content.addEventListener(MouseEvent.CLICK, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(DragEvent.DRAG_ENTER, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(DragEvent.DRAG_OVER, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_DOWN, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_MOVE, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_OUT, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_UP, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_OVER, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OVER, _mouseClick, true);
			assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OUT, _mouseClick, true);*/
			
			
		}
		
		
		function assetErrorHandler(event:*) {
				
				trace("asdfadsf");
			var errorText:String;
			switch (event.data) {
				case 100:
					errorText = "The requested video was not found. It may have been removed or marked as private.";
					break;
				case 101:
				case 150:
					errorText = "The requested video does not allow playback in embedded players."
					break;
				default:
					errorText = "An error ocurred with the requested video";
			}
			
			ErrorHandler.alertError(errorText);
		}
		
		
		protected override function _initCCHandler(event:FlexEvent) {
			// set the mouse handlers here as well - for some reason the ones set in the super class
			// are not getting called for the youtube asset
			
			/*assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_DOWN, this._mouseDownHandler);
			assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_UP, this._mouseUpHandler);
			assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OVER, this._mouseRollOverHandler);
			assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OUT, this._mouseRollOutHandler);*/
			
			super._initCCHandler(event);
		}
		
		
		protected override function assetLoadedHandler(event:Event=null) {
			
			var embedCode:String = assetCmpnt.loader.content.getVideoEmbedCode();
			
			/*if (! embedCode) {
				ErrorHandler.alertError("This YouTube video is not enabled for embedding. Please enable it for embedding or choose another YouTube video.");
				return;
			}*/
			
			super.assetLoadedHandler(event);
		}	
		
		
		protected function _stopHandler(event:Event)
		{
			//this.ns.pause();
			
			this.assetCmpnt.pause();
			
			//this._isPlaying = false;
		}
		
		
		public override function setProperties(properties:Object, currentFrame:int=undefined) 
		{
			
			var isPlaying:Boolean = false;
			var playerState:int = assetCmpnt.loader.content.getPlayerState();
			if (playerState == 1) {
				isPlaying = true;
			}
			
			var embedCode:String = assetCmpnt.loader.content.getVideoEmbedCode();
			
			
			if (assetEnabled && this.theMovie) {	
				if (this.theMovie.isPlaying) 
				{
					// we need the isPlaying flag, because we don't want to start again if it's already playing
					if (! isPlaying)
					//if (true)
					{
						var offset:int = ((currentFrame - this.firstFrame) / Application.application.stage.frameRate);
						
						trace("seeking to"+ offset);
						this.assetCmpnt.seekTo(offset);
						this.assetCmpnt.play();
						
						
						//this.ns.seek(offset / 1000);
						//this.ns.resume();
						//this._isPlaying = true;
					} 
					
				} else {
					var offset:int = ((currentFrame - this.firstFrame) / Application.application.stage.frameRate);
					
					trace("seeking to" + offset);
					this.assetCmpnt.seekTo(offset);
					//this.ns.seek(offset / 1000);
					
				}
			}
			
			super.setProperties(properties, currentFrame);
		}
			


	}
}
