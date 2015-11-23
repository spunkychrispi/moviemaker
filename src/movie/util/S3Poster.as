package movie.util
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	
	import s3.flash.S3PostOptions;
	import s3.flash.S3PostRequest;
	
	import mx.core.Application;
	
	import mx.controls.Alert;
		
	public class S3Poster extends EventDispatcher
	{
		var accessKey:String;
	
		var bucket:String;
		var files:Array;
		
		public function S3Poster(accessKey:String)
		{
			this.accessKey = accessKey;
		}
		
		
		/**
		 */
		public function postFiles(bucket:String, files:Array) {
			
			this.bucket = bucket;
			this.files = files;
			
			postNextFile();
		}
		
		
		protected function postNextFile() {	
		
			if (files.length > 0) {
				var fileToPost:Object = files.pop();
				
				post(bucket, fileToPost);
				
			} else {
				files = null;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		
		public function post(bucket:String, file:Object) {
			
			var options:S3PostOptions = new S3PostOptions();
           	//options.secure = true;
            options.secure = false;
            options.acl = "public-read";
            options.contentType = file.contentType;
            options.policy = file.policy;
            options.signature = file.signature;
          
			 // create the post request
            var s3Request:S3PostRequest = new S3PostRequest(accessKey, bucket, file.filename, options);
            
            // hook up the user interface
            s3Request.addEventListener(Event.OPEN, function(event:Event):void {
                dispatchEvent(new Event(Event.OPEN));
            });
            s3Request.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
            	Alert.show("progress event");
                //setProgress(Math.floor(event.bytesLoaded/event.bytesTotal * 100));
               // trace(Math.floor(event.bytesLoaded/event.bytesTotal * 100));
                
            });
            s3Request.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
            	Alert.show("error: " + event);
                dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
            });
            s3Request.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
            	Alert.show("security error");
                dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR))
            });
            s3Request.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(event:Event):void {
                dispatchEvent(new DataEvent(DataEvent.UPLOAD_COMPLETE_DATA))
                
                Application.application.hideProgressBar();
                if (files) {
                	postNextFile();
                }
            });
            
            //try {
                // submit the post request
                if (file.fileReference) s3Request.uploadFileReference(file.fileReference);
                else s3Request.uploadByteArray(file.byteArray);
                Application.application.showProgressBar(null, file.progressLabel, true, false);
           /* } catch(e:Error) {
                trace("An error occurred: " + e);
            }*/
		}




	}
	
	
}