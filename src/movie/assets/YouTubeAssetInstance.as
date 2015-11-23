package movie.assets
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import movie.movie.Movie;
	import movie.movie.MovieEvent;
	import movie.util.ImageProcessor;
	import movie.util.YouTubeVideoFeed;
	
	import mx.core.Application;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	
	import nl.flexcoders.controls.YouTubePlayer;
	
	import scion.util.ScionErrorHandler;
	
	
			
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
														
		protected var preBuffered:Boolean;				// flag if the video has already been loaded and buffered, this is
														// for when users upload or select the same video twice, we'll
														// know when to call the asset loaded handler
														
		/**
		 * Sometimes when the youtube stops to buffer, after it's done buffering, it goes into a pause state, even
		 * though the main movie had been playing before. So save the previous state of the movie so we can go 
		 * back to it when the youtube is done buffering.
		 */
		protected var movieStateBeforeBuffering:String;	
		
		// thumbnail vars
		protected var _thumbnailWidth;
		protected var _thumbnailHeight;
		protected var _thumbnail:ByteArray;
		protected var videoFeed:YouTubeVideoFeed;
		protected var fromLargeThumbnail:Boolean;
		protected var imageProcessor:ImageProcessor;
					
	
		public function YouTubeAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "YouTube";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			initialAssetBuffering = false;
			movieStoppedForBuffering = false;
			movieStateBeforeBuffering = null;
			
			//this._isPlaying = false;	
			
			Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			
			properties.fullscreen = true;
			properties.hardcodedZIndex = 0;
			
			super(name, properties, assetClass);
			
			//width = 320;	// default size from youtube
			//height = 240;
			
			// hack to get the width and height set before the assetLoaded handler is called
			// we want youtube to be visible before it is loaded so that users can see the buffering
			// youtube symbol - that means we have to set the width and height before they are usually 
			// set in the assetLoaded handler
			//width = Application.application.stageWidth;
			//height = Application.application.stageHeight;
			
			if (properties.loadData) {
			//if (false) {
				//trace("youtube player loaded");
				//assetCmpnt = properties.loadData;
				
				// commenting out the proceeding line keeps a getVideoInfo unhandled error exception
				// from being thrown - not sure what this line is for anyway
				//assetCmpnt.videoID = 0;
				
				assetCmpnt = new MovieYouTubePlayer();
				assetCmpnt.loader = properties.loadData;
				
		
				onLoaderInit();
			} else {
				//trace("loading youtube player");
				assetCmpnt = new MovieYouTubePlayer();
				Application.application.showProgressBar(assetCmpnt.loader.contentLoaderInfo, "loading YouTube player", true);
				assetCmpnt.loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
			}
			
			preBuffered = (assetCmpnt.videoID == properties.assetPath) ? true : false;
			assetCmpnt.videoID = properties.assetPath;
			//assetCmpnt.width = width;
			//assetCmpnt.height = height;
			
			setAssetComponent(assetCmpnt);
			
			addEventListener(DragEvent.DRAG_ENTER, _dragTest, true);
			addEventListener(MouseEvent.CLICK, _mouseClick, true);
			addEventListener(MouseEvent.MOUSE_MOVE, _mouseClick, true);
			addEventListener(MouseEvent.MOUSE_OVER, _mouseClick, true);
		}
		
		public override function _dragTest(event:Event) {
			//trace("cmpnt hello");
			event.stopImmediatePropagation();
		}
		
		public override function _mouseClick(event:Event) {
			//trace("cmpnt " + event.type);
			event.stopImmediatePropagation();
		}
		
	
		
		protected function onLoaderInit(event:Event=null) {
			Application.application.hideProgressBar();
			assetCmpnt.addEventListener(MovieEvent.YOUTUBE_PLAYER_READY, youTubeOnReadyHandler);
			assetCmpnt.loader.content.addEventListener("onError", youTubeErrorHandler);
			assetCmpnt.loader.content.addEventListener("onReady", youTubeReadyAHandler);
			assetCmpnt.loader.content.addEventListener("onStateChange", youTubeStateChangeHandler);
			
			// hack to get the width and height set before the assetLoaded handler is called
			// we want youtube to be visible before it is loaded so that users can see the buffering
			// youtube symbol - that means we have to set the width and height before they are usually 
			// set in the assetLoaded handler
			assetCmpnt.width = Application.application.stageWidth;
			assetCmpnt.height = Application.application.stageHeight;
			
		}
		
		
		// hack to remove the listeners from the cmpnt so that we can reuse it
		public function removeListeners() {
			assetCmpnt.removeEventListener(MovieEvent.YOUTUBE_PLAYER_READY, youTubeOnReadyHandler);
			assetCmpnt.loader.content.removeEventListener("onError", youTubeErrorHandler);
			assetCmpnt.loader.content.removeEventListener("onReady", youTubeReadyAHandler);
			assetCmpnt.loader.content.removeEventListener("onStateChange", youTubeStateChangeHandler);		
		}
		
		
		function youTubeReadyAHandler(event:*) {
			//trace("onReady event called");
			assetCmpnt.visible = true;
		}
		
		function youTubeOnReadyHandler(event:*) {
			
			//assetCmpnt.play();
			//trace("youtubeplay moveEvent called");
			//assetCmpnt.loader.content.addEventListener("onStateChange", youTubeStateChangeHandler);
			
			//assetCmpnt.seekTo(0, true);
			//assetLoadedHandler();
		}
		
		
		/**
		 * Use the youtube player state change to determine when the movie is loaded and
		 * ready to play. After the movie has buffered and then is in a pause or play state, 
		 * the asset is loaded.
		 * After the asset is loaded, if the youtube player is buffering, pause the main movie
		 * until the player starts playing again.
		 * 
		 * The player states are:
		 * unstarted (-1), ended (0), playing (1), paused (2), buffering (3), video cued (5)
		 * Cued is not what I expected, and is only used when you are initiallly loading the youtube
		 * movie with a cue point.
		 */
		protected function youTubeStateChangeHandler(event:*) {
	
			/*trace("youtube state change");
			trace(event.data);	
			
			trace(assetCmpnt.player.getCurrentTime());
			trace(assetCmpnt.player.getDuration());*/
			
			//trace("movie status"+Application.application.theMovie.status);	
			// determine initial buffering and loaded states
			switch (event.data) {
				case 3:  //buffering
					if (! assetLoaded) {
						//trace("setting intialAssetBuffering flag");
						initialAssetBuffering = true;
						//trace("duration at buffering:"+assetCmpnt.loader.content.getDuration());
					}
					break;
				case 1: 
				case 2:
					if (initialAssetBuffering || preBuffered) {
						//trace("calling asset loaded");
						initialAssetBuffering = false;
						assetLoadedHandler();
						//trace("duration at pause/play:"+assetCmpnt.loader.content.getDuration());
					}
					break;
			}
			
			if (assetLoaded) {
				// pause/play movie during buffering so that the movie isn't playing
				// while youtube is buffering
				switch (event.data) {
					case 1: // playing
						movieStateBeforeBuffering = null;
						if (!theMovie.isPlaying) {
							theMovie.play();
						}
						break;
					case 2:
						if (movieStateBeforeBuffering=="playing") {
							theMovie.play();
						} else {
							// if the youtube movie is done playing, don't stop the main movie
							// in case they got out of sync and the main movie isn't finished yet
							if (assetCmpnt.player.getCurrentTime() < assetCmpnt.player.getDuration()) {
								theMovie.stop();
							}
						}
						movieStateBeforeBuffering = null;
						break;
					case 3:	// buffering
						//trace("pausing movie for youtube");
						//if (theMovie.isPlaying) {
						if (true) {
							//trace("doing pause");
							movieStoppedForBuffering = true;
							if (! movieStateBeforeBuffering) movieStateBeforeBuffering = theMovie.status;
							theMovie.stop();
						}
						break;
				}
			}
				
		}
		
		/**
		 * If there is an error, remove the asset from the movie.
		 */
		function youTubeErrorHandler(event:*) {
			
			var errorText:String;
			//trace(event.data);
			switch (event.data) {
				case 100:
					ScionErrorHandler.makerAlert("The requested video was not found", "It may have been removed or marked as private", "Go Back");
					break;
				case 101:
				case 150:
					ScionErrorHandler.makerAlert("Playback error", "The requested video does not allow playback in embedded players", "Go Back");
					break;
				default:
					ScionErrorHandler.makerAlert("An error ocurred with the requested video", "Please make sure you are entering the video URL", "Go Back");
			}
			
			// remove the video from the movie
			//theMovie.removeAsset(this);
			
			// for some reason this will get called again on future youtube errors for other youtube assets, so remove
			// the handler, as once there is an error, we remove the asset
			//assetCmpnt.loader.content.removeEventListener("onError", youTubeErrorHandler);
			
			
			//ErrorHandler.alertError("", errorText, "Go Back");
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
			
			//var embedCode:String = assetCmpnt.loader.content.getVideoEmbedCode();
			
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
		
		
		protected override function removeFromStageHandler(event:Event) {
			removeListeners();
			super.removeFromStageHandler(event);
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
						
						//trace("seeking to" + offset);
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
		
		
		
		/********************************** THUMBNAIL *************************************/
		
		
		public function createThumbnail(width:int, height:int, fromLargeThumbnail:Boolean=false)
		{
			if (assetCmpnt) {
				_thumbnailWidth = width;
				_thumbnailHeight = height;
				this.fromLargeThumbnail = fromLargeThumbnail;
				
				if (! videoFeed) {
					videoFeed = new YouTubeVideoFeed();
					videoFeed.addEventListener(Event.COMPLETE, onFeedLoaded);
					videoFeed.getFeed(initializeProperties.assetPath);
				} else {
					onFeedLoaded();
				}
			}
		}
		
		
		protected function onFeedLoaded(event:Event=null) {
			
			//var thumbnailURL:String = videoFeed.getThumbnailURL(fromLargeThumbnail);
			// always grab the larger thumbnail so that we can shrink and cut out the letterbox
			var thumbnailURL:String = videoFeed.getThumbnailURL(true);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onThumbnailLoaded);
			loader.load(new URLRequest(thumbnailURL));
		}
				
	
		protected function onThumbnailLoaded(event:Event) {
			var loader:URLLoader = event.target as URLLoader;
			
			imageProcessor = new ImageProcessor();
			imageProcessor.addEventListener(Event.COMPLETE, imageProcessorLoadedHandler);
			imageProcessor.loadByteArray(loader.data);
		}
		
		public function imageProcessorLoadedHandler(event:Event) {
			
			// some of the older youtube thumbnails are larger, so shrink those first
			if (fromLargeThumbnail) {
				// kind of a hack for the scion site - we don't want the letterbox to show on the larger
				// thumbnail - so don't minimize completely. This functionality should be in ScionYouTubeAssetInstance
				imageProcessor.minimizeImage(_thumbnailWidth*1.35, imageProcessor.originalWidth);
			} else {
				// and here as well - shrink a little under so that we cut out the letterbox
				imageProcessor.minimizeImage(_thumbnailWidth*1.17, imageProcessor.originalWidth);
			}
			
			imageProcessor.cropImageCenter(_thumbnailWidth, _thumbnailHeight);
			_thumbnail = imageProcessor.getJPGEncoding();
			dispatchEvent(new AssetEvent(AssetEvent.THUMBNAIL_READY));
		}
				
		public function get thumbnail() 
		{
			return _thumbnail;
		}		

	}
}
