package movie.util
{
	import mx.rpc.remoting.mxml.RemoteObject;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class DataClientRemoteObject implements IDataClient
	{
		
		protected var _destination:String;
		protected var _source:String;
		protected var _method:String;
		protected var _params:Array;
		
		protected var _remoteObject:RemoteObject;
		
		public function DataClientRemoteObject(destination:String, source:String, method:String, params:Array)
		{
			this._destination 	= destination;
			this._source 		= source;
			this._method 		= method;
			this._params 		= params;
			
			this._remoteObject 					= new RemoteObject();
			this._remoteObject.destination 		= this._destination;
			this._remoteObject.source 			= this._source;
			this._remoteObject.showBusyCursor 	= true;
		}
		
		public function setFaultHandler(faultHandler:Function):void
		{
			this._remoteObject.addEventListener(FaultEvent.FAULT, faultHandler);
		}
		
		public function setResultHandler(resultHandler:Function):void
		{
			this._remoteObject.addEventListener(ResultEvent.RESULT, resultHandler);
		}
		
		public function execute():void {
			
			// this confusing statement is just calling the method of the remote object with
			// an array of parameters, as opposed to a normal delimited set of function parameters
			this._remoteObject[this._method].send.apply(null, this._params);
		}
	}
}