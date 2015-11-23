package movie.assets
{
	import flash.display.DisplayObjectContainer;
	
	import scion.components.AssetButton;
	
	/**
	 * List of assetClasses, to be sent to a container component for display
	 */
	public class AssetClassList
	{
		
		protected var _listContainer:DisplayObjectContainer;
		

		public function AssetClassList(listContainer:DisplayObjectContainer)
		{
			this._listContainer = listContainer;	
		}
		
		
		public function addAsset(asset:AssetClass, position:int=-1) {
			
			var assetItem:AssetClassListItem = new AssetClassListItem();
			assetItem.constructor(asset);
			
			addListItem(assetItem, position);
		}
		
		protected function addListItem(assetItem:AssetClassListItem, position:int) {
			if (position!=-1) this._listContainer.addChildAt(assetItem, position);
			else this._listContainer.addChild(assetItem);
		}
		
		
		// reset the asset buttons to the unselected state
		public function resetAssets() {
			
			var assetButton:AssetButton;
			for (var x:int=0; x<_listContainer.numChildren; x++) {
				assetButton = _listContainer.getChildAt(x) as AssetButton;
				assetButton.deselect();
			}
		}
	}
}