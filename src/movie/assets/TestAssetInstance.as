package movie.assets
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import movie.util.ImageProcessor;
	
	import mx.binding.utils.*;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	
	public class TestAssetInstance extends AssetInstance
	{
		
		
		public function TestAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "Test";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			
			super(name, properties, assetClass);
			
			setAssetComponent(new TestAssetInstanceCmpnt());
		}
		
		
		protected override function _initCCHandler(event:FlexEvent) 
		{
			
			super._initCCHandler(event);
			assetLoadedHandler();
			
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
		
	}
}