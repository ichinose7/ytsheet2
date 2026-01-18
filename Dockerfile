FROM httpd:2.4

# 必要なパッケージのインストール (Perl, make, gccなど)
RUN apt-get update && \
    apt-get install -y perl cpanminus make gcc locales libperl-dev && \
    rm -rf /var/lib/apt/lists/*

# 日本語ロケールの設定
RUN sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# Perlモジュールのインストール (ytsheetで必要そうなもの)
RUN cpanm CGI JSON

# Apacheの設定変更 (CGIの有効化)
RUN sed -i \
        -e 's/#LoadModule cgid_module/LoadModule cgid_module/' \
        -e 's/#LoadModule cgi_module/LoadModule cgi_module/' \
        /usr/local/apache2/conf/httpd.conf

# ディレクトリ設定 (CGI実行許可、DirectoryIndex設定)
RUN echo '<Directory "/usr/local/apache2/htdocs">' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    Options +ExecCGI' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    AddHandler cgi-script .cgi .pl' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    DirectoryIndex index.cgi index.html' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    AllowOverride All' >> /usr/local/apache2/conf/httpd.conf && \
    echo '</Directory>' >> /usr/local/apache2/conf/httpd.conf
