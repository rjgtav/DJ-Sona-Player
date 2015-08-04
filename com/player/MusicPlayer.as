package com.player 
{
	import com.loader.AssetLoader;
	import com.Main;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	public class MusicPlayer extends EventDispatcher
	{
		/*-------------------------------*
		 |	Private Variables
		 *-------------------------------*/
		private static const TIMER_WAIT:Number = 1.5;
		
		/*-------------------------------*
		 |	Private Variables
		 *-------------------------------*/
		private var _assetLoader:AssetLoader;
		
		private var _clipIndex:int;
		
		private var _isReady:Boolean = true;
		private var _isLooping:Boolean;
		
		private var _soundIntroChannel:SoundChannel;
		private var _soundLoopChannel:SoundChannel;
		private var _soundIntro:Sound;
		private var _soundLoop:Sound;
		private var _soundTransform:SoundTransform;
		
		private var _state:Object;
		
		private var _timer:Timer;
		
		/*-------------------------------*
		 |	Constructor
		 *-------------------------------*/
		public function MusicPlayer(assetLoader:AssetLoader) {
			_assetLoader = assetLoader;
			
			_soundTransform = new SoundTransform();
			_soundTransform.volume = 1;
			
			_timer = new Timer(0);
			_timer.addEventListener(TimerEvent.TIMER, _onTimer);
		}
		
		/*-------------------------------*
		 |	Public Getters/Setters
		 *-------------------------------*/
		public function getProgress():Number {
			return _isReady ? _soundLoopChannel.position / _soundLoop.length : 0;
		}
		public function getIsReady():Boolean {
			return _isReady;
		}
		
		public function setIsLooping(isLooping:Boolean) {
			_isLooping = isLooping;
		}
		public function setIsMuted(isMuted:Boolean) {
			_soundTransform.volume = isMuted ? 0 : 1;
			
			if(_soundIntroChannel != null)
				_soundIntroChannel.soundTransform = _soundTransform;
			if(_soundLoopChannel != null)
				_soundLoopChannel.soundTransform = _soundTransform;
		}
		public function setIsPlaying(isPlaying:Boolean) {
			if (isPlaying) {
				if (_state.soundIntro) {
					_soundIntroChannel = _soundIntro.play(_state.soundIntroPosition);
					_soundIntroChannel.soundTransform = _soundTransform;
					_soundIntroChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundIntroComplete);
				}
				
				if (_state.soundLoop) {
					_soundLoopChannel = _soundLoop.play(_state.soundLoopPosition);
					_soundLoopChannel.soundTransform = _soundTransform;
					_soundLoopChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundLoopComplete);
				} else {
					_timer.delay = TIMER_WAIT * 1000 - _state.soundIntroPosition;
					_timer.start();
				}
			} else {
				_state = {
					soundIntro: _soundIntroChannel != null,
					soundIntroPosition: _soundIntroChannel != null ? _soundIntroChannel.position : -1,
					soundLoop: _soundLoopChannel != null,
					soundLoopPosition: _soundLoopChannel != null ? _soundLoopChannel.position : -1
				}
				
				stop();
			}
		}
		
		/*-------------------------------*
		 |	Public Methods
		 *-------------------------------*/
		public function play(clipIndex:int) {
			_clipIndex = clipIndex;
			_isReady = false;
			
			stop();
			
			_soundIntro = _assetLoader.getMusicIntro(_clipIndex);
			_soundLoop = _assetLoader.getMusicLoop(_clipIndex);
			
			// Play intro sound
			_soundIntroChannel = _soundIntro.play(0);
			_soundIntroChannel.soundTransform = _soundTransform;
			_soundIntroChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundIntroComplete);
			
			// Play loop sound TIMER_WAIT seconds later
			_soundLoopChannel = null;
			_timer.delay = TIMER_WAIT * 1000;
			_timer.start();
		}
		public function stop() {
			if (_soundIntroChannel != null) {
				_soundIntroChannel.stop();
				_soundIntroChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundIntroComplete);
			}
			
			if (_soundLoopChannel != null){
				_soundLoopChannel.stop();
				_soundLoopChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundLoopComplete);
			}
			
			if (_timer.running)
				_timer.stop();
		}
		
		/*-------------------------------*
		 |	Private Event Handlers
		 *-------------------------------*/
		private function _onSoundIntroComplete(e:Event) {
			_soundIntroChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundIntroComplete);
			_soundIntroChannel = null;
		}
		private function _onSoundLoopComplete(e:Event) {
			_soundLoopChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundLoopComplete);
			
			if (_isLooping) {
				_onTimer(null);
			} else {
				dispatchEvent(e);
			}
		}
		private function _onTimer(e:TimerEvent) {
			_isReady = true;
			_timer.stop();
			
			_soundLoopChannel = _soundLoop.play(0);
			_soundLoopChannel.soundTransform = _soundTransform;
			_soundLoopChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundLoopComplete);
		}
	}
}