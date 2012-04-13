#!/bin/ruby -Ku 
#--*-coding:utf-8-*--

#require 'rubygems'
require 'wx'
require 'wx/classes/timer.rb'

require 'bcdiceCore.rb'
require 'ArgsAnalizer.rb'
require 'IniFile.rb'

$LOAD_PATH << File.dirname(__FILE__) + "/irc"
require 'ircLib.rb'
require 'ircBot.rb'

$isDebug = false

class BCDiceGuiApp < Wx::App
  private

  def on_init
    BCDiceDialog.new.show_modal
    return false
  end
end

$debugText = nil

def debugPrint(text)
  return if( $debugText.nil? ) 
  $debugText.append_text(text)
end


class BCDiceDialog < Wx::Dialog
  
  def initialize
    super(nil, -1, 'B&C Dice')
    
    @iniFile = IniFile.new($iniFileName)
    
    analizeArgs
    
    @allBox = Wx::BoxSizer.new(Wx::VERTICAL)
    
    initServerSet
    
    @serverName = createAddedTextInput( $server, "サーバ名" )
    @portNo = createAddedTextInput( $port.to_s, "ポート番号" )
    @channel = createAddedTextInput( $defaultLoginChannelsText, "ログインチャンネル" )
    @nickName = createAddedTextInput( $nick, "ニックネーム" )
    initGameType
    @extraCardFileText = createAddedTextInput( $extraCardFileName, "拡張カードファイル名" )
    @ircCodeText = createAddedTextInput( $ircCode, "IRC文字コード" )
    
    @executeButton = createButton('接続')
    evt_button(@executeButton.get_id) {|event| on_execute }
    
    @stopButton = createButton('切断')
    @stopButton.enable(false)
    evt_button(@stopButton.get_id) {|event| on_stop }

    addCtrlOnLine( @executeButton, @stopButton)
    
    
    addTestTextBoxs
    # initDebugTextBox
    
    loadSaveData
    
    set_sizer(@allBox)
    @allBox.set_size_hints(self)
    
    argsAnalizer = ArgsAnalizer.new(ARGV)
    argsAnalizer.analize
    
    @ircBot = nil
    unless( argsAnalizer.isStartIrc )
      @ircBot = getInitializedIrcBot()
      setAllGames(@ircBot)
      destroy
    end
  end
  
  
  def analizeArgs
    argsAnalizer = ArgsAnalizer.new(ARGV)
    @isAnalized = argsAnalizer.analize
  end
  
  def initServerSet
    @serverSetChoise = Wx::ComboBox.new(self, -1, 
                                        :size => Wx::Size.new(250, 25))
    
    initServerSetChoiseList
    
    evt_combobox(@serverSetChoise.get_id) { |event| on_load }

    @saveButton = createButton('この設定で保存')
    evt_button(@saveButton.get_id) {|event| on_save }
    
    @deleteButton = createButton('この設定を削除')
    evt_button(@deleteButton.get_id) {|event| on_delete }
    
    addCtrl(@serverSetChoise, "設定", @saveButton, @deleteButton)
  end
  
  
  def initServerSetChoiseList
    @serverSetChoise.clear()
    
    list = loadServerSetNameList
    
    list.each_with_index do |name, index|
      @serverSetChoise.insert( name, index )
    end
  end
  
  def loadServerSetNameList
    sectionNames = @iniFile.getSectionNames
    serverSetNameList = []
    
    sectionNames.each do |name|
      if( /#{@@serverSertPrefix}(.+)/ === name )
        serverSetNameList << $1
      end
    end
    
    return serverSetNameList
  end
  
  def on_load
    serverSet = @serverSetChoise.get_value
    debug( 'on_load serverSet', serverSet )
    
    sectionName = getServerSetSectionName(serverSet)
    
    loadTextValueFromIniFile(sectionName, "serverName", @serverName)
    loadTextValueFromIniFile(sectionName, "portNo", @portNo)
    loadTextValueFromIniFile(sectionName, "channel", @channel)
    loadTextValueFromIniFile(sectionName, "nickName", @nickName)
    loadTextValueFromIniFile(sectionName, "extraCardFileText", @extraCardFileText)
    loadTextValueFromIniFile(sectionName, "ircCodeText", @ircCodeText)
  end
  
  def loadTextValueFromIniFile(section, key, input)
    debug('loadTextValueFromIniFile begin')
    value = @iniFile.read(section, key)
    debug('value', value)
    
    return if( value.nil? )
    
    input.set_value( value )
  end
  
  @@serverSertPrefix = "ServerSet_"
  
  def getServerSetSectionName(serverSet)
    return "#{@@serverSertPrefix}#{serverSet}"
  end
  

  def on_save
    debug( 'on_save begin')
    serverSet = @serverSetChoise.get_value
    debug( 'on_save serverSet', serverSet )
    
    sectionName = getServerSetSectionName(serverSet)
    debug( 'sectionName', sectionName )
    
    saveTextValueToIniFile(sectionName, "serverName", @serverName)
    saveTextValueToIniFile(sectionName, "portNo", @portNo)
    saveTextValueToIniFile(sectionName, "channel", @channel)
    saveTextValueToIniFile(sectionName, "nickName", @nickName)
    saveTextValueToIniFile(sectionName, "extraCardFileText", @extraCardFileText)
    saveTextValueToIniFile(sectionName, "ircCodeText", @ircCodeText)
    
    initServerSetChoiseList
  end
  
  def saveTextValueToIniFile(section, key, input)
    value = input.get_value
    @iniFile.write(section, key, value)
  end
  
  def on_delete
    serverSet = @serverSetChoise.get_value
    sectionName = getServerSetSectionName(serverSet)
    
    @iniFile.deleteSection(sectionName)
    
    initServerSetChoiseList
  end
  
  
  def createButton(labelText)
    Wx::Button.new(self, -1, labelText)
  end
  
  def createTextInput(defaultText)
    Wx::TextCtrl.new(self, -1, defaultText)
  end
  
  def createAddedTextInput(defaultText, labelText, *addCtrls)
    textInput = createTextInput(defaultText)
    addCtrl(textInput, labelText, *addCtrls)
    return textInput
  end
  
  def createLabel(labelText)
    Wx::StaticText.new(self, -1, labelText)
  end
  
  def addCtrl(ctrl, labelText = nil, *addCtrls)
    if( labelText.nil? )
      @allBox.add(ctrl, 0, Wx::ALL, 2)
      return ctrl
    end
    
    ctrls = []
    unless( labelText.nil? )
      label = createLabel(labelText)
      ctrls << label
    end
    
    ctrls << ctrl
    ctrls += addCtrls
    
    line = getLineCtrl( ctrls )
    
    @allBox.add(line, 0, Wx::ALL, 2)
    
    return ctrl
  end
  
  def addCtrlOnLine(*ctrls)
    line = getLineCtrl(ctrls)
    @allBox.add(line, 0, Wx::ALL, 2)
    return line
  end
  
  def getLineCtrl(ctrls)
    line = Wx::BoxSizer.new(Wx::HORIZONTAL)
    
    ctrls.each do |ctrl|
      line.add(ctrl, 0, Wx::ALL, 2)
    end
    
    return line
  end
  
  
  def initGameType
    @gameType = Wx::Choice.new(self, -1)
    addCtrl(@gameType, "ゲームタイトル")
    
    gameTypes = getAllGameTypes.sort
    gameTypes.each_with_index do |type, index|
      @gameType.insert( type, index )
    end
    
    @gameType.insert( "NonTitle", 0 )
    
    index = gameTypes.index($defaultGameType)
    index ||= 0
    @gameType.set_selection(index)
    
    evt_choice(@gameType.get_id) { |event| onChoiseGame }
  end
  
  def getAllGameTypes
    return %w{
Arianrhod
ArsMagica
BarnaKronika
ChaosFlare
Chill
Cthulhu
CthulhuTech
DarkBlaze
DemonParasite
DoubleCross
EarthDawn
EclipsePhase
Elric!
EmbryoMachine
GehennaAn
GunDog
GunDogZero
Hieizan
HuntersMoon
InfiniteFantasia
MagicaLogia
MeikyuDays
MeikyuKingdom
MonotoneMusium
Nechronica
NightWizard
NightmareHunterDeep
ParasiteBlood
Peekaboo
Pendragon
PhantasmAdventure
RokumonSekai2
RoleMaster
RuneQuest
SataSupe
ShadowRun
ShadowRun4
ShinobiGami
SwordWorld
SwordWorld2.0
TORG
TokumeiTenkousei
Tunnels&Trolls
WARPS
WarHammer
ZettaiReido
}
  end
  
  def onChoiseGame
    return if( @ircBot.nil? )
    @ircBot.setGameByTitle( @gameType.get_string_selection )
  end
  
  def addTestTextBoxs
    label = createLabel('動作テスト欄')
    # @testInput = createTextInput( "3d6          " )
    # @testInput.set_default_style( Wx::TextAttr.new(Wx::TE_PROCESS_ENTER) )
    inputSize = Wx::Size.new(250, 25)
    @testInput = Wx::TextCtrl.new(self, -1, "2d6",
                                  :style => Wx::TE_PROCESS_ENTER,
                                  :size => inputSize)
    
    evt_text_enter(@testInput.get_id) { |event| expressTestInput }
    @testButton = createButton('テスト実施')
    evt_button(@testButton.get_id) {|event| expressTestInput }
    
    addCtrlOnLine( label, @testInput, @testButton )
    
    size = Wx::Size.new(500, 150)
    @testOutput = Wx::TextCtrl.new(self, -1, "", 
                                  :style => Wx::TE_MULTILINE,
                                  :size => size)
    addCtrl(@testOutput)
  end
  
  def expressTestInput
    begin
      onEnterTestInputCatched
    rescue => e
      debug("onEnterTestInput error " + e.to_s)
    end
  end
  
  def onEnterTestInputCatched
    debug("onEnterTestInput")
    
    # @testOutput.set_value("")
    
    bcdiceMarker = BCDiceMaker.new
    bcdice = bcdiceMarker.newBcDice()
    bcdice.setIrcClient(self)
    bcdice.setGameByTitle( @gameType.get_string_selection )
    
    arg = @testInput.get_value
    channel = ""
    nick_e = ""
    tnick = ""
    bcdice.setMessage(arg)
    bcdice.setChannel(channel)
    # bcdice.recieveMessage(nick_e, tnick)
    bcdice.recievePublicMessage(nick_e)
  end
  
  def sendMessage(to, message)
    # @testOutput.set_value( message + "\n" )
    unless( @testOutput.get_value().empty? )
      @testOutput.append_text( "\r\n" )
    end
    @testOutput.append_text( message )
  end
  
  def sendMessageToOnlySender(nick_e, message)
    sendMessage(to, message)
  end
  
  def sendMessageToChannels(message)
    sendMessage(to, message)
  end

  
  def initDebugTextBox
    size = Wx::Size.new(600, 200)
    $debugText = Wx::TextCtrl.new(self, -1, "", 
                                  :style => Wx::TE_MULTILINE,
                                  :size => size)
    addCtrl($debugText)
    $isDebug = true
  end
  
  def on_execute
    begin
      setConfig
      startIrcBot
      @executeButton.enable(false)
      @stopButton.enable(true)
    rescue => e
      Wx::message_box(e.to_s)
    end
  end
  
  def setConfig
    $server = @serverName.get_value
    $port = @portNo.get_value.to_i
    $defaultLoginChannelsText = @channel.get_value
    $nick = @nickName.get_value
    $defaultGameType = @gameType.get_string_selection
    $extraCardFileName = @extraCardFileText.get_value
    $ircCode = @ircCodeText.get_value
  end
  
  def startIrcBot
    @ircBot = getInitializedIrcBot()
    
    @ircBot.setQuitFuction( Proc.new{destroy} )
    @ircBot.setPrintFuction( Proc.new{|message| printText(message) } )
    
    startIrcBotOnThread
    startThreadTimer
  end
  
  def startIrcBotOnThread
    
    printText("connect to IRC server.")
    
    ircThread = Thread.new do
      begin
        @ircBot.start
      ensure
        @ircBot = nil
      end
    end
  end
  
  #Rubyスレッドの処理が正常に実行されるように、
  #定期的にGUI処理をSleepし、スレッド処理権限を譲渡する
  def startThreadTimer
    Wx::Timer.every(100) do
      sleep 0.05
    end
  end
  
  def printText(message)
    # Wx::message_box(message.inspect, 'bcdice')
    @testOutput.append_text( "#{message}\r\n" )
  end
  
  def on_stop
    return if( @ircBot.nil? )
    
    @ircBot.quit
    
    @executeButton.enable(true)
    @stopButton.enable(false)
    
    printText("IRC disconnected.")
  end
  
  def setAllGames(ircBot)
    getAllGameTypes.each do |type|
      @ircBot.setGameByTitle( type )
    end
  end
  
  
  def loadSaveData
    index = 0
    @serverSetChoise.set_selection(index)
  end
  
end



def mainBcDiceGui
 BCDiceGuiApp.new.main_loop
end
