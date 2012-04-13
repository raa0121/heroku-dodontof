//--*-coding:utf-8-*--

package {
    
    import mx.collections.ArrayCollection;
    import mx.managers.PopUpManager;
    
    public class ChangeMagicRangeDD4thWindow  extends AddMagicRangeDD4thWindow {
        
        private var magicRange:MagicRangeDD4th = null;
        
        public function setMagicRange(magicRange_:MagicRangeDD4th):void {
            magicRange = magicRange_;
        }
        
        override protected function init():void {
            title = "魔法範囲変更(D&D4版)";
            executeButton.label = "変更";
            
            magicRangeName.text = magicRange.getName();
            
            //magicRangeType.text = magicRange.getRangeType();
            ChangeMagicRangeWindow.selectMagicRangeType(magicRangeType, magicRange.getRangeType());
            
            magicRangeRadius.value = magicRange.getRadius();
            magicRangeColorPicker.selectedColor = magicRange.getColor();
            magicRangeTimeRange.value = magicRange.getTimeRange();
            magicRangeInfo.text = magicRange.getInfo();
        }
        
        override public function execute():void {
            changeMagicRange();
        }
        
        private function changeMagicRange():void {
            try{
                var guiInputSender:GuiInputSender = DodontoF_Main.getInstance().getGuiInputSender();
                
                guiInputSender.changeMagicRangeDD4th(
                                                     magicRange,
                                                     magicRangeName.text,
                                                     getFeets(),
                                                     magicRangeType.selectedItem.data,
                                                     ("0x" + magicRangeColorPicker.selectedColor.toString(16)),
                                                     magicRangeInfo.text,
                                                     magicRangeTimeRange.value);
                
                PopUpManager.removePopUp(this);
            } catch(error:Error) {
                this.status = error.message;
            }
        }
        
    }
}
