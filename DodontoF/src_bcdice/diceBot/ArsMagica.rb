#--*-coding:utf-8-*--

class ArsMagica < DiceBot
  
  def initialize
    super
    @sendMode = 2;
  end
  
  def gameType
    "ArsMagica"
  end
  
  def getHelpMessage
    "・ArsMagica ストレスダイス(ArSx) (x:ボッチダイス)"
  end
  
  def changeText(string)
    return string unless(/ArS/i =~ string)
    
    string = string.gsub(/ArS(\d+)([^\d\s][\+\-\d]+)/i) {"1R10#{$2}[#{$1}]"}
    string = string.gsub(/ArS([^\d\s][\+\-\d]+)/i) {"1R10#{$1}"}
    string = string.gsub(/ArS(\d+)/i) {"1R10[#{$1}]"}
    string = string.gsub(/ArS/i) {"1R10"}
    
    return string
  end
  
  def dice_command_xRn(string, nick_e)
    arsmagica_stress(string, nick_e)
  end
  
  
  def check_nD10(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)# ゲーム別成功度判定(nD10)
    if(signOfInequality != ">=")
      return "" 
    end
    
    if(total_n >= diff)
      return " ＞ 成功";
    end
    
    return " ＞ 失敗";
  end
  
  def check_1D10(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)     # ゲーム別成功度判定(1D10)
    if(signOfInequality != ">=")
      return ""
    end
    
    if(total_n >= diff)
      return " ＞ 成功";
    end
    
    return " ＞ 失敗";
  end
  
  
  def arsmagica_stress(string, nick_e)
    output = "1";
    
    return "1" unless (/(^|\s)S?(1[rR]10([\+\-\d]*)(\[(\d+)\])?(([>=]+)(\d+))?)(\s|$)/i =~ string)
    
    diff = 0;
    botch = 1;
    bonus = 0;
    crit_mul = 1;
    total = 0;
    signOfInequality = "";
    bonusText = $3
    botch = $5.to_i if($4);
    
    if($6)
      signOfInequality = marshalSignOfInequality($7);
      diff = $8;
    end
    
    bonus = parren_killer("(0#{bonusText})") unless( bonusText.empty? )
    
    die = rand(10);
    output = "(#{$2}) ＞ ";
    
    if(die == 0) # botch?
      count0 = 0;
      dice_n = []
      
      botch.times do |i|
        botch_die = rand(10);
        count0 += 1 if(botch_die == 0);
        dice_n.push( botch_die )
      end
      
      dice_n = dice_n.sort if(sortType != 0);
      
      output += "0[#{die},#{ dice_n.join(',') }]";
      
      if(count0 != 0)
        bonus = 0;
        
        if(count0 > 1)
          output += " ＞ #{count0}Botch!";
        else
          output += " ＞ Botch!";
        end
        
        signOfInequality = "";
      else
        if(bonus > 0)
          output += "+#{bonus} ＞ #{bonus}";
        elsif(bonus < 0)
          output += "#{bonus} ＞ #{bonus}";
        else
          output += " ＞ 0";
        end
        total = bonus;
      end
    elsif(die == 1)    # Crit
      crit_dice = "";
      while (die == 1)
        crit_mul *= 2;
        die = rand(10) + 1;
        crit_dice += "#{die},";
      end
      total = die * crit_mul;
      crit_dice = crit_dice.sub(/,$/, '')
      output += "#{total}";
      if( sendMode != 0 )
        output += "[1,#{crit_dice}]";
      end
      total += bonus;
      if(bonus > 0)
        output += "+#{bonus} ＞ #{total}";
      elsif(bonus < 0)
        output += "#{bonus} ＞ #{total}";
      end
    else
      total = die + bonus;
      if(bonus > 0)
        output += "#{die}+#{bonus} ＞ #{total}";
      elsif(bonus < 0)
        output += "#{die$bonus} ＞ #{total}";
      else
        output += "#{total}";
      end
    end
    if(signOfInequality != "")  # 成功度判定処理
      output += check_suc(total, 0, signOfInequality, diff, 1, 10, 0, 0);
    end
    
    return output;
  end
end
