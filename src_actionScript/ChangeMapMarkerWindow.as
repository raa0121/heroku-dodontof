//--*-coding:utf-8-*--

package {
    public class ChangeMapMarkerWindow extends AddMapMarkerWindow {
        import mx.managers.PopUpManager;
        
        private var mapMarker:MapMarker;
        
        public function setMapMarker(mapMarker_:MapMarker):void {
            mapMarker = mapMarker_;
        }
        
        protected override function init():void {
            title = "マップマーカー変更";
            executeButton.label = "変更";
            
            this.isCreate = false;
            this.isMany.height = 0;
            this.changeExecuteSpace.height = 25;
            this.height += 25;
            
            message.text = mapMarker.getMessage();
            colorPicker.selectedColor = mapMarker.getColor();
            isPaint.selected = mapMarker.isPaintMode();
            mapMarkerWidth.value = mapMarker.getWidth();
            mapMarkerHeigth.value = mapMarker.getHeight();
        }
        
        override protected function setDragEvent():void {
        }
        
        override public function execute():void {
            changeMapMarker();
        }
        
        private function changeMapMarker():void {
            try{
                var guiInputSender:GuiInputSender = DodontoF_Main.getInstance().getGuiInputSender();
                
                mapMarker.setMessage( message.text );
                mapMarker.setColor( colorPicker.selectedColor );
                mapMarker.setPaintMode( isPaint.selected );
                mapMarker.setWidth( mapMarkerWidth.value );
                mapMarker.setHeight( mapMarkerHeigth.value );
                mapMarker.loadViewImage();
                
                guiInputSender.getSender().changeCharacter( mapMarker.getJsonData() );
                PopUpManager.removePopUp(this);
            } catch(error:Error) {
                this.status = error.message;
            }
        }
    }
}


