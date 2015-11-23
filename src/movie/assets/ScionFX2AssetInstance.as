package movie.assets
{
	import flash.events.MouseEvent;
	
	import movie.movie.MovieEvent;
	
	import mx.events.FlexEvent;


	/**
	 * Same as ScionFX, except that when we stop the movie, we have to remove the asset from the stage
	 * so that it stops animating
	 */
	
	
	public class ScionFX2AssetInstance extends SWFAssetInstance
	{
		
		/**
		 * Flag so that we don't call initHandler again in the setProperties method
		 */
		var initialLoad:Boolean = true;

		public function ScionFX2AssetInstance(name:String, properties:Object, assetClass:AssetClass)
		{
			properties.fullscreen = true;
			//properties.hardcodedZIndex = 2;
			
			super(name, properties, assetClass);
			
			//_floater = true;
			this.type = "ScionFX2";
			allowMultipleInstancesOfSWF = false;	// do not duplicated this fx when the same
													// asset class is added multiple times
		}
		
		/**
		 * For some reason, the mouseUpHandler causes the swf to dissapear when the movie
		 * is paused, so just remove the handler for this asset.
		 */
		protected override function _initCCHandler(event:FlexEvent)
		{
			super._initCCHandler(event);
			
			assetCmpnt.removeEventListener(MouseEvent.MOUSE_UP, this._mouseUpHandler);
			
			// remove mouse events capture from the swf
			assetCmpnt.mouseEnabled = assetCmpnt.mouseChildren = assetCmpnt.buttonMode = false;
		}
		
		
		protected override function _stopHandler(event:MovieEvent)
		{
			if (assetCmpnt.parent) {
				assetCmpnt.parent.removeChild(assetCmpnt);
				assetCmpnt.source = null;
			}
			
			this._isPlaying = false;
			
			//super._stopHandler(event);
			
		}

		
		
		public override function setProperties(properties:Object, currentFrame:int=undefined) 
		{
			//trace(ObjectUtil.toString(properties));
			
			if (this.theMovie && movieIsControllable) {		
				
				if (this.theMovie.isPlaying) 
				{
					// we need the isPlaying flag, because we don't want to start the sound again if it's already playing
					if (! this._isPlaying)
					//if (true)
					{
						//this.assetCmpnt.content.gotoAndPlay(getRelativeFrame(currentFrame));
						
						//assetCmpnt.source = theAssetSource;
						if (! initialLoad) {
							assetInitHandler();
						} else {
							initialLoad = false;
						}
						theMovie.stage.addChild(assetCmpnt);
						
						this._isPlaying = true;
						
					} else {
						/*if (currentFrame > assetCmpnt.content.totalFrames) {
							assetCmpnt.content.gotoAndPlay(getRelativeFrame(currentFrame));
						}*/
					}
					
				} else {
					//this.assetCmpnt.content.gotoAndStop(getRelativeFrame(currentFrame))
					
					/*if (assetCmpnt.parent) {
						assetCmpnt.parent.removeChild(assetCmpnt);
						assetCmpnt.source = null;
					}*/
					
				}
			}
			
			if (assetCmpnt.content) {
				super.setProperties(properties, currentFrame);
			}
		}
		
		
		
	/*	This functionality is now part of the ScionTextFXAssetInstance class
		public function setFXText(inText:String) {
			setProperties({text:inText});
		}
	
	
		public override function setProperties(properties:Object, currentFrame:int=undefined) {
					
			if (properties.text) {
				this.assetCmpnt.content.setCaption(properties.text);
			}
			
			super.setProperties(properties, currentFrame);
		}*/
	}
}