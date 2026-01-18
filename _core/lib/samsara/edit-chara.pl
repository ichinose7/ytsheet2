############# フォーム・キャラクター #############
use strict;
#use warnings;
use utf8;
use open ":utf8";
use feature 'say';
use JSON::PP;

my $LOGIN_ID = $::LOGIN_ID;

require $set::lib_palette_sub;
require $set::data_class;
require $set::data_races;

my ($data, $mode, $file, $message) = getSheetData($::in{mode});
our %pc = %{ $data };

my $mode_make = ($mode =~ /^(blanksheet|copy|convert)$/) ? 1 : 0;

if($message){
  my $name = unescapeTags($pc{characterName} || $pc{aka} || '無題');
  $message =~ s/<!NAME>/$name/;
}
if($mode_make){ $pc{playerName} = (getplayername($LOGIN_ID))[0]; }
if($mode_make){ $pc{protect} ||= $LOGIN_ID ? 'account' : 'password'; }

if($mode eq 'edit' || ($mode eq 'convert' && $pc{ver})){
  %pc = data_update_chara(\%pc);
}
elsif($mode eq 'blanksheet'){
  $pc{group} = $set::group_default;
  $pc{karmaInside} = $set::make_karma;
  $pc{money} = $set::make_money;
  $pc{moneyAuto} = 1;
  $pc{depositAuto} = 1;
  $pc{paletteUseBuff} = 1;
  $pc{langEarth1} = $data::lang_earth_default;
  %pc = applyCustomizedInitialValues(\%pc, '');
}

$pc{imageFit} = $pc{imageFit} eq 'percent' ? 'percentX' : $pc{imageFit};
$pc{imagePercent}   //= '200';
$pc{imagePositionX} //= '50';
$pc{imagePositionY} //= '50';
$pc{wordsX} ||= '右';
$pc{wordsY} ||= '上';

setDefaultColors();

$pc{carrierNum}   ||= 3;
$pc{cheatNum}     ||= 1;
$pc{equipNum}     ||= 1;
$pc{toolNum}      ||= 3;
$pc{followerNum}  ||= 1;
$pc{historyNum}   ||= 3;
$pc{cashbookNum}  ||= 3;
$pc{langIraNum}   ||= 1;
$pc{langEarthNum} ||= 1;

$pc{words}       =~ s/&lt;br&gt;/\n/g;
$pc{freeNote}    =~ s/&lt;br&gt;/\n/g;
$pc{chatPalette} =~ s/&lt;br&gt;/\n/g;

