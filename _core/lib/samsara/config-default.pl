################# デフォルト設定 #################
use strict;
use utf8;

package set;

our $game = 'samsara'; # システムID

# config.cgiのほうが優先されます

## ●タイトル
  our $title = 'ゆとシートⅡ for サンサーラバラッド';

## ●管理パスワード
  our $masterkey = '';
  
## ●管理人ユーザーID
  our $masterid = '';

## ●登録関係
  our $registerkey = '';
  our $user_reqd = 0;
  our $id_type = 0;

## ●OAuth2 でのログイン関係
  our $oauth_service = '';
  our $oauth_login_url = '';
  our $oauth_client_id = '';
  our $oauth_secret_id = '';
  our $oauth_redirect_url = '';
  our $oauth_scope = '';
  our @oauth_discord_login_servers = (); 

## ●画像関係
  our $image_maxsize = 1024 * 1024 * 1;

## ●削除関係
  our $del_back = 0;

## ●一覧表示関係
  our $simplelist = 0; 

## ●グループ設定
  our @groups = (
    ["pc",  "01", "ＰＣ", "プレイヤーキャラクター"],
    ["npc", "99", "ＮＰＣ", "ノンプレイヤーキャラクター"],
  );
  our $group_default = 'pc';
  our $list_maxline = 0;
  our $pagemax = 0;

  # グループ自動移動
  our @grades = ();

## ●キャラクターシートの各種初期値
  our $make_karma = 150;
  our $make_money = 1000;
  our $make_fix   = 0;

## ●メイキング
  our $making_max = 0;
  our $average_over = 0;
  our $adventurer_onlyonce = 0;
  our $making_interval = 0;

## ●保存時の送信モード
  our $base64mode = 0;

## ●Cookie
  our $cookie = 'ytsheet2';

## ●各種ファイルへのパス
  our $sendmail = '/usr/sbin/sendmail';
  our $admimail = 'noreply@yutorize.2-d.jp';
  
  our $data_dir = './data/';
  our $passfile = $data_dir . 'charpass.cgi';
  our $listfile = $data_dir . 'charlist.cgi';
  our $makelist = $data_dir . 'makelist.cgi';
  our $char_dir = $data_dir . 'chara/';
  
  our $userfile    = $::core_dir . '/data/users.cgi';
  our $login_users = $::core_dir . '/data/login_users.cgi';
  our $tokenfile   = $::core_dir . '/data/token.cgi';
  
  our $lib_form     = $::core_dir . '/lib/form.pl';
  our $lib_info     = $::core_dir . '/lib/info.pl';
  our $lib_register = $::core_dir . '/lib/register.pl';
  our $lib_reminder = $::core_dir . '/lib/reminder.pl';
  our $lib_delete   = $::core_dir . '/lib/delete.pl';
  our $lib_others   = $::core_dir . '/lib/others.pl';

  # 編集画面
  our $lib_edit = $::core_dir . '/lib/edit.pl';
  our $lib_edit_char = $::core_dir . '/lib/samsara/edit-chara.pl';
  # 保存処理
  our $lib_save   = $::core_dir . '/lib/save.pl';
  our $lib_calc_char = $::core_dir . '/lib/samsara/calc-chara.pl';
  # シート表示
  our $lib_view   = $::core_dir . '/lib/view.pl';
  our $lib_view_char = $::core_dir . '/lib/samsara/view-chara.pl';
  # チャットパレット
  our $lib_palette     = $::core_dir . '/lib/palette.pl';
  our $lib_palette_sub = $::core_dir . '/lib/samsara/palette-sub.pl';
  # キャラ作成
  our $lib_making = $::core_dir . '/lib/samsara/making.pl';
  # 一覧
  our $lib_list_char = $::core_dir . '/lib/samsara/list-chara.pl';
  our $lib_list_make = $::core_dir . '/lib/samsara/list-making.pl';
  # JS
  our $lib_js_consts = $::core_dir . '/lib/samsara/js-consts.pl';
  # JSON出力
  our $lib_json     = $::core_dir . '/lib/json.pl';
  our $lib_json_sub = $::core_dir . '/lib/samsara/json-sub.pl';
  # コンバート
  our $lib_convert = $::core_dir . '/lib/samsara/convert.pl';

  # 各種データ
  our $data_races = $::core_dir . '/lib/samsara/data-races.pl';
  our $data_items = $::core_dir . '/lib/samsara/data-items.pl';
  our $data_class = $::core_dir . '/lib/samsara/data-class.pl';

  # HTMLテンプレート
  our $icon_dir   = $::core_dir . '/skin/samsara/img/'; # アイコン
  our $skin_tmpl  = $::core_dir . '/skin/samsara/index.html';
  our $skin_sheet = $::core_dir . '/skin/samsara/sheet-chara.html';
  
  # その他の設定
  our %lib_type = (); # モンスター等は一旦未定義

1;