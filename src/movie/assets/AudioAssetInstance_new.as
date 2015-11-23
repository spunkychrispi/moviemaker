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
		
		public function AudioAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "Audio";
			this._tweenPropertiesList = [];
			this._statePropertiesList = ["centerX", "centerY"];
			
			numberAudioAssets++;
			
			_floater = true;
			
			widgetControls = [];
					
			super(name, properties, assetClass);
			
		}
		
		
		protected override function _initCCHandler(event:FlexEvent)
		{
			this._isPlaying = false;	
			
			
			this.assetCmpnt = new AudioAssetInstanceCmpnt();
			// we are not listening for when the audio icon is loaded - concerned with the mp3 at the moment
			//assetCmpnt.addEventListener(Event.COMPLETE, assetLoadedHandler);
			
			this._makeUndraggable();
			
			super._initCCHandler(event);
			
			if (_constructorProperties.loadData) {
				this._theAudio = _constructorProperties.loadData;
				this._originalBytes = _constructorProperties.loadBytes;
				
				assetLoadedHandler();
			} else {
				var req:URLRequest = new URLRequest(_constructorProperties.assetPath);
				this._theAudio = new Sound(req);
				
				_theAudio.addEventListener(ProgressEvent.PROGRESS, audioProgressHandler);
				
			}
		}
		
		
		protected function audioProgressHandler(event:Event) {
			
			if (_theAudio.isBuffering) {
			//if (_theAudio.bytesLoaded < _theAudio.bytesTotal) {
				//trace("loading audio" + _theAudio.bytesLoaded + " < " + _theAudio.bytesTotal);
			} else {
				_theAudio.removeEventListener(ProgressEvent.PROGRESS, audioProgressHandler);
				assetLoadedHandler();
			}
		}
		
		
		protected override function assetLoadedHandler(event:Event=null) {
						
			Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			
			_initializeProperties.centerX = width/2 + 10;
			_initializeProperties.centerY = height/2 + 10 + ((height + 10) * (numberAudioAssets - 1))
			
			super.assetLoadedHandler(event);
		}
		
		
		public override function get duration():Number {
			
			if (assetLoaded) {
				return _theAudio.length / 1000;
			} else {
				return 0;
			}
		}
	
		
		protected function _stopHandler(event:Event)
		{
			//if (this._soundChannel) this._soundChannel.stop();
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
				this.visible = offset <= this._theAudio.length ? true : false;
			} else {
				visible = false;
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



