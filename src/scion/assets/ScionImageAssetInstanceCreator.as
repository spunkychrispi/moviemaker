package scion.assets
{
	import flash.utils.ByteArray;
	import movie.util.ImageProcessor;
	import movie.assets.ImageAssetInstanceCreator;
	import flash.events.Event;
	import mx.core.Application;



	/**
	 * Creates the thumbnail from the image bytearray
	 */
	public class ScionImageAssetInstanceCreator extends ImageAssetInstanceCreator
	{
					
		var thumbnailHeight:int;
		var thumbnailWidth:int;
		public var thumbnail:ByteArray;				
		
		
		public function ScionImageAssetInstanceCreator(type:String="ScionImage")
		{
			super(type);
			
			thumbnailWidth = Application.application.thumbnailWidth;
			thumbnailHeight = Application.application.thumbnailHeight;
		}
		
		
		/*public override function completeHandler(event:Event) {
			
			// create the thumbnail for the movie
			imageProcessor.makeThumbnail(thumbnailWidth, thumbnailHeight);
			thumbnail = imageProcessor.getJPGEncoding();
			imageProcessor.reset();
			
			super.completeHandler(event);
		}*/
		
	}
}