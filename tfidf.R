# install.packages("RMeCab", repos = "http://rmecab.jp/R")

library(RMeCab)

source("constants.R")


tfidf = docMatrix(WIKIPEDIA_CONTENT_DIR, weight="tf*idf")