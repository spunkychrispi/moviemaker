package movie.assets
{
	
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	import mx.events.FlexEvent;
	
	import movie.util.ImageProcessor;
	
	import mx.controls.Alert;
	import mx.core.Application;

	
	
	/**
	 * Creates image and thumbnail assets from provided bitmap data. Saves them to the server, and then
	 * returns the factory class object to be added to the asset list.
	 */
	public class ImageAssetClassCreator extends EventDispatcher
	{
		
		protected var loader:Loader;
		protected var name:String;
		protected var imageByteArray:ByteArray;
		protected var imageProcessor:ImageProcessor;
		
		var maxWidth:int;
		var maxHeight:int;
		var thumbWidth:int;
		var thumbHeight:int;
		var imageData:ByteArray;
		
		
		public function ImageAssetClassCreator(name:String, imageData:ByteArray)
		{
			this.name = name;
			this.imageByteArray = imageData;
			this.maxWidth = Application.application.stageWidth;
			this.maxHeight = Application.application.stageHeight;
			this.thumbWidth = Application.application.thumbWidth;
			this.thumbHeight = Application.application.thumbHeight;
			this.imageData = imageData;
		}
		
		
		public function initialize() {
			imageProcessor = new ImageProcessor();
			imageProcessor.addEventListener(Event.COMPLETE, completeHandler);
			imageProcessor.loadByteArray(imageData);
		}
		
		
		public function completeHandler(event:Event) {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		public function createClass():AssetClass
		{
			// resize the asset, and make the thumbnail
			imageProcessor.minimizeImage(maxWidth, maxHeight);
			var finalByteArray:ByteArray = imageProcessor.getJPGEncoding();
			
			imageProcessor.reset();
			imageProcessor.makeThumbnail(thumbWidth, thumbHeight);
			var thumbByteArray = imageProcessor.getJPGEncoding();
			
			// upload the assets to the server
			// first, create the URLLoader that will send the URLRequest
			var tmpLoader = new URLLoader();
			var tmpLoader2 = new URLLoader();
     		
     		tmpLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            tmpLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            tmpLoader.addEventListener(Event.COMPLETE, onSuccess);
			
			var assetFilename:String = name+".jpg";
			var thumbFilename:String = name+"_thumb.jpg";
			var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			
			// upload the main asset
			var request:URLRequest = new URLRequest("/movie_scripts/quick_upload3.php?name="+assetFilename);
			request.requestHeaders.push(header);
			request.method = URLRequestMethod.POST;
			request.data = finalByteArray;
     		try {
            	tmpLoader.load(request);
            } catch (error:Error) {
            	trace("Unable to dispatch load request: " + error);
            } 
            
            tmpLoader2.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            tmpLoader2.addEventListener(IOErrorEvent.IO_ERROR, onError);
            tmpLoader2.addEventListener(Event.COMPLETE, onSuccess);
            
            // upload the thumb asset
			request = new URLRequest("/movie_scripts/quick_upload3.php?name="+thumbFilename);
			request.requestHeaders.push(header);
			request.method = URLRequestMethod.POST;
			request.data = thumbByteArray;
     		try {
            	tmpLoader2.load(request);
            } catch (error:Error) {
            	trace("Unable to dispatch load request: " + error);
            }   
			
			// now create the class and return it 
			var imageClass:AssetClass = new AssetClass(name, "ScionImage", null, null, {assetPath:"/movie_scripts/files/"+assetFilename});
			//var imageClass:AssetClass = new AssetClass(name, "ScionImage", "/movie_scripts/files/"+thumbFilename, null, {assetPath:"/movie_scripts/files/"+assetFilename});
            return imageClass;
 		}
 		

     /**
             * Event handler to deal with any issues during file load/upload.
             */
            private function onSuccess(event:Event):void
            {
                //Alert.show("success!");
                //submitBtn.enabled = true;
            }

            /**
             * Event handler to deal with any issues during file load/upload.
             */
            private function onError(event:Event):void
            {
                Alert.show(event.toString());
                //submitBtn.enabled = true;
            }

	}
}			