package movie.assets
{
	import flash.events.Event;
	
	public class ScionYouTubeAssetInstance extends YouTubeAssetInstance
	{
		import mx.core.Application;
		import nl.flexcoders.controls.YouTubePlayer;
		import movie.movie.Movie;
		import scion.movie.ScionMovie;
				
		public static var youTubePlayer:YouTubePlayer; // holds the player if it has already been loaded
		
		public function ScionYouTubeAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			properties.fullscreen = true;
			properties.hardcodedZIndex = 0;
						
			if (ScionYouTubeAssetInstance.youTubePlayer) {
				
				// remove the previous listeners, so we don't add them twice
				// hack!
				if (ScionMovie(Movie.movie).theYouTubeAssetInstance!=null) {
					ScionMovie(Movie.movie).theYouTubeAssetInstance.removeListeners();
				}
				
				properties.loadData = youTubePlayer.loader;
			}
			
			super(name, properties, assetClass);
		}
		
		
		/**
		 * After the youtube player has initialized, save it for reuse
		 */
		protected override function onLoaderInit(event:Event=null) {
			ScionYouTubeAssetInstance.youTubePlayer = assetCmpnt;
			super.onLoaderInit(event);
		}
		
		
		/*protected override function youTubeStateChangeHandler(event:*) {
			
			var duration:int = assetCmpnt.player.getDuration();
			
			if (duration) {
				theMovie.setDuration(duration);
			}
			super.youTubeStateChangedHandler(event);
		}*/
		
		override function youTubeErrorHandler(event:*) 
		{
			super.youTubeErrorHandler(event);
			
			// if there is an error before the asset has been loaded, remove the listeners - as the asset won't get
			// loaded and we don't want them as they will interfere with other assets using the same assetCmpnt
			if (! assetLoaded) {
				removeListeners();
			}
		}
		
		public function createThumbnailSmall()
		{
			super.createThumbnail(Application.application.thumbnailWidth, Application.application.thumbnailHeight);
		}
		
		
		public function createThumbnailLarge() 
		{
			super.createThumbnail(Application.application.thumbnailWidthLarge, Application.application.thumbnailHeightLarge, true);
		}
		
		public function createThumbnailLargest() 
		{
			super.createThumbnail(Application.application.thumbnailWidthLargest, Application.application.thumbnailHeightLargest, true);
		}
			
	}
}