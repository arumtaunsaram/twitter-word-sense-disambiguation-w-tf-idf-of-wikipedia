# twitteRパッケージをまだインストールしていない場合は、下1行の先頭の#を取り除き、
# twitteRパッケージをインストールしてください
# install.packages("twitteR")

# RMeCabパッケージをまだインストールしていない場合は、下1行の先頭の#を取り除き、
# RMeCabパッケージをインストールしてください
# install.packages("RMeCab", repos = "http://rmecab.jp/R")

library(twitteR)
library(RMeCab)

source("constants.R")
source("constants-private.R")

target_word = "小笠原"

setup_twitter_oauth(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_SECRET)

tweets = searchTwitter(target_word, n=500)
# スコアの格納先(tweets with affinities)
twa <- NULL

# tf-idf データを読み込む
tf_idf <- docMatrix(WIKIPEDIA_CONTENT_DIR, weight="tf*idf")
# 区分対象とするクラスの列のみを残す
# (各クラスの語彙列に全体を考慮したtf*idf値が
# 残るので、それが残れば十分)
tf_idf <- tf_idf[,intersect(colnames(tf_idf),kTargetClasses)]
# 対象語の出現情報を消す
# (そうしないと、ある特定のクラスの記事で
# 対象語が繰り返されている場合、すべての対象語で
# その繰り返された対象語の結果が特定のクラスに
# 重み付けされてしまう)
tf_idf[Term=target_word,] <- (tf_idf[Term=target_word,] * 0)

# tweetをファイルに出力する
# cf. http://rmecab.jp/wiki/index.php?RMeCabFunctions#content_1_15
tmpdir <- tempdir()
for (tweet in tweets)
{
        td <- tempfile(tweet$id, tmpdir = tmpdir)
        write(tweet$text, file = td)
        word_freq <- RMeCabFreq(td)
        
        # ツイートに含まれる各語彙について、出現頻度を
        # tf-idf表の値に掛ける
        terms.in.tf_idf <- subset(word_freq, Term %in% row.names(tf_idf))
        scores.raw <- apply(terms.in.tf_idf, 1, function(fr){
                        retval <- tf_idf[fr[["Term"]],] * as.numeric(fr[["Freq"]]);
                        return(retval)
                })
        
        #
        # applyを使い作成した表を整形する
        #
        
        # クラス分類が行となったため、列に戻す
        scores <- t(scores.raw)
        # 便宜のため、列名(このままだと数値)を語彙に書き換える
        rownames(scores) <- terms.in.tf_idf$Term
        
        # tf-idf表に存在した全てのツイート内の出現語彙について
        # どのクラスに所属するかのスコアを累計する。
        affinities <- apply(scores, 2, sum)
        
        # それぞれのクラスについて、ほかと比べてどれだけ強い
        # のか割合を出す
        denominator <- sum(affinities)
        if (denominator > 0)
        {
                rates <- affinities / denominator
                # 検算
                # print("summation of all rates:")
                # print(sum(rates))
        } else {
                rates <- rep(0, length(names(affinities)))
        }
        # 割合の列名はクラスの末尾に.pをつけたものとする。
        names(rates) <- lapply(names(affinities), function(name){return(paste(name, "p", sep="."))})

        row1 <- data.frame(t(affinities),
                        t(rates),
                        tweet.id=tweet$id,
                        tweet.created=tweet$created,
                        tweet.user=tweet$screenName,
                        tweet.text=tweet$text
                        )
        twa <- rbind(twa, row1)
}
