package movie.assets
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import movie.util.ImageProcessor;
	
	import mx.binding.utils.*;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	
	public class ImageAssetInstance extends AssetInstance
	{
		
		protected var _thumbnailWidth;
		protected var _thumbnailHeight;
		protected var _thumbnail:ByteArray;
		protected var imageProcessor:ImageProcessor;
		
		public function ImageAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "Image";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			
			super(name, properties, assetClass);
			
			setAssetComponent(new ImageAssetInstanceCmpnt());
		}
		
		
		protected override function _initCCHandler(event:FlexEvent) 
		{
			
			//this.assetCmpnt = new ImageAssetInstanceCmpnt();
			//assetCmpnt.addEventListener(FlexEvent.CREATION_COMPLETE, assetCCHandler);
			if (_constructorProperties.loadData) {
				assetCmpnt.source = _constructorProperties.loadData;
				super._initCCHandler(event);
				assetLoadedHandler();
			} else {
				//assetCmpnt.addEventListener(FlexEvent.UPDATE_COMPLETE, assetLoadedHandler);
				assetCmpnt.addEventListener(Event.COMPLETE, assetLoadedHandler);
				assetCmpnt.source = _constructorProperties.assetPath;
				Application.application.showProgressBar(assetCmpnt, "loading image");
				super._initCCHandler(event);
			}
		}
		
		
		protected override function assetLoadedHandler(event:Event=null) {
			
			// this gets called multiple times, so only call the parent assetLoaded when
			// the width has been set, which means that the content actually has been loaded
			
			// now this is causing assetLoaded to not get called when the asset is pre-loaded through
			// the loadData property, so comment this out
			//if (assetCmpnt.width != 0) {
				super.assetLoadedHandler(event);
			//}
		}
		
		public function get byteSource() {
			return assetCmpnt.source;
		}
		
		
		
		/****************************** THUMBNAIL *********************************/
		
		/**
		 * Return a jpg thumbnail of the byteArray
		 */
		
		public function createThumbnail(width:int, height:int)
		{
			if (assetCmpnt) {
				_thumbnailWidth = width;
				_thumbnailHeight = height;
				
				// only load the imageProcessor & bitmap if we haven't done so already
				if (imageProcessor==null) {
					imageProcessor = new ImageProcessor();
					imageProcessor.addEventListener(Event.COMPLETE, imageProcessorLoadedHandler);
					
					var bitMap:Bitmap = assetCmpnt.content as Bitmap;
					bitMap.smoothing = true;
					imageProcessor.loadBitmapData(bitMap.bitmapData);
				} else {
					imageProcessor.reset();
					imageProcessorLoadedHandler();
				}
			}
		}
		
		protected function imageProcessorLoadedHandler(event:Event=null) 
		{
			imageProcessor.makeThumbnail(_thumbnailWidth, _thumbnailHeight);
			_thumbnail = imageProcessor.getJPGEncoding();
			
			dispatchEvent(new AssetEvent(AssetEvent.THUMBNAIL_READY));
		}
		
		public function get thumbnail() 
		{
			return _thumbnail;
		}
	}
}