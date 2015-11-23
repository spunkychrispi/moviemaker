package scion.movie
{
	import flash.events.Event;

	public class ScionMovieEvent extends Event
	{
		
		public static const YOUTUBE_ASSET_CHANGED:String = "YouTubeAssetChanged";
		public static const AUDIO_ASSET_ADDED:String = "AudioAssetAdded";
		
		public var currentFrame:Number;
		
		public function ScionMovieEvent(type:String, currentFrame:Number=undefined, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.currentFrame = currentFrame;
			
			super(type, bubbles, cancelable);
		}
		
	}
}