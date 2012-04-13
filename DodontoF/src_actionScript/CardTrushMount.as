//--*-coding:utf-8-*--

package {
    
    import flash.events.MouseEvent;
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.text.TextFieldAutoSize;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.geom.Point;
    import mx.controls.Text;
    import mx.controls.Label;
    import mx.managers.PopUpManager;
    import mx.containers.Box;
    import mx.effects.Glow;
    
    public class CardTrushMount extends CardMount {
        
        public static function getTypeStatic():String {
            return "CardTrushMount";
        }
        
        override public function getType():String {
            return getTypeStatic();
        }
        
        override public function getTypeName():String {
            return "カード捨て札";
        }
        
        public static function getJsonData(imageName_:String,
                                           imageNameBack_:String,
                                           x_:int,
                                           y_:int):Object {
            var characterJsonData:Object = CardMount.getJsonData(imageName_, imageNameBack_, x_, y_);
            
            characterJsonData.type = getTypeStatic();
            
            return characterJsonData;
        }
        
        override public function getJsonData():Object {
            var characterJsonData:Object = super.getJsonData();
            
            characterJsonData.type = getTypeStatic();
            
            return characterJsonData;
        }
        
        public function CardTrushMount(params:Object) {
            super(params);
        }
        
        override protected function setParams(params:Object):void {
            super.setParams(params);
        }
        
        override public function getRoundColor():int {
            return 0x000000;
        }
        
        override public function getTitleText():String {
            return "捨て札：" + getCardCount() + "枚";
        }
        
        override protected function isOwner():Boolean {
            return false;
        }
        
        override protected function isSetViewForevroungOnMouseClicked():Boolean {
            return false;
        }
        
        public function hitTestObject(card:Card):Boolean {
            return view.hitTestObject(card.getView());
        }
        
        override protected function isPrintCardText():Boolean {
            return false;
        }
        
        override protected function initContextMenu():void {
            var menu:ContextMenu = new ContextMenu();
            menu.hideBuiltInItems();
            
            addMenuItem(menu, "一番上のカードを場に戻す", getContextMenuItemCardReturn);
            addMenuItem(menu, "捨て札を山札に積んでシャッフルする", getContextMenuItemCardShuffle, true);
            addMenuItem(menu, "捨て札をそのまま山札に積んで、シャッフルしない", getContextMenuItemCardNoShuffle, true);
            
            addMenuItem(menu, "山からカードを選び出す", getContextMenuItemCardSelect, true);
            
            view.contextMenu = menu;
        }
        
        protected function getContextMenuItemCardReturn(event:ContextMenuEvent):void {
            try {
                returnCard();
            } catch(e:Error) {
                Log.loggingException("MapMask.getContextMenuItemMoveLock()", e);
            }
        }
        
        private function returnCard():void {
            var message:String = "";
            if( this.getCardName() == "" ) {
                message = "が「" + this.getMountNameForDisplay() + "」の捨て札からカードを引き戻しました。";
            } else {
                message = "が捨て札から「" + this.getCardName() + "」を引き戻しました。";
            }
            
            DodontoF_Main.getInstance().getChatWindow().sendSystemMessage( message );
            sender.returnCard( getMountName(),
                               this.getX(),
                               this.getY(),
                               getId() );
        }
        
        private function getContextMenuItemCardShuffle(event:ContextMenuEvent):void {
            try {
                shuffleCards(true);
            } catch(e:Error) {
                Log.loggingException("CardTrushMount.getContextMenuItemCardShuffle()", e);
            }
        }
        
        private function getContextMenuItemCardNoShuffle(event:ContextMenuEvent):void {
            try {
                shuffleCards(false);
            } catch(e:Error) {
                Log.loggingException("CardTrushMount.getContextMenuItemCardNoShuffle()", e);
            }
        }
        
        private function shuffleCards(isShuffle:Boolean):void {
            sender.shuffleCards( this.getMountName(), this.getId(), isShuffle );
        }
        
        override protected function openSelectCardWindow():void {
            var window:SelectCardWindow = DodontoF.popup(SelectTrushCardWindow, true) as SelectCardWindow;
            window.setCardMount(this);
        }
        
        
        override protected function canDoubleClick():Boolean {
            return true;
        }
        
        override protected function doubleClickEvent(event:MouseEvent):void {
            returnCard();
        }
                
    }
}
