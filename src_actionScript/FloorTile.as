//--*-coding:utf-8-*--

package {
    
    import mx.core.UIComponent;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import mx.managers.PopUpManager;
    import mx.controls.Alert;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.text.TextFieldAutoSize;
    
    
    public class FloorTile extends MovablePiece {
        
        private var imageUrl:String;
        private var width:int;
        private var height:int;
        private var rotation:int = 0;
        
        private var thisObj:FloorTile;
        
        public static function getTypeStatic():String {
            return "floorTile";
        }
        
        override public function getType():String {
            return getTypeStatic();
        }
        
        override public function getTypeName():String {
            return "フロアタイル";
        }
        
        
        
        public static function getJsonData(imageUrl:String,
                                           width:int,
                                           height:int,
                                           rotation:int,
                                           createPositionX:int,
                                           createPositionY:int):Object {
            var draggable:Boolean = true;
            var jsonData:Object = MovablePiece.getJsonData(getTypeStatic(), createPositionX, createPositionY, draggable);
            
            jsonData.imageUrl = imageUrl;
            jsonData.width = width;
            jsonData.height = height;
            jsonData.rotation = rotation;
            
            return jsonData;
        }
        
        override public function getJsonData():Object {
            var jsonData:Object = super.getJsonData();
            
            jsonData.imageUrl = imageUrl;
            jsonData.width = width;
            jsonData.height = height;
            jsonData.rotation = this.rotation;
            
            return jsonData;
        }
        
        public function FloorTile(params:Object) {
            this.thisObj = this;
            
            this.imageUrl = params.imageUrl;
            this.width = params.width;
            this.height = params.height;
            this.rotation = params.rotation;
            
            super(params);
            
            //自分の環境に仮作成する場合のために、作成直後はドラッグ不可に。
            //応答が正常ならどちらにしろupdateで更新されるはずなのでこの実装で問題は無い。
            setDraggable(false);
            
            view.setMaintainAspectRatio(false);
        }
        
        override public function isGotoGraveyard():Boolean {
            return false;
        }
        
        override protected function initContextMenu():void {
            var menu:ContextMenu = new ContextMenu();
            menu.hideBuiltInItems();
            
            addMenuItem(menu, "タイルの固定／固定解除", this.getContextMenuItemMoveLock);
            addMenuItem(menu, "右回転",    this.getContextMenuItemFunctionObRotateCharacter( 90), true);
            addMenuItem(menu, "180度回転", this.getContextMenuItemFunctionObRotateCharacter(180));
            addMenuItem(menu, "左回転",    this.getContextMenuItemFunctionObRotateCharacter(270));
            addMenuItem(menu, "フロアタイルの削除", this.getContextMenuItemRemoveCharacter, true);
            
            view.contextMenu = menu;
        }
        
        private function getContextMenuItemMoveLock(event:ContextMenuEvent):void {
            setDraggable( ! getDraggable() );
            drawTile();
            sender.changeCharacter( getJsonData() );
        }
        
        protected function getContextMenuItemFunctionObRotateCharacter(rotationDiff:Number):Function {
            return function(event:ContextMenuEvent):void {
                var rotation:Number = thisObj.rotation;
                rotation += rotationDiff;
                rotation = ( rotation % 360 );
                thisObj.rotation = rotation;
                
                thisObj.loadViewImage();
                sender.changeCharacter( thisObj.getJsonData() );
            };
        }
        
        override public function getMapLayer():UIComponent {
            return getMap().getMapTileLayer();
        }
        
        private var lineColor:uint = 0xFFFF99;
        private var lockedLineColor:uint = 0xFF9999;
        
        private function getLineColor():uint {
            if( getDraggable() ) {
                return lineColor;
            }
            return lockedLineColor;
        }
        
        override protected function initDraw(x:Number, y:Number):void {
            drawTile();
            move(x, y, true);
        }
        
        private function drawTile():void {
            view.setLineColor( getLineColor() )
            view.setLineDiameter(10);
            loadViewImage();
        }
        
        private var editable:Boolean = false;
        
        public function setEditMode(b:Boolean):void {
            this.editable = b;
            view.setIsDrawRound(this.editable);
            drawTile();
        }
        
        override public function loadViewImage():void {
            var name:String = this.imageUrl;
            var rotation:int = 0;
            view.loadImageWidthHeightRotation(name, this.imageUrl,
                                              this.width, this.height,
                                              this.rotation);
        }
        
        override protected function update(params:Object):void {
            super.update(params);
            
            this.imageUrl = params.imageUrl;
            this.width = params.width;
            this.height = params.height;
            
            setEditMode( getMap().isFloorTileEditMode() );
            
            initDraw(getX(), getY());
        }
        
        public function getImageUrl():String {
            return imageUrl;
        }
        
        
        override protected function initCreation():void {
            var textHeight:int = 50;
            
            var nameTextField:TextField = new TextField();
            nameTextField.text = "作成中…";
            
            nameTextField.background = true;
            nameTextField.multiline = false;
            nameTextField.selectable = false;
            nameTextField.mouseEnabled = false;
            nameTextField.y = (textHeight * -1);
            
            nameTextField.autoSize = flash.text.TextFieldAutoSize.CENTER;
            nameTextField.height = textHeight;
            
            var format:TextFormat = new TextFormat(); 
            format.size = textHeight;
            nameTextField.setTextFormat(format);
            
            var allWidth:int = this.width * getSquareLength();
            nameTextField.x = ( (1.0 * allWidth / 2) - (nameTextField.width / 2) );
            
            view.addChild(nameTextField);
        }
        
        override public function getWidth():int {
            return this.width;
        }
        
        override public function getHeight():int {
            return this.height;
        }
        
        override public function getOwnWidth():int {
            return getWidth() * getSquareLength();
        }
        
        override public function getOwnHeight():int {
            return getHeight() * getSquareLength();
        }
        
    }
}