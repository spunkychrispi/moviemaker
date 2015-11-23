package movie.assets
{
	public class ScionImageAssetInstance extends ImageAssetInstance
	{
		import mx.core.Application;
		import scion.movie.ScionMovie;
		import movie.movie.Movie;
		
		public function ScionImageAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			properties.fullscreen = true;
			properties.hardcodedZIndex = 0;
			
			super(name, properties, assetClass);
			
			/*var movie:ScionMovie = Movie.movie as ScionMovie;
			controlWidget = movie.theControlWidget;
			widgetControls = ["size", "rotation"];*/
			type = "ScionImage";
		}
		
		
		public function createThumbnailSmall()
		{
			super.createThumbnail(Application.application.thumbnailWidth, Application.application.thumbnailHeight);
		}
		
		
		public function createThumbnailLarge() 
		{
			super.createThumbnail(Application.application.thumbnailWidthLarge, Application.application.thumbnailHeightLarge);
		}
		
		public function createThumbnailLargest() 
		{
			super.createThumbnail(Application.application.thumbnailWidthLargest, Application.application.thumbnailHeightLargest);
		}
	}
}