//--*-coding:utf-8-*--

package {
    import mx.managers.PopUpManager;
    
    public class ChangeStandingGraphicsWindow extends AddStandingGraphicsWindow {
        
        private var index:int = 0;
        private var effectId:String = "";
        
        public function init(info:Object, index_:int):void {
            title = "立ち絵変更";
            executeButton.label = "変更";
            
            index = index_;
            effectId = info.effectId;
            
            characterName.text = info.name;
            state.text = info.state;
            source.text = info.source;
            
            leftIndex.value = ((parseInt(info.leftIndex) == 0) ? 1 : parseInt(info.leftIndex));
        }
        
        protected override function isLoadInitImageList():Boolean {
            return false;
        }
        
        protected override function getEffectParamsExt(params:Object):void {
            params.effectId = effectId;
        }
        
        protected override function execute():void {
            var params:Object = getEffectParams();
            
            DodontoF_Main.getInstance().standingGraphicInfos[index] = params;
            
            var guiInputSender:GuiInputSender = DodontoF_Main.getInstance().getGuiInputSender();
            guiInputSender.changeEffect(params);
            
            PopUpManager.removePopUp(this);
        }
        
    }
}

