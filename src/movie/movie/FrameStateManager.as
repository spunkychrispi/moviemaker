package movie.movie
{
	import mx.collections.ArrayCollection;
	
	
	/**
	 * 
	 */
	public class FrameStateManager
	{
		/**
		 * _keyFrames[assetName][propertyName][keyFrame#] - keeps track of property/keyframe combos
		 * The propertyName value will be an indexed array of the keyframes in order, to allow quick searching
		 * of the keyframe closest to the current frame.
		 */
		protected var _keyFrames:Object;
		
		/**
		 * _frames[assetName][frame][propertyName][propertyValue] - there will only be frame properties
		 * for tween frames or keyframes.
		 */	
		protected var _frames:Object;
		
		protected var _numberOfFrames:int;
		
		protected var _origNumberOfFrames:int;
		
		
		public function FrameStateManager(numberOfFrames:int)
		{
			_origNumberOfFrames = numberOfFrames;
			this._numberOfFrames = numberOfFrames;
			
			this._frames = new Object();
			this._keyFrames = new Object();
		}
		
		
		public function resetState() {
			
			_numberOfFrames = _origNumberOfFrames;
			_frames = new Object();
			_keyFrames = new Object();
		}
		
		
		/**
		 * Set the properties of the asset for the corresponding frame.
		 */
		public function setAssetsFrameProperties(frame:int, assetName:String, properties:Object, tweenPropertiesList:Array=null, keyFrame:Boolean=true)
		{
			// if this is a keyframe - meaning this will be a keyframe for any properties that have
			// changed since the previous keyframe
			if (keyFrame) {
				
				// initialize the asset's keyframe object if it's not already
				if (! this._keyFrames[assetName]) {
					this._keyFrames[assetName] = new Object();
				}
				
				// for each property, find its most recent keyframe. If there isn't one, or if the property has changed
				// since the keyframe, create a new keyframe from the current frame
				for (var propertyName:String in properties) {
					// initialize the asset property's keyframe array if it's not already
					this._prepKeyFrame(assetName, propertyName);
					
					var mostRecentKeyFrame:int = getPropertysNearestKeyFrame(assetName, propertyName, frame);
					
					// if there was a previous key frame and the value in the previous keyframe is the same as this value,
					// this isn't a new keyframe for the property
					if (mostRecentKeyFrame) {
					
						var mostRecentProperties:Object = this.getAssetsFrameProperties(assetName, mostRecentKeyFrame);
						
						// however, if the property is x or y, we want to record this if either x or y has changed
						if (propertyName == "x" || propertyName == "y") {
							
							if (mostRecentProperties.x == properties.x && mostRecentProperties.y == properties.y)
								continue;
						
						} else {
							if (mostRecentProperties[propertyName] == properties[propertyName]) {
								// if this isn't a new keyframe, move on to the next property
								continue;
							} 
						}
					}
					
					// otherwise, set the frame property, make a keyframe, and perform tweening if this is a tween property
					this._addPropertyToFrame(assetName, propertyName, properties[propertyName], frame);
					
					// add the keyframe
					this._addKeyFrame(assetName, propertyName, frame);
					
					// perform tweening
					if (tweenPropertiesList && tweenPropertiesList.indexOf(propertyName) > -1)
					{
						if (mostRecentKeyFrame) 
						{
							// tween the property - first tween from the most recent keyframe to this frame
							this._tweenProperty(assetName, propertyName, mostRecentProperties[propertyName], mostRecentKeyFrame, properties[propertyName], frame);
						}
						
						// now, get the next keyframe after this one
						// if there is one, and the values are different, tween between the two frames
						var nextKeyFrame:int = getPropertysNearestKeyFrame(assetName, propertyName, frame, false);
						if (nextKeyFrame) 
						{
							var nextProperties:Object = this.getAssetsFrameProperties(assetName, nextKeyFrame);
							if (nextProperties[propertyName] != properties[propertyName])
							{
								this._tweenProperty(assetName, propertyName, properties[propertyName], frame, nextProperties[propertyName], nextKeyFrame);
							}
						}
					}
					
				}
	
			}
			
		}
		
		
		/**
		 * Creates the array for the asset/property's keyframes if there isn't one already.
		 */
		protected function _prepKeyFrame(assetName:String, propertyName:String)
		{
			if (! this._keyFrames[assetName][propertyName]) 
			{
				this._keyFrames[assetName][propertyName] = new Array();
			}	
		}
		
		
		/**
		 * Creates the frame object and assetName properties object if needed
		 * 
		 */
		protected function _prepFrame(frame:int, assetName:String)
		{
			// create the frame object if there isn't one already
			if (! this._frames.hasOwnProperty(assetName)) 
			{
				this._frames[assetName] = new Object();
			}
			
			// create the asset properties object if there isn't one already
			if (! this._frames[assetName].hasOwnProperty(frame))
			{
				this._frames[assetName][frame] = new Object();
			}
		}

		
		protected function _tweenProperty(assetName:String, propertyName:String, valueA:Number, frameA:int, valueB:Number, frameB:int)
		{	
			var tweenValue:Number;
			var tweenFrame:int;
			var numberOfTweenFrames:int = (frameB - frameA) - 1;
			
			var incrementValue = (valueB - valueA) / (numberOfTweenFrames + 1);
			
			// for each tween frame, generate the tween properties
			for (var tweenCount:int=1; tweenCount<=numberOfTweenFrames; tweenCount++) 
			{
				tweenFrame = tweenCount + frameA;
				//tweenValue = valueA + Math.round(tweenCount * incrementValue);
				tweenValue = valueA + (tweenCount * incrementValue);	// took out the rounding
				this._addPropertyToFrame(assetName, propertyName, tweenValue, tweenFrame);
			}	
		}
		
		
		
		public function getPropertysNearestKeyFrame(assetName:String, propertyName:String, frame:int, getPreceeding:Boolean=true):int
		{
			// loop through the keyFrames array till you find the keyFrame just before the current frame
			// we're just doing a basic loop search for the time being, as opposed to something more
			// efficient but more complicated
			
			// if get getPreceeding, return the closest keyFrame before the current frame, 
			// if not getPreceeding, return the closest keyFrame after the current frame
			
			var mostRecentKeyFrame:int;
			for each (var keyFrame:int in this._keyFrames[assetName][propertyName])
			{
				if (getPreceeding)
				{ 
					if (keyFrame >=frame) break;
				} else
				{
					if (keyFrame > frame) break;
				}
				mostRecentKeyFrame = keyFrame;
			}
			
			if (getPreceeding) return mostRecentKeyFrame;
			else return keyFrame;
		}
			
		
		public function getAssetsFrameProperties(assetName:String, frame:int)
		{
			if (this._frames[assetName] && this._frames[assetName][frame])
				return this._frames[assetName][frame];
			else return null;
		}
		
		
		public function getAssetsFrameProperty(assetName:String, propertyName:String, frame:int)
		{
			var properties:Object = this.getAssetsFrameProperties(assetName, frame);
			if (properties && properties.hasOwnProperty(propertyName)) return properties[propertyName];
			else return null;
		}
		
		
		
		protected function _addPropertyToFrame(assetName:String, propertyName:String, propertyValue:*, frame:int)
		{
			// create the frame object + asset/property objects if there isn't one already
			this._prepFrame(frame, assetName);
			
			this._frames[assetName][frame][propertyName] = propertyValue;
		}
		
		
		
		protected function _addKeyFrame(assetName:String, propertyName:String, frame:int)
		{
			// find the most recent keyframe before this, and splice this into the array just after
			// if the keyframe already exists, then don't do anything
			
			var keyFrameAtIndex:int;
			for (var keyFrameIndex=0; keyFrameIndex<this._keyFrames[assetName][propertyName].length; keyFrameIndex++)
			{
				keyFrameAtIndex = this._keyFrames[assetName][propertyName][keyFrameIndex];
				if (keyFrameAtIndex >=frame) break;
			}
			
			if (this._keyFrames[assetName][propertyName][keyFrameIndex] != frame)
			{
				// now, we want to insert the new keyFrame at keyFrameIndex, so splice the array there
				this._keyFrames[assetName][propertyName].splice(keyFrameIndex, 0, frame);
			}
		}
		
		
		protected function _deleteKeyFrame(assetName:String, propertyName:String, frame:int, deleteProceedingKeyFrames:Boolean=true)
		{
			// get the index of the keyframe
			var keyFrameAtIndex:int;
			for (var keyFrameIndex=0; keyFrameIndex<this._keyFrames[assetName][propertyName].length; keyFrameIndex++)
			{
				keyFrameAtIndex = this._keyFrames[assetName][propertyName][keyFrameIndex];
				if (keyFrameAtIndex >=frame) break;
			}
			
			// if we're deleting all the keyframes starting with this one, just truncate the array
			if (deleteProceedingKeyFrames)
			{
				this._keyFrames[assetName][propertyName] = this._keyFrames[assetName][propertyName].slice(0, keyFrameIndex);
			} else
			{
				// otherwise, only delete the keyFrame at the keyFrameIndex if it actually matches the frame sent in
				// if it doens't match, then there isn't a keyframe for this frame
				if (keyFrameAtIndex == frame)
				{
					this._keyFrames[assetName][propertyName].splice(keyFrameAtIndex, 1);
				}
			}
			
			
		}
		
		
		public function getAssetsMostRecentState(assetName:String, propertiesList:Array, currentFrame:int):Object
		{
			var returnProperties:Object = new Object();
			var returnProperty:*;
			
			// if the remove_from_stage state has been set before this frame, then just return remove_from_stage
			if (! this.isAssetOnStage(assetName, currentFrame))
			{
				//returnProperties.remove_from_stage = 1;
				return null;
				
			} else
			{
				// for each property in property list, get the most recent value for the property
				for each (var propertyName:String in propertiesList)
				{
					returnProperty = this.getPropertysMostRecentState(assetName, propertyName, currentFrame);
					if (returnProperty != null) returnProperties[propertyName] = returnProperty;
				}
			}
			
			return returnProperties;	
		}
		
		
		
		public function isAssetOnStage(assetName:String, frame:int):Boolean
		{
			// currently, just return true unless the asset has been deleted - ie unless it has
			// removeFromStage property for a keyframe
			var onStage = true;
			if (this._keyFrames[assetName])
			{
				if (this._keyFrames[assetName].removeFromStage && this._keyFrames[assetName].removeFromStage[0] <= frame)
				{
					onStage = false;
				}
			} else
			{
				onStage = false;
			}
			
			return onStage;
		}
		
		
		public function getPropertysMostRecentState(assetName:String, propertyName:String, currentFrame:int)
		{
			var mostRecentFrame:int = currentFrame;
			var returnState:*;
			
			// if there isn't a frame state for this property, get the most recent keyframe
			returnState = this.getAssetsFrameProperty(assetName, propertyName, mostRecentFrame);
			
			if (returnState == null)
			{
				mostRecentFrame = this.getPropertysNearestKeyFrame(assetName, propertyName, currentFrame);
				if (mostRecentFrame)
				{
					returnState = this.getAssetsFrameProperty(assetName, propertyName, mostRecentFrame);
				}
			}
			
			return returnState;
		}
		
		
		public function removeAssetsFrameProperties(assetName:String, frame:int, deleteFromProceedingStates:Boolean=false)
		{
			// delete from the frames
			delete this._frames[assetName][frame];
			
			if (deleteFromProceedingStates)
			{
				// this is a brute interation through all the remaining frames
				// could be more efficient
				for (var x:int=frame+1; x<=this._numberOfFrames; x++)
				{
					if (this._frames[assetName][frame]) delete this._frames[assetName][frame];
				}
			}
			
			// delete the keyframe setting
			for (var propertyName in this._keyFrames[assetName])
			{
				this._deleteKeyFrame(assetName, propertyName, frame, deleteFromProceedingStates);
			}
		}
		
		
		/**
		 * Completely remove the asset from the state manager
		 */
		public function deleteAsset(assetName:String)
		{
			delete this._frames[assetName];
			delete this._keyFrames[assetName];
		}
			
		
		public function get frames() {
			return _frames;
		}
		
		
		public function set frames(frames:Object) {
			_frames = frames;
		}
		
		
		public function get keyFrames() {
			return _keyFrames;
		}
		
		public function set keyFrames(keyFrames:Object) {
			_keyFrames = keyFrames;
		}
		
	
	}
}