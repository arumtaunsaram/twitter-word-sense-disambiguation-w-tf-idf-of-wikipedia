# WikipediRパッケージをまだインストールしていない場合は、下1行の先頭の#を取り除き、
# WikipediRパッケージをインストールしてください
#install.packages("WikipediR")

# xml2パッケージをまだインストールしていない場合は、下1行の先頭の#を取り除き、
# xml2パッケージをインストールしてください
#install.packages("xml2")

library(WikipediR)
library(xml2)

source("constants.R")

kWikipediaArticleNamespace = 0

downloadWikipediaContent <- function(page_name, random=FALSE) {

        if (random)
        {
                wp_html <- random_page("ja", "wikipedia", 
                                # 記事のみを対象とする(会話ノートやテンプレート
                                # ページを含めない)
                                namespaces = list(kWikipediaArticleNamespace))
                page_name <- wp_html$parse$title
        } else {
                wp_html <- page_content("ja", "wikipedia", page_name=page_name)
        }
        # page_content関数は独自のpccontentクラスを返すため、
        # その中のparse->text->"*"プロパティを明示しxml2ライブラリに文字列を渡す
        tree <- read_html(wp_html$parse$text$"*", encoding="UTF-8")
        content_text <- xml_find_all(tree, "//body//text()")
        # content_text はxmlnode型のリストなので、テキストに変換する(xml2パッケージが提供するxml_text関数を使用)
        texts <- sapply(content_text,xml_text)
        # 改行のみ含まれる要素を削除する
        texts <- texts[texts != "\n"]
        
        # 保存先パスを生成する
        file_path_and_name = file.path(WIKIPEDIA_CONTENT_DIR,
                                       # 保存先ファイル名
                                       page_name)
        # ファイルに保存する
        write.table(texts, file=file_path_and_name, row.names=FALSE, quote=FALSE)

}

#
# 手続き開始
#

# キャッシュディレクトリから、以前のキャッシュを削除する
lapply(list.files(WIKIPEDIA_CONTENT_DIR), function(x) {file.remove(file.path(WIKIPEDIA_CONTENT_DIR, x))})

# 対象クラスのWikipedia記事をダウンロードする
for(page in kTargetClasses) {
        downloadWikipediaContent(page)
}

# 対象クラスとは他の記事をランダムで取得し、各クラスに
# たまたま重みがつけられた一般語彙の打ち消しを狙う
for(i in 1:50) {
        downloadWikipediaContent(NULL, random=TRUE)
}