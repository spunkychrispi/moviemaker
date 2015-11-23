package movie.assets
{
	import movie.movie.Movie;
	
	import scion.movie.ScionMovie;
	import mx.core.Application;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	
	public class ScionAudioAssetInstance extends AudioAssetInstance
	{
		
		static var theAudioAsset:ScionAudioAssetInstance;
		
		protected var hardcoded_duration:Number;	// the duration for the canned assets needs to be set, because	
												// when we are loading the song from a url, we won't know the full
												// duration until the whole song is loaded, so just hardcode the duration
		
		public function ScionAudioAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			properties.hardcodedZIndex = 1;
			super(name, properties, assetClass);
			
			if (properties.duration) {
				hardcoded_duration = properties.duration;
			}
			
			// we only want one asset here at a time, so delete whatever is currently the asset
			var movie:ScionMovie = Movie.movie as ScionMovie;
			if (movie.theAudioAssetInstance) {
				//Application.application.theMovie.removeAsset(movie.theAudioAssetInstance);
			}
	
			_floater = false;
			type = "ScionAudio";
		}


		public override function setProperties(properties:Object, currentFrame:int=undefined) {
			
			super.setProperties(properties, currentFrame);
			
			if (assetLoaded) {
				assetCmpnt.visible = false;
			}
		}
		
		
		// completely override the original function - we don't want to call the assetLoaded for mode=maker
		// or mode=preview until the sound has fully loaded 
		/*protected override function audioProgressHandler(event:Event) {
			
			if (_theAudio.isBuffering) {
				//trace("loading audio" + _theAudio.bytesLoaded + " < " + _theAudio.bytesTotal);
			} else {
				
				if (Movie.movie.mode!='maker' && Movie.movie.mode!='preview') {
					_theAudio.removeEventListener(Event.COMPLETE, assetLoadedHandler);
					_theAudio.removeEventListener(ProgressEvent.PROGRESS, audioProgressHandler);
					Application.application.hideProgressBar();
					assetLoadedHandler();
				}
			}
		}*/
		
		
		public override function get duration():Number {
			
			if (! isNaN(hardcoded_duration)) {
				return hardcoded_duration;
			} else {
				return super.duration;
			}
		}
		
	}
}