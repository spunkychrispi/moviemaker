package scion.components.skins
{
	import mx.core.UIComponent;

	public class AssetSliderTrack extends UIComponent
	{
		override public function get height():Number{
            return 7;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

			//trace("slider width/height:"+unscaledWidth + " " + unscaledHeight);
			
			unscaledWidth = 118;
			unscaledHeight = 7;
			
			var xDif:int = 4;
			var yDif:int = -6;
			
			// draw the bg for the track
			graphics.beginFill(0x000000, .3);
			graphics.drawRect(0-xDif, 0-yDif, unscaledWidth, unscaledHeight);
			graphics.endFill();

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