# 使い方

## 準備

1. RStudioで `twitter-word-sense-disambiguation-w-tf-idf-of-wikipedia.Rproj` を開く
2. RStudioで上記.Rprojファイルが含まれるディレクトリにて"Set As Working Directory"を実行する
3. ブラウザでtwitterにアクセスし、開発者向けページ Tools > Manage your apps にて新規 twitter app を作成し consumer key, consumer secret を、ボタンを押してaccess token, access secretを生成する。
4. 手順3で取得した値を `constants-private.R` に書き写す
5. `constants.R` を開きtwitterで検索したいキーワード(`kTargetWord`)と、詳細分類したいクラス(`kTargetClasses`)を指定する

## 実行

1. `download_base_documents.R` を開き実行(sourceする)
2. `main.R` を開き実行(sourceする)
3. データフレーム `twa` にどのクラスにどれだけ近かったかを示す値が格納されます。クラス名の末尾に".p"をつけた列にアクセスすると、対象のクラス群全体を1としたときに、そのクラスに所属する可能性がどれだけかを知ることが出来ます。

  例: 
  ```
  twa[twa$小笠原諸島.p > 0.27,]
  ```

## 既知の問題

- Mac上で `kTargetClass` に濁点を含む名詞を設定した場合に、その名詞がクラス分類の対象となりません
