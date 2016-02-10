package ui 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class ScrollPane extends Sprite
	{
		private var back:Shape;
		private var view:Shape;
		private var cont:Sprite;
		private var contMask:Shape;
		public function ScrollPane()
		{
			back = new Shape();
			back.graphics.beginFill(0x0, 0);
			back.graphics.drawRect(0, 0, 10, 10);
			back.graphics.endFill();
			super.addChild(back);
			//
			view = new Shape();
			view.graphics.beginFill(0x999999, 1);
			view.graphics.drawRect(0, 0, 4, 2);
			view.graphics.endFill();
			super.addChild(view);
			//
			cont = new Sprite();
			cont.graphics.beginFill(0x0, 0);
			cont.graphics.drawRect(0, 0, 10, 10);
			cont.graphics.endFill();
			super.addChild(cont);
			//
			contMask = new Shape();
			contMask.x = cont.x;
			contMask.graphics.beginFill(0xff0000, 0.5);
			contMask.graphics.drawRect(0, 0, 10, 10);
			contMask.graphics.endFill();
			super.addChild(contMask);
			cont.mask = contMask;
			//
			this.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler, true);
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			if (isMove) {
				event.stopImmediatePropagation();
				isMove = false;
			}
		}
		
		private var isMove:Boolean;
		private var downContY:Number;
		private var downMouseY:Number;
		private function downHandler(event:MouseEvent):void
		{
			downContY = cont.y;
			downMouseY = this.mouseY;
			this.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
		private function moveHandler(event:MouseEvent):void
		{
			if (!isMove && Math.abs(downMouseY-this.mouseY) > 2) {
				isMove = true;
			}
			var newY:Number = downContY + (this.mouseY-downMouseY);
			if (newY < _height-cont.height) {
				newY = _height-cont.height;
			}
			if (newY > 0) {
				newY = 0;
			}
			cont.y = newY;
			var percent:Number = cont.y/(_height-cont.height);
			view.y = (_height-view.height)*percent;
		}
		private function upHandler(event:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
		
		public override function set width(value:Number):void
		{
			back.width = value;
			view.x = value-view.width;
			contMask.width = value;
		}
		
		private var _height:Number = 10;
		public override function set height(value:Number):void
		{
			this._height = value;
			back.height = value;
			contMask.height = value;
			reinit();
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			cont.addChild(child)
			reinit();
			return child;
		}
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			cont.removeChild(child)
			reinit();
			return child;
		}
		private function reinit():void
		{
			if (cont.height < _height) {
				view.visible = false;
				return;
			}
			view.visible = true;
			view.height = _height/(cont.height/_height);
		}
	}
}