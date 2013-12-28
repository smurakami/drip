# Dripper

Haml, Sass(Scss), CoffeeScriptを監視して自動でコンパイルするシェルスクリプトです。

# 動機

主な動機は、Guardのhamlがうまく動かなかったことです。卒業研究にhamlを使う必要があったために、とりあえずの代替案として本ツールを作成しました。

#How To Use

haml, sass, coffeeコマンドが使用可能であることが前提です。
カレントディレクトリにdrip.shを置く場合、

```sh
chmod u+x drip.sh
```
を実行してください。その上で

```sh
./drip.sh init
```
を実行することで、必要なディレクトリ構成を作成する事が出来ます。
このディレクトリ構成は

```drip.sh
HAML_DIR=haml
SASS_DIR=sass
COFFEE_DIR=coffee
JS_DIR=js
CSS_DIR=css
```
の部分を編集することで制御できます。

ディレクトリ構成を作成したら、

```sh
./drip
```
でファイルの監視を開始します。
中止はctrl-cで。

## 注意

現在hamlディレクトリとcoffeeディレクトリが空だとエラーが出るバグがあります。

```sh
touch haml/index.haml
```
等を実行するとうまく動きます。