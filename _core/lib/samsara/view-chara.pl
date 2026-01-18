################## データ表示 ##################
use strict;
#use warnings;
use utf8;
use open ":utf8";
use HTML::Template;

require $set::lib_palette_sub;
require $set::data_class;
require $set::data_races;

my $id = $::in{id};
my ($data, $mode, $file, $message) = getSheetData($mode);
our %pc = %{ $data };

if($::in{url}){ $pc{imageURL} = $::in{url}; }

if($pc{forbidden} && !$pc{yourAuthor}){
  my $author = $pc{playerName};
  my $protect = $pc{protect};
  my $forbidden = $pc{forbidden};
  if($forbidden eq 'all'){ %pc = (); }
  if($forbidden ne 'battle'){
    $pc{aka} = ''; $pc{characterName} = noiseText(6,14);
    $pc{group} = $pc{tags} = ''; $pc{freeNote} = ''; $pc{imageURL} = '';
  }
  $pc{playerName} = $author; $pc{protect} = $protect; $pc{forbidden} = $forbidden; $pc{forbiddenMode} = 1;
}

my $SHEET = HTML::Template->new( filename => $set::skin_sheet, utf8 => 1,
  loop_context_vars => 1, die_on_bad_params => 0, die_on_missing_include => 0, case_sensitive => 1, global_vars => 1
);

$SHEET->param(modeDownload => $mode eq 'download');
$SHEET->param(ver => $::ver);
$SHEET->param(coreDir => $::core_dir);
$SHEET->param(id => $id);
$SHEET->param(characterName => $pc{characterName});
$SHEET->param(aka => $pc{aka});
$SHEET->param(playerName => $pc{playerName});
$SHEET->param(imageURL => $pc{imageURL});

$SHEET->param(age => $pc{age});
$SHEET->param(gender => $pc{gender});
$SHEET->param(birth => $pc{birth});
$SHEET->param(causeOfDeath => $pc{causeOfDeath});
$SHEET->param(race => $pc{race});

$SHEET->param(karmaInside => $pc{karmaInside});

# 能力値計算（スキルチート + 種族 + 成長）
my @stats = ('Body', 'Mind', 'Sense', 'Intellect');
my %sttTotal;
foreach my $stat (@stats){
  my $skillCheat = $pc{"stt${stat}SkillCheat"} || 0;
  my $race = $pc{"stt${stat}Race"} || 0;
  my $growth = $pc{"stt${stat}Growth"} || 0;
  $sttTotal{$stat} = $skillCheat + $race + $growth;
  my $suc = $sttTotal{$stat} * 5;
  $suc = 99 if $suc > 99;
  
  $SHEET->param("stt${stat}Total" => $sttTotal{$stat});
  $SHEET->param("stt${stat}SkillCheat" => $skillCheat);
  $SHEET->param("stt${stat}Race" => $race);
  $SHEET->param("stt${stat}Growth" => $growth);
  $SHEET->param("suc${stat}" => $suc);
}

# カルマ計算（種族・成長はカルマ内）
my $karmaUsed = 0;
foreach my $stat (@stats){
  $karmaUsed += $pc{"stt${stat}Race"} || 0;
  $karmaUsed += $pc{"stt${stat}Growth"} || 0;
}
for (my $i = 1; $i <= ($pc{cheatNum}||0); $i++) { $karmaUsed += $pc{"cheat${i}Karma"} || 0; }
for (my $i = 1; $i <= ($pc{carrierNum}||0); $i++) { $karmaUsed += $pc{"carrier${i}Karma"} || 0; }
for (my $i = 1; $i <= ($pc{equipNum}||0); $i++) { $karmaUsed += $pc{"equip${i}Karma"} || 0; }
my $historyKarma = 0;
for (my $i = 1; $i <= ($pc{historyNum}||0); $i++) { $historyKarma += $pc{"history${i}Karma"} || 0; }
my $karmaTotal = ($pc{karmaInside}||0) + $historyKarma;
my $karmaLatent = $karmaTotal - $karmaUsed;
# 限界強度は切り上げ
use POSIX qw(ceil);
my $karmaLimit = ceil($karmaLatent / 5);
$SHEET->param(karmaUsed => $karmaUsed);
$SHEET->param(karmaLatent => $karmaLatent);
$SHEET->param(karmaLimit => $karmaLimit);

# HP計算
my $hpBase = ($sttTotal{Body} + $sttTotal{Mind}) * 3;
my $hpMod = $pc{hpMod} || 0;
my $hpTotal = $hpBase + $hpMod;
$SHEET->param(hpBase => $hpBase);
$SHEET->param(hpMod => $hpMod);
$SHEET->param(hpTotal => $hpTotal);

