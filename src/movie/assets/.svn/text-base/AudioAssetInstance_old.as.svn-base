package movie.assets
{
	import flash.events.Event;
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
			
			if (properties.loadData) {
				this._theAudio = properties.loadData;
				this._originalBytes = properties.loadBytes;
			} else {
				var req:URLRequest = new URLRequest(properties.assetPath);
				this._theAudio = new Sound(req);
			}
			this._isPlaying = false;
			//this.assetCmpnt = new ImageAssetInstanceCmpnt();		
			
			_floater = true;
			
			Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			
			widgetControls = [];
					
			super(name, properties, assetClass);
			
			this.assetCmpnt = new AudioAssetInstanceCmpnt();
			assetCmpnt.addEventListener(FlexEvent.CREATION_COMPLETE, assetLoadedHandler);
		}
		
		
		protected override function _initCCHandler(event:FlexEvent)
		{
			
			
			super._initCCHandler(event);
			
			this._makeUndraggable();
		}
		
		
		protected override function assetLoadedHandler(event:Event=null) {
			
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
			this.visible = offset <= this._theAudio.length ? true : false;
				
			if (assetEnabled && this.theMovie && this.theMovie.isPlaying) 
			{
				// we need the isPlaying flag, because we don't want to start the sound again if it's already playing
				if (! this._isPlaying)
				{
					// if the offset isn't greater than the length of the sound
					if (offset <= this._theAudio.length)
					{
						//this._soundChannel = this._theAudio.play(offset);
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



