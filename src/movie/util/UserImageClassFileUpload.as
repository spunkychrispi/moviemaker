package movie.util
{
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import mx.events.FlexEvent;
	import movie.assets.ImageAssetClassCreator;
	import mx.core.Application;

	public class UserImageClassFileUpload extends FileUpload
	{
		
		var imageClassCreator:ImageAssetClassCreator;
		
		public function UserImageClassFileUpload() {
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			//super();
		}
		
		
		protected function creationCompleteHandler(event:Event) {
			this.BrowseButton.label = "Upload Image";
		}
		
		public override function onFileLoaded(event:Event):void
        {
        	this.fileUploadURL = "/movie_scripts/quick_upload2.php";
        	
            var fileReference:FileReference=event.target as FileReference;
            
            var data:ByteArray=fileReference["data"];
            
            imageClassCreator = new ImageAssetClassCreator(filename(fileReference.name), data);
            imageClassCreator.addEventListener(Event.COMPLETE, completeHandler);
            imageClassCreator.initialize();
            
            //super.onFileLoaded(event);
        }
        
        private function completeHandler(event:Event) {
        	 
            var imageClass = imageClassCreator.createClass();
            Application.application.assetList.addAsset(imageClass, 9);
        }
		
	}
}