# 限界重量計算
my $weightLimitBase = $sttTotal{Body} * 2;
my $weightLimitMod = $pc{weightLimitMod} || 0;
my $weightLimit = $weightLimitBase + $weightLimitMod;
$SHEET->param(weightLimitBase => $weightLimitBase);
$SHEET->param(weightLimitMod => $weightLimitMod);
$SHEET->param(weightLimit => $weightLimit);
$SHEET->param(weightHeld => $pc{weightHeld});

my $overWeight = ($pc{weightHeld} || 0) > $weightLimit ? ($pc{weightHeld} - $weightLimit) : 0;

# AP計算
my $apBase = $sttTotal{Sense} + $sttTotal{Intellect};
my $apMod = $pc{apMod} || 0;
my $apTotal = $apBase + $apMod - $overWeight;
$SHEET->param(apBase => $apBase);
$SHEET->param(apMod => $apMod);
$SHEET->param(apTotal => $apTotal);

# 装甲値計算
my $defenseTotal = 0;
for (my $i = 1; $i <= ($pc{equipNum}||0); $i++) {
  if($pc{"equip${i}Equipped"}){ $defenseTotal += $pc{"equip${i}Defense"} || 0; }
}
$SHEET->param(defenseTotal => $defenseTotal);

# 部隊値計算
my $troopTotal = 0;
for (my $i = 1; $i <= ($pc{followerNum}||0); $i++) { $troopTotal += $pc{"follower${i}Troop"} || 0; }
$SHEET->param(troopTotal => $troopTotal);

$SHEET->param(storage => $pc{storage});

$SHEET->param(jobCarrier => $pc{jobCarrier});
$SHEET->param(lifeLevel => $pc{lifeLevel});
$SHEET->param(money => $pc{money});
$SHEET->param(income => $pc{income});
$SHEET->param(outcome => $pc{outcome});
$SHEET->param(surplus => $pc{surplus});

# 行為タグ（カテゴリ別）
my @tagsBody; my @tagsMind; my @tagsSense; my @tagsIntellect;
foreach my $cat_data (@data::tags_category){
  my ($cat_id, $cat_name, @rows) = @$cat_data;
  foreach my $row (@rows){
    foreach my $tag (@$row){
      if($pc{"tag${tag}"}){
        if($cat_id eq 'body'){ push(@tagsBody, { "TAG" => $tag }); }
        elsif($cat_id eq 'mind'){ push(@tagsMind, { "TAG" => $tag }); }
        elsif($cat_id eq 'sense'){ push(@tagsSense, { "TAG" => $tag }); }
        elsif($cat_id eq 'intellect'){ push(@tagsIntellect, { "TAG" => $tag }); }
      }
    }
  }
}
$SHEET->param(TagsBody => \@tagsBody);
$SHEET->param(TagsMind => \@tagsMind);
$SHEET->param(TagsSense => \@tagsSense);
$SHEET->param(TagsIntellect => \@tagsIntellect);

# 言語（イラ）
my @langIra;
for (my $i = 1; $i <= ($pc{langIraNum}||0); $i++){
  push(@langIra, { "LANG" => $pc{"langIra${i}"} }) if $pc{"langIra${i}"};
}
$SHEET->param(LangIra => \@langIra);

# 言語（地球）
my @langEarth;
for (my $i = 1; $i <= ($pc{langEarthNum}||0); $i++){
  push(@langEarth, { "LANG" => $pc{"langEarth${i}"} }) if $pc{"langEarth${i}"};
}
$SHEET->param(LangEarth => \@langEarth);

# チート
my @cheats;
foreach my $num (1 .. ($pc{cheatNum}||0)){
  next if !$pc{"cheat${num}Name"};
  push(@cheats, { "NAME" => $pc{"cheat${num}Name"}, "KARMA" => $pc{"cheat${num}Karma"}, "USE" => $pc{"cheat${num}Use"}, "POWER" => $pc{"cheat${num}Power"}, "RANGE" => $pc{"cheat${num}Range"}, "TARGET" => $pc{"cheat${num}Target"}, "EFFECT" => $pc{"cheat${num}Effect"} });
}
$SHEET->param(Cheats => \@cheats);

# キャリアパス
my @carriers;
foreach my $num (1 .. ($pc{carrierNum}||0)){
  next if !$pc{"carrier${num}Name"} && !$pc{"carrier${num}Skill"};
  push(@carriers, { "ERA" => $pc{"carrier${num}Era"}, "NAME" => $pc{"carrier${num}Name"}, "TYPE" => $pc{"carrier${num}Type"}, "SKILL" => $pc{"carrier${num}Skill"}, "SKILL_TYPE" => $pc{"carrier${num}SkillType"}, "KARMA" => $pc{"carrier${num}Karma"}, "USE" => $pc{"carrier${num}Use"}, "AP" => $pc{"carrier${num}Ap"}, "RANGE" => $pc{"carrier${num}Range"}, "TARGET" => $pc{"carrier${num}Target"}, "CHECK" => $pc{"carrier${num}Check"}, "REF" => $pc{"carrier${num}Ref"} });
}
$SHEET->param(Carriers => \@carriers);

