package movie.assets
{
	
	import movie.util.*;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class AssetImporter
	{
		
		protected var _dataClient:IDataClient;
		protected var _dataTransformer:IDataTransform;
		protected var _retrieveAssetsCallback:Function;
		
		public function AssetImporter(dataClient:IDataClient=null, dataTransformer:IDataTransform=null)
		{
			if (dataClient) {
				this.dataClient = dataClient;
			}
			
			if (dataTransformer) {
				this.dataTransformer = dataTransformer;
			}
		}
		
		public function get dataClient()
		{
			return this._dataClient;
		}
		
		public function set dataClient(dataClient:IDataClient)
		{
			dataClient.setResultHandler(this.retrievedAssetsHandler);
			dataClient.setFaultHandler(this.importAssetsFaultHandler);
			
			this._dataClient = dataClient;
		}
		
		public function get dataTransformer() {
			return this._dataTransformer
		}
		
		public function set dataTransformer(dataTransformer:IDataTransform) {
			this._dataTransformer = dataTransformer;
		}

		public function importAssets(callback:Function):void
		{
			this._retrieveAssetsCallback = callback;
			
			this.dataClient.execute();
		
		}
		
		public function retrievedAssetsHandler(event:ResultEvent):void {
			
			var assets:Array = new Array();
			var rawAssets:Array = event.result as Array;
			
			for each (var asset in rawAssets) {
				assets.push(this._dataTransformer.transform(asset));
			}
			
			this._retrieveAssetsCallback(assets);
		}
		
		public function importAssetsFaultHandler(event:FaultEvent):void
		{
			
		}
		
		/*public function sendAssetsTo(destination:DisplayObjectContainer):void
		{
			for each (var assetProto:Object in this._assets) {
				
				var assetObject = new MovieAsset(assetProto.node_title);
				assetObject.addToAssetList(destination);
				
			}
		}*/
	}
}
