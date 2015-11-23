package scion.components.skins
{
	import mx.controls.sliderClasses.SliderThumb;

	public class ScrubberSliderThumb extends SliderThumb
	{
		
		public static var theWidth:int = 10;
		public static var theHeight:int = 13;

		public function ScrubberSliderThumb()
		{
			super();
			this.width= ScrubberSliderThumb.theWidth;
			this.height = ScrubberSliderThumb.theHeight;
		}
	
	   /*override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            super.updateDisplayList(unscaledWidth,unscaledHeight);
            this.graphics.beginFill(0x000000,1);
            this.graphics.drawCircle(2,-8,4);
           	this.graphics.endFill();
        }*/


     }
}
