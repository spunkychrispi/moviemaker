package movie.assets
{
	import mx.binding.utils.*;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	
	
	public class TextAssetInstance extends AssetInstance
	{
		
		public function TextAssetInstance(name:String, properties:Object, assetClass:AssetClass)
		{
			this.type = "Text";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			
			super(name, properties, assetClass);
		
			this.assetCmpnt = new Label();
			this.assetCmpnt.text = "hello there!";
			
			// widget settings - maybe move to base class
			this.controlWidget = new AssetInstanceWidget();	
			this.controlWidget.constructor(this, ["text", "rotation"]);
		}
		
		public function set text(text:String) {
			this.assetCmpnt.text = text;
		}
		
		public function get text() {
			return this.assetCmpnt.text;
		}
		
	}
}