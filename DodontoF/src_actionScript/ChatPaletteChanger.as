//--*-coding:utf-8-*--

package {
    
    public class ChatPaletteChanger {
        
        private var buffer:Array = new Array();
        private var definitions:Object = new Object();
        
        public function setTexts(array:Array):void {
            buffer = array;
        }
        
        public function getText(index:int):String {
            var line:String = buffer[index];
            return getTextFromText(line);
        }
        
        public function getTextFromText(line:String):String {
            if( line == null ) {
                return "";
            }
            
            for (var key:String in definitions) {
                var value:String = definitions[key];
                
                var pattern:String = "{" + key + "}";
                line = getChangedLine(line, pattern, value);
                var pattern2:String = "｛" + key + "｝";
                line = getChangedLine(line, pattern2, value);
            }
            
            Log.logging("getTextFromText result", line);
            return line;
        }
        
        private function getChangedLine(line:String, pattern:String, value:String):String {
            Log.logging("getChangedLine pattern", pattern);
            
            var oldLine:String = "";
            while (oldLine != line) {
                oldLine = line;
                line = line.replace(pattern, value);
            }
            
            return line;
        }
        
        
        private var loopMax:int = 30; //無限ルーム回避のためのMAXループ回数
        
        public function analize():void {
            var lines:Array = buffer;
            
            for(var i:int = 0 ; i < loopMax ; i++) { //本来は無限ループで良いが、安全のため上限を設ける
                analizeBuffer(lines);
                var newLines:Array = getChangedTexts(lines);
                
                if( Utils.isSameArray(lines, newLines) ) {
                    break;
                }
                
                lines = newLines;
            }
            
        }
        
        private function analizeBuffer(lines:Array):void {
            definitions = new Object();
            
            for each(var line:String in lines) {
                analizeDefinition(line);
            }
            
            Log.logging("definitions", definitions);
        }
        
        static private var definitionRegExp:RegExp = /^(\/\/|／／)(.+?)\s*(=|＝)\s*(.+?)\s*$/m;
        
        private function analizeDefinition(line:String):void {
            var result:Object = definitionRegExp.exec(line);
            if( result == null ) {
                return;
            }
            
            var key:String = result[2];
            var value:String = result[4];
            definitions[key] = value;
        }
        
        private function getChangedTexts(lines:Array):Array {
            var newLines:Array = new Array();
            
            for each(var line:String in lines) {
                newLines.push( getTextFromText(line) );
            }
            
            return newLines;
        }
        
    }
}

/*
=====================================
//cl=8
//筋力=3
//知力=7
3d6+{知力}+{cl} エンサイクロペディア[エルディダイト]
2d6+{知力}+3 アイテム鑑定[出自：冒険者]
2d6+{筋力} 筋力判定
=====================================

//A = 1
//B = 2
//AB = {A} + {B}

*/
