package data;

use strict;
#use warnings;
use utf8;

# 種族定義
our @races = (
  '地球',
  '人間',
  # 他の種族は不明
);

our %races = (
  '地球' => {
    name => '地球',
    kana => 'ちきゅう',
    # 初期能力値などは不明なので空
  },
  '人間' => {
    name => '人間',
    kana => 'にんげん',
  },
);

1;