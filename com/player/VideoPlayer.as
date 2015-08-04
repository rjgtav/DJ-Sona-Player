package com.player 
{
	import com.loader.AssetLoader;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.utils.ByteArray;
	
	public class VideoPlayer extends Sprite
	{
		/*-------------------------------*
		 |	Private Variables
		 *-------------------------------*/
		private var _assetLoader:AssetLoader;
		
		private var _byteArrayIntro:ByteArray;
		private var _byteArrayLoop:ByteArray;
		
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		
		private var _state:Object;
		
		private var _video:Video;
		
		/*-------------------------------*
		 |	Constructor
		 *-------------------------------*/
		public function VideoPlayer(assetLoader:AssetLoader) {
			_assetLoader = assetLoader;
			
			_video = new Video(1280, 800);
			_video.smoothing = true;
			_video.deblocking = 1;
			addChild(_video);
		}
		
		/*-------------------------------*
		 |	Public Getters/Setters
		 *-------------------------------*/
		public function setIsPlaying(isPlaying:Boolean) {
			if (isPlaying) {
				if (!_state.netConnection)
					connect();
				else if (!_state.netStream)
					connectStream();
				else
					_netStream.resume();
			} else {
				_state = {
					netConnection: _netConnection != null,
					netStream: _netStream != null,
					isPlaying: _netStream != null && _netStream.time > 0
				}
				
				_netStream.pause();
			}
		}
		
		/*-------------------------------*
		 |	Public Methods
		 *-------------------------------*/
		public function play(clipIndex:int) {
			stop();
			
			_byteArrayIntro = _assetLoader.getIntro(clipIndex);
			_byteArrayLoop = _assetLoader.getLoop(clipIndex);
			connect();
		}
		
		public function stop() {
			if (_netConnection != null) {
				_netConnection.close();
				_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
				_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError);
				
				_netConnection = null;
			}
			
			if (_netStream != null) {
				_netStream.close();
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
				_netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError);
				
				_netStream = null;
			}
		}
		
		/*-------------------------------*
		 |	Private Methods
		 *-------------------------------*/
		private function connect() {
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError);
			_netConnection.connect(null);
		}
		private function connectStream() {
			_netStream = new NetStream(_netConnection);
			_netStream.client = this;
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
			_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError);
			
			_video.attachNetStream(_netStream);
			
			_netStream.play(null);
			_netStream.appendBytes(_byteArrayIntro);
		}
		
		/*-------------------------------*
		 |	Public Event Handlers
		 *-------------------------------*/
		public function onMetaData(metaData:Object) {
			/*
			for (var propName:String in metaData) {
				trace(propName + " = " + metaData[propName]);
			}
			*/
			
			// Add the loop video again to the stream
			_netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			_netStream.appendBytes(_byteArrayLoop);
		}
		public function onXMPData(xmpData:Object) { }
		public function onPlayStatus(playStatus:Object) { }
		
		/*-------------------------------*
		 |	Private Event Handlers
		 *-------------------------------*/
		private function _onAsyncError(e:AsyncErrorEvent) {
			throw new Error("Async error: " + e);
		}
		private function _onNetStatus(e:NetStatusEvent) {
			switch(e.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					throw(new Error("Unable to locate video data."));
					break;
			}
		}
		private function _onSecurityError(e:SecurityErrorEvent) {
			throw new Error("Security error: " + e);
		}
	}
}