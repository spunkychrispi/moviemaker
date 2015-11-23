package movie.assets
{	
	public class ScionTextFXAssetInstance extends SWFAssetInstance
	{
		import mx.core.Application;
		import movie.movie.Movie;
		import flash.events.Event;
		import scion.movie.ScionMovie;
		import mx.events.FlexEvent;
		import flash.display.MovieClip;
		import flash.utils.getQualifiedClassName;
		import flash.events.MouseEvent;
		import scion.assets.BorderCloseImage;

		protected var originalWidth:Number;		// used to set the new x&y of the child movie when the size of the child movie
												// changes due to text editing
		protected var originalHeight:Number;
		protected var originalX:Number;
		protected var originalY:Number;
		protected var resetSize:Boolean = false;	// when the width changes, due to text editing, the size will change, but we don't
													// want that to scale the asset, so set this flag, which will get reset once 
													// setSize is called
		protected var childClip:MovieClip;
		
		public var initialSelect:Boolean;		// when the asset is selected for the first time, which is when it is first
													// put onto the stage, set the originalSize so that we can set the widget
													// slider maximum off of that
													
		public var rawWidth:Number;				// the width and height of the asset before scaling
		public var rawHeight:Number;
			
		[Bindable]										
		public var scale:Number;
	
		public function ScionTextFXAssetInstance(name:String, properties:Object, assetClass:AssetClass)
		{
			super(name, properties, assetClass);
			
			_statePropertiesList = ["centerX", "centerY", "scale", "rotation"];
			_tweenPropertiesList = ["centerX", "centerY", "scale", "rotation"];
			
			var movie:ScionMovie = Movie.movie as ScionMovie;
			controlWidget = movie.theControlWidget;
			widgetControls = ["scale", "rotation"];
			useLoadedData = false;
			
			this.type = "ScionTextFX";
			
			initialSelect = true;
		}
		
			
		/**
		 * Center the asset in the middle of the stage
		 */
		protected override function assetLoadedHandler(event:Event=null) {
			
			BorderCloseImage(assetCmpnt).closeButton.addEventListener(MouseEvent.MOUSE_DOWN, closeButtonClickedHandler);
			
			originalWidth = assetCmpnt.width;
			originalHeight = assetCmpnt.height;
			rawWidth = assetCmpnt.width;
			rawHeight = assetCmpnt.height;
			//originalSize = assetCmpnt.width;
			childClip = assetCmpnt.content.getChildAt(0);
			originalX = childClip.x;
			originalY = childClip.y;
			//trace("original x:"+originalX+" original y:"+originalY);
			//sizeSliderMax = assetCmpnt.width * 4;
			
			setScale(100);
			
			assetCmpnt.scaleContent = true;
			
			_constructorProperties.centerX = Math.floor(Movie.movie.stageWidth / 2);
			_constructorProperties.centerY = Math.floor(Movie.movie.stageHeight / 2);
			
			super.assetLoadedHandler(event);
		}
		
		
		public function closeButtonClickedHandler(event:Event) {
				
			Movie.movie.removeAsset(this, Movie.movie.currentFrame, true);
		}
		
		
		// needed for the setProperties function to set this correctly
		public function setFxText(text:String) {
			fxText = text;
		}

	
		public function set fxText(text:String) {
			
			
			assetCmpnt.content.setCaption(text);
			
			//assetCmpnt.width = assetCmpnt.content.width;
			
			// first, get the ratio of the slider, so that we can keep the scale position the same
			//var scaleRatio:Number = controlWidget.widget.sizeControl.maximum  / theSize;
			
			var scaler:Number = scale/100;
			rawWidth = assetCmpnt.content.width / scaler;
			rawHeight = assetCmpnt.content.height / scaler;
			
			setWidth(assetCmpnt.content.width);
			resetSize = true;
			
			var xDiff:Number = (assetCmpnt.content.width/scaler) - originalWidth;
			//trace("pre set childx: "+childClip.x);
			childClip.x = originalX + (xDiff/2);
			
			assetCmpnt.invalidateProperties();
			assetCmpnt.invalidateDisplayList();
		
			setInitializeProperty("fxText", text);
		}
		
		public function get fxText() {
			return getInitializeProperty("fxText");
		}
		
		
		public function setScale(scale:Number) 
		{
			this.scale = scale;
			var scaler:Number = scale/100;
			setWidth(rawWidth * scaler);
			setHeight(rawHeight * scaler);
			
			//trace("scaled child x:"+childClip.x);
			
			setStateProperty('scale', scale);
		}
			
		
	
		/*************************** Set the styles for the highlight / select states *******************************/
		

		protected override function _mouseRollOverHandler(event:MouseEvent)
		{
			if (theMovie.mode=='maker') {
				assetCmpnt.useHandCursor = true;
				assetCmpnt.buttonMode = true;
			} else {
				assetCmpnt.useHandCursor = false;
			}
			
			super._mouseRollOverHandler(event); 
		}
		
		
		
		protected override function _highlight()
		{	
			if (theMovie.mode=="preview" || theMovie.mode=="player") return;
			super._highlight();
			
			//assetCmpnt.setStyle("borderStyle", "solid");
			//assetCmpnt.setStyle("borderThickness", "2");
			assetCmpnt.setStyle("borderColor", "#2980BC");
			assetCmpnt.setStyle("borderThickness", "1");
			assetCmpnt.setStyle("borderAlpha", "1");
			assetCmpnt.setStyle("selected", false);
	
		}
		
		
		protected override function _unHighlight()
		{
			if (theMovie.mode=="preview" || theMovie.mode=="player") return;
			super._unHighlight();
			
			//assetCmpnt.setStyle("borderStyle", "solid");
			//assetCmpnt.setStyle("borderThickness", "0");
			assetCmpnt.setStyle("borderThickness", "1");
			assetCmpnt.setStyle("borderAlpha", "0");
			assetCmpnt.setStyle("selected", false);
			
		}
		
		
		protected override function _select()
		{	
			if (theMovie.mode=="preview" || theMovie.mode=="player") return;	
			super._select();
			
			//assetCmpnt.setStyle("borderStyle", "solid");
			//assetCmpnt.setStyle("borderThickness", "2");
			assetCmpnt.setStyle("borderColor", "#FFFFFF");
			assetCmpnt.setStyle("borderThickness", "1");
			assetCmpnt.setStyle("borderAlpha", "1");
			assetCmpnt.setStyle("selected", true);
		}
		
		
		protected override function _unSelect()
		{
			super._unSelect();
			
			//assetCmpnt.setStyle("borderThickness", "0");
			assetCmpnt.setStyle("borderAlpha", "0");
			assetCmpnt.setStyle("borderThickness", "1");
			assetCmpnt.setStyle("selected", false);
		}
		
	}
}