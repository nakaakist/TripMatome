#herokuでのdb初期化と記事取得の開始
```bash
heroku scale cron=0
```
で現在動いている記事取得スクリプトを停止。
```bash
heroku pg:reset DATABASE
```
でdb削除。
```bash
heroku run rake db:migrate
```
でdb作成。
```bash
heroku scale cron=1
```
で記事取得開始。毎時間ごと、**時00分に記事を取得する。  
一番最初の記事取得では原理的に日付までしか取得できない。