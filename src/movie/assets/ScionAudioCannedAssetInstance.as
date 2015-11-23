package movie.assets
{
	public class ScionAudioCannedAssetInstance extends ScionAudioAssetInstance
	{
		public var cannedAsset:Boolean = true;
		
		public function ScionAudioCannedAssetInstance(name:String, properties:Object, assetClass:AssetClass=null)
		{
			super(name, properties, assetClass);
		}
	}
}