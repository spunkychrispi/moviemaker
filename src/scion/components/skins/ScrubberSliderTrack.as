package scion.components.skins
{
	import mx.core.UIComponent;

	public class ScrubberSliderTrack extends UIComponent
	{
		override public function get height():Number{
            return 20;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

			//trace("slider width/height:"+unscaledWidth + " " + unscaledHeight);
			//unscaledWidth = 371;
			unscaledWidth += 12;
			unscaledHeight = 15;
			
			var xDif:int = 6;
			var yDif:int = -3;
			

            // create a border for the track - the track itself is empty
            graphics.lineStyle(1, 0xAFAFAF);
            graphics.moveTo(0-xDif, 0-yDif);
            graphics.lineTo(unscaledWidth-1-xDif, 0-yDif);
            graphics.lineTo(unscaledWidth-1-xDif, unscaledHeight-1-yDif);
            graphics.lineTo(0-xDif, unscaledHeight-1-yDif);
            graphics.lineTo(0-xDif, 0-yDif);
		
        }

	}
}