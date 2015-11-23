package movie.util
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader; 
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * Currently this just returns back jpg encodings.
	 * Loads an image ByteArray and then can scale or create a thumbnail.
	 */
	public class ImageProcessor extends EventDispatcher
	{
		var originalBitmapData:BitmapData;		// original image data
		var workingBitmapData:BitmapData;		// any proecessing is made on this bitmap
		public var originalWidth:Number;
		public var originalHeight:Number;
		var loader:Loader;
		
		public function loadByteArray(imageArray:ByteArray) {
			
			loader = new Loader();
			//Application.application.showProgressBar(loader, "Image Processing", false);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.loadBytes(imageArray);
		}
		
		
		public function loaderCompleteHandler(event:Event) {

			loadBitmapData(Bitmap(event.currentTarget.content).bitmapData);
		}
		
		 
		public function loadBitmapData(imageBitmapData:BitmapData)
		{
			
			originalBitmapData = imageBitmapData;
			workingBitmapData = originalBitmapData;
			originalWidth = originalBitmapData.width;
		 	originalHeight = originalBitmapData.height;
		 	
		 	dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		public function reset() {
			workingBitmapData = originalBitmapData;
		}
		
		
		/**
		 * Returns a jpg that has been shrunk to fit just in or out of the dimensions,
		 * depending on doMax parameter
		 */ 
		public function minimizeImage(maxWidth:int, maxHeight:int, doMax:Boolean=true) {
		 	
		 	var returnArray:ByteArray;
		 
		 	// resize only if we need to 
		 	if (originalWidth > maxWidth || originalHeight > maxHeight)
		 	{
		 		// find the scale factor and new dimensions
		  		var sx:Number =  maxWidth / originalWidth;
		  		var sy:Number = maxHeight / originalHeight;
		  		var scale:Number = doMax ? Math.min(sx, sy) : Math.max(sx, sy);
		  		scaleImage(scale);
		  	}	  	
		}
		
		
		public function scaleImage(scale:Number) {
			
			//var resizeMatrix:Matrix = new Matrix();
		  	var newWidth:Number = originalWidth * scale;
		  	var newHeight:Number = originalHeight * scale;	
		  	
		  	/*
		  	var tmpBitmapData:BitmapData;
		  	
		 	resizeMatrix.scale(scale, scale);
		 	tmpBitmapData = new BitmapData( newWidth, newHeight); 
		 	tmpBitmapData.draw(workingBitmapData, resizeMatrix, null, null, null, true);
		 	workingBitmapData = tmpBitmapData;*/
		 	
		 	workingBitmapData = jacWrightResizeImage(workingBitmapData, newWidth, newHeight); 
		}
		
		
		public function cropImage(toWidth:int, toHeight:int) {
			var tmpBitmapData:BitmapData;
		 	tmpBitmapData = new BitmapData(toWidth, toHeight); 
		 	tmpBitmapData.draw(workingBitmapData, null, null, null, null, true);
		 	workingBitmapData = tmpBitmapData;
		}
	
	
		/**
		 * Crops the image from all the edges, so the center of the image
		 * stays in the center
		 */
		
		public function cropImageCenter(toWidth:int, toHeight:int) {
			var tmpBitmapData:BitmapData;
		 	tmpBitmapData = new BitmapData(toWidth, toHeight); 
		 	
		 	// create the rectangle we will grab from the original image
		 	var x:Number = (workingBitmapData.width - toWidth) / 2;
		 	var y:Number = (workingBitmapData.height - toHeight) / 2;
		 	
		 	tmpBitmapData.copyPixels(workingBitmapData, new Rectangle(x, y, toWidth, toHeight), new Point(0, 0));
		 	
		 	//tmpBitmapData.draw(workingBitmapData);
		 	workingBitmapData = tmpBitmapData;
		 }

		
		public function makeThumbnail(width:int, height:int) {
			
			minimizeImage(width, height, false);
			cropImageCenter(width, height);
		}
		
		
		public function getJPGEncoding(quality:int=100) {
			var jpgEncoder:JPGEncoder = new JPGEncoder(quality);
			var jpgArray:ByteArray = jpgEncoder.encode(workingBitmapData);
			
			return jpgArray;
		}
		
		
		
		// grabbed from http://jacwright.com/blog/221/high-quality-high-performance-thumbnails-in-flash/
		private  static const IDEAL_RESIZE_PERCENT:Number  = .5;
		
		public static function jacWrightResizeImage(source:BitmapData, width:Number, height:Number, constrainProportions:Boolean = true):BitmapData
		{
		    var scaleX:Number = width/source.width;
		    var scaleY:Number = height/source.height;
		    if (constrainProportions) {
		        if (scaleX> scaleY) scaleX = scaleY;
		        else scaleY = scaleX;
		    }
		   
		    var bitmapData:BitmapData = source;
		   
		    if (scaleX>= 1 && scaleY>= 1) {
		        bitmapData = new BitmapData(Math.ceil(source.width*scaleX), Math.ceil(source.height*scaleY), true, 0);
		        bitmapData.draw(source, new Matrix(scaleX, 0, 0, scaleY), null, null, null, true);
		        return bitmapData;
		    }
		   
		    // scale it by the IDEAL for best quality
		    var nextScaleX:Number = scaleX;
		    var nextScaleY:Number = scaleY;
		    while (nextScaleX <1) nextScaleX /= IDEAL_RESIZE_PERCENT;
		    while (nextScaleY <1) nextScaleY /= IDEAL_RESIZE_PERCENT;
		   
		    if (scaleX <IDEAL_RESIZE_PERCENT) nextScaleX *= IDEAL_RESIZE_PERCENT;
		    if (scaleY <IDEAL_RESIZE_PERCENT) nextScaleY *= IDEAL_RESIZE_PERCENT;
		   
		    var temp:BitmapData = new BitmapData(bitmapData.width*nextScaleX, bitmapData.height*nextScaleY, true, 0);
		    temp.draw(bitmapData, new Matrix(nextScaleX, 0, 0, nextScaleY), null, null, null, true);
		    bitmapData = temp;
		   
		    nextScaleX *= IDEAL_RESIZE_PERCENT;
		    nextScaleY *= IDEAL_RESIZE_PERCENT;
		   
		    while (nextScaleX>= scaleX || nextScaleY>= scaleY) {
		        var actualScaleX:Number = nextScaleX>= scaleX ? IDEAL_RESIZE_PERCENT : 1;
		        var actualScaleY:Number = nextScaleY>= scaleY ? IDEAL_RESIZE_PERCENT : 1;
		        temp = new BitmapData(bitmapData.width*actualScaleX, bitmapData.height*actualScaleY, true, 0);
		        temp.draw(bitmapData, new Matrix(actualScaleX, 0, 0, actualScaleY), null, null, null, true);
		        bitmapData.dispose();
		        nextScaleX *= IDEAL_RESIZE_PERCENT;
		        nextScaleY *= IDEAL_RESIZE_PERCENT;
		        bitmapData = temp;
		    }
		   
		    return bitmapData;
		}

	}
}

