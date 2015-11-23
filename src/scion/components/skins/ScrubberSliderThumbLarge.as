package scion.components.skins
{
	import mx.controls.sliderClasses.SliderThumb;

	public class ScrubberSliderThumbLarge extends SliderThumb
	{
		
		public static var theWidth:int = 13;
		public static var theHeight:int = 22;

		public function ScrubberSliderThumbLarge()
		{
			super();
			this.width= ScrubberSliderThumbLarge.theWidth;
			this.height = ScrubberSliderThumbLarge.theHeight;
		}
	
	   /*override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            super.updateDisplayList(unscaledWidth,unscaledHeight);
            this.graphics.beginFill(0x000000,1);
            this.graphics.drawCircle(2,-8,4);
           	this.graphics.endFill();
        }*/


     }
}
