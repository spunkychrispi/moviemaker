package movie.assets
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import movie.movie.*;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	public class AudioAssetInstance extends AssetInstance
	{
		
		protected static var numberAudioAssets = 0;
		
		protected var _theAudio:Sound;
		protected var _soundChannel:SoundChannel;
		protected var _isPlaying;
		protected var _originalBytes:ByteArray;		// stores the original bytes when loaded from load data
													// so they can be saved to a file
													
		/**
		 * Used when returning the duration - if the sound is done buffering, but not completely loaded, sound.length
		 * is only the length of the currently loaded bytes, not of the entire sound.
		 */
		protected var _soundCompletelyLoaded:Boolean = false;
		
		public function AudioAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "Audio";
			this._tweenPropertiesList = [];
			this._statePropertiesList = ["centerX", "centerY"];
			
			numberAudioAssets++;
			
			_floater = true;
			
			widgetControls = [];
					
			super(name, properties, assetClass);
			
			setAssetComponent(new AudioAssetInstanceCmpnt());
		}
		
		
		protected override function _initCCHandler(event:FlexEvent)
		{
			this._isPlaying = false;	
			
			// we are not listening for when the audio icon is loaded - concerned with the mp3 at the moment
			//assetCmpnt.addEventListener(Event.COMPLETE, assetLoadedHandler);
			
			this._makeUndraggable();
			
			super._initCCHandler(event);
			
			if (_constructorProperties.loadData) {
				this._theAudio = _constructorProperties.loadData;
				this._originalBytes = _constructorProperties.loadBytes;
				_soundCompletelyLoaded = true;
				
				assetLoadedHandler();
			} else {
				
				var req:URLRequest = new URLRequest(_constructorProperties.assetPath);
				this._theAudio = new Sound(req);
				Application.application.showProgressBar(_theAudio, "loading audio");
				
				/* The asset is loaded with the isBuffering value is false. For long asset files
				  this will happen in the ProgressEvent, since the asset will be done buffering 
				  long before it's completely loaded.
				  For short files, the asset might be completely loaded and the ProgressEvent
				  might never get called with an isBuffering value of false, so we have
				  to use both these handlers to check to see if the asset is loaded.
				 */
				_theAudio.addEventListener(ProgressEvent.PROGRESS, audioProgressHandler);
				_theAudio.addEventListener(Event.COMPLETE, assetLoadedHandler);
				
				// either way the assetLoadedHandler is called, set the assetComletelyLoaded flag
				// when the complete event is thrown
				_theAudio.addEventListener(Event.COMPLETE, soundCompletelyLoadedHandler);
			}
		}
		
		
		protected function audioProgressHandler(event:Event) {
			
			if (_theAudio.isBuffering) {
				//trace("loading audio" + _theAudio.bytesLoaded + " < " + _theAudio.bytesTotal);
			} else {
				_theAudio.removeEventListener(Event.COMPLETE, assetLoadedHandler);
				_theAudio.removeEventListener(ProgressEvent.PROGRESS, audioProgressHandler);
				
				Application.application.hideProgressBar();
				assetLoadedHandler();
			}
		}
		
		
		protected override function assetLoadedHandler(event:Event=null) {
						
			Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			
			_initializeProperties.centerX = assetCmpnt.width/2 + 10;
			_initializeProperties.centerY = assetCmpnt.height/2 + 10 + ((assetCmpnt.height + 10) * (numberAudioAssets - 1))
			
			super.assetLoadedHandler(event);
		}
		
		
		public override function deleteAsset()
		{
			stop();
			_theAudio = null;
			
			super.deleteAsset();
		}
		
		
		protected function soundCompletelyLoadedHandler(event:Event) {
			_soundCompletelyLoaded = true;
		}
		
		
		protected function set soundCompletelyLoaded(inValue:Boolean)
		{
			_soundCompletelyLoaded = inValue;
		}
		
		
		public function get soundCompletelyLoaded() 
		{
			return _soundCompletelyLoaded;
		}
		
		
		public override function get duration():Number {
			
			if (assetLoaded) {
				return _theAudio.length / 1000;
				//return 100;
			} else {
				return 0;
			}
		}
	
		
		protected function _stopHandler(event:Event)
		{
			stop();
		}
		
		
		public function stop() 
		{
			if (this._soundChannel) this._soundChannel.stop();
			this._isPlaying = false;
		}
		
		
		public override function setProperties(properties:Object, currentFrame:int=undefined) 
		{
			// get the time into the sound to start playing
			var offset:int = ((currentFrame - this.firstFrame + 1) / Movie.movie.frameRate) * 1000;
			
			//trace(Application.application.stage.frameRate);
			
			// show the icon regardless of whether the audio is playing or not, to indicate where the audio will
			// play if the movie is playing
			if (assetLoaded) {
				assetCmpnt.visible = offset <= this._theAudio.length ? true : false;
			} else {
				assetCmpnt.visible = false;
			}
				
			if (assetLoaded && assetEnabled && this.theMovie && this.theMovie.isPlaying) 
			{
				// we need the isPlaying flag, because we don't want to start the sound again if it's already playing
				if (! this._isPlaying)
				{
					// if the offset isn't greater than the length of the sound
					if (offset <= this._theAudio.length)
					{
						/*if (_soundChannel) {
							_soundChannel.stop();
						}*/
							
						this._soundChannel = this._theAudio.play(offset);
						this._isPlaying = true;
					}
				} 
				else	// if the sound is already playing
				{
					// hide the icon if the sound has stopped
					if (offset > this._theAudio.length)
					{
						this._isPlaying = false;
					}
				}
			}
			
			super.setProperties(properties, currentFrame);
		}
		
		
		public function get byteSource() {
			return _originalBytes;
		}
		
	}
}



