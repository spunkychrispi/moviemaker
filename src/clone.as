package {
	
	import flash.utils.ByteArray;
	
	/**
	 * Returns a deep copy of the source. This has not been fully tested - grabbed from 
	 * http://www.kirupa.com/forum/showthread.php?p=1897368
	 */
	public function clone(source:Object):* {
	    var copier:ByteArray = new ByteArray();
	    copier.writeObject(source);
	    copier.position = 0;
	    return(copier.readObject());
	}
}