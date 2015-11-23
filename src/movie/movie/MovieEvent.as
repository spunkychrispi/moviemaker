package movie.movie
{
	import flash.events.Event;

	public class MovieEvent extends Event
	{
		
		public static const MOVIE_START:String = "MovieStart";
		public static const MOVIE_STOP:String = "MovieStop";
		public static const MOVIE_FINISHED:String = "MovieFinished";
		public static const MOVIE_FRAME_CHANGE:String = "FrameChange";
		public static const MOVIE_DURATION_CHANGE:String = "DurationChange";
		public static const MOVIE_LOADED:String = "MovieLoaded";
		
		public static const MOVIE_CREATED:String = "MovieCreated";
		
		public static const ASSET_SELECTED:String = "AssetSelected";
		public static const ASSET_DESELECTED:String = "AssetDeselected";
		
		public static const YOUTUBE_PLAYER_READY:String ="YouTubePlayerReady";
		
		public var currentFrame:Number;
		
		public function MovieEvent(type:String, currentFrame:Number=undefined, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.currentFrame = currentFrame;
			
			super(type, bubbles, cancelable);
		}
		
	}
}