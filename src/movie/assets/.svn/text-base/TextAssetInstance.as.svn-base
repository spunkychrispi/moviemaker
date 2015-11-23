package movie.assets
{
	import mx.binding.utils.*;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	import flash.events.Event;
	import movie.movie.Movie;
	import scion.movie.ScionMovie;
	
	
	/**
	 * This asset isn't completely working with the latest version of AssetIntance.
	 * Needs some fixes
	 */
	public class TextAssetInstance extends AssetInstance
	{
		
		public function TextAssetInstance(name:String, properties:Object, assetClass:AssetClass)
		{
			this.type = "Text";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			
			super(name, properties, assetClass);
			
			setAssetComponent(new TextAssetInstanceCmpnt());
			
			var movie:ScionMovie = Movie.movie as ScionMovie;
			controlWidget = movie.theControlWidget;
			widgetControls = ["size", "rotation"];
		}
		
		
		protected override function _initCCHandler(event:FlexEvent) 
		{
			
			super._initCCHandler(event);
			
			assetLoadedHandler();
		}
		
		
		protected override function assetLoadedHandler(event:Event=null) {
			
				assetCmpnt.visible = true;
				assetCmpnt.text = "hello there";
				assetCmpnt.setStyle('color', '#FFFFFF');
				super.assetLoadedHandler(event);
		}
		
		
		public function set text(text:String) {
			this.assetCmpnt.text = text;
		}
		
		public function get text() {
			return this.assetCmpnt.text;
		}
		
		
		public override function setProperties(properties:Object, currentFrame:int=undefined) 
		{	
			//delete(properties['rotation']);
			//delete(properties['height']);
			//delete(properties['width']);
			delete(properties['centerX']);
			delete(properties['centerY']);
			super.setProperties(properties, currentFrame);

		}
		
		
		
		
			/*************************** Set the styles for the highlight / select states *******************************/
		
		
		protected override function _highlight()
		{	
			super._highlight();
			
			//assetCmpnt.setStyle("borderStyle", "solid");
			//assetCmpnt.setStyle("borderThickness", "2");
			assetCmpnt.setStyle("borderColor", "#2980BC");
			assetCmpnt.setStyle("borderThickness", "1");
			assetCmpnt.setStyle("borderAlpha", "1");
	
		}
		
		
		protected override function _unHighlight()
		{
			//assetCmpnt.setStyle("borderStyle", "solid");
			//assetCmpnt.setStyle("borderThickness", "0");
			assetCmpnt.setStyle("borderThickness", "1");
			assetCmpnt.setStyle("borderAlpha", "0");
			
			super._unHighlight();
		}
		
		
		protected override function _select()
		{		
			super._select();
			
			//assetCmpnt.setStyle("borderStyle", "solid");
			//assetCmpnt.setStyle("borderThickness", "2");
			assetCmpnt.setStyle("borderColor", "#FFFFFF");
			assetCmpnt.setStyle("borderThickness", "1");
			assetCmpnt.setStyle("borderAlpha", "1");
	
		}
		
		
		protected override function _unSelect()
		{
			//assetCmpnt.setStyle("borderThickness", "0");
			assetCmpnt.setStyle("borderAlpha", "0");
			assetCmpnt.setStyle("borderThickness", "1");
			
			super._unSelect();
		}
		
	}
}