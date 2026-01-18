#!/usr/bin/perlml
################################################
##     ゆとシートⅡ for サンサーラバラッド     ##
##          by ゆとらいず工房                 ##
##    https://yutorize.2-d.jp               ##
################################################
# システムID: samsara
use strict;
#use warnings;
use utf8;
use open ":utf8";
binmode STDOUT, ':utf8';
use CGI::Carp qw(fatalsToBrowser);
use CGI qw/:all/;
use Fcntl;

### 設定読込 #########################################################################################
our $core_dir = '../_core';
use lib '../_core/module';

# サンサーラバラッド用設定ファイルを読み込み
require $core_dir.'/lib/samsara/config-default.pl';
require './config.cgi';
require $core_dir.'/lib/subroutine.pl';
require $core_dir.'/lib/samsara/subroutine-samsara.pl';

require $core_dir.'/lib/junction.pl';

exit;