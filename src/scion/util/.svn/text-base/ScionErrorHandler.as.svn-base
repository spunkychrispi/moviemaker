package scion.util
{
	import movie.components.TextHelpBox;
	import movie.util.ErrorHandler;
	
	import mx.core.Application;
	
	import scion.components.MovieMaker;
	import mx.managers.PopUpManager;
	
	public class ScionErrorHandler
	{
		
		private static var textWin:TextHelpBox;
			
		public static function makerAlert(title:String, message:String, buttonLabel:String) 
		{
			// pop open the alert to cover the entire component, sans the lefthand tab
			var maker:MovieMaker = Application.application.movieMaker;
			
			var properties:Object = new Object;
			properties.x = maker.x + maker.tabWidth;
			properties.y = maker.y;
			properties.width = maker.width - maker.tabWidth;
			properties.height = maker.height;
			
			ErrorHandler.alertError(title, message, buttonLabel, properties);
		}
		
		
		public static function makerHelp() 
		{ 
			var properties:Object = new Object;
			properties.x = 5;
			properties.y = 5;
			//properties.width = maker.width - maker.tabWidth;
			//properties.height = maker.height;
			
			ErrorHandler.alertHelp(properties);
		}
		
		
		public static function makerTextHelp() 
		{
			var properties:Object = new Object;
			properties.x = 5;
			properties.y = 263;
			//properties.width = maker.width - maker.tabWidth;
			//properties.height = maker.height;
			
			ScionErrorHandler.textWin = ErrorHandler.alertTextHelp(properties);
		}
		
		
		public static function closeTextHelp()
		{
			PopUpManager.removePopUp(ScionErrorHandler.textWin);
		}

	}
}