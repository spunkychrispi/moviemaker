package movie.assets
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.getDefinitionByName;
	
	import org.audiofx.mp3.MP3FileReferenceLoader;
	import org.audiofx.mp3.MP3SoundEvent;
	
	/**
	 * Create an asset instance from an mp3 fileReference
	 */
	public class AudioAssetInstanceCreator extends EventDispatcher	{

		var audioInstance:AudioAssetInstance;
		var scionAudioInstance:ScionAudioAssetInstance;
		
		var type:String;
		var name:String;
		var properties:Object;
		
		var loader:MP3FileReferenceLoader;
		
		private var _asset:AudioAssetInstance;
		
		public function AudioAssetInstanceCreator(type:String="Audio") {
			this.type = type;
			properties = new Object();
		}
		
		
		public function get asset() {
			return _asset;
		}
		

		
		public function createInstanceFromFileReference(fileReference:FileReference) {
			
			/* Send to the assetInstance the original mp3 bytes, for future saving,
		 		as well as the Sound object that we create from the file.
		 	*/
			
			name = fileReference.name;
			
			// When the loading is done, create a reference to the laoded byteArray
			fileReference.addEventListener(Event.COMPLETE, fileLoadingCompleteHandler);
			
			loader = new MP3FileReferenceLoader();
			loader.addEventListener(MP3SoundEvent.COMPLETE, mp3LoaderCompleteHandler);
		    loader.getSound(fileReference);
		}
		
		
		private function fileLoadingCompleteHandler(event:Event) {
			var fileReference:FileReference = event.target as FileReference;
			
			properties.loadBytes = fileReference.data;
		}
			
		     
		     
		private function mp3LoaderCompleteHandler(event:MP3SoundEvent):void
		{
			properties.loadData = event.sound;
			loader.removeEventListener(MP3SoundEvent.COMPLETE, mp3LoaderCompleteHandler);
			
			var className:String = "movie.assets."+type+"AssetInstance";
			var classVar:Class = getDefinitionByName( className ) as Class;
			_asset = new classVar(name, properties);
			//_asset = new ScionAudioAssetInstance("test", properties);
			
		    this.dispatchEvent(new AssetEvent(AssetEvent.ASSET_CREATED));
		}
			
	}
}



