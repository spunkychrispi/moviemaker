package movie.assets
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import movie.movie.Movie;
	import movie.movie.MovieEvent;
	import movie.util.ErrorHandler;
	
	import mx.core.Application;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	
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
		
		protected var initialAssetBuffering:Boolean;	// flag is set when the movie starts buffering for the
														// first time, that way we know to call the assetloaded
														// handlers on the first play/pause state after the buffering
														// state
		protected var movieStoppedForBuffering:Boolean;	// when the youtube movie is buffering, stop the main movie
														// and set this flag so this asset will know that the main movie
														// stopped for buffering, and so when the main movie stops all the
														// other assets, this one won't get stopped as well
	
		public function YouTubeAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "YouTube";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			initialAssetBuffering = false;
			movieStoppedForBuffering = false;
			
			//this._isPlaying = false;	
			
			properties.fullscreen = true;
			properties.hardcodedZIndex = 0;
			
			super(name, properties, assetClass);
		}
		
		
		protected override function _initCCHandler(event:FlexEvent)
		{
			
			//width = 320;	// default size from youtube
			//height = 240;
			
			// hack to get the width and height set before the assetLoaded handler is called
			// we want youtube to be visible before it is loaded so that users can see the buffering
			// youtube symbol - that means we have to set the width and height before they are usually 
			// set in the assetLoaded handler
			width = Application.application.stageWidth;
			height = Application.application.stageHeight;
			
			if (_constructorProperties.loadData) {
				trace("youtube player loaded");
				assetCmpnt = _constructorProperties.loadData;
				assetCmpnt.videoID = 0;
				onLoaderInit();
			} else {
				trace("loading youtube player");
				assetCmpnt = new YouTubePlayer();
				//Application.application.showProgressBar(assetCmpnt.loader, true);
				assetCmpnt.loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
			}
			
			assetCmpnt.videoID = _constructorProperties.assetPath;
			assetCmpnt.width = width;
			assetCmpnt.height = height;
			
			addEventListener(DragEvent.DRAG_ENTER, _dragTest, true);
			addEventListener(MouseEvent.CLICK, _mouseClick, true);
			addEventListener(MouseEvent.MOUSE_MOVE, _mouseClick, true);
			addEventListener(MouseEvent.MOUSE_OVER, _mouseClick, true);
			
			Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			
			super._initCCHandler(event);
		}
		
		public override function _dragTest(event:Event) {
			trace("cmpnt hello");
			event.stopImmediatePropagation();
		}
		
		public override function _mouseClick(event:Event) {
			trace("cmpnt " + event.type);
			event.stopImmediatePropagation();
		}
		
	
		
		protected function onLoaderInit(event:Event=null) {
			assetCmpnt.addEventListener(MovieEvent.YOUTUBE_PLAYER_READY, youTubeOnReadyHandler);
			assetCmpnt.loader.content.addEventListener("onError", youTubeErrorHandler);
			assetCmpnt.loader.content.addEventListener("onReady", youTubeReadyAHandler);
			assetCmpnt.loader.content.addEventListener("onStateChange", youTubeStateChangeHandler);
			
			//assetCmpnt.play();
			
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
		
		
		function youTubeReadyAHandler(event:*) {
			trace("onReady event called");
			visible = true;
		}
		
		function youTubeOnReadyHandler(event:*) {
			
			//assetCmpnt.play();
			trace("youtubeplay moveEvent called");
			//assetCmpnt.loader.content.addEventListener("onStateChange", youTubeStateChangeHandler);
			
			//assetCmpnt.seekTo(0, true);
			//assetLoadedHandler();
		}
		
		protected function youTubeStateChangeHandler(event:*) {
	
			trace("youtube state change");
			trace(event.data);		
			// determine initial buffering and loaded states
			switch (event.data) {
				case 3:  //buffering
					if (! assetLoaded) {
						trace("setting intialAssetBuffering flag");
						initialAssetBuffering = true;
						//trace("duration at buffering:"+assetCmpnt.loader.content.getDuration());
					}
					break;
				case 1: 
				case 2:
					if (initialAssetBuffering) {
						trace("calling asset loaded");
						initialAssetBuffering = false;
						assetLoadedHandler();
						trace("duration at pause/play:"+assetCmpnt.loader.content.getDuration());
					}
					break;
			}
			
			if (assetLoaded) {
				// pause/play movie during buffering so that the movie isn't playing
				// while youtube is buffering
				switch (event.data) {
					case 1: // playing
						if (!theMovie.isPlaying) {
							theMovie.play();
						}
						break;
					case 3:	// buffering
					default:
						trace("pausing movie for youtube");
						//if (theMovie.isPlaying) {
						if (true) {
							trace("doing pause");
							movieStoppedForBuffering = true;
							theMovie.stop();
						}
						break;
				}
			}
				
		}
		
		function youTubeErrorHandler(event:*) {
				
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
		
		
		/*protected override function _initCCHandler(event:FlexEvent) {
			// set the mouse handlers here as well - for some reason the ones set in the super class
			// are not getting called for the youtube asset
			
			//assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_DOWN, this._mouseDownHandler);
			//assetCmpnt.loader.content.addEventListener(MouseEvent.MOUSE_UP, this._mouseUpHandler);
			//assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OVER, this._mouseRollOverHandler);
			//assetCmpnt.loader.content.addEventListener(MouseEvent.ROLL_OUT, this._mouseRollOutHandler);
			
			super._initCCHandler(event);
		}*/
		
		
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
			
			if (movieStoppedForBuffering) {
				movieStoppedForBuffering = false;
			} else {
				this.assetCmpnt.pause();
			}
			
			//this._isPlaying = false;
		}
		
		
		public override function setProperties(properties:Object, currentFrame:int=undefined) 
		{
			
			if (assetLoaded) {
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
							var offset:int = ((currentFrame - this.firstFrame) / Movie.movie.frameRate);
							
							//trace("seeking to"+ offset);
							//trace("NOT SEEKING TO");
							//this.assetCmpnt.seekTo(offset);  
							this.assetCmpnt.play();
							
							
							//this.ns.seek(offset / 1000);
							//this.ns.resume();
							//this._isPlaying = true;
						} 
						
					} else {
						var offset:int = ((currentFrame - this.firstFrame) / Movie.movie.frameRate);
						
						trace("seeking to" + offset);
						this.assetCmpnt.seekTo(offset, true);
						//this.ns.seek(offset / 1000);
						
					}
				}
			}
			
			super.setProperties(properties, currentFrame);
		}
		
		
		public function doPlay() {
			this.assetCmpnt.play();
		}
			

		public override function get duration():Number {
			
			var duration:Number;
			if (assetLoaded) {
				duration = assetCmpnt.player.getDuration();
			} else {
				duration = 0;
			}
			return duration;
		}
		

		public function get player():Object {
			if (assetCmpnt) {
				return assetCmpnt.player;
			}
			return null;
		}

	}
}
