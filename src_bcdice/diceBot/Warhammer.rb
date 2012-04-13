#--*-coding:utf-8-*--

class Warhammer < DiceBot
  
  def initialize
    super
    @sendMode = 2;
    @fractionType = "roundUp";     # 端数切り上げに設定
  end
  
  
  def gameType
    "Warhammer"
  end
  
  def getHelpMessage
    return <<MESSAGETEXT
・ウォーハンマークリティカル表(WHpx) (pは部位(HABL)でxはクリティカル値)
・ウォーハンマー命中判定　  　(WHx\@p) (xは技能値, pは対象(\@のみで全種))
MESSAGETEXT
  end
  
  def dice_command(string, nick_e)
    output_msg, secret_flg = dice_comman_atack(string, nick_e)
    if( output_msg == '1' )
      output_msg, secret_flg = dice_comman_criticald(string, nick_e)
    end
    
    return output_msg, secret_flg
  end
  
  
  # ウォーハンマー攻撃コマンド
  def dice_comman_atack(string, nick_e)
    secret_flg = false
    
    return '1', secret_flg unless(/(^|\s)(S)?(WH\d+(@[\dWH]*)?)($|\s)/ =~ string)

    secretMarker = $2
    command = $3
    output_msg = wh_att(command, nick_e);
    if( secretMarker )    # 隠しロール
        secret_flg = true if(output_msg != '1');
      end
    
    return output_msg, secret_flg
  end
  
  # ウォーハンマークリティカル表
  def dice_comman_criticald(string, nick_e)
    secret_flg = false
    
    unless( /((^|\s)(S)?WH[HABTLW]\d+)($|\s)/i =~ string)
      return '1', secret_flg
    end
    
    secretMarker = $3
    command = $1.upcase
    output_msg = wh_crit(command, nick_e);
    if( secretMarker )   # 隠しロール
      secret_flg = true if(output_msg != '1');
    end
    
    return output_msg, secret_flg
  end
  
  def check_1D100(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)    # ゲーム別成功度判定(1d100)
    return '' unless(signOfInequality == "<=")
    
    if(total_n <= diff)
      return " ＞ 成功(成功度#{ ((diff - total_n)/10) })";
    end
      
    return " ＞ 失敗(失敗度#{ ((total_n - diff) / 10) })";
  end
  
