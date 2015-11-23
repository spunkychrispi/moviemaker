package scion.assets
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import movie.assets.AssetClassList;
	import movie.assets.AssetClassListItem;

	/**
	 * Encapsulates button management - when one fx asset is selected, the others
	 * are unselected.
	 */
	public class ScionAssetClassList extends AssetClassList
	{
		
		//protected var assetButtonSelected:Object = new Object();
		//protected var selectedButton:AssetClassListItem;
		
		public function ScionAssetClassList(listContainer:DisplayObjectContainer)
		{
			super(listContainer);	
		}
		
		protected override function addListItem(assetItem:AssetClassListItem, position:int) {
			
			//[assetItem.asset] = false;
			assetItem.addEventListener(MouseEvent.CLICK, clickHandler);
			super.addListItem(assetItem, position);
		}
		
		/**
		 * Deselect all the buttons except for the one currently selected.
		 */
		protected function clickHandler(event:Event) {
			/*var targetAssetName:* = event.currentTarget.asset;
			
			for (var assetName:String in assetButtonSelected) {
				assetButtonSelected[assetName] = false;
			}
			assetButtonSelected[targetAssetName] = true;*/
			
			deselectItems();
			
			event.currentTarget.select();		
		}
		
		
		public function deselectItems()
		{
			var assetItem:AssetClassListItem;
			for (var x:int=0; x<_listContainer.numChildren; x++) {
				assetItem = _listContainer.getChildAt(x) as AssetClassListItem;
				assetItem.deselect();
			}	
		}
		
	}
}