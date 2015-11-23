package movie.assets
{
	import flash.events.Event;

	public class AssetEvent extends Event
	{
		
		/**
		 * The asset is fully loaded, initialized, and ready for display.
		 */
		public static const ASSET_COMPLETE:String = "AssetComplete";
		
		/**
		 * ??
		 */
		public static const ASSET_CREATED:String = "AssetCreated";
		
		/**
		 * The assets initCCHandler method has completed
		 */
		public static const ASSET_INITIALIZED:String = "AssetInitialized";
		
		/**
		 * After the thumbnail has been created and the property set.
		 */
		 public static const THUMBNAIL_READY:String = "ThumbnailReady";
		
		
		
		public function AssetEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}