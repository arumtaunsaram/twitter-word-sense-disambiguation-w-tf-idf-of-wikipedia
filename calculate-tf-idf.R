#install.packages("WikipediR")
#install.packages("xml2")

library(WikipediR)
library(xml2)

source("constants.R")

downloadWikipediaContent <- function(page_name) {

        wp_html <- page_content("ja", "wikipedia", page_name=page_name)
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

target_pages <- c("小笠原諸島", "小笠原満男", "小笠原流", "小笠原氏", "小笠原慎之介", "小笠原道大", "小笠原茉由", "小笠原登")

for(page in target_pages) {
        downloadWikipediaContent(page)
}