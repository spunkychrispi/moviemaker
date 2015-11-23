package movie.util
{
	
	/**
	 * Provides upload handlers for fileuploading
	 */
	public class FileUploader
	{
        import flash.events.MouseEvent;
        import flash.net.FileReference;
        import flash.net.FileFilter;
        import flash.events.MouseEvent;
        import flash.events.Event;
        import flash.events.IOErrorEvent;
        import mx.controls.ProgressBarMode;
        import mx.core.Application;
        import flash.net.URLRequest;
        import flash.events.ProgressEvent;
        import movie.assets.AssetClass;
 
 
        public var fileReference:FileReference;
        public var fileUploadURL:String;
		private var onSelectHandler:Function;
		private var onLoadedHandler:Function;
 
 
 		public function FileUploader(selectedHandler:Function, loadedHandler:Function)
		{
			onSelectHandler = selectedHandler;
			onLoadedHandler = loadedHandler;
		} 
		
        public function onBrowseButtonClicked(event:MouseEvent):void
        {
			//trace("onBrowse");
			fileReference=new FileReference();
			fileReference.addEventListener(Event.SELECT, onSelectHandler);
			var swfTypeFilter:FileFilter = new FileFilter("SWF Files (*.swf)","*.swf");
			var allTypeFilter:FileFilter = new FileFilter("All Files (*.*)","*.*");
			fileReference.browse([swfTypeFilter, allTypeFilter]);
        }
 
 
       public function onUploadButtonClicked(event:MouseEvent):void
       {
           // trace("onFileSelected");
            fileReference.addEventListener(Event.COMPLETE, onLoadedHandler);
            fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            //fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            
            try {
            	fileReference.load();
            } catch (e:Error) {
            	trace("caught error");
            }
       }
 
 
      /* private function progressHandler(event:ProgressEvent):void
       {
            var file:FileReference = FileReference(event.target);
            var percentLoaded:Number=event.bytesLoaded/event.bytesTotal*100;
            trace("loaded: "+percentLoaded+"%");
            ProgresBar.mode=ProgressBarMode.MANUAL;
            ProgresBar.minimum=0;
            ProgresBar.maximum=100;
           	ProgresBar.setProgress(percentLoaded, 100);
        }*/
 
 
        /*public function onFileLoaded(event:Event):void
        {
            var fileReference:FileReference=event.target as FileReference;
            fileReference.upload(new URLRequest(fileUploadURL));
        }*/
        
        public function onFileLoadError(event:IOErrorEvent)
        {
        	Application.application.alertError("IO ERROR");
        }
	

	}
}



		        
	   