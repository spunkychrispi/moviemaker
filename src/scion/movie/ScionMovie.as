package scion.movie
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import movie.assets.*;
	import movie.movie.Movie;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	import scion.components.ScionAssetWidget;
		

	public class ScionMovie extends Movie 
	{
		
		// keep tabs of the assets currently being used so that we may poll their duration,
		// among other things
		public var theScionFXAssetInstance:AssetInstance;
		//public var theScionFX2AssetInstance:ScionFX2AssetInstance;
		public var theYouTubeAssetInstance:YouTubeAssetInstance;
		public var theAudioAssetInstance:AudioAssetInstance;
		public var theImageAssetInstance:ImageAssetInstance;
		
		public var theControlWidget:AssetWidgetManager;
		
		public var FXText:String;
		
		public var thumbnailLarge:ByteArray;
		public var thumbnailLargest:ByteArray;
		
		// place the first text asset on the first frame, for the proceeding ones, place 
		// whereever the movie is
		private var firstTextAsset = true;
		
		
		public function ScionMovie(stage:UIComponent, controlPanel:UIComponent, numberOfFrames:int, frameRate:int)
		{
			var widgetCmpnt:ScionAssetWidget = new ScionAssetWidget();
			theControlWidget = new AssetWidgetManager(widgetCmpnt);
			
			super(stage, controlPanel, numberOfFrames, frameRate);
		}
		
		
		/**
		 * When we add an asset to the movie, preview the asset by making the other assets
		 * invisible and playing the movie.
		 */
		public override function addAssetToMovie(assetName:String, asset:AssetInstance) {
			
			// disable all the current assets
			// turn this off for right now - if we turn it on again, we'll need to keep
			// from disabling the text fx when the user adds another text fx.
			/*var assets:Array = getAssets();
			for each (var assetToDisable:* in assets) {
				disableAsset(assetToDisable);
			}*/
						
			stop();
			
			// add the textFX wherever the playhead is
			// for the rest, add to the beginning of the movie
			if (asset.type!="ScionTextFX") {
				goToFrame(1);
				playCurrentFrame();
				
			} /*else if (firstTextAsset) {
				goToFrame(1);
				firstTextAsset = false;
			}*/
						
			addAssetToCurrentFrame(assetName, asset);
			
		}
		
		/**
		 * When any state is saved, set the movieSaved flag to false.
		 */
		public override function captureAssetAtCurrentFrame(asset:AssetInstance) {
			Application.application.movieChangesSaved = false;
			super.captureAssetAtCurrentFrame(asset);
		}
		
		
		protected override function onAssetComplete(asset:AssetInstance) {
			
			//trace("asset complete: playing movie");
			switch(asset.type) {
				case "ScionFX":
				case "ScionFX2":
					if (theScionFXAssetInstance!=null) {
						Movie.movie.removeAsset(theScionFXAssetInstance);
					}
					//theScionFXAssetInstance = asset as ScionFXAssetInstance;
					theScionFXAssetInstance = asset;
					break;
				case "YouTube":
					theYouTubeAssetInstance = asset as YouTubeAssetInstance;
					dispatchEvent(new ScionMovieEvent(ScionMovieEvent.YOUTUBE_ASSET_CHANGED));
					break;
				case "Audio":
				case "ScionAudio":
					if (theAudioAssetInstance!=null) {
						theAudioAssetInstance.deleteAsset();
					}
					theAudioAssetInstance = asset as AudioAssetInstance;
					dispatchEvent(new Event(ScionMovieEvent.AUDIO_ASSET_ADDED));
					break;
				case "Image":
				case "ScionImage":
					theYouTubeAssetInstance = null;
					theImageAssetInstance = asset as ImageAssetInstance;
					dispatchEvent(new ScionMovieEvent(ScionMovieEvent.YOUTUBE_ASSET_CHANGED));
					break;
			}
			
			setMovieDuration();
			
			// when the asset is finished loading in the movie, play the movie.
			if (asset.type=="ScionFX" || asset.type=="ScionFX2" || asset.type=="ScionAudio" || asset.type=="YouTube" || asset.type=="ScionImage") {
				play();
			}
			
			super.onAssetComplete(asset);
		}
		
		
		/**
		 * Override this function that is part of the movie loading so that we
		 * can set the youtube asset so that the youtubeProgressBar will catch
		 * the youTubeAssetChangedEvent
		 */
		protected override function loadAsset(event:Event=null) {
			
			if (assetsToLoad.length>0 && assetsToLoad[0].type == "YouTube") {
				
				assetsToLoad[0].addEventListener(AssetEvent.ASSET_COMPLETE, youTubeLoadedHandler);
			}
			
			super.loadAsset(event);
		}
		
		
		protected function youTubeLoadedHandler(event:Event) {
			theYouTubeAssetInstance = event.target as YouTubeAssetInstance;
			dispatchEvent(new ScionMovieEvent(ScionMovieEvent.YOUTUBE_ASSET_CHANGED));
		}
		
		
		/**
		 * Play the entire movie from the beginning, with all the assets enabled
		 */
		public function playAll() {
			
			for each (var asset:AssetInstance in getAssets()) {
				enableAsset(asset);
			}
			
			// not sure why I have to call playCurrentFrame in order to get the youtube
			// movie to start from the beginning
			stop();
			goToFrame(1);
			playCurrentFrame();
			play();
		}
		
		
		/**
		 * Start playing the youtube movie first. When that has started playing, it will call
		 * play on the movie again. So if the youtube movie is already playing, then pass the
		 * play call to the parent movie class.
		 */
		public override function play(playFromBeginning:Boolean=false) {
			
			var callSuper = true;
			if (theYouTubeAssetInstance && theYouTubeAssetInstance.assetEnabled) {
				
				var player:Object = theYouTubeAssetInstance.player;
				if (player && player.getPlayerState()!=1) {
					theYouTubeAssetInstance.doPlay();
					_stage.addEventListener(Event.ENTER_FRAME, this.checkYouTubePlayingHandler);
					callSuper = false;
					
				} else {
					_stage.removeEventListener(Event.ENTER_FRAME, this.checkYouTubePlayingHandler);
					callSuper = true;
				}
			} 
			
			if (callSuper) super.play(playFromBeginning);
		}
		
		
		
		/**
		 * If the user hits delete, only delete the asset if it's a textFx asset.
		 */
		 public override function removeAsset(asset:*, frame:int=0, userRequestedDelete:Boolean=false) 
		 {
		 	if (userRequestedDelete && asset.type!="ScionTextFX") return;
		 	
		 	super.removeAsset(asset, frame, userRequestedDelete);
		 }
				
				
		function checkYouTubePlayingHandler(event:Event) {
			play();
		}
		
		
		
		public override function set mode(mode:String)
		{
			if (mode=='preview') {
				if (_selectedAsset!=null) {
					_selectedAsset.unSelect();
				}
			}
			super.mode = mode;
		}
		
		
		/**
		 * Set the duration of the movie depending on what assets are loaded. If there is a 
		 * YouTube asset, set to the duration of the YouTube asset. Otherwise, set to the duration
		 * of either the audio or fx, whichever is greater. Set duration minimum to be 20s.
		 */
		protected var durationMin:Number = 20;
		protected var duration:Number;
		protected var timer:Timer;
		
		public function setMovieDuration() {
			
			var useAudioDuration = false;
			
			var youTubeDuration:Number = theYouTubeAssetInstance ? theYouTubeAssetInstance.duration : 0;
			var audioDuration:Number = theAudioAssetInstance ? theAudioAssetInstance.duration : 0;
			var fxDuration:Number = theScionFXAssetInstance ? theScionFXAssetInstance.duration : 0;
			
			/*if (theYouTubeAssetInstance) {
				duration = theYouTubeAssetInstance.duration;
			} else {

				// get the longest of the audio or the swf			
				var audioDuration = */
				
			if (youTubeDuration) {
				duration = youTubeDuration;
			} else if (audioDuration > fxDuration) {
				duration = audioDuration;
				useAudioDuration = true;
			} else {
				duration = fxDuration;
			}
			if (!youTubeDuration && (! duration || duration < durationMin)) duration = durationMin;
				
			numberOfFrames = Math.ceil(duration * frameRate);
			
			/*if (useAudioDuration && ! theAudioAssetInstance.soundCompletelyLoaded) {
				
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER, setMovieDurationFromAudio);
				timer.start();
			}*/
		}
		
		
		public override function resetState() {
			//setMovieDuration();
			numberOfFrames = 20*frameRate;
			super.resetState();
			
			theScionFXAssetInstance = null;
			theYouTubeAssetInstance = null;
			theAudioAssetInstance = null;
			theImageAssetInstance = null;
		}

		// keep on setting the duration as long as the audio is still loading
		/*protected function setMovieDurationFromAudio(event:TimerEvent) {
			trace("setting duration from audio");
			duration = theAudioAssetInstance.duration;
			numberOfFrames = Math.ceil(duration * frameRate);
			
			if (theAudioAssetInstance.soundCompletelyLoaded) {
				timer.stop();
			}
		}*/
			
		
		
		
		/*public override function reset() {
		
			// set all the asset pointers to null
			theScionFXAssetInstance = null;
			theYouTubeAssetInstance = null;
			theAudioAssetInstance = null;
			theImageAssetInstance = null;
			
			super.reset();
		}*/
		
		
		
		/* This funcionality is now in the ScionTextFXAssetInstance and the
		text tab of the maker component
			public function setFXText(text:String) {
			FXText = text;
			sendFXText();
		}
		
		protected function sendFXText() {
			if (theScionFXAssetInstance) {
				theScionFXAssetInstance.setFXText(FXText);
			}
		}*/
		
	
	}
}