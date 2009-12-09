package fr.technolog33k.events
{
	import flash.events.Event;
	
	public class NativeSpeechEvent extends Event
	{
		public static const COMMAND_ERROR:String = 'commandError';
		public static const SPEECH_DONE:String = 'speechDone';
		public static const SPEECH_ERROR:String = 'speechError';
		public static const VOICES_LOADED:String = 'voicesLoaded';
		
		public var data:*;
		
		public function NativeSpeechEvent(type:String, data:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}