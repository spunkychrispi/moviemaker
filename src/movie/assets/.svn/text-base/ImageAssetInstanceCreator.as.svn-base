package movie.assets
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import mx.core.Application;
	import movie.movie.Movie;
	import movie.util.ImageProcessor;
	
	
	/**
	 * Create an asset instance from a image filereference
	 */
	public class ImageAssetInstanceCreator extends EventDispatcher	{

		var imageInstance:ImageAssetInstance;
		var scionImageInstance:ScionImageAssetInstance;
		
		var type:String;
		var name:String;
		
		private var _asset:ImageAssetInstance;
		protected var imageProcessor:ImageProcessor;
		
		public function ImageAssetInstanceCreator(type:String="Image") {
			this.type = type;
		}
		
		public function get asset() {
			return _asset;
		}
		
		public function createInstanceFromFileReference(fileReference:FileReference) {
			
			name = fileReference.name;
			var imageData:ByteArray = fileReference.data;
			
			// shrink to the size of the stage
			// resize the asset
			imageProcessor = new ImageProcessor();
			imageProcessor.addEventListener(Event.COMPLETE, completeHandler);
			imageProcessor.loadByteArray(imageData);
		}
		
		public function completeHandler(event:Event) {
			
			var theMovie:Movie = Application.application.theMovie;
			imageProcessor.minimizeImage(theMovie.stageWidth, theMovie.stageHeight);
			var finalByteArray:ByteArray = imageProcessor.getJPGEncoding();
			
			var properties:Object = new Object();
			properties.loadData = finalByteArray;
			
			var className:String = "movie.assets."+type+"AssetInstance";
			var classVar:Class = getDefinitionByName( className ) as Class;
			_asset = new classVar(name, properties);
			//_asset = new ScionAudioAssetInstance("test", properties);
			
		    this.dispatchEvent(new AssetEvent(AssetEvent.ASSET_CREATED));
		}
			
	}
}



