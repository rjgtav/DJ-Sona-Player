package com 
{
	import com.help.Help;
	import com.loader.AssetLoader;
	import com.player.MusicPlayer;
	import com.player.PlayerStatus;
	import com.player.VideoPlayer;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class Main extends MovieClip
	{
		/*-------------------------------*
		 |	Private Variables
		 *-------------------------------*/
		private var _aspectRatio:Number;
		private var _currentClip:int;
		
		private var _isFinished:Boolean;
		private var _isLooping:Boolean;
		private var _isMuted:Boolean;
		private var _isPlaying:Boolean = true;
		
		private var _assetLoader:AssetLoader;
		private var _help:Help;
		private var _musicPlayer:MusicPlayer;
		private var _playerStatus:PlayerStatus;
		private var _videoPlayer:VideoPlayer;
		
		private var _nativeWindow:NativeWindow;
		
		/*-------------------------------*
		 |	Constructor
		 *-------------------------------*/
		public function Main() {
			_assetLoader = new AssetLoader();
			_assetLoader.addEventListener("ready", _onAssetLoaderReady);
			_assetLoader.addEventListener("finished", _onAssetLoaderFinished);
			
			_musicPlayer = new MusicPlayer(_assetLoader);
			_musicPlayer.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_videoPlayer = new VideoPlayer(_assetLoader);
			addChild(_videoPlayer);
			
			_playerStatus = new PlayerStatus(_musicPlayer);
			addChild(_playerStatus);
			
			_help = new Help();
			addChild(_help);
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		/*-------------------------------*
		 |	Private Methods
		 *-------------------------------*/
		private function _playClip(clipIndex:int) {
			if (!_musicPlayer.getIsReady())
				return;
			
			_currentClip = clipIndex % AssetLoader.CLIP_LIST.length;
			
			_musicPlayer.play(_currentClip);
			_videoPlayer.play(_currentClip);
			_playerStatus.play(_currentClip);
		}
		
		/*-------------------------------*
		 |	Private Event Handlers
		 *-------------------------------*/
		private function _onAddedToStage(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			_nativeWindow = stage.nativeWindow;
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, _onResize);
			
			_aspectRatio = _nativeWindow.width / _nativeWindow.height;
			
			stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
		}
		
		private function _onAssetLoaderFinished(e:Event) {
			_assetLoader.removeEventListener("finished", _onAssetLoaderFinished);
			
			_isFinished = true;
		}
		private function _onAssetLoaderReady(e:Event) {
			_assetLoader.removeEventListener("ready", _onAssetLoaderReady);
			
			_playClip(0);
		}
		
		private function _onKeyUp(e:KeyboardEvent) {
			var keyCode:int = e.keyCode;
			
			if (keyCode == 76) {							// L
				// Toogle looping
				_isLooping = !_isLooping;
				
				_musicPlayer.setIsLooping(_isLooping);
				_playerStatus.setIsLooping(_isLooping);
			} else if (keyCode == 77) {						// M
				// Toggle muted
				_isMuted = !_isMuted;
				
				_musicPlayer.setIsMuted(_isMuted);
			} else if (keyCode == 78 || keyCode == 53) {	// N or 5
				if (!_isFinished)
					return;
				
				// Play next track
				_playClip(_currentClip + 1);
			} else if (keyCode == 80 || keyCode == 32) {	// Space or P
				_isPlaying = !_isPlaying;
				
				_videoPlayer.setIsPlaying(_isPlaying);
				_musicPlayer.setIsPlaying(_isPlaying);
				_playerStatus.setIsPlaying(_isPlaying);
			} else if (keyCode == 82) {						// R
				// Replay current track
				_playClip(_currentClip);
			} else if (keyCode == 122) {					// F11
				if (stage.displayState == StageDisplayState.NORMAL)
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				else
					stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function _onResize(e:NativeWindowBoundsEvent) {
			e.preventDefault();
			
			if (e.beforeBounds.width != e.afterBounds.width) {
				_nativeWindow.width = e.afterBounds.width;
				_nativeWindow.height = _nativeWindow.width / _aspectRatio;
			} else if (e.beforeBounds.height != e.afterBounds.height) {
				_nativeWindow.height = e.afterBounds.height;
				_nativeWindow.width = _nativeWindow.height * _aspectRatio;
			}
		}
		
		private function _onSoundComplete(e:Event) {
			_playClip(_currentClip + 1);
		}
		
	}
}