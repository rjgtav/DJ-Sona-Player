package com.player 
{
	import com.loader.AssetLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	
	public class PlayerStatus extends Sprite
	{
		/*-------------------------------*
		 |	Private Static Constants
		 *-------------------------------*/
		private static const SUFFIX_ICON:String = "_icon";
		
		/*-------------------------------*
		 |	Private Variables
		 *-------------------------------*/
		private var _icons:Array = [];
		private var _iconFirst:Bitmap;
		
		private var _isLooping:Boolean;
		
		private var _musicPlayer:MusicPlayer;
		private var _sprite:Sprite;
		
		private var _state:Object;
		
		private var _textField:TextField;
		
		/*-------------------------------*
		 |	Constructor
		 *-------------------------------*/
		public function PlayerStatus(musicPlayer:MusicPlayer) {
			_musicPlayer = musicPlayer;
			
			this.scaleX = this.scaleY = .35;
			
			// Initialize _icons array
			var icon:Bitmap;
			for (var i:int = 0; i < AssetLoader.CLIP_LIST.length; i ++ ) {
				var iconClass:Class = getDefinitionByName(AssetLoader.CLIP_LIST[i] + SUFFIX_ICON) as Class;
				icon = new Bitmap(BitmapData(new iconClass()), "auto", true);
				_icons.push(icon);
				
				addChild(icon);
			}
			
			// Initialize sprite
			_sprite = new Sprite();
			addChild(_sprite);
			
			// Initialize textfield
			_textField = new TextField();
			_textField.selectable = false;
			_textField.defaultTextFormat = new TextFormat("Arial", 40, 0xFFFFFF, null, null, null, null, null, "center");
			_textField.width = icon.width;
			_textField.height = 50;
			_textField.x = icon.width - _textField.width;
			_textField.y = icon.height - _textField.height;
			addChild(_textField);
		}
		
		/*-------------------------------*
		 |	Public Getters/Setters
		 *-------------------------------*/
		public function setIsLooping(isLooping:Boolean) {
			_isLooping = isLooping;
			
			_textField.text = _isLooping ? "Loop" : "";
		}
		public function setIsPlaying(isPlaying:Boolean) {
			if (isPlaying) {
				if (_state.onEnterFrame)
					addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			} else {
				_state = {
					onEnterFrame: hasEventListener(Event.ENTER_FRAME)
				}
				
				stop();
			}
		}
		
		/*-------------------------------*
		 |	Public Methods
		 *-------------------------------*/
		public function play(clipIndex:int) {
			stop();
			
			_iconFirst = _icons[clipIndex];
			_iconFirst.alpha = 1;
			_iconFirst.x = 0;
			_iconFirst.scaleX = _iconFirst.scaleY = 1;
			
			var second:Bitmap = _icons[++clipIndex % _icons.length];
				second.alpha = .5;
				second.x = _iconFirst.x + _iconFirst.width;
				second.scaleX = second.scaleY = .75;
			
			var third:Bitmap = _icons[++clipIndex % _icons.length];
				third.alpha = .5;
				third.x = second.x + second.width;
				third.scaleX = third.scaleY = .75;
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		public function stop() {
			removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		/*-------------------------------*
		 |	Private Event Handlers
		 *-------------------------------*/
		private function _onEnterFrame(e:Event) {
			_sprite.graphics.clear();
			
			if (_isLooping) {
				// Add shade behind text
				_sprite.graphics.beginFill(0x00172A, .80);
				_sprite.graphics.drawRect(_textField.x, _textField.y, _textField.width, _textField.height);
				_sprite.graphics.endFill();
			} else {
				// Show progress bar
				_sprite.graphics.lineStyle(7, 0x00FF00, 1);
				_sprite.graphics.moveTo(0, _iconFirst.height);
				_sprite.graphics.lineTo(Math.max(2, _iconFirst.width * _musicPlayer.getProgress()), _iconFirst.height);
			}
		}
	}
}