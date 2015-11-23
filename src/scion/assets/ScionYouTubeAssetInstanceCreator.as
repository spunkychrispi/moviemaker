package scion.assets
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import movie.assets.YouTubeAssetInstanceCreator;
	import movie.util.ImageProcessor;
	import movie.util.YouTubeVideoFeed;
	
	import mx.core.Application;



	/**
	 * Creates the thumbnail from the image bytearray
	 */
	public class ScionYouTubeAssetInstanceCreator extends YouTubeAssetInstanceCreator
	{
					
		var thumbnailHeight:int;
		var thumbnailWidth:int;
		public var thumbnail:ByteArray;	
		var videoFeed:YouTubeVideoFeed;	
		
		
		public function ScionYouTubeAssetInstanceCreator(type:String="ScionImage")
		{
			super(type);
			
			thumbnailWidth = Application.application.thumbnailWidth;
			thumbnailHeight = Application.application.thumbnailHeight;
		}
		
		
		
			// create the thumbnail for the movie
			// DEPRECATED - make the thumbnail when the movie gets saved
		/*protected override function assetCreatedHandler() {
			// hijack the parent's assetCreated dispatcher so that we can create the
			// thumbnail
			
			videoFeed = new YouTubeVideoFeed();
			videoFeed.addEventListener(Event.COMPLETE, onFeedLoaded);
			videoFeed.getFeed(name);
			
		}
		
		
		protected function onFeedLoaded(event:Event) {
			
			var thumbnailURL:String = videoFeed.getThumbnailURL();
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onThumbnailLoaded);
			loader.load(new URLRequest(thumbnailURL));
		}
		
		
		
		var imageProcessor:ImageProcessor;
		
		protected function onThumbnailLoaded(event:Event) {
			var loader:URLLoader = event.target as URLLoader;
			
			imageProcessor = new ImageProcessor();
			imageProcessor.addEventListener(Event.COMPLETE, completeHandler);
			imageProcessor.loadByteArray(loader.data);
		}
		
		public function completeHandler(event:Event) {
			
			// some of the older youtube thumbnails are larger, so shrink those first
			imageProcessor.minimizeImage(Application.application.thumbnailWidth, imageProcessor.originalWidth);
			
			imageProcessor.cropImageCenter(Application.application.thumbnailWidth, Application.application.thumbnailHeight);
			thumbnail = imageProcessor.getJPGEncoding();
			
			super.assetCreatedHandler();
		}
		
		*/
	}
}