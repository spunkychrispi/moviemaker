package movie.assets
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.events.SliderEvent;
	
	/**
	 * Code for a widget so that any widget can be used.
	 */
	public class AssetWidgetManager
	{
		
		public var widget:AssetWidget;
		

		var _enabledControls:Array;
		var _bindingVariables:Object;
		
		var target:AssetInstance;
		
		var changeWatchers:Array = new Array();
		
		public function AssetWidgetManager(widget:AssetWidget)
		{
			this.widget = widget;
		}
		
		
		public function initializeControls(asset:AssetInstance, enabledControls:Array=null, bindingVariables:Array=null)
		{
			if (enabledControls) this._enabledControls = enabledControls;
			else this._enabledControls = widget.defaultControls;
			
			if (bindingVariables) this._bindingVariables = bindingVariables;
			else this._bindingVariables = widget.defaultBindingVariables;
			
			this.target = asset;
			
			widget.initializeControls(asset);
			
			// first, remove all the previous changeWatchers
			for each (var cw:ChangeWatcher in changeWatchers) {
				cw.unwatch();
			}
			
			for each (var controlName:String in _enabledControls) {
				changeWatchers.push(BindingUtils.bindProperty(widget[controlName+"Control"], widget.targetProperties[controlName], target, _bindingVariables[controlName]));
				
				var handlerName:String = widget.hasOwnProperty(controlName+"ChangeHandler") ? controlName+"ChangeHandler" : "changeHandler";
				widget[controlName+"Control"].addEventListener(SliderEvent.CHANGE, widget[handlerName]);
				//widget[controlName+"Control"].visible = true;
				//widget[controlName+"Label"].visible = true;
			}
			//BindingUtils.bindProperty(rotationControl, "value", target, "rotation");
			//BindingUtils.bindProperty(this.positionX, "text", target, "x");
			//BindingUtils.bindProperty(this.positionY, "text", target, "y");*/
		}

	}
}