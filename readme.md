# info

nod のものレポを使用しています

# メモ

## npm でインストールする際のコマンド例

```
npm install <ライブラリ名> -w user_front
```

#

```
openssl s_client -connect token.actions.githubusercontent.com:443 -showcerts \
 </dev/null 2>/dev/null \
 | openssl x509 -noout -fingerprint -sha1 \
 | sed 's/://g' | sed 's/SHA1 Fingerprint=//'
```
