package fr.technolog33k
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import fr.technolog33k.events.NativeSpeechEvent;

	public class NativeSpeech extends EventDispatcher
	{
		private var processBuffer:ByteArray;
		private var nativeProcess:NativeProcess;
		private var os:String;
		
		public function NativeSpeech()
		{
			os = Capabilities.os.split(' ')[0];
		}
		
		public function say(text:String, voice:String):void
		{
			var executable:File;
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var args:Vector.<String> = new Vector.<String>;

			if (os == 'Windows') {
				executable = new File(File.applicationDirectory.nativePath + '\\bin\\SayWin32.exe');
				args.push("'" + text + "'");
			} else if (os == 'Mac') {
				executable = new File('/usr/bin/say');
				args.push('--voice=' + voice);
				args.push("'" + text + "'");
			} else {
				throw new Error("This application isn't compatible with your operating system (yet?)");
			}
			
			if (!executable.exists) {
				dispatchEvent(new NativeSpeechEvent(NativeSpeechEvent.COMMAND_ERROR, executable.nativePath));
				return;
			}
			npInfo.executable = executable;
			npInfo.arguments = args;
			
			processBuffer = new ByteArray();
			nativeProcess = new NativeProcess();
			nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onSayOutputData);
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onSayOutputClose);
			nativeProcess.start(npInfo);
		}
		
		private function onSayOutputData(e:ProgressEvent):void
		{
			nativeProcess.standardError.readBytes(processBuffer, processBuffer.length);
			
		}
		
		private function onSayOutputClose(e:Event):void
		{
			var output:String = new String(processBuffer);
			if (output.length > 0) {
				dispatchEvent(new NativeSpeechEvent(NativeSpeechEvent.SPEECH_ERROR, output));
			} else {
				dispatchEvent(new NativeSpeechEvent(NativeSpeechEvent.SPEECH_DONE));
			}
		}
		
		public function getVoices():void
		{
			if (os == 'Windows') {
				var voicesList:Array = ['Microsoft Default Voice'];
				dispatchEvent(new NativeSpeechEvent(NativeSpeechEvent.VOICES_LOADED, voicesList));
			} else if (os == 'Mac') {
				var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var args:Vector.<String> = new Vector.<String>;
				
				npInfo.executable = new File('/bin/ls');
				args.push('/System/Library/Speech/Voices/');
				npInfo.arguments = args;
				
				processBuffer = new ByteArray();
				nativeProcess = new NativeProcess();
				nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onGetVoicesOutputData);
				nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onGetVoicesOutputClose);
				nativeProcess.start(npInfo);
			} else {
				throw new Error("This application isn't compatible with your operating system (yet?)");
			}
		}
		
		private function onGetVoicesOutputData(e:ProgressEvent):void
		{
			nativeProcess.standardOutput.readBytes(processBuffer, processBuffer.length);
		}

		private function onGetVoicesOutputClose(e:Event):void
		{
			var buffer:String = new String(processBuffer);
			var pattern:RegExp = new RegExp(/.SpeechVoice/g);
			var voicesList:Array = buffer.replace(pattern, '').split('\n');
			voicesList.pop();
			dispatchEvent(new NativeSpeechEvent(NativeSpeechEvent.VOICES_LOADED, voicesList));
		}
	}
}