my $titlebarname = removeTags removeRuby unescapeTags ($pc{characterName} || ($pc{aka} ? qq{"$pc{aka}"} : ''));
print <<"HTML";
Content-type: text/html\n
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>@{[$mode eq 'edit'?"編集：$titlebarname" : '新規作成']} - $set::title</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/_common/css/base.css?${main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/_common/css/sheet.css?${main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/samsara/css/chara.css?${main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/_common/css/edit.css?${main::ver}">
  <link rel="stylesheet" media="all" href="${main::core_dir}/skin/samsara/css/edit.css?${main::ver}">
  <script src="${main::core_dir}/skin/_common/js/lib/Sortable.min.js"></script>
  <script src="${main::core_dir}/skin/_common/js/lib/compressor.min.js"></script>
  <script src="./?mode=js-consts&ver=${main::ver}"></script>
  <script src="${main::core_dir}/lib/edit.js?${main::ver}" defer></script>
  <script src="${main::core_dir}/lib/samsara/edit-chara.js?${main::ver}" defer></script>
  <style>
    #image, .image-custom-view { background-image: url("$pc{imageURL}"); }
    /* 上部：パーソナリティとキャラクター画像 */
    .top-row { display: flex; gap: 1rem; flex-wrap: wrap; }
    .personality-box { flex: 1 1 350px; }
    .personality-box table { width: 100%; border-collapse: collapse; }
    .personality-box th, .personality-box td { border: 1px solid #666; padding: 0.4rem; }
    .personality-box th { background: #5a8f5a; color: #fff; width: 110px; text-align: left; }
    .personality-box td input, .personality-box td select { width: 100%; }
    .image-box { flex: 0 0 200px; }
    /* メインエリア：行為タグ(左)、能力値等(右) */
    .main-row { display: flex; gap: 1rem; flex-wrap: wrap; margin-top: 1rem; }
    .tags-column { flex: 0 0 280px; }
    .stats-column { flex: 1 1 500px; }
    /* 行為タグ縦並び */
    .tags-category-box { border: 1px solid #888; margin-bottom: 0.5rem; }
    .tags-category-box h3 { margin: 0; padding: 0.3rem 0.5rem; font-size: 0.95rem; background: #5a8f5a; color: #fff; }
    .tags-row { display: flex; flex-wrap: wrap; padding: 0.3rem; gap: 0.2rem 0.6rem; }
    .tags-row label { display: flex; align-items: center; gap: 0.1rem; font-size: 1.1rem; white-space: nowrap; }
    .tags-row input[type="checkbox"] { transform: scale(1.1); }
    /* 言語セクション */
    .lang-section { display: flex; gap: 1rem; flex-wrap: wrap; margin-top: 0.5rem; }
    .lang-box { flex: 1 1 130px; border: 1px solid #888; }
    .lang-box h4 { margin: 0; padding: 0.2rem 0.4rem; font-size: 0.85rem; background: #5a8f5a; color: #fff; }
    .lang-container { padding: 0.3rem; }
    .lang-row { margin-bottom: 0.2rem; }
    .lang-row input, .lang-row select { width: 100%; font-size: 0.9rem; }
    .add-del-btn { font-size: 0.8rem; }
    .add-del-btn a { cursor: pointer; margin-right: 0.5rem; }
    /* テーブル共通 */
    .status-table { width: 100%; border-collapse: collapse; }
    .status-table th, .status-table td { border: 1px solid #666; padding: 0.3rem; text-align: center; }
    .status-table th { background: #5a8f5a; color: #fff; }
    .status-table input[type="number"] { width: 50px; text-align: center; }
    .hp-total, .ap-total { font-size: 1.3rem; font-weight: bold; color: #c00; }
    .stt-total { font-size: 1.2rem; font-weight: bold; color: #009; }
    textarea.resizable { resize: vertical; min-height: 100px; width: 100%; }
  </style>
</head>
<body>
  <script src="${main::core_dir}/skin/_common/js/common.js?${main::ver}"></script>
  <header><h1>$set::title</h1></header>
  <main><article>
    <form name="sheet" method="post" action="./" enctype="multipart/form-data">
    <input type="hidden" name="ver" value="${main::ver}">
HTML
if($mode_make){ print '<input type="hidden" name="_token" value="'.tokenMake().'">'."\n"; }
print <<"HTML";
    <input type="hidden" name="mode" value="@{[ $mode eq 'edit' ? 'save' : 'make' ]}">
    
    <div id="header-menu">
      <h2><span></span></h2>
      <ul>
        <li onclick="sectionSelect('common');"><span>キャラクター</span><span>データ</span>
        <li onclick="sectionSelect('palette');"><span>コマ</span><span>設定</span>
        <li onclick="sectionSelect('color');" class="color-icon" title="カラーカスタム">
        <li onclick="view('text-rule')" class="help-icon" title="テキスト整形ルール">
        <li onclick="nightModeChange()" class="nightmode-icon" title="ナイトモード切替">
        <li onclick="exportAsJson()" class="download-icon" title="JSON出力">
        <li class="buttons">
          <ul>
            <li @{[ display ($mode eq 'edit') ]} class="view-icon" title="閲覧画面"><a href="./?id=$::in{id}"></a>
            <li @{[ display ($mode eq 'edit') ]} class="copy" onclick="window.open('./?mode=copy&id=$::in{id}@{[  $::in{log}?"&log=$::in{log}":'' ]}');">複製
            <li class="submit" onclick="formSubmit()" title="Ctrl+S">保存
          </ul>
        </li>
      </ul>
      <div id="save-state"></div>
    </div>
    <aside class="message">$message</aside>
    
    <section id="section-common">
HTML
if($set::user_reqd){
  print '<input type="hidden" name="protect" value="account"><input type="hidden" name="protectOld" value="'.$pc{protect}.'"><input type="hidden" name="pass" value="'.$::in{pass}.'">'."\n";
} else {
  if($set::registerkey && $mode_make){ print '登録キー：<input type="text" name="registerkey" required>'."\n"; }
  print '<details class="box" id="edit-protect" '.($mode eq 'edit' ? '':'open').'><summary>編集保護設定</summary><fieldset id="edit-protect-view"><input type="hidden" name="protectOld" value="'.$pc{protect}.'">';
  if($LOGIN_ID){ print '<input type="radio" name="protect" value="account"'.($pc{protect} eq 'account'?' checked':'').'> アカウントに紐付ける<br>'; }
  print '<input type="radio" name="protect" value="password"'.($pc{protect} eq 'password'?' checked':'').'> パスワードで保護 ';
  if ($mode eq 'edit' && $pc{protect} eq 'password' && $::in{pass}) { print '<input type="hidden" name="pass" value="'.$::in{pass}.'"><br>'; }
  else { print '<input type="password" name="pass"><br>'; }
  print '<input type="radio" name="protect" value="none"'.($pc{protect} eq 'none'?' checked':'').'> 保護しない</fieldset></details>'."\n";
}

print <<"HTML";
    <dl class="box" id="hide-options">
      <dt>閲覧可否設定
      <dd id="forbidden-checkbox"><select name="forbidden">
        <option value="">内容を全て開示
        <option value="battle" @{[ $pc{forbidden} eq 'battle' ? 'selected' : '' ]}>データ・数値のみ秘匿
        <option value="all" @{[ $pc{forbidden} eq 'all' ? 'selected' : '' ]}>内容を全て秘匿
      </select>
      <dd id="hide-checkbox"><select name="hide">
        <option value="">一覧に表示
        <option value="1" @{[ $pc{hide} ? 'selected' : '' ]}>一覧には非表示
      </select>
    </dl>
    <div class="box" id="group">
      <dl><dt>グループ<dd><select name="group">
HTML
foreach (@set::groups){
  my $id = @$_[0]; my $name = @$_[2]; my $exclusive = @$_[4];
  next if($exclusive && (!$LOGIN_ID || $LOGIN_ID !~ /^($exclusive)$/));
  print '<option value="'.$id.'"'.($pc{group} eq $id ? ' selected': '').'>'.$name.'</option>';
}
print <<"HTML";
      </select><dt>タグ<dd>@{[ input 'tags','','','' ]}</dl>
    </div>

    <!-- 上部：パーソナリティ + キャラクター画像 -->
    <div class="top-row">
      <div class="box personality-box" id="personality" data-content-title="パーソナリティ">
        <h2>パーソナリティ</h2>
        <table>
          <tr><th>キャラクター名</th><td>@{[input('characterName','text',"setName")]}</td></tr>
          <tr><th>プレイヤー名</th><td>@{[input('playerName')]}</td></tr>
          <tr><th>地球での氏名</th><td>@{[input('aka','text',"setName")]}</td></tr>
          <tr><th>死因</th><td>@{[input('causeOfDeath')]}</td></tr>
          <tr><th>種族</th><td>@{[input('race')]}</td></tr>
          <tr><th>年齢</th><td>@{[input('age')]}</td></tr>
          <tr><th>性別</th><td><select name="gender"><option value="男性"@{[$pc{gender} eq '男性' ? ' selected' : '']}>男性</option><option value="女性"@{[$pc{gender} eq '女性' ? ' selected' : '']}>女性</option><option value="その他"@{[$pc{gender} eq 'その他' ? ' selected' : '']}>その他</option></select></td></tr>
          <tr><th>出身</th><td>@{[input('birth')]}</td></tr>
        </table>
      </div>
      <div class="box image-box" id="image-section" data-content-title="キャラクター画像">
        <h2>キャラクター画像</h2>
        @{[ imageForm($pc{imageURL}) ]}
      </div>
    </div>

    <!-- カルマセクション -->
    <div class="box" id="karma-section" data-content-title="カルマ">
      <h2>カルマ</h2>
      <table class="status-table">
        <tr><th style="width:25%">内包カルマ</th><th style="width:25%">使用カルマ</th><th style="width:25%">潜在カルマ</th><th style="width:25%">限界強度</th></tr>
        <tr>
          <td>@{[input('karmaInside','number','calcKarma')]}</td>
          <td><b id="karma-used-view">0</b></td>
          <td><b id="karma-latent-view">0</b></td>
          <td><b id="karma-limit-view">0</b></td>
        </tr>
      </table>
    </div>

    <!-- メインエリア：行為タグ(左) + 能力値等(右) -->
    <div class="main-row">
      <!-- 左：行為タグ縦並び -->
      <div class="tags-column">
        <div class="box" id="tags-section" data-content-title="行為タグ">
          <h2>行為タグ</h2>
HTML
foreach my $cat_data (@data::tags_category){
  my ($cat_id, $cat_name, @rows) = @$cat_data;
  print "<div class=\"tags-category-box\" id=\"tags-${cat_id}\"><h3>${cat_name}</h3><div class=\"tags-row\">";
  foreach my $row (@rows){
    foreach my $tag (@$row){ print '<label>'.checkbox("tag${tag}", '', '').$tag.'</label>'; }
  }
  print '</div></div>';
}
print <<"HTML";
          <!-- 言語セクション -->
          <div class="lang-section">
            <div class="lang-box">
              <h4>言語(イラ)</h4>
              @{[input('langIraNum','hidden')]}
              <div class="lang-container" id="lang-ira-container">
                <template id="lang-ira-template"><div class="lang-row" id="lang-ira-rowTMPL"><select name="langIraTMPL">
HTML
foreach my $lang (@data::lang_ira_default){ print "<option value=\"$lang\">$lang</option>"; }
print <<"HTML";
                </select></div></template>
HTML
foreach my $num (1 .. $pc{langIraNum}){
  print '<div class="lang-row" id="lang-ira-row'.$num.'"><select name="langIra'.$num.'">';
  foreach my $lang (@data::lang_ira_default){ print '<option value="'.$lang.'"'.($pc{"langIra${num}"} eq $lang ? ' selected':'').'>'.$lang.'</option>'; }
  print '</select></div>';
}
print <<"HTML";
              </div>
              <div class="add-del-btn"><a onclick="addLangIra()">＋</a><a onclick="delLangIra()">－</a></div>
            </div>
            <div class="lang-box">
              <h4>言語(地球)</h4>
              @{[input('langEarthNum','hidden')]}
              <div class="lang-container" id="lang-earth-container">
                <template id="lang-earth-template"><div class="lang-row" id="lang-earth-rowTMPL"><input type="text" name="langEarthTMPL" value=""></div></template>
HTML
foreach my $num (1 .. $pc{langEarthNum}){
  print '<div class="lang-row" id="lang-earth-row'.$num.'"><input type="text" name="langEarth'.$num.'" value="'.$pc{"langEarth${num}"}.'"></div>';
}
print <<"HTML";
              </div>
              <div class="add-del-btn"><a onclick="addLangEarth()">＋</a><a onclick="delLangEarth()">－</a></div>
            </div>
          </div>
        </div>
      </div>
      <!-- 右：能力値・副能力値・生活 -->
      <div class="stats-column">
        <!-- 能力値セクション -->
        <div class="box" id="status-section" data-content-title="能力値">
          <h2>能力値</h2>
          <table class="status-table">
            <tr><th></th><th>【身体】</th><th>【精神】</th><th>【感覚】</th><th>【知性】</th></tr>
            <tr><th>能力値</th>
              <td><span class="stt-total" id="stt-body-total">0</span></td>
              <td><span class="stt-total" id="stt-mind-total">0</span></td>
              <td><span class="stt-total" id="stt-sense-total">0</span></td>
              <td><span class="stt-total" id="stt-intellect-total">0</span></td>
            </tr>
            <tr><th>成功率</th>
              <td><b id="suc-body-view">0</b>%</td>
              <td><b id="suc-mind-view">0</b>%</td>
              <td><b id="suc-sense-view">0</b>%</td>
              <td><b id="suc-intellect-view">0</b>%</td>
            </tr>
            <tr><th>スキル・チート</th>
              <td>@{[input('sttBodySkillCheat','number','calcStt')]}</td>
              <td>@{[input('sttMindSkillCheat','number','calcStt')]}</td>
              <td>@{[input('sttSenseSkillCheat','number','calcStt')]}</td>
              <td>@{[input('sttIntellectSkillCheat','number','calcStt')]}</td>
            </tr>
            <tr><th>種族</th>
              <td>@{[input('sttBodyRace','number','calcStt;calcKarma')]}</td>
              <td>@{[input('sttMindRace','number','calcStt;calcKarma')]}</td>
              <td>@{[input('sttSenseRace','number','calcStt;calcKarma')]}</td>
              <td>@{[input('sttIntellectRace','number','calcStt;calcKarma')]}</td>
            </tr>
            <tr><th>成長</th>
              <td>@{[input('sttBodyGrowth','number','calcStt;calcKarma')]}</td>
              <td>@{[input('sttMindGrowth','number','calcStt;calcKarma')]}</td>
              <td>@{[input('sttSenseGrowth','number','calcStt;calcKarma')]}</td>
              <td>@{[input('sttIntellectGrowth','number','calcStt;calcKarma')]}</td>
            </tr>
          </table>
        </div>
        <!-- 副能力値セクション -->
        <div class="box" id="sub-status-section" data-content-title="副能力値">
          <h2>副能力値</h2>
          <table class="status-table">
            <tr><th>【HP】</th><th>【装甲値】</th><th>【部隊値】</th><th>【AP】</th></tr>
            <tr>
              <td>基本<span id="hp-base-view">0</span>+補正@{[input('hpMod','number','calcSubStt','style="width:40px"')]}=<span class="hp-total" id="hp-total-view">0</span></td>
              <td><b id="defense-total-view">0</b></td>
              <td><b id="troop-total-view">0</b></td>
              <td>基本<span id="ap-base-view">0</span>+補正@{[input('apMod','number','calcSubStt','style="width:40px"')]}=<span class="ap-total" id="ap-total-view">0</span></td>
            </tr>
          </table>
          <table class="status-table" style="margin-top:0.3rem;">
            <tr><th>限界重量</th><th>所持重量</th><th>収納・積載</th></tr>
            <tr>
              <td>基本<span id="weight-limit-base-view">0</span>+補正@{[input('weightLimitMod','number','calcSubStt','style="width:40px"')]}=<span id="weight-limit-total-view">0</span></td>
              <td>@{[input('weightHeld','number','calcSubStt')]}</td>
              <td>@{[input('storage')]}</td>
            </tr>
          </table>
        </div>
        <!-- 生活セクション -->
        <div class="box" id="life-section" data-content-title="生活">
          <h2>生活</h2>
          <table class="status-table">
            <tr><th>現在の職業キャリア</th><th>生活レベル</th><th>所持金</th></tr>
            <tr><td>@{[input('jobCarrier')]}</td><td>@{[input('lifeLevel')]}</td><td>@{[input('money','number')]} Rs</td></tr>
          </table>
          <table class="status-table" style="margin-top:0.3rem;">
            <tr><th>収入</th><td>@{[input('income','number')]}</td><th>支出</th><td>@{[input('outcome','number')]}</td><th>余剰</th><td>@{[input('surplus','number')]} Rs</td></tr>
          </table>
        </div>
      </div>
    </div>

    <!-- チートセクション -->
    <div class="box" id="cheat-section" data-content-title="チート">
      <h2>チート</h2>
      <table class="status-table edit-table" id="cheat-table">
        <thead><tr><th>チート名</th><th>汎用効果</th><th>カルマ</th><th>使用</th><th>強度</th><th>射程</th><th>対象</th><th>効果</th></tr></thead>
        <tbody>
HTML
foreach my $num ('TMPL',1..$pc{cheatNum}){
   print '<template id="cheat-template">' if $num eq 'TMPL';
   print '<tr id="cheat-row'.$num.'"><td>'.input("cheat${num}Name").'<td>'.checkbox("cheat${num}EffAttack",'攻').checkbox("cheat${num}EffHeal",'復').checkbox("cheat${num}EffBuff",'付').'<td>'.input("cheat${num}Karma",'number','calcKarma','style="width:50px"').'<td>'.input("cheat${num}Use",'','','style="width:50px"').'<td>'.input("cheat${num}Power",'','','style="width:50px"').'<td>'.input("cheat${num}Range",'','','style="width:50px"').'<td>'.input("cheat${num}Target",'','','style="width:60px"').'<td>'.input("cheat${num}Effect");
   print '</template>' if $num eq 'TMPL';
}
print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addCheat()">▼</a><a onclick="delCheat()">▲</a></div>
      @{[input('cheatNum','hidden')]}
    </div>

    <!-- キャリアパスセクション -->
    <div class="box" id="carrier-section" data-content-title="キャリアパス">
      <h2>キャリアパス</h2>
      <table class="status-table edit-table" id="carrier-table">
        <thead><tr><th>時期</th><th>キャリア</th><th>種別</th><th>スキル名</th><th>種別</th><th>カルマ</th><th>使用</th><th>AP</th><th>射程</th><th>対象</th><th>判定</th><th>参照</th></tr></thead>
        <tbody>
HTML
foreach my $num ('TMPL',1..$pc{carrierNum}){
   print '<template id="carrier-template">' if $num eq 'TMPL';
   print '<tr id="carrier-row'.$num.'"><td>'.input("carrier${num}Era",'','','style="width:50px"').'<td>'.input("carrier${num}Name").'<td>'.input("carrier${num}Type",'','','style="width:50px"').'<td>'.input("carrier${num}Skill").'<td>'.input("carrier${num}SkillType",'','','style="width:50px"').'<td>'.input("carrier${num}Karma",'number','calcKarma','style="width:50px"').'<td>'.input("carrier${num}Use",'','','style="width:50px"').'<td>'.input("carrier${num}Ap",'','','style="width:40px"').'<td>'.input("carrier${num}Range",'','','style="width:40px"').'<td>'.input("carrier${num}Target",'','','style="width:60px"').'<td>'.input("carrier${num}Check",'','','style="width:50px"').'<td>'.input("carrier${num}Ref",'','','style="width:50px"');
   print '</template>' if $num eq 'TMPL';
}
print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addCarrier()">▼</a><a onclick="delCarrier()">▲</a></div>
      @{[input('carrierNum','hidden')]}
    </div>

    <!-- 装備アイテムセクション -->
    <div class="box" id="equip-section" data-content-title="装備アイテム">
      <h2>装備アイテム</h2>
      <table class="status-table edit-table" id="equip-table">
        <thead><tr><th>装備</th><th>アイテム名</th><th>部位</th><th>使用</th><th>AP</th><th>射程</th><th>対象</th><th>判定</th><th>威力</th><th>F値</th><th>C値</th><th>装甲</th><th>重量</th><th>価格</th><th>カルマ</th><th>参照</th></tr></thead>
        <tbody>
HTML
foreach my $num ('TMPL',1..$pc{equipNum}){
   print '<template id="equip-template">' if $num eq 'TMPL';
   print '<tr id="equip-row'.$num.'"><td>'.checkbox("equip${num}Equipped",'','calcSubStt').'<td>'.input("equip${num}Name").'<td>'.input("equip${num}Part",'','','style="width:50px"').'<td>'.input("equip${num}Use",'','','style="width:50px"').'<td>'.input("equip${num}Ap",'','','style="width:40px"').'<td>'.input("equip${num}Range",'','','style="width:40px"').'<td>'.input("equip${num}Target",'','','style="width:60px"').'<td>'.input("equip${num}Check",'','','style="width:50px"').'<td>'.input("equip${num}Power",'','','style="width:60px"').'<td>'.input("equip${num}FVal",'','','style="width:30px"').'<td>'.input("equip${num}CVal",'','','style="width:30px"').'<td>'.input("equip${num}Defense",'number','calcSubStt','style="width:40px"').'<td>'.input("equip${num}Weight",'','','style="width:40px"').'<td>'.input("equip${num}Price",'','','style="width:50px"').'<td>'.input("equip${num}Karma",'number','calcKarma','style="width:50px"').'<td>'.input("equip${num}Ref",'','','style="width:50px"');
   print '</template>' if $num eq 'TMPL';
}
print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addEquip()">▼</a><a onclick="delEquip()">▲</a></div>
      @{[input('equipNum','hidden')]}
    </div>

    <!-- 道具アイテムセクション -->
    <div class="box" id="tool-section" data-content-title="道具アイテム">
      <h2>道具アイテム</h2>
      <table class="status-table edit-table" id="tool-table">
        <thead><tr><th>アイテム名</th><th>セット数</th><th>重量</th><th>価格</th><th>参照</th></tr></thead>
        <tbody>
HTML
foreach my $num ('TMPL',1..$pc{toolNum}){
   print '<template id="tool-template">' if $num eq 'TMPL';
   print '<tr id="tool-row'.$num.'"><td>'.input("tool${num}Name").'<td>'.input("tool${num}Count",'number','','style="width:50px"').'<td>'.input("tool${num}Weight",'number','','style="width:50px"').'<td>'.input("tool${num}Price",'number','','style="width:60px"').'<td>'.input("tool${num}Ref",'','','style="width:50px"');
   print '</template>' if $num eq 'TMPL';
}
print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addTool()">▼</a><a onclick="delTool()">▲</a></div>
      @{[input('toolNum','hidden')]}
    </div>

    <!-- フォロワーセクション -->
    <div class="box" id="follower-section" data-content-title="フォロワー">
      <h2>フォロワー</h2>
      <table class="status-table edit-table" id="follower-table">
        <thead><tr><th>フォロワー名</th><th>人数</th><th>部隊値</th><th>使用</th><th>AP</th><th>射程</th><th>対象</th><th>判定</th><th>威力</th><th>F値</th><th>C値</th><th>購入</th><th>支出</th><th>参照</th></tr></thead>
        <tbody>
HTML
foreach my $num ('TMPL',1..$pc{followerNum}){
   print '<template id="follower-template">' if $num eq 'TMPL';
   print '<tr id="follower-row'.$num.'"><td>'.input("follower${num}Name").'<td>'.input("follower${num}Count",'number','','style="width:40px"').'<td>'.input("follower${num}Troop",'number','calcSubStt','style="width:50px"').'<td>'.input("follower${num}Use",'','','style="width:50px"').'<td>'.input("follower${num}Ap",'','','style="width:40px"').'<td>'.input("follower${num}Range",'','','style="width:40px"').'<td>'.input("follower${num}Target",'','','style="width:60px"').'<td>'.input("follower${num}Check",'','','style="width:50px"').'<td>'.input("follower${num}Power",'','','style="width:60px"').'<td>'.input("follower${num}FVal",'','','style="width:30px"').'<td>'.input("follower${num}CVal",'','','style="width:30px"').'<td>'.input("follower${num}Purchase",'number','','style="width:50px"').'<td>'.input("follower${num}Expense",'number','','style="width:50px"').'<td>'.input("follower${num}Ref",'','','style="width:50px"');
   print '</template>' if $num eq 'TMPL';
}
print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addFollower()">▼</a><a onclick="delFollower()">▲</a></div>
      @{[input('followerNum','hidden')]}
      <dl><dt>部隊スキル<dd>@{[input('followerSkillName')]}</dl>
      <dl><dt>効果<dd>@{[input('followerSkillEffect')]}</dl>
    </div>

    <!-- 容姿・詳細・メモ -->
    <div class="box" id="free-note-section" data-content-title="容姿・詳細・メモ">
      <h2><label for="freeNote">容姿・詳細・メモ</label></h2>
      <ul class="annotate"><li>テキスト整形ルールが適用されます。</li></ul>
      <textarea name="freeNote" id="freeNote" class="resizable">$pc{freeNote}</textarea>
    </div>

    <!-- セッション履歴 -->
    <div class="box" id="history-section" data-content-title="セッション履歴">
      <h2>セッション履歴</h2>
      @{[input 'historyNum','hidden']}
      <table class="status-table edit-table" id="history-table">
        <thead><tr><th>日付</th><th>タイトル</th><th>入手カルマ</th><th>報酬金額</th><th>GM</th><th>備考</th></tr></thead>
        <tbody>
HTML
foreach my $num ('TMPL',1 .. $pc{historyNum}) {
  print '<template id="history-template">' if $num eq 'TMPL';
  print '<tr id="history-row'.$num.'"><td>'.input("history${num}Date",'','','style="width:80px"').'<td>'.input("history${num}Title").'<td>'.input("history${num}Karma",'number','calcKarma','style="width:60px"').'<td>'.input("history${num}Money",'number','','style="width:70px"').'<td>'.input("history${num}Gm",'','','style="width:80px"').'<td>'.input("history${num}Note").'</tr>';
  print '</template>' if $num eq 'TMPL';
}
print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addHistory()">▼</a><a onclick="delHistory()">▲</a></div>
    </div>

    <!-- 収支履歴 -->
    <div class="box" id="cashbook-section" data-content-title="収支履歴">
      <h2>収支履歴</h2>
      @{[input 'cashbookNum','hidden']}
      <table class="status-table edit-table" id="cashbook-table">
        <thead><tr><th>日付</th><th>項目</th><th>収入</th><th>支出</th><th>残高</th><th>備考</th></tr></thead>
        <tbody>
HTML
foreach my $num ('TMPL',1 .. $pc{cashbookNum}) {
  print '<template id="cashbook-template">' if $num eq 'TMPL';
  print '<tr id="cashbook-row'.$num.'"><td>'.input("cashbook${num}Date",'','','style="width:80px"').'<td>'.input("cashbook${num}Item").'<td>'.input("cashbook${num}Income",'number','calcCashbook','style="width:70px"').'<td>'.input("cashbook${num}Expense",'number','calcCashbook','style="width:70px"').'<td><b id="cashbook'.$num.'Balance">0</b></td><td>'.input("cashbook${num}Note").'</tr>';
  print '</template>' if $num eq 'TMPL';
}
print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addCashbook()">▼</a><a onclick="delCashbook()">▲</a></div>
    </div>

    </section>

    <!-- テキスト整形ルール -->
    <section id="popup-text-rule" class="pop-up" style="display:none;">
      <div class="pop-up-body">
        <h2>テキスト整形ルール<span class="close-icon" onclick="hidePopUp()"></span></h2>
        <div class="content">
          <dl>
            <dt>&lt;b&gt;太字&lt;/b&gt;<dd><b>太字</b>
            <dt>&lt;i&gt;斜体&lt;/i&gt;<dd><i>斜体</i>
            <dt>&lt;u&gt;下線&lt;/u&gt;<dd><u>下線</u>
            <dt>&lt;s&gt;打消&lt;/s&gt;<dd><s>打消</s>
            <dt>&lt;ruby&gt;文字列&lt;rt&gt;ルビ&lt;/rt&gt;&lt;/ruby&gt;<dd><ruby>文字列<rt>ルビ</rt></ruby>
            <dt>[[折り畳み見出し:折り畳み内容]]<dd>折り畳み表示にします
            <dt>{{非表示}}<dd>閲覧時に非表示になります
            <dt>%%色:文字列%%<dd>色を変更します
            <dt>---<dd>水平線を挿入
            <dt>[名前](URL)<dd>リンクを作成
            <dt>## 見出し<dd>見出しを作成
          </dl>
        </div>
      </div>
    </section>

    </form>
  </article></main>
  <footer><p class="notes"> (C)Yutorize <a href="http://yutorize.2-d.jp">ゆとらいず工房</a></p></footer>
</body>
</html>
HTML

1;
