package scion.components.skins
{
	import mx.controls.sliderClasses.SliderThumb;

	public class AssetSliderThumb extends SliderThumb
	{
		
		public static var theWidth:int = 15;
		public static var theHeight:int = 17;

		public function AssetSliderThumb()
		{
			super();
			this.width= AssetSliderThumb.theWidth;
			this.height = AssetSliderThumb.theHeight;
		}
	
	   /*override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            super.updateDisplayList(unscaledWidth,unscaledHeight);
            this.graphics.beginFill(0x000000,1);
            this.graphics.drawCircle(2,-8,4);
           	this.graphics.endFill();
        }*/


     }
}
