package movie.assets
{
	
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import mx.core.Application;
	
	import mx.utils.URLUtil;
	
	import scion.util.ScionErrorHandler;
	
	/**
	 * Create an asset instance from a youtube url
	 */
	public class YouTubeAssetInstanceCreator extends EventDispatcher	{

		var youTubeInstance:YouTubeAssetInstance;
		var scionYouTubeInstance:ScionYouTubeAssetInstance;
		
		var type:String;
		
		public var error:String;
		
		protected var name:String;
		
		private var _asset:YouTubeAssetInstance;
		
		public function YouTubeAssetInstanceCreator(type:String="YouTube") {
			this.type = type;
		}
		
		
		public function get asset() {
			return _asset;
		}
		

		public function createInstanceFromURL(url:String) {
			
			// parse the youtube id from the string
			// use the urlutils object, so first, get the parameters string
			var paramsString:String = url.substr(url.indexOf("?")+1);
			var params:Object = URLUtil.stringToObject(paramsString, "&");
			var youTubeID = params.v;
			
			if (! youTubeID) {
				Application.application.hideProgressBar();
				ScionErrorHandler.makerAlert("YouTube ID cannot be found", "Please enter a valid url to the YouTube video", "Go Back");
				return;
			}
			
			name = youTubeID;
			
			var properties:Object = new Object();
			properties.assetPath = youTubeID;
			
			var className:String = "movie.assets."+type+"AssetInstance";
			var classVar:Class = getDefinitionByName( className ) as Class;
			_asset = new classVar(name, properties);
			//_asset = new ScionAudioAssetInstance("test", properties);
		
			assetCreatedHandler();
		}
		
		protected function assetCreatedHandler() {
			
		    this.dispatchEvent(new AssetEvent(AssetEvent.ASSET_CREATED));
		}
			
	}
}



