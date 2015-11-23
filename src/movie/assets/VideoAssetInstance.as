package movie.assets
{
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import movie.movie.MovieEvent;
	import movie.movie.Movie;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class VideoAssetInstance extends AssetInstance
	{
		
		protected var _isPlaying:Boolean;
		protected var ns:NetStream;
		protected var vid:Video;
	
	
		public function VideoAssetInstance(name:String, properties:Object, assetClass:AssetClass)
		{
			this.type = "Video";
			this._tweenPropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			this._statePropertiesList = ["centerX", "centerY", "width", "height", "rotation"];
			
			this._isPlaying = false;	
			
			Application.application.theStage.addEventListener(MovieEvent.MOVIE_STOP, this._stopHandler);
			
			super(name, properties, assetClass);
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
			//ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.asyncErrorHandler);
			ns.client = new Object();
			
			ns.play(properties.assetPath);
			ns.pause();
			ns.seek(0);
			
			vid = new Video();
			vid.attachNetStream(ns);
			
			this.assetCmpnt = new UIComponent();
			assetCmpnt.addEventListener(FlexEvent.CREATION_COMPLETE, assetLoadedHandler);
			assetCmpnt.addChild(vid); //Vid being a flash.media.Video
			assetCmpnt.width = vid.width;
			assetCmpnt.height = vid.height;
		
		}
		
		
		function asyncErrorHandler(event:AsyncErrorEvent):void
		{
		    // ignore error
		}
		
		
		
		protected function _stopHandler(event:Event)
		{
			this.ns.pause();
			
			this._isPlaying = false;
		}
		
		
		public override function setProperties(properties:Object, currentFrame:int=undefined) 
		{
			
			if (properties.width) vid.width = assetCmpnt.width;
			if (properties.height) vid.height = assetCmpnt.height;
			
			if (this.theMovie) {	
				if (this.theMovie.isPlaying) 
				{
					// we need the isPlaying flag, because we don't want to start the sound again if it's already playing
					if (! this._isPlaying)
					{
						var offset:int = ((currentFrame - this.firstFrame) / Movie.movie.frameRate) * 1000;
						this.ns.seek(offset / 1000);
						this.ns.resume();
						this._isPlaying = true;
					} 
					
				} else {
					var offset:int = ((currentFrame - this.firstFrame) / Movie.movie.frameRate) * 1000;
					this.ns.seek(offset / 1000);
					
				}
			}
			
			super.setProperties(properties, currentFrame);
		}
			


	}
}
