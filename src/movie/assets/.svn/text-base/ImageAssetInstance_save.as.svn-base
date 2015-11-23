package movie.assets
{
	import flash.events.Event;
	
	import mx.binding.utils.*;
	import mx.events.FlexEvent;
	import mx.core.Application;
	
	
	public class ImageAssetInstance extends AssetInstance
	{
		
		public function ImageAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			this.type = "Image";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			
			super(name, properties, assetClass);
			
			this.assetCmpnt = new ImageAssetInstanceCmpnt();
			//assetCmpnt.addEventListener(FlexEvent.CREATION_COMPLETE, assetCCHandler);
			if (properties.loadData) {
				assetCmpnt.source = properties.loadData;
				assetLoadedHandler();
			} else {
				//assetCmpnt.addEventListener(FlexEvent.UPDATE_COMPLETE, assetLoadedHandler);
				assetCmpnt.addEventListener(Event.COMPLETE, assetLoadedHandler);
				assetCmpnt.source = properties.assetPath;
				Application.application.showProgressBar(assetCmpnt);
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
	}
}