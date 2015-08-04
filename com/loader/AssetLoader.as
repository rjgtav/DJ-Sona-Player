package com.loader 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class AssetLoader extends EventDispatcher
	{
		/*-------------------------------*
		 |	Public Static Constants
		 *-------------------------------*/
		public static const CLIP_LIST:Array = [
			"sona_DJ_kinetic",
			"sona_DJ_concussive",
			"sona_DJ_ethereal",
		];
		
		/*-------------------------------*
		 |	Private Static Constants
		 *-------------------------------*/
		private static const FOLDER_FLV:String = "assets/flv/";
		private static const FOLDER_MUSIC:String = "assets/music/";
		
		private static const SUFFIX_INTRO:String = "_intro";
		private static const SUFFIX_LOOP:String = "_loop";
		
		/*-------------------------------*
		 |	Private Variables
		 *-------------------------------*/
		private var _loadedIntros:Array = [];
		private var _loadedLoops:Array = [];
		private var _loadedMusicIntros:Array = [];
		private var _loadedMusicLoops:Array = [];
		
		private var _isStarting:Boolean = true;
		private var _isFinished:Boolean = false;
		
		/*-------------------------------*
		 |	Constructor
		 *-------------------------------*/
		public function AssetLoader() {
			// Start loading everything
			_loadIntro();
			_loadLoop();
			_loadMusicIntro();
			_loadMusicLoop();
		}
		
		/*-------------------------------*
		 |	Public Methods
		 *-------------------------------*/
		public function getIntro(id:int):ByteArray {	return _loadedIntros[id] as ByteArray; }
		public function getLoop(id:int):ByteArray {		return _loadedLoops[id] as ByteArray; }
		public function getMusicIntro(id:int):Sound {	return _loadedMusicIntros[id] as Sound; }
		public function getMusicLoop(id:int):Sound {	return _loadedMusicLoops[id] as Sound; }
		
		/*-------------------------------*
		 |	Private Methods
		 *-------------------------------*/
		private function _checkIfReady() {
			if (
				_isStarting &&
				_loadedIntros.length >= 1 &&
				_loadedLoops.length >= 1 &&
				_loadedMusicIntros.length >= 1 &&
				_loadedMusicLoops.length >= 1
			) {
				_isStarting = false;
				dispatchEvent(new Event("ready"));
			}
			
			var clipNum:int = CLIP_LIST.length;
			
			if (
				!_isFinished &&
				_loadedIntros.length == clipNum &&
				_loadedLoops.length == clipNum &&
				_loadedMusicIntros.length == clipNum &&
				_loadedMusicLoops.length == clipNum
			) {
				_isFinished = true;
				dispatchEvent(new Event("finished"));
			}
		}
		
		private function _loadIntro() {
			var urlRequest:URLRequest = new URLRequest(FOLDER_FLV + CLIP_LIST[_loadedIntros.length] + SUFFIX_INTRO + ".flv");
			var urlLoader:URLLoader = new URLLoader(urlRequest);
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE, _onIntroComplete);
				urlLoader.load(urlRequest);
		}
		private function _loadLoop() {
			var urlRequest:URLRequest = new URLRequest(FOLDER_FLV + CLIP_LIST[_loadedLoops.length] + SUFFIX_LOOP + ".flv");
			var urlLoader:URLLoader = new URLLoader(urlRequest);
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE, _onLoopComplete);
				urlLoader.load(urlRequest);
		}
		private function _loadMusicIntro() {
			var urlRequest:URLRequest = new URLRequest(FOLDER_MUSIC + CLIP_LIST[_loadedMusicIntros.length] + SUFFIX_INTRO + ".mp3");
			var sound:Sound = new Sound();
				sound.addEventListener(Event.COMPLETE, _onMusicIntroComplete);
				sound.load(urlRequest);
		}
		private function _loadMusicLoop() {
			var urlRequest:URLRequest = new URLRequest(FOLDER_MUSIC + CLIP_LIST[_loadedMusicLoops.length] + SUFFIX_LOOP + ".mp3");
			var sound:Sound = new Sound();
				sound.addEventListener(Event.COMPLETE, _onMusicLoopComplete);
				sound.load(urlRequest);
		}
		
		/*-------------------------------*
		 |	Private Event Handlers
		 *-------------------------------*/
		private function _onIntroComplete(e:Event) {
			var urlLoader:URLLoader = URLLoader(e.target);
				urlLoader.removeEventListener(Event.COMPLETE, _onIntroComplete);
			
			_loadedIntros[_loadedIntros.length] = urlLoader.data;
			
			// Check if ready
			_checkIfReady();
			
			// Load next intro
			if (_loadedIntros.length < CLIP_LIST.length)
				_loadIntro();
		}
		private function _onLoopComplete(e:Event) {
			var urlLoader:URLLoader = URLLoader(e.target);
				urlLoader.removeEventListener(Event.COMPLETE, _onLoopComplete);
			
			_loadedLoops[_loadedLoops.length] = urlLoader.data;
			
			// Check if ready
			_checkIfReady();
			
			// Load next loop
			if (_loadedLoops.length < CLIP_LIST.length)
				_loadLoop();
		}
		private function _onMusicIntroComplete(e:Event) {
			var sound:Sound = Sound(e.target);
				sound.removeEventListener(Event.COMPLETE, _onMusicIntroComplete);
			
			_loadedMusicIntros[_loadedMusicIntros.length] = sound;
			
			// Check if ready
			_checkIfReady();
			
			// Load next music intro
			if (_loadedMusicIntros.length < CLIP_LIST.length)
				_loadMusicIntro();
		}
		private function _onMusicLoopComplete(e:Event) {
			var sound:Sound = Sound(e.target);
				sound.removeEventListener(Event.COMPLETE, _onMusicLoopComplete);
			
			_loadedMusicLoops[_loadedMusicLoops.length] = sound;
			
			// Check if ready
			_checkIfReady();
			
			// Load next music loop
			if (_loadedMusicLoops.length < CLIP_LIST.length)
				_loadMusicLoop();
		}
		
	}
}