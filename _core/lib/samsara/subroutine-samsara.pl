use strict;
#use warnings;
use utf8;
use open ":utf8";
use CGI::Cookie;
use List::Util qw/max min/;
use Fcntl;

### サブルーチン-Samsara ##################################################################################

### ユニットステータス出力 --------------------------------------------------
sub createUnitStatus {
  my %pc = %{$_[0]};
  my $target = $_[1] || '';
  my @unitStatus;

  # サンサーラバラッドの簡易ステータス表示
  # HP, AP, 内包カルマ, 使用カルマ などを表示すべきか
  
  @unitStatus = (
    { 'HP' => $pc{hpTotal} },
    { 'AP' => $pc{apTotal} },
  );
  
  # 簡易表示の設定があれば従う
  foreach my $key (split ',', $pc{unitStatusNotOutput}){
    @unitStatus = grep { !exists $_->{$key} } @unitStatus;
  }

  foreach my $num (1..$pc{unitStatusNum}){
    next if !$pc{"unitStatus${num}Label"};
    push(@unitStatus, { $pc{"unitStatus${num}Label"} => $pc{"unitStatus${num}Value"} });
  }

  return \@unitStatus;
}

### クラス色分け --------------------------------------------------
sub class_color {
  my $text = shift;
  # 必要に応じて実装
  return $text;
}

### アイコン置換 --------------------------------------------------
sub checkSkillName {
  my $text = shift;
  # SW2.0/2.5のアイコン置換ロジックを流用（必要に応じて変更）
  my $markList = "[○◯〇＞▶〆☆≫»□☐☑🗨▽▼]|&gt;&gt;";
  
  $text =~ s/^((?:$markList)+.+?)(　|$)/&replaceSkillName($1).$2/egim;
  return $text;

  sub replaceSkillName {
    my @names;
    foreach (split '、', $_[0]){
      $_ =~ s/^(?:$markList)+/&textToIcon($&)/egim;
      push(@names, $_);
    }
    return join('、', @names);
  }
}
sub textToIcon {
  my $text = shift;
  
  $text =~ s{\[常\]|[○◯〇]}{<i class="s-icon passive"><span class="raw">&#91;常&#93;</span></i>}gi;
  $text =~ s{\[主\]|[＞▶〆]}{<i class="s-icon major"><span class="raw">&#91;主&#93;</span></i>}gi;
  $text =~ s{\[補\]|[☆≫»]|&gt;&gt;}{<i class="s-icon minor"><span class="raw">&#91;補&#93;</span></i>}gi;
  $text =~ s{\[宣\]|[□☐☑🗨]}{<i class="s-icon active"><span class="raw">&#91;宣&#93;</span></i>}gi;
  $text =~ s{\[条\]|[▽]}{<i class="s-icon condition"><span class="raw">&#91;条&#93;</span></i>}gi;
  $text =~ s{\[選\]|[▼]}{<i class="s-icon selection"><span class="raw">&#91;選&#93;</span></i>}gi;
  
  return $text;
}
sub checkArtsName {
  my $text = checkSkillName($_[0]);
  my $mark;
  while($text =~ s#^<i class="s-icon [^>]+?">.*?</i>##){
    $mark .= $&;
  }
  return $text, $mark;
}

### 補正値記法の解釈 --------------------------------------------------
sub extractModifications {
  my %pc = %{shift;};
  my @modifications = ();
  
  # サンサーラバラッドで補正値の概念がどの程度あるか不明だが、
  # 一旦SW2.5のものをコメントアウトして空配列を返すようにしておく
  # 必要が生じたら復活させる

  return \@modifications;
}

### バージョンアップデート --------------------------------------------------
sub data_update_chara {
  my %pc = %{$_[0]};
  my $ver = $pc{ver};
  $ver =~ s/^([0-9]+)\.([0-9]+)\.([0-9]+)$/$1.$2$3/;
  delete $pc{updateMessage};

  # 新規作成なので過去バージョン互習処理は基本的に不要

  $pc{ver} = $main::ver;
  $pc{lasttimever} = $ver;
  return %pc;
}

sub isEmptyValue {
  my $value = shift;
  return defined($value) && $value ne '' && $value !~ /^[-ー－―]$/ ? 0 : 1;
}

1;
