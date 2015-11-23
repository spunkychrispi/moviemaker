package movie.assets
{
	import mx.controls.Image;
	
	public class AssetInstanceCreator
	{
		
		import flash.utils.getDefinitionByName;
		
		// these variables just exist so the compiler will compile these classes in for the getDefinitionByName below
		var imageInstance:ImageAssetInstance;
		var swfInstance:SWFAssetInstance;
		var audioInstance:AudioAssetInstance;
		var videoInstance:VideoAssetInstance;
		var textInstance:TextAssetInstance;
		var youtubeInstance:YouTubeAssetInstance;
		var scionFXInstance:ScionFXAssetInstance;
		var scionFX2Instance:ScionFX2AssetInstance;
		var scionAudioInstance:ScionAudioAssetInstance;
		var scionImageInstance:ScionImageAssetInstance;
		var scionYouTubeInstance:ScionYouTubeAssetInstance;
		var scionTextFXInstance:ScionTextFXAssetInstance;
		var scionImageCannedAssetInstance:ScionImageCannedAssetInstance;
		var scionAudioCannedAssetInstance:ScionAudioCannedAssetInstance;
		var testAssetInstance:TestAssetInstance;
		
		
		//public var stageProperties:Array;
		//public var stageName:String;
		
		/**
		 * Create an object that is a subclass of MovieAssetInstance, based on the type parameter
		 */
		public static function createAssetInstance(type:String, name:String, properties:Object, assetClass:AssetClass=null):*
		{
			var className:String = "movie.assets."+type+"AssetInstance";
			var classVar:Class = getDefinitionByName( className ) as Class;
			var instance:* = new classVar(name, properties, assetClass);
			
			return instance; 
		}
	}
}