package movie.movie
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import movie.assets.*;
	import movie.util.ErrorHandler;
	import movie.util.S3Poster;
	
	import mx.core.Application;
	
	import s3.flash.S3PostRequest;
	
	import scion.controller.MovieController;
	import scion.movie.ScionMovie;
	
	
	public class MovieSaveLoad
	{
		
		var s3Request:S3PostRequest;
		//var ref:FileReference;
		static var movieID:String;
		var metaProperties:Object; 		// properties to be saved with the movie, ie name, email, title, etc, but
										// that aren't included in the movieProperties itself
										
		static var S3Properties:Object;		// returned from server - list of S3 policies/signatures/etc
										
		var theMovie:ScionMovie;


		public function MovieSaveLoad()
		{
			theMovie = Movie.movie as ScionMovie;
		}
		
		
		/**
		 * Save the movie to the server.
		 * 
		 * The save process goes like this:
		 * - request movieID and S3 policy/signatures for the assets from the server
		 * - recieve movieID and S3 signatures
		 * - save assets and movie properties file to S3
		 * - request saveMovie to server, with movie metaProperties - this will save the movieID and 
		 *  	metaPropreties to the database
		 * - recieve saveMovie success state
		 */
		
		public function save(movie:Movie, metaProperties:Object) {

			//resetMovie();
			//return;

			this.metaProperties = metaProperties;
			
			// first, make a request for a new movie id and to
			// receive S3 polices & signatures
			// if the movie was saved previously in the same session, 
			// then the movieID and S3Properties will already be in the static vars
			
			// 9/20/2010 - now get a new ID each time - the movie gets reset every time we save
			
			/*if (movieID) {
				generateThumbnails();
			} else {*/
			if (true) { 
			
				var server:String = Application.application.server;
				var request:URLRequest = new URLRequest(server+"/movie/create");
				 
				var loader:URLLoader = new URLLoader();
				//loader.dataFormat = URLLoaderDataFormat.VARIABLES;
				loader.addEventListener(Event.COMPLETE, saveRequestCompleteHandler);
				
	     		try {
	            	loader.load(request);
	            } catch (error:Error) {
	            	trace("Unable to dispatch load request: " + error);
	            } 
				
				
				// upload assets to S3
			}
		}

		
		public function saveRequestCompleteHandler(event:Event) {
			
			var loader:URLLoader = event.target as URLLoader;
			S3Properties = JSON.decode(loader.data);
			movieID = S3Properties.movieId;
			S3Properties.accessKey = MovieController.S3_ACCESS_ID;
			//S3Properties.bucket = Application.application.S3_BUCKET;
			
			//trace(loader.data);
			//trace("save request complete");
			
			//var s3Data:Object = JSON.decode(loader.data);
			
			// generate the thumbnail for the movie
			// the last event handler for this will call saveAssetsToS3
			//if (! theMovie.thumbnail) {
				generateThumbnails();
			//}
			//saveAssetsToS3(S3Properties);
		}
		
		
		public function constructS3URL(bucket:String, filename:String) {
			return "http://"+bucket+".s3.amazonaws.com/"+filename;
		}
		
		
		/**
		 * Get small and large thumbnails. If there is an image asset - create the thumbnails from that.
		 * Otherwise grab the youtube assets thumbnails.
		 */
		private var theThumbnailAsset:*;
		
		public function generateThumbnails() {
			
			if (theMovie.theImageAssetInstance) {
				theThumbnailAsset = theMovie.theImageAssetInstance;
			} else if (theMovie.theYouTubeAssetInstance) {
				theThumbnailAsset = theMovie.theYouTubeAssetInstance;
			}
			
			theThumbnailAsset.addEventListener(AssetEvent.THUMBNAIL_READY, smallThumbnailReady);
			theThumbnailAsset.createThumbnailSmall();
		}
		
		protected function smallThumbnailReady(event:Event)
		{
			theThumbnailAsset.removeEventListener(AssetEvent.THUMBNAIL_READY, smallThumbnailReady);
			
			theMovie.thumbnail = theThumbnailAsset.thumbnail;
			
			theThumbnailAsset.addEventListener(AssetEvent.THUMBNAIL_READY, largeThumbnailReady);
			theThumbnailAsset.createThumbnailLarge();
		}
		
		
		protected function largeThumbnailReady(event:Event)
		{
			theThumbnailAsset.removeEventListener(AssetEvent.THUMBNAIL_READY, largeThumbnailReady);
			theMovie.thumbnailLarge = theThumbnailAsset.thumbnail;
			
			theThumbnailAsset.addEventListener(AssetEvent.THUMBNAIL_READY, largestThumbnailReady);
			theThumbnailAsset.createThumbnailLargest();
		}
		
		protected function largestThumbnailReady(event:Event)
		{
			theThumbnailAsset.removeEventListener(AssetEvent.THUMBNAIL_READY, largestThumbnailReady);
			theMovie.thumbnailLargest = theThumbnailAsset.thumbnail;
			
			saveAssetsToS3(S3Properties);
		}
		
		public function saveAssetsToS3(S3Properties:Object) {
		
			//var theByteArray:ByteArray = theMovie.theImageAssetInstance.assetCmpnt.source;
			
			var filesToPost:Array = new Array();
			
			if (theMovie.theImageAssetInstance && getQualifiedClassName(theMovie.theImageAssetInstance)!="movie.assets::ScionImageCannedAssetInstance") {
				var jpgFile:Object = new Object();
				jpgFile.filename = S3Properties.policies.jpg.fileName;
				jpgFile.contentType = "image/jpeg";
				jpgFile.policy = S3Properties.policies.jpg.policy;
				jpgFile.signature = S3Properties.policies.jpg.signature;
				jpgFile.byteArray = theMovie.theImageAssetInstance.byteSource;
				jpgFile.progressLabel = "Uploading Image";
				filesToPost.push(jpgFile);
				
				var assetPath:String = constructS3URL(S3Properties.bucket, jpgFile.filename);
				theMovie.theImageAssetInstance.setProperties({assetPath:assetPath});
			}
			
			if (theMovie.theAudioAssetInstance && getQualifiedClassName(theMovie.theAudioAssetInstance)!="movie.assets::ScionAudioCannedAssetInstance") {
				var mp3File:Object = new Object();
				mp3File.filename = S3Properties.policies.mp3.fileName;
				mp3File.contentType = "audio/mp3";
				mp3File.policy = S3Properties.policies.mp3.policy;
				mp3File.signature = S3Properties.policies.mp3.signature;
				mp3File.byteArray = theMovie.theAudioAssetInstance.byteSource;
				mp3File.progressLabel = "Uploading Audio - this may take a while if the audio is long";
				filesToPost.push(mp3File);
				
				var assetPath:String = constructS3URL(S3Properties.bucket, mp3File.filename);
				theMovie.theAudioAssetInstance.setProperties({assetPath:assetPath});
			}
			
			if (theMovie.thumbnail) {
				var thumbFile:Object = new Object();
				thumbFile.filename = S3Properties.policies.thumb.fileName;
				thumbFile.contentType = "image/jpeg";
				thumbFile.policy = S3Properties.policies.thumb.policy;
				thumbFile.signature = S3Properties.policies.thumb.signature;
				thumbFile.byteArray = theMovie.thumbnail;
				thumbFile.progressLabel = "Uploading Thumbnail";
				//thumbFile.byteArray = theMovie.theImageAssetInstance.byteSource;
				filesToPost.push(thumbFile);
				
				var assetPath:String = constructS3URL(S3Properties.bucket, thumbFile.filename);
				theMovie.thumbnailURL = assetPath;
			}
			
			if (theMovie.thumbnailLarge) {
				var thumbFileLarge:Object = new Object();
				thumbFileLarge.filename = S3Properties.policies.thumbLarge.fileName;
				thumbFileLarge.contentType = "image/jpeg";
				thumbFileLarge.policy = S3Properties.policies.thumbLarge.policy;
				thumbFileLarge.signature = S3Properties.policies.thumbLarge.signature;
				thumbFileLarge.byteArray = theMovie.thumbnailLarge;
				thumbFileLarge.progressLabel = "Uploading Thumbnail";
				//thumbFile.byteArray = theMovie.theImageAssetInstance.byteSource;
				filesToPost.push(thumbFileLarge);
				
				var assetPath:String = constructS3URL(S3Properties.bucket, thumbFileLarge.filename);
				theMovie.thumbnailURL = assetPath;
			}
			
			if (theMovie.thumbnailLargest) {
				var thumbFileLargest:Object = new Object();
				thumbFileLargest.filename = S3Properties.policies.thumbLargest.fileName;
				thumbFileLargest.contentType = "image/jpeg";
				thumbFileLargest.policy = S3Properties.policies.thumbLargest.policy;
				thumbFileLargest.signature = S3Properties.policies.thumbLargest.signature;
				thumbFileLargest.byteArray = theMovie.thumbnailLargest;
				thumbFileLargest.progressLabel = "Uploading Thumbnail";
				//thumbFile.byteArray = theMovie.theImageAssetInstance.byteSource;
				filesToPost.push(thumbFileLargest);
				
				var assetPath:String = constructS3URL(S3Properties.bucket, thumbFileLargest.filename);
				theMovie.thumbnailURL = assetPath;
			}
			
			// now that  we have the assetPaths saved to the assets
			// we can save the movie data as a binary file to s3 as well
			var movieByteArray = theMovie.saveToByteArray();  // contains the movie
			
			var propertiesFile:Object = new Object();
			propertiesFile.filename = S3Properties.policies.properties.fileName;
			propertiesFile.contentType = "application/octet-stream";
			propertiesFile.policy = S3Properties.policies.properties.policy;
			propertiesFile.signature = S3Properties.policies.properties.signature;
			propertiesFile.byteArray = movieByteArray;
			propertiesFile.progressLabel = "Uploading Movie";
			//propertiesFile.byteArray = theMovie.theImageAssetInstance.byteSource;
			filesToPost.push(propertiesFile);
			
			
			var s3Poster:S3Poster = new S3Poster(S3Properties.accessKey);
			
			s3Poster.addEventListener(Event.COMPLETE, filesUploadedHandler);
			
			s3Poster.addEventListener(Event.OPEN, function(event:Event):void {
                setStatus("Uploading...");
                writeLine("Upload started: ");
            });
            s3Poster.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
                //setProgress(Math.floor(event.bytesLoaded/event.bytesTotal * 100));
                trace(Math.floor(event.bytesLoaded/event.bytesTotal * 100));
            });
            s3Poster.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
                setStatus("Upload error!");
                writeLine("An IO error occurred: " + event);
            });
            s3Poster.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
                setStatus("Upload error!");
                writeLine("A security error occurred: " + event);
            });
            s3Poster.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(event:DataEvent):void {
                setStatus("Upload complete");
                writeLine("Yay!!");
            });
            
            s3Poster.postFiles(S3Properties.bucket, filesToPost);  
		}
		
		
		protected function filesUploadedHandler(event:Event) {
			
			// now that the files are uploaded and we have the assetPaths saved to the assets
			// we can save the movie data
	
			var url:String = Application.application.server+"/movie/save";
			var variables:URLVariables = new URLVariables();
			variables.id = movieID;
			
			// addthe metaProperties to the variables
			for (var propertyName:String in metaProperties) {
				variables[propertyName] = metaProperties[propertyName]
			}
			
			var request:URLRequest = new URLRequest(url);
			//var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			//request.requestHeaders.push(header);
			request.method = URLRequestMethod.POST;
			request.data = variables;
			
			var loader:URLLoader = new URLLoader();
			//loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, saveMovieCompleteHandler);
			
			try {
            	loader.load(request);
            } catch (error:Error) {
            	trace("Unable to dispatch load request: " + error);
            } 
  		}
  		
  		
  		protected function saveMovieCompleteHandler(event:Event) {
  			var loader:URLLoader = event.target as URLLoader;
			var returnProps:Object = JSON.decode(loader.data);
			
			if (returnProps.success) {
  				//trace("movie saved!");
  				//trace("MovieID: " + movieID);
  				
  				var callback:Function = function():void {
  					ExternalInterface.call("openDrawerByName", "share");
  					Application.application.closeMakerDrawer();
  				};
  				
  				errorAlert("Your movie was saved", "Now share it with your friends!", callback);
  			} else {
  				errorAlert("Save error", "There was a problem with saving your movie.");
 			}
 			
 			Application.application.shareTabVisible = true;
 			
 			ExternalInterface.call("showShareTab");
 			
 			Application.application.movieChangesSaved = true;
 			
 			resetMovie();
  		}
  		
  		
  		// remove the current movie and reset to blank state
  		protected function resetMovie() {
  			Application.application.resetState();
  			
  			theMovie = Movie.movie as ScionMovie;
  			theMovie.resetState();
  		}
  		
  		
  		
  		protected function errorAlert(title:String, message:String, callback:Function=null) 
  		{
  			var properties:Object = new Object;
  			properties.width = 300;
			properties.height = 150;
			properties.x = (Movie.movie.stageWidth-properties.width)/2;
			properties.y = (Movie.movie.stageHeight-properties.height)/2;
			properties.labelX = 20;
			
			if (callback) {
				properties.callback = callback;
			}

			ErrorHandler.alertError(title, message, "OK", properties);
  		}
       
		
		public function setStatus(status:String) {
			//trace(status);
		}
		
		public function writeLine(line:String) {
			//trace(line);
		}
		
		
		
		/************************************** LOADING *********************************************/
		
			
		var tmpLoader:URLLoader;
		public function load(movieID:String, s3Bucket:String) {
			
			// get the properties file from s3
			var filename:String = movieID+".bin";
			var url:String = constructS3URL(s3Bucket, filename);
			
			tmpLoader = new URLLoader();
			tmpLoader.dataFormat = URLLoaderDataFormat.BINARY;
			var request:URLRequest = new URLRequest(url);
			
			tmpLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			tmpLoader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			
			try {
            	tmpLoader.load(request);
            } catch (error:Error) {
            	trace("Unable to dispatch load request: " + error);
            } 
		}
		
		
		public function httpStatusHandler(event:HTTPStatusEvent) {
			
			if (event.status >= 300) {
				tmpLoader.removeEventListener(Event.COMPLETE, loadCompleteHandler);
				
				Application.application.hideProgressBar();
				
				ErrorHandler.alertError("Movie Error", "The requested movie was not found.", null, 
							{x:0,y:0,width:Application.application.stageWidth,height:Application.application.stageHeight});
			}	
		}
		
		
		public function loadCompleteHandler(event:Event) {
			var tmpLoader:URLLoader = event.target as URLLoader;
			
            var byteArray:ByteArray = tmpLoader.data;
            var saveObject:Object = byteArray.readObject();
            
            Movie.movie.addEventListener(MovieEvent.MOVIE_LOADED, movieLoadedHandler);
            Movie.movie.reset();
            Movie.movie.loadMovie(saveObject);
		}
		
		
		protected function movieLoadedHandler(event:Event) {
			Movie.movie.play();
        }
	
	}
}