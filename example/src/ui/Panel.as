package ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Panel extends Sprite
	{
		private var info:XML;
		private var socList:Vector.<SocData>;
		private var socDataById:Object;
		public function Panel(info:XML)
		{
			this.info = info;
			if (this.stage) {
				init();
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		
		private function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.init();
		}
		
		private var _width:Number;
		public override function set width(value:Number):void
		{
			_width = value;
		}
		private var _height:Number;
		public override function set height(value:Number):void
		{
			_height = value;
		}
		
		private var _buttonWidth:Number
		public function set buttonWidth(value:Number):void
		{
			_buttonWidth = value;
		}
		private var _buttonHeight:Number
		public function set buttonHeight(value:Number):void
		{
			_buttonHeight = value;
		}
		
		
		private function init():void
		{
			SocView._width = _width;
			SocView._height = _height;
			SocView._buttonWidth = _buttonWidth;
			SocView._buttonHeight = _buttonHeight;
			//
			socList = Parser.parse(info);
			socDataById = new Object();
			var socData:SocData;
			var i:int;
			for (i=0; i<socList.length; i++) {
				socData = socList[i];
				socDataById[socData.id] = socData;
			}
			createUI(socList);
		}
		
		private var buttonsCont:Sprite;
		private function createUI(socList:Vector.<SocData>):void
		{
			buttonsCont = new Sprite();
			buttonsCont.x = 20;
			buttonsCont.y = 20;
			this.addChild(buttonsCont);
			var i:int;
			var tabButton:Button;
			var socData:SocData;
			for (i=0; i<socList.length; i++) {
				socData = socList[i];
				tabButton = new Button(socData.id);
				tabButton.name = socData.id;
				tabButton.y = buttonsCont.height ? buttonsCont.height + 10 : 0;
				
				tabButton.width = _buttonWidth-10;
				tabButton.height = _buttonHeight-10;
				
				buttonsCont.addChild(tabButton);
				tabButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			}
		}
		
		private function buttonClickHandler(event:MouseEvent):void
		{
			var target:Button = event.currentTarget as Button;
			
			showSoc(socDataById[target.name]);
			
			var dropEvent:PanelEvent = new PanelEvent(PanelEvent.SOCIAL_ACTION);
			dropEvent.socId = target.name;
			dropEvent.buttonId = target.name;
			this.dispatchEvent(dropEvent);
			
		}
		
		private var socViewById:Object = new Object();
		private var currentSocView:SocView;
		private function showSoc(socData:SocData):void
		{
			buttonsCont.visible = false;
			//
			if (currentSocView) {
				if (this.contains(currentSocView)) this.removeChild(currentSocView);
				currentSocView = null;
			}
			if (!socViewById[socData.id]) {
				currentSocView = new SocView(socData);
				//
				currentSocView.addEventListener(PanelEvent.BACK, socBackHandler);
				//currentSocView.addEventListener(SocViewEvent.ACTION, socActionHandler);
				socViewById[socData.id] = currentSocView;
			} else {
				currentSocView = socViewById[socData.id];
			}
			this.addChild(currentSocView);
		}
		
		private function socBackHandler(event:PanelEvent):void
		{
			buttonsCont.visible = true;
			if (currentSocView) {
				if (this.contains(currentSocView)) this.removeChild(currentSocView);
				currentSocView = null;
			}
		}
		
		/*
		private function socActionHandler(event:SocViewEvent):void
		{
			this.dispatchEvent(event.clone());
		}
		*/
	}
}
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import ui.Button;
import ui.ScrollPane;
import ui.PanelEvent;

class SocView extends Sprite
{
	private var data:SocData;
	public function SocView(data:SocData)
	{
		this.data = data;
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(event:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		createUI();
	}
	
	public static var _width:Number = 100;
	public static var _height:Number = 100;
	public static var _buttonWidth:Number = 300;
	public static var _buttonHeight:Number = 100;
	
	private function createUI():void
	{
		var back:Button = new Button('back', 0x666666, 0xaaaaaa);
		back.x = 10;
		back.y = 10;
		back.width = _buttonWidth-10;
		back.height = _buttonHeight-10;
		this.addChild(back);
		back.addEventListener(MouseEvent.CLICK, backClickHandler);
		//
		var scroll:ScrollPane = new ScrollPane();
		scroll.x = 10;
		scroll.y = back.y + back.height + 10;
		scroll.width = _width - scroll.x*2;
		scroll.height = _height - scroll.y - 10;
		this.addChild(scroll);
		//
		var i:int;
		var button:Button;
		var buttonData:ButtonData;
		var xPos:Number = 0;
		var yPos:Number = 0;
		for (i=0; i<data.buttons.length; i++) {
			buttonData = data.buttons[i];
			button = new Button(buttonData.label);
			button.width = _buttonWidth-10;
			button.height = _buttonHeight-10;
			button.name = buttonData.id;
			button.x = xPos;
			button.y = yPos;
			button.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			scroll.addChild(button);
			//
			xPos += _buttonWidth;
			if (xPos+_buttonWidth >= _width) {
				xPos = 0;
				yPos += _buttonHeight;
			}
		}
	}
	
	private function backClickHandler(event:MouseEvent):void
	{
		var dropEvent:PanelEvent = new PanelEvent(PanelEvent.BACK);
		this.dispatchEvent(dropEvent);
	}
	
	private function buttonClickHandler(event:MouseEvent):void
	{
		var button:Button = event.currentTarget as Button;
		//
		var dropEvent:PanelEvent = new PanelEvent(PanelEvent.ACTION);
		dropEvent.socId = data.id;
		dropEvent.buttonId = button.name;
		this.dispatchEvent(dropEvent);
	}
}

class Parser
{
	public static function parse(info:XML):Vector.<SocData>
	{
		var socList:Vector.<SocData> = new Vector.<SocData>();
		var i:int;
		var socData:SocData;
		var socXml:XML;
		for (i=0; i<info.soc.length(); i++) {
			socXml = info.soc[i];
			socData = parseSocData(socXml);
			socList.push(socData);
		}
		
		return socList;
	}
	
	private static function parseSocData(xml:XML):SocData
	{
		var id:String = xml.attribute('id');
		var buttons:Vector.<ButtonData> = new Vector.<ButtonData>();
		var buttonXml:XMLList = xml['button'];
		var count:int = buttonXml.length();
		var i:int;
		for (i=0; i<count; i++) {
			buttons.push(parseButton(buttonXml[i]));
		}
		//
		return new SocData(id, buttons);
	}
	
	public static function parseButton(xml:XML):ButtonData
	{
		var id:String = xml.attribute('id');
		var label:String = xml.attribute('label');
		if (!label || label == '') {
			label = id;
		}
		return new ButtonData(label, id);
	}
}

class ButtonData
{
	public var label:String;
	public var id:String;
	public function ButtonData(label:String, id:String)
	{
		this.label = label;
		this.id = id;
	}
	
	public function toString():String
	{
		return '[Button id='+id+', label='+label+']';
	}
}

class SocData
{
	public var id:String;
	public var buttons:Vector.<ButtonData>;
	public function SocData(id:String, buttons:Vector.<ButtonData>)
	{
		this.id = id;
		this.buttons = buttons;
	}
}