# 装備
my @equip;
foreach my $num (1 .. ($pc{equipNum}||0)){
  next if !$pc{"equip${num}Name"};
  push(@equip, { "NAME" => $pc{"equip${num}Name"}, "PART" => $pc{"equip${num}Part"}, "USE" => $pc{"equip${num}Use"}, "AP" => $pc{"equip${num}Ap"}, "RANGE" => $pc{"equip${num}Range"}, "TARGET" => $pc{"equip${num}Target"}, "CHECK" => $pc{"equip${num}Check"}, "POWER" => $pc{"equip${num}Power"}, "FVAL" => $pc{"equip${num}FVal"}, "CVAL" => $pc{"equip${num}CVal"}, "DEFENSE" => $pc{"equip${num}Defense"}, "WEIGHT" => $pc{"equip${num}Weight"}, "PRICE" => $pc{"equip${num}Price"}, "KARMA" => $pc{"equip${num}Karma"}, "REF" => $pc{"equip${num}Ref"}, "EQUIPPED" => $pc{"equip${num}Equipped"} ? "checked" : "" });
}
$SHEET->param(Equipment => \@equip);

# 道具
my @tools;
foreach my $num (1 .. ($pc{toolNum}||0)){
  next if !$pc{"tool${num}Name"};
  push(@tools, { "NAME" => $pc{"tool${num}Name"}, "COUNT" => $pc{"tool${num}Count"}, "WEIGHT" => $pc{"tool${num}Weight"}, "PRICE" => $pc{"tool${num}Price"}, "REF" => $pc{"tool${num}Ref"} });
}
$SHEET->param(Tools => \@tools);

# フォロワー
my @followers;
foreach my $num (1 .. ($pc{followerNum}||0)){
  next if !$pc{"follower${num}Name"};
  push(@followers, { "NAME" => $pc{"follower${num}Name"}, "COUNT" => $pc{"follower${num}Count"}, "TROOP" => $pc{"follower${num}Troop"}, "USE" => $pc{"follower${num}Use"}, "AP" => $pc{"follower${num}Ap"}, "RANGE" => $pc{"follower${num}Range"}, "TARGET" => $pc{"follower${num}Target"}, "CHECK" => $pc{"follower${num}Check"}, "POWER" => $pc{"follower${num}Power"}, "FVAL" => $pc{"follower${num}FVal"}, "CVAL" => $pc{"follower${num}CVal"}, "PURCHASE" => $pc{"follower${num}Purchase"}, "EXPENSE" => $pc{"follower${num}Expense"}, "REF" => $pc{"follower${num}Ref"} });
}
$SHEET->param(Followers => \@followers);
$SHEET->param(followerSkillName => $pc{followerSkillName});
$SHEET->param(followerSkillEffect => $pc{followerSkillEffect});

# 履歴
my @history;
foreach my $num (1 .. ($pc{historyNum}||0)){
  next if !$pc{"history${num}Date"} && !$pc{"history${num}Title"};
  push(@history, { "DATE" => $pc{"history${num}Date"}, "TITLE" => $pc{"history${num}Title"}, "KARMA" => $pc{"history${num}Karma"}, "MONEY" => $pc{"history${num}Money"}, "GM" => $pc{"history${num}Gm"}, "NOTE" => $pc{"history${num}Note"} });
}
$SHEET->param(History => \@history);

# 収支履歴
my @cashbook; my $balance = 0;
foreach my $num (1 .. ($pc{cashbookNum}||0)){
  next if !$pc{"cashbook${num}Date"} && !$pc{"cashbook${num}Item"};
  my $income = $pc{"cashbook${num}Income"} || 0;
  my $expense = $pc{"cashbook${num}Expense"} || 0;
  $balance = $balance + $income - $expense;
  push(@cashbook, { "DATE" => $pc{"cashbook${num}Date"}, "ITEM" => $pc{"cashbook${num}Item"}, "INCOME" => $income, "EXPENSE" => $expense, "BALANCE" => $balance, "NOTE" => $pc{"cashbook${num}Note"} });
}
$SHEET->param(Cashbook => \@cashbook);

$SHEET->param(freeNote => $pc{freeNote});
$SHEET->param(rawName => $pc{characterName} || ($pc{aka} ? qq{"$pc{aka}"} : ''));

print "Content-Type: text/html\n\n";
print $SHEET->output;

1;
