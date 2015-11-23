package movie.assets
{
	import movie.movie.*;
	
	/**
	 * Container for asset properties. "Class" here should maybe be called Factory. AssetClass contains
	 * all the properties necessary for creating an asset instance. After addToMovie is called,
	 * AssetClass creates the asset instance and adds it to the movie.
	 */ 
	public class AssetClass
	{
		var type:String; 
		var group:String;
		public var name:String;
		var thumbnail:*;
		var thumbnailRoll:*;
		public var properties:Object;
		public var buttonProperties:Object;
		
		/**
		 * Any data that needs to be loaded for this asset - it can be stored in the assetClass so 
		 * that it doesn't need to be loaded for each asset.
		 */
		protected var _loadedData:Object; 
		
		public function AssetClass(name:String, type:String, thumbnail:*=null, group:String=null, properties:Object=null, thumbnailRoll:*=null, buttonProperties:Object=null)
		{
			this.type = type;
			this.name = name;
			this.group = group;
			
			//var defaultThumbnail = "assets/"+type+"_AssetClass_thumbnail.png";
			//this.thumbnail = thumbnail ? thumbnail : defaultThumbnail;
			
			this.thumbnail = thumbnail;
			
			if (properties) this.properties = properties;		// these get sent to the instance as properties
			else this.properties = new Object();
			
			if (buttonProperties) this.buttonProperties = buttonProperties;		// these get sent to the instance as buttonProperties
			else this.buttonProperties = new Object();
			
			if (thumbnailRoll) this.thumbnailRoll = thumbnailRoll;
		}
	
	
		public function addToAssetList(list:AssetClassList):Boolean
		{
			
			/*this.nameCmp.text = this._name;
			this.imageCmp.source = "http://local.scion/" + this._thumbnail;*/
			list.addAsset(this);
			return true;
		}
		
		public function addToMovie(theMovie:Movie, x:int, y:int):Boolean
		{
			this.properties.centerX = x;
			this.properties.centerY = y;
			var assetInstance:* = AssetInstanceCreator.createAssetInstance(type, name, properties, this);
			//theMovie.addAssetToCurrentFrame(this.name, assetInstance);
			theMovie.addAssetToMovie(this.name, assetInstance);
			
			/*var assetWidget = new AssetWidget();
			
			// just set the image here for right now - need to move functionality to assetWidget
			assetWidget.source = "http://local.scion/" + this.properties.asset_filepath;
			assetWidget.width = 200;
			assetWidget.height = 200;
			
			assetWidget.x = x;
			assetWidget.y = y;
			//theMovie.addAssetToCurrentFrame("test", assetWidget);
			
			theMovie.addChild(assetWidget);*/
			
			return true;
		}
		
	
		
		
		public function set loadedData(loadedData:Object) {
			properties.loadedData = loadedData;
		}
		
	}
}