package movie.movie
{
	
	/**
	 * Contains all the assets in the movie, and generates unique names for the assets
	 */
	public class AssetManager
	{
		
		protected var _assets:Array;				// all assets in the movie, indexed by stageName
		protected var _assetClassCount:Array;		// keeps track of number of assets we have for each class so that
													// we can create unique stageNames
		
		public function AssetManager()
		{
			this._assets = new Array();
			this._assetClassCount = new Array();
		}
		
		/**
		 * Generate a stageName for the asset, and add the asset to the asset list
		 */
		public function addAsset(className:String, asset:Object) {
			
			// add this to the class count
			if (! this._assetClassCount[className])
			{
				this._assetClassCount[className] = 0;
			}
			this._assetClassCount[className]++;
			
			var stageName:String = asset.stageName ? asset.stageName : className + this._assetClassCount[className];
			
			// save the asset internally
			this._assets[stageName] = asset;
			
			return stageName;
		}
		
		
		public function removeAsset(stageName:String)
		{
			delete this._assets[stageName];
			
			// maybe also decrement the classCount?
		}

		public function get assets()
		{
			return this._assets;
		}
		
		public function set assets(assets:Array) {
			_assets = assets;
		}
		
		public function resetState() {
			_assets = new Array();
			_assetClassCount = new Array();
		}

	}
}