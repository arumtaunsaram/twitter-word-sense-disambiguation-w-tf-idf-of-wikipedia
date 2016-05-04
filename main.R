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

tweets = searchTwitter(target_word)
# スコアの格納先
tweets.w.affinities <- NULL

# tf-idf データを読み込む
tf_idf = docMatrix(WIKIPEDIA_CONTENT_DIR, weight="tf*idf")

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
        
        # applyを使って作成した表を整形
        
        # クラス分類が行となったため、列に戻す
        scores <- t(scores.raw)
        # 便宜のため、列名(このままだと数値)を語彙に書き換える
        rownames(scores) <- terms.in.tf_idf$Term
        
        print(tweet$text)
        # tf-idf表に存在した全てのツイート内の出現語彙について
        # どのクラスに所属するかのスコアを累計する。
        affirnities <- apply(scores, 2, sum)
        print(apply(scores, 2, sum))
        tweets.w.affinities <- rbind(tweets.w.affinities,
              cbind(t(affirnities), 
                    tweet.id=tweet$id,
                    tweet.created=tweet$created,
                    tweet.user=tweet$screenName,
                    tweet.text=tweet$text,
                    tweet.longitude=tweet$longitude,
                    tweet.latitude=tweet$latitude)
        )
}

