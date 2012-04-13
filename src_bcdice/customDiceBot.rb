#--*-coding:utf-8-*--

require 'bcdiceCore.rb'

class CgiDiceBot
  
  def initialize
    @rollResult = ""
    @isSecret = false
    @rands = nil #テスト以外ではnilで良い。ダイス目操作パラメータ
    @isTest = false
  end
  
  attr :isSecret
  
  def rollFromCgi()
    cgi = CGI.new
    @cgiParams = @cgi.params
    
    rollFromCgiParams(cgiParams)
  end
  
  def rollFromCgiParamsDummy()
    @cgiParams = {
      'message' => 'STG20',
      # 'message' => 'S2d6',
      'gameType' => 'TORG',
      'channel' => '1',
      'state' => 'state',
      'sendto' => 'sendto',
      'color' => '999999',
    }
    
    rollFromCgiParams
  end
  
  def rollFromCgiParams
    message = @cgiParams['message']
    gameType = @cgiParams['gameType']
    gameType ||= 'diceBot';
    # $rand_seed = @cgiParams['randomSeed']
    
    result = ""
    
    result << "##>customBot BEGIN<##"
    result << getDiceBotParamText('channel')
    result << getDiceBotParamText('name')
    result << getDiceBotParamText('state')
    result << getDiceBotParamText('sendto')
    result << getDiceBotParamText('color')
    result << message
    result << roll(message, gameType)
    result << "##>customBot END<##"
    
    return result
  end
  
  def getDiceBotParamText(paramName)
    param = @cgiParams[paramName]
    param ||= ''
    
    "#{param}\t"
  end
  
  
  def roll(message, gameType)
    executeDiceBot(message, gameType)
    
    rollResult = @rollResult
    @rollResult = ""
    
    result = ""
    
    unless( @isTest )
      # result << "##>isSecretDice<##" if( @isSecret )
    end
    
    unless( rollResult.empty? )
      result << "\n#{gameType} #{rollResult}"
    end
    
    return result
  end
  
  def setTest()
    @isTest = true
  end
  
  def setRandomValues(rands)
    @rands = rands
  end
  
  def executeDiceBot(message, gameType)
    bcdiceMarker = BCDiceMaker.new
    bcdice = bcdiceMarker.newBcDice()
    
    bcdice.setIrcClient(self)
    bcdice.setRandomValues(@rands)
    bcdice.isKeepSecretDice(false)
    bcdice.setTest(@isTest)
    
    bcdice.setGameByTitle( gameType )
    bcdice.setMessage(message)
    
    channel = ""
    nick_e = ""
    bcdice.setChannel(channel)
    bcdice.recievePublicMessage(nick_e)
  end
  
  def sendMessage(to, message)
    @rollResult << message
  end
  
  def sendMessageToOnlySender(nick_e, message)
    debug(message, "customDiceBot.sendMessageToOnlySender message")
    @isSecret = true
    @rollResult << message
  end
  
  def sendMessageToChannels(message)
    @rollResult << message
  end
  
end


if( $0 === __FILE__ )
  bot = CgiDiceBot.new
  
  result = ''
  if( ARGV.length > 0 )
    result = bot.roll(ARGV[0], ARGV[1])
  else
    result = bot.rollFromCgiParamsDummy
  end
  
  print( result + "\n" )
end
