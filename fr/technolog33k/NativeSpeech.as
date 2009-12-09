package fr.technolog33k
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import fr.technolog33k.events.NativeSpeechEvent;

	public class NativeSpeech extends EventDispatcher
	{
		private var processBuffer:ByteArray;
		private var nativeProcess:NativeProcess;
		
		public function NativeSpeech()
		{
			getVoices();
		}
		
		public function say(text:String, voice:String):void
		{			
			var executable:File = new File('/usr/bin/say');
			if (!executable.exists) {
				dispatchEvent(new NativeSpeechEvent(NativeSpeechEvent.COMMAND_ERROR));
				return;
			}
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.executable = executable;
			var args:Vector.<String> = new Vector.<String>;
			args.push('--voice=' + voice);
			args.push("'" + text + "'");
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
		
		private function getVoices():void
		{
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.executable = new File('/bin/ls');
			var args:Vector.<String> = new Vector.<String>;
			args.push('/System/Library/Speech/Voices/');
			npInfo.arguments = args;
			
			processBuffer = new ByteArray();
			nativeProcess = new NativeProcess();
			nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onGetVoicesOutputData);
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onGetVoicesOutputClose);
			nativeProcess.start(npInfo);
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