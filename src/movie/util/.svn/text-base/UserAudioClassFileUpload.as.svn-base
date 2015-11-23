package movie.util
{
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import mx.events.FlexEvent;
	import movie.assets.AudioAssetClassCreator;
	
	import mx.core.Application;


	/** Extends the fileUpload component. Takes the audio file, calls audioClassCreator with it, 
	 *  then adds the new Audio Class to the class list.
	 */
	public class UserAudioClassFileUpload extends FileUpload
	{
		
		var audioClassCreator:AudioAssetClassCreator;
		
		
		public function UserAudioClassFileUpload() {
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			//super();
		}
		
		
		protected function creationCompleteHandler(event:Event) {
			this.BrowseButton.label = "Upload mp3 File";
		}
		
		
		public override function onFileLoaded(event:Event):void
        {
        	this.fileUploadURL = "/movie_scripts/quick_upload2.php";
        	
            var fileReference:FileReference=event.target as FileReference;
            
            var data:ByteArray=fileReference["data"];
            
            audioClassCreator = new AudioAssetClassCreator(filename(fileReference.name), data);
            audioClassCreator.addEventListener(Event.COMPLETE, completeHandler);
            audioClassCreator.initialize();
            
            //super.onFileLoaded(event);
        }
        
        private function completeHandler(event:Event) {
        	 
            var audioClass = audioClassCreator.createClass();
            Application.application.assetList.addAsset(audioClass, 6);
        }
		
	}
}