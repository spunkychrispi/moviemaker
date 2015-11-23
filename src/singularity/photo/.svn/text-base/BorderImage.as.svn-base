package singularity.photo
{
	import mx.controls.Image;
	
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
	[Style(name="borderAlpha", type="Number", format="Length", inherit="no")]
	
	public class BorderImage extends Image
		{
			
		[Embed('/assets/asset_button_close.png')]
        public var closeButtonSrc:Class;
	
			
		public function BorderImage()
		{
			super();
		}
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var closeButton:Image = new Image();
			closeButton.source = closeButtonSrc;
			
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
				//graphics.lineStyle(getStyle('borderThickness'),getStyle('borderColor'),getStyle('borderAlpha'),false);
				//graphics.drawRect(-(getStyle('borderThickness')/2),-(getStyle('borderThickness')/2),w+getStyle('borderThickness'),h+getStyle('borderThickness'));
			}
			
			
			var closeButton:Image = new Image();
			closeButton.source = closeButtonSrc;
			
			addChild(closeButton);
			
			super.updateDisplayList(w,h);
		}
	
	}
}