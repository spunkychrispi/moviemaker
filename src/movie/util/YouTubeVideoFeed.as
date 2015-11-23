package movie.util
{
	import flash.events.EventDispatcher;
	
	/** Retrieve the first thumbnail for a video, give its id
	 */
	public class YouTubeVideoFeed extends EventDispatcher
	{
		import flash.events.Event;
		import flash.net.URLLoader;
		import flash.net.URLRequest;
		
		var feedXML:XML;
		var videoID:String;
		
		
		public function YouTubeVideoFeed()
		{
		}
		
		
		public function getFeed(videoID:String) {
			
			this.videoID = videoID;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoaded);
			loader.load(new URLRequest("http://gdata.youtube.com/feeds/videos/"+videoID));
		}

			
		function onLoaded(event:Event):void
		{
			feedXML = new XML(event.target.data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function getThumbnailURL(getLargeThumbnail:Boolean=false) {
			if (getLargeThumbnail) {
				return feedXML..*::thumbnail[3].@url;
			} else {
				return feedXML..*::thumbnail[0].@url;
			}
		}
 

	}
}