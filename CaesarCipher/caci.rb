#
# usage : ruby caci.rb -f filename [-k keynumber]
#

# ********************************************************************
#   定数
# ********************************************************************
OUTPUTFILE_EXT = ".cc"  # 出力ファイルに付与する拡張子

# ********************************************************************
# *  name      : キー＆ファイル名取得処理                            *
# *  content   : コマンドライン配列からキーとファイル名を取得        *
# *  parameter : (I) arrayCommand    コマンドライン配列              *
# *              (I) bind            out用引数を使うためのbinding    *
# *              (O) outIntKeyNumber キーを入れる変数                *
# *              (O) outStrFileName  ファイル名を入れる変数          *
# *  return    : 無し                                                *
# *  remarks   : 処理結果を返すべきだが、面倒なので省略              *
# ********************************************************************
def getKeyAndFilename(arrayCommand, bind, outIntKeyNumber, outStrFileName)

  next_cancel = false

  #--------------------------------------------------------------
  # 個数分回す
  #--------------------------------------------------------------
  arrayCommand.size.times { |i|
    if next_cancel == true
      next_cancel = false
      next
    end

    #--------------------------------------------------------------
    # 解析
    #--------------------------------------------------------------
    case arrayCommand[i].upcase
    # ファイル名
    when "-F"
      next_cancel = true
      puts "#{arrayCommand[i]} #{arrayCommand[i+1]}"
      bind.local_variable_set(outStrFileName, arrayCommand[i+1])
    # キー
    when "-K"
      next_cancel = true
      puts "#{arrayCommand[i]} #{arrayCommand[i+1]}"
      bind.local_variable_set(outIntKeyNumber, arrayCommand[i+1].to_i)
    # その他
    else
      next_cancel = false
      puts arrayCommand[i]
    end
  }

end


# ********************************************************************
# *  name      : 文字ずらし処理                                      *
# *  content   : 対象文字にキーを足したものを返す                    *
# *  parameter : (I) uchar 対象文字                                  *
# *              (I) schar キー                                      *
# *  return    : 対象文字にキーを足したもの                          *
# *  remarks   :                                                     *
# ********************************************************************
def getCaesarCipher(src, key)
  return src + key
end


# ********************************************************************
# *  name      : 大文字小文字処理                                    *
# *  content   : 大文字と小文字を変換する、英字以外はそのまま返す    *
# *  parameter : (I) uchar 対象文字                                  *
# *  return    : 対象文字を大文字or小文字に変換したもの              *
# *  remarks   :                                                     *
# ********************************************************************
def chgCase(src)
  diff = 'a'.ord - 'A'.ord

  # 小文字の場合
  if ("a".."z").include?(src.chr)
    return src - diff
  # 大文字の場合
  elsif ("A".."Z").include?(src.chr)
    return src + diff
  # その他
  else
    return src
  end
end


# ********************************************************************
# *  name      : 処理メイン                                          *
# ********************************************************************
keynumber = 0
filename  = ""

getKeyAndFilename(ARGV, binding, :keynumber, :filename)
puts "--------"
puts keynumber
puts filename

# ファイルの存在確認
if File.exist?(filename) == false
  puts("error : input file open error.(#{filename})");
  exit
end


#==============================================================
# １文字ずつ読み込んでファイル出力
#==============================================================
#--------------------------------------------------------------
# OPEN（入力ファイル）
#--------------------------------------------------------------
inFile  = File.open(filename, "rb")
inFile.binmode
#--------------------------------------------------------------
# OPEN（出力ファイル）
#--------------------------------------------------------------
outFile = File.open(filename + OUTPUTFILE_EXT, "wb")
outFile.binmode

#--------------------------------------------------------------
# READ ＆ 暗号化
#--------------------------------------------------------------
# キーナンバーから暗号用に使う値を算出する
while( binC = inFile.getc )
  puts("0x{binC.ord.to_s(16)} (#{binC})")

  ordBinC = binC.ord
  ordFirstC = "\0"
  ordLastC  = "\0"

  #--------------------------------------------------------------
  # 文字の種類の判定
  #--------------------------------------------------------------
  if ("a".."z").include?(binC)
    puts "小文字"
    ordFirstC = 'a'.ord
    ordLastC  = 'z'.ord
  elsif ("A".."Z").include?(binC)
    puts "大文字"
    ordFirstC = 'A'.ord
    ordLastC  = 'Z'.ord
  elsif ("0".."9").include?(binC)
    puts "数字"
    ordFirstC = '0'.ord
    ordLastC  = '9'.ord
  else
    puts "default"
  end


  #--------------------------------------------------------------
  # （必要があれば）変換範囲内の文字に収める
  #--------------------------------------------------------------
  if ordFirstC != "\0"
    #--------------------------------------------------------------
    # 暗号化実施
    #--------------------------------------------------------------
    ordBinC = getCaesarCipher(ordBinC, keynumber)

    if(ordBinC > ordLastC)
      ordBinC -= (ordLastC - ordFirstC + 1)
    elsif(ordBinC < ordFirstC)
      ordBinC += (ordLastC - ordFirstC + 1)
    else
      # nop
    end
  end

  #--------------------------------------------------------------
  # 大文字小文字変換
  #--------------------------------------------------------------
  ordBinC = chgCase(ordBinC)

  #--------------------------------------------------------------
  # ファイル出力
  #--------------------------------------------------------------
  outFile.putc(ordBinC.chr)

end


#--------------------------------------------------------------
# CLOSE
#--------------------------------------------------------------
inFile.close
#--------------------------------------------------------------
# CLOSE
#--------------------------------------------------------------
outFile.close