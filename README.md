# Androidのapkの中身を変えるサンプル

* [Cordova](https://cordova.apache.org/)でAndroidの[EpisoPass](http://EpisoPass.com/)アプリを作れるようにしたのだが、異なるデータに対していちいちビルドするのは大変だからapkの中のデータ(```qa.json```)だけ変えようと思った
* apkはzipファイルだから、unzipしてqa.jsonだけ入れ替えて再zipすれば良いかと思ったら**大甘だった**
* apk内のあらゆるファイルに署名して、それをzipして、できたzipファイルをさらに署名しなければならないようである
* 原理はサッパリわからないのだが、以下のサイトを参考にしてなんとか変換できた。

### 参考サイト

 * [Android 作成したアプリに署名を行う](http://blue-red.ddo.jp/~ao/wiki/wiki.cgi?page=Android+%BA%EE%C0%AE%A4%B7%A4%BF%A5%A2%A5%D7%A5%EA%A4%CB%BD%F0%CC%BE%A4%F2%B9%D4%A4%A6)
   * keytool, jarsigner の使い方
 * [APK ファイルの署名の仕様](http://d.hatena.ne.jp/urandroid/20110818/1313656536)
   * testkey.pk8 とかいうファイルを使ってる
   * これが何なのかは知らない
 * [https://github.com/appium/sign](https://github.com/appium/sign)
   * testkey.pk8とかが置いてあったリポジトリ
   * どういう経緯のものなのかは知らない
 
これらのやり方をまとめてMakefileに書いてある。