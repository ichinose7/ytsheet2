# ytsheet2 ローカル開発環境

## セットアップ

1. Docker Desktopをインストール
2. このフォルダで以下を実行:
   ```
   docker-compose up -d
   ```
3. http://localhost:8080/ でアクセス

## 注意事項

### shebang（1行目）について

各システムの `index.cgi` の1行目が `#!/usr/bin/perlml` になっています。
これは **mixhost専用** のPerlパスです。

**mixhost以外のサーバーにデプロイする場合**、各 `index.cgi` の1行目を以下に変更してください：

```perl
#!/usr/bin/perl
```

対象ファイル:
- `sw2.5/index.cgi`
- `sw2.0/index.cgi`
- `dx3rd/index.cgi`
- `ar2e/index.cgi`
- `gc/index.cgi`
- `kiz/index.cgi`
- `blp/index.cgi`
- `gs/index.cgi`
- `ms/index.cgi`
- `vc/index.cgi`

### config.cgi について

各システムフォルダ内の `config.cgi` は `.gitignore` で除外されています。
`config.cgi.default` をコピーして `config.cgi` を作成し、必要に応じて設定を変更してください。

### アップロード時の注意

以下のファイルは**サーバーにアップロードしないでください**（ローカル開発用）:
- `Dockerfile`
- `docker-compose.yml`
- `.gitignore`
- `.git/`
