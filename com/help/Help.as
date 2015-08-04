package com.help 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	
	public class Help extends Sprite
	{
		/*-------------------------------*
		 |	Private Variables
		 *-------------------------------*/
		private var _buttonTextField:TextField;
		
		private var _helpWindow:MovieClip;
		
		/*-------------------------------*
		 |	Constructor
		 *-------------------------------*/
		public function Help() {
			// Initialize textfield
			_buttonTextField = new TextField();
			_buttonTextField.selectable = false;
			_buttonTextField.defaultTextFormat = new TextFormat("Arial", 20, 0xFFFFFF, null, null, null, null, null, "center");
			_buttonTextField.width = 25;
			_buttonTextField.height = 25;
			_buttonTextField.text = "?";
			_buttonTextField.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);
			_buttonTextField.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
			addChild(_buttonTextField);
			
			// Initialize help window
			var helpWindowClass:Class = getDefinitionByName("HelpWindow") as Class;
			_helpWindow = new helpWindowClass() as MovieClip;
			_helpWindow.visible = false;
			addChild(_helpWindow);
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		/*-------------------------------*
		 |	Private Event Handlers
		 *-------------------------------*/
		private function _onAddedToStage(e:Event) {
			_buttonTextField.x = stage.stageWidth - _buttonTextField.width;
			
			_helpWindow.x = (stage.stageWidth - _helpWindow.width) / 2;
			_helpWindow.y = (stage.stageHeight - _helpWindow.height) / 2;
			
			// Add shade below textfield
			graphics.beginFill(0x00172A, .80);
			graphics.drawRect(_buttonTextField.x, _buttonTextField.y, _buttonTextField.width, _buttonTextField.height);
			graphics.endFill();
		}
		
		private function _onRollOver(e:MouseEvent) {
			_helpWindow.visible = true;
		}
		private function _onRollOut(e:MouseEvent) {
			_helpWindow.visible = false;
		}
	}
}