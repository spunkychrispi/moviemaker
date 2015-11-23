package scion.controller
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	import movie.movie.Movie;
	import movie.movie.MovieEvent;
	import movie.movie.MovieSaveLoad;
	import scion.movie.ScionMovie;
	
	import mx.core.Application;  
	import mx.controls.Alert;
	import mx.utils.URLUtil;
	  
	
	/**
	 * Singleton class. Handles requests from UI.
	 * 
	 * Most UI requests aren't in here - need to be migrated to this class.
	 */
	public class MovieController
	{
		public static var S3_ACCESS_ID;
		public static var S3_BUCKET;
		public static var SITE_URL;
		
		private static var _controller:MovieController;
		private var movie:ScionMovie;
		
		public static function get controller() {
			if (! _controller) {
				_controller = new MovieController(Movie.movie);
			}
			return _controller; 
		} 
		
		public function MovieController(movie:Movie)
		{
			this.movie = movie as ScionMovie;
			MovieController._controller = this;

			
			if (Application.application.parameters.env==null || Application.application.parameters.env=='production') {
				S3_ACCESS_ID = "AKIAIYBXXYGIHDTX2NJQ";
				S3_BUCKET = "scionmotionfx";
				//SITE_URL = "motionfx.largetail.com";
			} else {
				S3_ACCESS_ID = "09HVE2QSRFVMBSCZ6NR2";
				S3_BUCKET = "spunkychrispiimages";
				//SITE_URL = "www.88engine.com";
			}
			
			SITE_URL = URLUtil.getServerName(Application.application.loaderInfo.url);
			
			this.movie.addEventListener(MovieEvent.MOVIE_FINISHED, _movieFinishedHandler);
			this.movie.addEventListener(MovieEvent.MOVIE_START, _moviePlayHandler);
		}
		
		
		/**
		 * Display the save form when the movie has finished.
		 */
		protected function _movieFinishedHandler(event:Event) {
			// they can save the movie only if they've input either an image or youtube
			// otherwise there wouldn't be a thumbnail
			//trace(Application.application.mode);
			
			//if (movie.mode=="preview") movie.mode = "maker";
			
			/*if ((movie.mode=="preview" || movie.mode=="maker") && 
					movie.theScionFXAssetInstance!=null && 
					(movie.theYouTubeAssetInstance!=null || movie.theImageAssetInstance!=null)) {
			//if (movie.mode=="preview" || movie.mode=='maker') {
				Application.application.displaySaveCmpnt();
			}*/
		}
		
		/**
		 * Display the save form when the movie has finished.
		 */
		protected function _moviePlayHandler(event:Event) {
			Application.application.hideSaveCmpnt();
		}
			
		
		public function saveMovie(formData:Object) {
			//trace("saving movie");
			
			var movieSaver:MovieSaveLoad = new MovieSaveLoad();
			movieSaver.save(movie, formData);
		}
		
		public function saveMovieRef(ref:FileReference) {
			var movieSaver:MovieSaveLoad = new MovieSaveLoad();
			movieSaver.save(movie, ref);
		}
		
		
		public function loadMovie(movieID:String, bucket:String) {
			var movieLoader:MovieSaveLoad = new MovieSaveLoad();
			movieLoader.load(movieID, bucket);
		}
			

	}
}