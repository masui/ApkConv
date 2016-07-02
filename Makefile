#
# 既存のapkの中身を変更する方法 2016/07/01
#
# * apkはzipなので、普通にunzipしてデータを変えた後で再署名すれば良いらしい
# * Java Keystoreファイルという秘密鍵を作成して署名する
#
# http://blue-red.ddo.jp/~ao/wiki/wiki.cgi?page=Android+%BA%EE%C0%AE%A4%B7%A4%BF%A5%A2%A5%D7%A5%EA%A4%CB%BD%F0%CC%BE%A4%F2%B9%D4%A4%A6
# > ・AndroidアプリケーションをAndroid端末へインストールするためには、apkファイルへの署名が必要。
# > ・署名に必要な非公開鍵の生成と管理を行うのがkeytool。
# > ・keytoolで生成された非公開鍵を使用して、apkファイルへ署名を行うのがjarsigner。
# > ・keytoolで非公開鍵を生成し、jarsignerで署名する。
#
# これ以外に、MANIFEST.MFなどを作りなおす必要がある!
# http://d.hatena.ne.jp/urandroid/20110818/131365653 の make-manifest.pl などを利用
#
# testkey.pem, 
# https://github.com/appium/sign

ORIGAPK=/Users/masui/EpisoPass/Cordova/platforms/android/build/outputs/apk/android-debug.apk
NEWAPK=new.apk
KEYSTORE=debug.keystore

conv: testkey.pem ${ORIGAPK} ${KEYSTORE}
	/bin/rm -r -f tmp
	mkdir tmp
	cd tmp; unzip ${ORIGAPK}
	/bin/rm -f ${NEWAPK}
	perl make-manifest.pl tmp > tmp/META-INF/MANIFEST.MF
	perl make-cert-sf.pl tmp/META-INF/MANIFEST.MF > tmp/META-INF/CERT.SF
	openssl smime -sign -inkey testkey.pem -signer testkey.x509.pem -in tmp/META-INF/CERT.SF -outform DER -noattr > tmp/META-INF/CERT.RSA
	cd tmp; jar cvf ../${NEWAPK} `find .`
	jarsigner -verbose -digestalg SHA1 -keystore ${KEYSTORE} -storepass android -keypass android -tsa http://timestamp.digicert.com ${NEWAPK} androiddebugkey

# qa.jsonを変更して署名してapk作りなおし
# keystoreが同じなら上書きインストールできる
modified: testkey.pem ${ORIGAPK} ${KEYSTORE}
	/bin/rm -r -f tmp
	mkdir tmp
	cd tmp; unzip ${ORIGAPK}
	/bin/cp qa.json.modified tmp/assets/www/qa.json
	/bin/rm -f ${NEWAPK}
	perl make-manifest.pl tmp > tmp/META-INF/MANIFEST.MF
	perl make-cert-sf.pl tmp/META-INF/MANIFEST.MF > tmp/META-INF/CERT.SF
	openssl smime -sign -inkey testkey.pem -signer testkey.x509.pem -in tmp/META-INF/CERT.SF -outform DER -noattr > tmp/META-INF/CERT.RSA
	cd tmp; jar cvf ../${NEWAPK} `find .`
	jarsigner -verbose -digestalg SHA1 -keystore ${KEYSTORE} -storepass android -keypass android -tsa http://timestamp.digicert.com ${NEWAPK} androiddebugkey

${KEYSTORE}:
	keytool -genkey -v -keystore ${KEYSTORE} -alias androiddebugkey -storepass android -keypass android -keyalg RSA -validity 10000 -dname "CN=Android Debug,O=Android,C=US"

# keystoreファイルのチェック
check:
	keytool -v -list -storepass android -keystore ${KEYSTORE}

install:
	adb install -r ${NEWAPK}

testkey.pem: testkey.pk8
	openssl pkcs8 -in testkey.pk8 -inform DER -nocrypt -out testkey.pem
