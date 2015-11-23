package movie.assets
{
	import mx.events.FlexEvent;
	import flash.events.MouseEvent;
		
	public class ScionFXAssetInstance extends SWFAssetInstance
	{
		import mx.core.Application;
	
		public function ScionFXAssetInstance(name:String, properties:Object, assetClass:AssetClass)
		{
			properties.fullscreen = true;
			//properties.hardcodedZIndex = 2;
			
			super(name, properties, assetClass);
			
			_floater = true;
			this.type = "ScionFX";
			allowMultipleInstancesOfSWF = false;	// do not duplicated this fx when the same
													// asset class is added multiple times
		}
		
		/**
		 * For some reason, the mouseUpHandler causes the swf to dissapear when the movie
		 * is paused, so just remove the handler for this asset.
		 */
		protected override function _initCCHandler(event:FlexEvent)
		{
			super._initCCHandler(event);
			
			assetCmpnt.removeEventListener(MouseEvent.MOUSE_UP, this._mouseUpHandler);
			
			// remove mouse events capture from the swf
			assetCmpnt.mouseEnabled = assetCmpnt.mouseChildren = assetCmpnt.buttonMode = false;
		}
		
		
		
	/*	This functionality is now part of the ScionTextFXAssetInstance class
		public function setFXText(inText:String) {
			setProperties({text:inText});
		}
	
	
		public override function setProperties(properties:Object, currentFrame:int=undefined) {
					
			if (properties.text) {
				this.assetCmpnt.content.setCaption(properties.text);
			}
			
			super.setProperties(properties, currentFrame);
		}*/
	}
}