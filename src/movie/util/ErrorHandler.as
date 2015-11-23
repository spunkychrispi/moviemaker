package movie.util
{
	
	// the error handling + popup windows is very, very sloppy due to time restrictions
	public class ErrorHandler
	{
		import mx.controls.Alert;
		import movie.components.AlertBox;
		import movie.components.DialogueBox;
		import movie.components.HelpBox;
		import movie.components.TextHelpBox;
		import mx.managers.PopUpManager;
		import mx.core.Application;
		import flash.events.Event;
		
       /* public static function alertError(text:String, title:String=null) {
        	Alert.show(text, title);
        }*/
        
        public static function alertError(title:String, message:String, buttonLabel:String=null, properties:Object=null, styleName="null") 
        {
        	var win:AlertBox = new AlertBox();
        	win.title = title;
        	win.message = message;
        	win.buttonLabel = buttonLabel;
        	if (buttonLabel == null) win.buttonVisible = false;
        	else win.buttonVisible = true;
        	
        	if (styleName) {
        		win.styleName = styleName;
        	}
        	for (var key:String in properties) {
        		win[key] = properties[key];
        	}
        	PopUpManager.addPopUp(win, Application.application.theStage, true);
        }
        
        
        public static function alertDialogue(title:String, message:String, callback:Function, properties:Object=null, styleName="null") 
        {
        	var win:DialogueBox = new DialogueBox();
        	win.title = title;
        	win.message = message;
        	if (styleName) {
        		win.styleName = styleName;
        	}
        	for (var key:String in properties) {
        		win[key] = properties[key];
        	}
        	win.addEventListener(Event.CLOSE, callback);
        	
        	PopUpManager.addPopUp(win, Application.application.theStage, true);
        }
        
        
        public static function alertHelp(properties:Object=null, styleName="null") 
        {
        	var win:HelpBox = new HelpBox();
        	
        	/*if (styleName) {
        		win.styleName = styleName;
        	}*/
        	for (var key:String in properties) {
        		win[key] = properties[key];
        	}
        	
        	PopUpManager.addPopUp(win, Application.application.theStage, false);
        }
        
        
        public static function alertTextHelp(properties:Object=null, styleName="null") 
        {
        	var win:TextHelpBox = new TextHelpBox();
        	
        	/*if (styleName) {
        		win.styleName = styleName;
        	}*/
        	for (var key:String in properties) {
        		win[key] = properties[key];
        	}
        	
        	PopUpManager.addPopUp(win, Application.application.theStage, false);
        	
        	// return win so that we can close it programmatically
        	return win;
        }
        	
        
        public static function alertInfo(text:String, flags:uint=0x4, clickListener:Function=null, title:String=null) {
        	Alert.show(text, title, flags, null, clickListener);
        }
	}
}