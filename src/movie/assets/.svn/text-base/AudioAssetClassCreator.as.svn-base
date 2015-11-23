package movie.assets
{
	
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.Application;

	
	
	/**
	 * Creates mp3 assets from provided mp3 file. Saves it to the server, and then
	 * returns the factory class object to be added to the asset list.
	 */
	public class AudioAssetClassCreator extends EventDispatcher
	{
		
		protected var loader:Loader;
		protected var name:String;
		
		var audioData:ByteArray;
		
		
		public function AudioAssetClassCreator(name:String, audioData:ByteArray)
		{
			this.name = name;
			this.audioData = audioData;
		}
		
		
		public function initialize() {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		public function createClass():AssetClass
		{	
			// upload the assets to the server
			// first, create the URLLoader that will send the URLRequest
			var tmpLoader = new URLLoader();
     		
     		tmpLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            tmpLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            tmpLoader.addEventListener(Event.COMPLETE, onSuccess);
			
			var assetFilename:String = name+".mp3";
			var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			
			// upload the main asset
			var request:URLRequest = new URLRequest("/movie_scripts/quick_upload3.php?name="+assetFilename);
			request.requestHeaders.push(header);
			request.method = URLRequestMethod.POST;
			request.data = audioData;
     		try {
            	tmpLoader.load(request);
            } catch (error:Error) {
            	trace("Unable to dispatch load request: " + error);
            } 
            
			// now create the class and return it 
			var audioClass:AssetClass = new AssetClass(name, "ScionAudio", null, null, {assetPath:"/movie_scripts/files/"+assetFilename});
            return audioClass;
 		}
 		

     /**
             * Event handler to deal with any issues during file load/upload.
             */
            private function onSuccess(event:Event):void
            {
               // Alert.show("success!");
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