####################            WHFRP関連          ########################
  def wh_crit(string, dst)
    # クリティカル効果データ
    whh = [
        '01:打撃で状況が把握出来なくなる。次ターンは1回の半アクションしか行なえない。',
        '02:耳を強打された為、耳鳴りが酷く目眩がする。1Rに渡って一切のアクションを行なえない。',
        '03:打撃が頭皮を酷く傷つけた。【武器技術度】に-10%。治療を受けるまで継続。',
        '04:鎧が損傷し当該部位のAP-1。修理するには(職能:鎧鍛冶)テスト。鎧を着けていないなら1Rの間アクションを行なえない。',
        '05:転んで倒れ、頭がくらくらする。1Rに渡ってあらゆるテストに-30で、立ち上がるには起立アクションが必要。',
        '06:1d10R気絶。',
        '07:1d10分気絶。以後CTはサドンデス。',
        '08:顔がずたずたになって倒れ、以後無防備状態。治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。以後CTはサドンデスを適用。【頑強】テストに失敗すると片方の視力を失う。',
        '09:凄まじい打撃により頭蓋骨が粉砕される。死は瞬時に訪れる。',
        '10:死亡する。いかに盛大に出血し、どのような死に様を見せたのかを説明してもよい。',
    ]
    wha = [
        '01:手に握っていたものを落とす。盾はくくりつけられている為、影響なし。',
        '02:打撃で腕が痺れ、1Rの間使えなくなる。',
        '03:手の機能が失われ、治療を受けるまで回復できない。手で握っていたもの(盾を除く)は落ちる。',
        '04:鎧が損傷する。当該部位のAP-1。修理するには(職能:鎧鍛冶)テスト。鎧を着けていないなら腕が痺れ、1Rの間使えなくなる。',
        '05:腕の機能が失われ、治療を受けるまで回復できない。手で握っていたもの(盾を除く)は落ちる。',
        '06:腕が砕かれる。手で握っていたもの(盾を除く)は落ちる。出血がひどく、治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。以後CTはサドンデスを適用。',
        '07:手首から先が血まみれの残骸と化す。手で握っていたもの(盾を除く)は落ちる。出血がひどく、治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。以後CTはサドンデスを適用。【頑健】テストに失敗すると手の機能を失う。',
        '08:腕は血まみれの肉塊がぶら下がっている状態になる。手で握っていたもの(盾を除く)は落ちる。治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。以後CTはサドンデスを適用。【頑健】テストに失敗すると肘から先の機能を失う。',
        '09:大動脈に傷が及んだ。コンマ数秒の内に損傷した肩から血を噴出して倒れる。ショックと失血により、ほぼ即死する。',
        '10:死亡する。いかに盛大に出血し、どのような死に様を見せたのかを説明してもよい。',
    ]
    whb = [
        '01:打撃で息が詰まる。1Rの間、キャラクターの全てのテストや攻撃に-20%。',
        '02:股間への一撃。苦痛のあまり、1Rに渡って一切のアクションを行なえない。',
        '03:打撃で肋骨がぐちゃぐちゃになる。以後治療を受けるまでの間、【武器技術度】に-10%。',
        '04:鎧が損傷する。当該部位のAP-1。修理するには(職能:鎧鍛冶)テスト。鎧を着けていないなら股間への一撃、1Rに渡って一切のアクションを行なえない。',
        '05:転んで倒れ、息が詰まって悶絶する。1Rに渡ってあらゆるテストに-30の修正、立ち上がるには起立アクションが必要。',
        '06:1d10R気絶。',
        '07:ひどい内出血が起こり、無防備状態。出血がひどく、治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。',
        '08:脊髄が粉砕されて倒れ、以後治療を受けるまで無防備状態。以後CTはサドンデスを適用。【頑強】テストに失敗すると腰から下が不随になる。',
        '09:凄まじい打撃により複数の臓器が破裂し、死は数秒のうちに訪れる。',
        '10:死亡する。いかに盛大に出血し、どのような死に様を見せたのかを説明してもよい。',
    ]
    whl = [
        '01:よろめく。次のターン、1回の半アクションしか行なえない。',
        '02:脚が痺れる。1Rに渡って【移動】は半減し、脚に関連する【敏捷】テストに-20%。回避が出来なくなる。',
        '03:脚の機能が失われ、治療を受けるまで回復しない。【移動】は半減し、脚に関連する【敏捷】テストに-20%。回避が出来なくなる。',
        '04:鎧が損傷する。当該部位のAP-1。修理するには(職能:鎧鍛冶)テスト。鎧を着けていないなら脚が痺れる、1Rに渡って【移動】は半減し、脚に関連する【敏捷】テストに-20%、回避不可になる。',
        '05:転んで倒れ、頭がくらくらする。1Rに渡ってあらゆるテストに-30の修正、立ち上がるには起立アクションが必要。',
        '06:脚が砕かれ、無防備状態。出血がひどく、治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。以後CTはサドンデスを適用。',
        '07:脚は血まみれの残骸と化し、無防備状態になる。治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。以後CTはサドンデスを適用。【頑強】テストに失敗すると足首から先を失う。',
        '08:脚は血まみれの肉塊がぶらさがっている状態。以後無防備状態。治療を受けるまで毎Rの被害者のターン開始時に20%で死亡。以後CTはサドンデスを適用。【頑強】テストに失敗すると膝から下を失う。',
        '09:大動脈に傷が及ぶ。コンマ数秒の内に脚の残骸から血を噴出して倒れ、ショックと出血で死は瞬時に訪れる。',
        '10:死亡する。いかに盛大に出血し、どのような死に様を見せたのかを説明してもよい。',
    ]
    whw = [
        '01:軽打。1ラウンドに渡って、あらゆるテストに-10％。',
        '02:かすり傷。+10％の【敏捷】テストを行い、失敗なら直ちに高度を1段階失う。地上にいるクリーチャーは、次のターンには飛び立てない。',
        '03:損傷する。【飛行移動力】が2点低下する。-10％の【敏捷】テストを行い、失敗なら直ちに高度を1段階失う。地上にいるクリーチャーは、次のターンには飛び立てない。',
        '04:酷く損傷する。【飛行移動力】が4点低下する。-30％の【敏捷】テストを行い、失敗なら直ちに高度を1段階失う。地上にいるクリーチャーは、1d10ターンが経過するまで飛び立てない。',
        '05:翼が使えなくなる。【飛行移動力】が0に低下する。飛行中のものは落下し、高度に応じたダメージを受ける。地上にいるクリーチャーは、怪我が癒えるまで飛び立てない。',
        '06:翼の付け根に傷が開く。【飛行移動力】が0に低下する。飛行中のものは落下し、高度に応じたダメージを受ける。地上にいるクリーチャーは、怪我が癒えるまで飛び立てない。治療を受けるまで毎R被害者のターン開始時に20％の確率で死亡。以後CTはサドンデスを適用。',
        '07:翼は血まみれの残骸と化し、無防備状態になる。【飛行移動力】が0に低下する。飛行中のものは落下し、高度に応じたダメージを受ける。地上にいるクリーチャーは、怪我が癒えるまで飛び立てない。治療を受けるまで毎R被害者のターン開始時に20％の確率で死亡。以後CTはサドンデスを適用。【頑強】テストに失敗すると飛行能力を失う。',
        '08:翼が千切れてバラバラになり、無防備状態になる。【飛行移動力】が0に低下する。飛行中のものは落下し、高度に応じたダメージを受ける。地上にいるクリーチャーは、怪我が癒えるまで飛び立てない。治療を受けるまで毎R被害者のターン開始時に20％の確率で死亡。以後CTはサドンデスを適用。飛行能力を失う。',
        '09:大動脈が切断された。コンマ数秒の内に血を噴き上げてくずおれる、ショックと出血で死は瞬時に訪れる。',
        '10:死亡する。いかに盛大に出血し、どのような死に様を見せたのかを説明してもよい。',
    ]
    
    criticalTable = [
         5, 7, 9,10,10,10,10,10,10,10,  #01-10
         5, 6, 8, 9,10,10,10,10,10,10,  #11-20
         4, 6, 8, 9, 9,10,10,10,10,10,  #21-30
         4, 5, 7, 8, 9, 9,10,10,10,10,  #31-40
         3, 5, 7, 8, 8, 9, 9,10,10,10,  #41-50
         3, 4, 6, 7, 8, 8, 9, 9,10,10,  #51-60
         2, 4, 6, 7, 7, 8, 8, 9, 9,10,  #61-70
         2, 3, 5, 6, 7, 7, 8, 8, 9, 9,  #71-80
         1, 3, 5, 6, 6, 7, 7, 8, 8, 9,  #81-90
         1, 2, 4, 5, 6, 6, 7, 7, 8, 8,  #91-00
    ]
    
    output = "1";
    
    unless(/WH([HABTLW])(\d+)/ =~ string)
      return '1';
    end
    
    partsWord = $1;     #部位
    criticalValue = $2.to_i;    #クリティカル値
    criticalValue = 10 if(criticalValue > 10);
    criticalValue = 1 if(criticalValue < 1);
    
    whpp = ''
    whppp = ''
    
    case partsWord
    when /H/i
      whpp = '頭部';
      whppp = whh
    when /A/i
      whpp = '腕部';
      whppp = wha
    when /[TB]/i
      whpp = '胴体';
      whppp = whb
    when /L/i
      whpp = '脚部';
      whppp = whl
    when /W/i
      whpp = '翼部';
      whppp = whw
    end
    
    dice_now, dice_str = roll(1, 100);
    
    crit_no = ((dice_now - 1) / 10).to_i * 10;
    crit_num = criticalTable[crit_no + criticalValue - 1];
    
    resultText = whppp[crit_num - 1];
    if(crit_num >= 5)
      resultText += 'サドンデス×'
    else
      resultText += 'サドンデス○'
    end
    
    output = "#{dst}:#{whpp}CT表(#{dice_now}+#{criticalValue}) ＞ #{resultText}";
  
    return output
  end
  
  def wh_atpos(pos_num, pos_type)   #WHFRP2命中部位表
    debug("wh_atpos begin pos_type", pos_type)
    pos_2l = [
      '二足',
      15,'頭部',
      35,'右腕',
      55,'左腕',
      80,'胴体',
      90,'右脚',
      100,'左脚',
    ]
    pos_2lw = [
      '有翼二足',
      15,'頭部',
      25,'右腕',
      35,'左腕',
      45,'右翼',
      55,'左翼',
      80,'胴体',
      90,'右脚',
      100,'左脚',
    ]
    pos_4l = [
      '四足',
      15,'頭部',
      60,'胴体',
      70,'右前脚',
      80,'左前脚',
      90,'右後脚',
      100,'左後脚',
    ]
    pos_4la = [
      '半人四足',
      10,'頭部',
      20,'右腕',
      30,'左腕',
      60,'胴体',
      70,'右前脚',
      80,'左前脚',
      90,'右後脚',
      100,'左後脚',
    ]
    pos_4lw = [
      '有翼四足',
      10,'頭部',
      20,'右翼',
      30,'左翼',
      60,'胴体',
      70,'右前脚',
      80,'左前脚',
      90,'右後脚',
      100,'左後脚',
    ]
    pos_b = [
        '鳥',
      15,'頭部',
      35,'右翼',
      55,'左翼',
      80,'胴体',
      90,'右脚',
      100,'左脚',
    ]
    
    wh_pos = [pos_2l, pos_2lw, pos_4l, pos_4la, pos_4lw, pos_b]
    
    pos_t = 0;
    debug("pos_type", pos_type)
    if(pos_type != "")
      case pos_type
      when /\@(2W|W2)/i
        pos_t = 1;
      when /\@(4W|W4)/i
        pos_t = 4;
      when /\@(4H|H4)/i
        pos_t = 3;
      when /\@4/i
        pos_t = 2;
      when /\@W/i
        pos_t = 5;
      else
        unless( /\@(2H|H2|2)/i =~ pos_type)
          pos_t = -1;
        end
      end
    end
    
    output = "";
    
    debug("pos_t", pos_t)
    if(pos_t < 0)
      wh_pos.each do |pos_i|
        output += get_wh_atpos_message(pos_i, pos_num)
      end
    else
      pos_i = wh_pos[pos_t];
      output += get_wh_atpos_message(pos_i, pos_num)
    end
    
    return output;
  end
  
  def get_wh_atpos_message(pos_i, pos_num)
    output = ""
    
    output += ' ' + pos_i[0] + ":";
    
    1.step(pos_i.length + 1, 2) do |i|
      if( pos_num <= pos_i[i] )
        output += pos_i[i + 1];
        break
      end
    end
    
    return output
  end
  
  def wh_att(string, nick_e)
    debug("wh_att begin string", string)
    
    pos_type = "";
    
    if( /(.+)(@.*)/ =~ string )
      string = $1;
      pos_type = $2;
      debug("pos_type", pos_type)
    end
    
    unless(/WH(\d+)/i =~ string)
      return '1'
    end
    
    diff = $1.to_i;
    
    total_n, dice_dmy = roll(1, 100);
    
    output = "#{nick_e}: (#{string}) ＞ #{total_n}";
    output += check_suc(total_n, 0, "<=", diff, 1, 100, 0, total_n);
    
    pos_num = (total_n % 10) * 10 + (total_n / 10).to_i;
    pos_num = 100 if(total_n >= 100);
    
    output += wh_atpos(pos_num, pos_type) if(total_n <= diff);
    
    return output;
  end


end
