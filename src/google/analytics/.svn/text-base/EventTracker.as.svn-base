package google.analytics
{
	public class EventTracker
	{
		
		import flash.external.ExternalInterface;
		
		static public function trackEvent(category, action, label=null, value=null) {
			//trace("google track: " + category + action + label + value);
			ExternalInterface.call("googleTrackEvent", category, action, label, value);
		}

	}
}