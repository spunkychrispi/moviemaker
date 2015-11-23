package movie.assets
{
	import mx.controls.Image;
	import mx.core.UIComponent;

	public class TestAssetInstanceCmpnt extends UIComponent
	{
		public var asset:AssetInstance;
		
		[Embed('/assets/asset_button_close.png')]
		public var closeButtonSrc:Class;
		
		public function TestAssetInstanceCmpnt()
		{
			super();
		}
		
		
		override protected function measure():void {
            super.measure();
    
            measuredWidth=100;
            measuredMinWidth=50;
            measuredHeight=50;
            measuredMinHeight=25;
        }
        
        
        override protected function createChildren():void {

    		// Call the createChildren() method of the superclass.
    		super.createChildren();
    		
    		var closeButton:Image = new Image();
    		closeButton.source = closeButtonSrc;
    		closeButton.width = 12;
    		closeButton.height = 12;
    		
    		closeButton.x = 50;
    		closeButton.y = 50;
    		
    		addChild(closeButton);
        }



		override protected function updateDisplayList(w:Number, h:Number):void
		{
			if (w) {
				graphics.clear();
				
				//x+=(getStyle('borderThickness')/2);
				//y+=(getStyle('borderThickness')/2);
				
				var borderThickness:Number = 2;
				if (borderThickness > 0) {
					graphics.lineStyle(2, 0xAFAFAF, 1, false);
					graphics.drawRect(-(borderThickness/2),-(borderThickness/2),w+borderThickness,h+borderThickness);
				}
				//graphics.lineStyle(getStyle('borderThickness'),getStyle('borderColor'),getStyle('borderAlpha'),false);
				//graphics.drawRect(-(getStyle('borderThickness')/2),-(getStyle('borderThickness')/2),w+getStyle('borderThickness'),h+getStyle('borderThickness'));
			}
			
		
			super.updateDisplayList(w,h);
		}

		
	}
}