package ui 
{
	import flash.display.Sprite;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Button extends Sprite
	{
		protected var textField:TextField;
		private var backColor:int;
		public function Button(text:String, textColor:int=0xffffff, backColor:int=0xff0000)
		{
			this.backColor = backColor;
			//
			textField = new TextField();
			var format:TextFormat = new TextFormat('_sans', Math.round(Capabilities.screenResolutionX*0.03), textColor,true);
			textField.defaultTextFormat = format;
			textField.text = text;
			textField.autoSize = TextFieldAutoSize.CENTER;
			this.addChild(textField);
			textField.mouseEnabled = false;
			//
			this.width = 150;
			this.height = 40;
		}
		
		protected var _width:Number = 10;
		public override function set width(value:Number):void
		{
			this._width = value;
			textField.x = (value - textField.width)/2;
			draw();
		}
		protected var _height:Number = 10;
		public override function set height(value:Number):void
		{
			this._height = value;
			textField.y = Math.round((value-textField.height)/2);
			draw();
		}
		
		protected function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(backColor, 1);
			this.graphics.drawRect(0, 0, _width, _height);
		}
	}
}