package movie.assets
{
	
	import flash.events.*;
	import flash.net.*;

	
	
	/**
	 * Creates youtube asset from provided youtube id
	 */
	public class YouTubeAssetClassCreator extends EventDispatcher
	{
		
		protected var name:String;
		
		
		public function YouTubeAssetClassCreator(youTubeID:String)
		{
			this.name = youTubeID;
		}
		
		
		public function initialize() {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		public function createClass():AssetClass
		{	
			
            
			// now create the class and return it 
			var youTubeClass:AssetClass = new AssetClass(name, "ScionYouTube", null, null, {assetPath:name});
            return youTubeClass;
 		}

	}
}			