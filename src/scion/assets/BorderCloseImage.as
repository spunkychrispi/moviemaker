package scion.assets
{
	import mx.controls.Image;
	
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
	[Style(name="borderAlpha", type="Number", format="Length", inherit="no")]
	[Style(name="selected", type="Boolean", inherit="no")]
	
	public class BorderCloseImage extends Image
		{
		public function BorderCloseImage()
		{
			super();
		}
		
		public var closeButton:Image;
		
		override protected function createChildren():void {

    		// Call the createChildren() method of the superclass.
    		super.createChildren();
    				
			[Embed('/assets/asset_button_close.png')]
			var closeButtonSrc:Class;
    		
    		closeButton = new Image();
    		closeButton.source = closeButtonSrc;
    		closeButton.width = 12;
    		closeButton.height = 12;
    		
    		//closeButton.addEventListener(MouseEvent.MOUSE_DOWN, 
    		
    		addChild(closeButton);
        }
		
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			if (w) {
				graphics.clear();
				
				//x+=(getStyle('borderThickness')/2);
				//y+=(getStyle('borderThickness')/2);
				
				var borderThickness:Number = getStyle('borderThickness');
				if (borderThickness > 0) {
					graphics.lineStyle(getStyle('borderThickness'),getStyle('borderColor'),getStyle('borderAlpha'),false);
					graphics.drawRect(-(borderThickness/2),-(borderThickness/2),w+borderThickness,h+borderThickness);
				}
				    		
				var selected:Boolean = getStyle('selected');
				//trace(selected);
				if (selected) {
					closeButton.visible = true;
    				closeButton.x = w-6;
    				closeButton.y = -6;
    			} else {
    				closeButton.visible = false;
    			}
				
				//graphics.lineStyle(getStyle('borderThickness'),getStyle('borderColor'),getStyle('borderAlpha'),false);
				//graphics.drawRect(-(getStyle('borderThickness')/2),-(getStyle('borderThickness')/2),w+getStyle('borderThickness'),h+getStyle('borderThickness'));
			}
			super.updateDisplayList(w,h);
		}
	}
}