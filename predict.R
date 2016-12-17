setwd("~/coursera/Data Science/course work/capstone")

require(text2vec)
require(data.table)
library(dplyr)
library(tidytext)
library(tidyr)
library(tokenizers)

######################################
# Read in data #
n<-1000000
twitter<-file("./corpora/en_US/en_US.twitter.txt")
blogs<-file("./corpora/en_US/en_US.blogs.txt")
news<-file("./corpora/en_US/en_US.news.txt")
twitter_f=readLines(twitter,encoding = "UTF-8", n=n)
blogs_f=readLines(blogs,encoding = "UTF-8", n=n)
news_f=readLines(news,encoding = "UTF-8", n=n)
close(twitter)
close(blogs)
close(news)
# function to create data frames (DFs)
get_sample<-function(data,sampleSize){
  sample(data,floor(sampleSize*length(data)),replace=F)
}
sampleSize=0.1
twitter_sample<-get_sample(twitter_f,sampleSize)%>%paste(collapse=" ")
twitter_sample<-iconv(twitter_sample, from="UTF-8", to="ASCII", sub="")
rm(twitter,twitter_f)
blogs_sample<-get_sample(blogs_f,sampleSize)%>%paste(collapse=" ")
blogs_sample<-iconv(blogs_sample, from="UTF-8", to="ASCII", sub="")
rm(blogs,blogs_f)
news_sample<-get_sample(news_f,sampleSize)%>%paste(collapse=" ")
news_sample<-iconv(news_sample, from="UTF-8", to="ASCII", sub="")
rm(news,news_f)
gc()
corpus<-paste(twitter_sample,blogs_sample,news_sample," ")
rm(twitter_sample,blogs_sample,news_sample)
# Create df
token_df<- function(text,corpus_name,ngrams){
  t=tokenize_ngrams(text, lowercase = TRUE, n = ngrams,
                    stopwords = character(), ngram_delim = " ", simplify = F) 
  name_vector=rep(corpus_name,length(t[[1]]))
  d=data.table(term=t[[1]], corpus=name_vector)
}
prep_fun <-tolower
tok_fun <- word_tokenizer
it_train <- itoken(corpus,
                  preprocessor = prep_fun, 
                  tokenizer = tok_fun, 
                  progressbar = FALSE)
rm(corpus)
unigram_vocab <- create_vocabulary(it_train, sep_ngram=" ")
unigram_vectorizer <- vocab_vectorizer(unigram_vocab)

bigram_vocab <- create_vocabulary(it_train, ngram=c(2L,2L),sep_ngram=" ")
bigram_vectorizer <- vocab_vectorizer(bigram_vocab)
trigram_vocab <- create_vocabulary(it_train, ngram=c(3L,3L),sep_ngram=" ")
trigram_vectorizer <- vocab_vectorizer(trigram_vocab)
fourgram_vocab <- create_vocabulary(it_train, ngram=c(4L,4L),sep_ngram=" ")
fourgram_vectorizer <- vocab_vectorizer(trigram_vocab)

t1 = Sys.time()
dtm_unigram  = create_dtm(it_train, unigram_vectorizer)
rm(unigram_vectorizer,unigram_vocab)
dtm_bigram  = create_dtm(it_train, bigram_vectorizer)
rm(bigram_vectorizer,bigram_vocab)
dtm_trigram  = create_dtm(it_train, trigram_vectorizer)
rm(trigram_vectorizer,trigram_vocab)
dtm_fourgram  = create_dtm(it_train, fourgram_vectorizer)
rm(fourgram_vectorizer,fourgram_vocab)
print(difftime(Sys.time(), t1, units = 'sec'))
unigramFrequencies<-data.table(term=dtm_unigram@Dimnames[2][[1]],N=dtm_unigram@x)
rm(dtm_unigram)
bigramFrequencies<-data.table(term=dtm_bigram@Dimnames[2][[1]],N=dtm_bigram@x)
rm(dtm_bigram)
trigramFrequencies<-data.table(term=dtm_trigram@Dimnames[2][[1]],N=dtm_trigram@x)
rm(dtm_trigram)
fourgramFrequencies<-data.table(term=dtm_fourgram@Dimnames[2][[1]],N=dtm_fourgram@x)
rm(dtm_fourgram)

unigramTokens<-rbind(token_df(twitter_sample,"twitter",1),token_df(blogs_sample,"blogs",1),token_df(news_sample,"news",1))
bigramTokens<-rbind(token_df(twitter_sample,"twitter",2),token_df(blogs_sample,"blogs",2),token_df(news_sample,"news",2))
trigramTokens<-rbind(token_df(twitter_sample,"twitter",3L),token_df(blogs_sample,"blogs",3L),token_df(news_sample,"news",3L))
fourgramTokens<-rbind(token_df(twitter_sample,"twitter",4L),token_df(blogs_sample,"blogs",4L),token_df(news_sample,"news",4L))
rm(twitter_sample,blogs_sample,news_sample)
gc()
# Overall term frequencies
unigramFrequencies<-unigramTokens[,.(.N),by=term]
unigramFrequencies[,ml:=N/sum(N)]
unigramFrequencies<-unigramFrequencies[order(-rank(N))]
i<-2; cumSum<-unigramFrequencies[1,N]
for(i in 2:nrow(unigramFrequencies)){cumSum=c(cumSum,cumSum[i-1]+unigramFrequencies[i,N])}
unigramFrequencies[,cumSum:=cumSum/sum(N)]
unigramFrequenciesPruned<-unigramFrequencies[1:min(which(unigramFrequencies[,cumSum] > 0.99))]
setkey(unigramFrequenciesPruned,term)
rm(unigramToken,unigramFrequencies)
bigramFrequencies<-bigramTokens[,.(.N),by=term]%>%
  separate(term, c("word1", "word2"), sep = " ")
rm(bigramTokens)
bigramFrequencies[,ml:=N/unigramFrequenciesPruned[.(word1)]$N]
setkey(bigramFrequencies,word1,word2)
trigramFrequencies<-trigramTokens[,.(.N),by=term]%>%
  separate(term, c("word1", "word2","word3"), sep = " ")
rm(trigramTokens)
trigramFrequencies[,ml:=N/bigramFrequencies[.(trigramFrequencies[,word1],
                                              trigramFrequencies[,word2])]$N]
setkey(trigramFrequencies,word1,word2,word3)
fourgramFrequencies<-fourgramTokens[,.(.N),by=term]%>%
  separate(term, c("word1", "word2","word3","word4"), sep = " ")
rm(fourgramTokens)
fourgramFrequencies[,ml:=N/trigramFrequencies[.(fourgramFrequencies[,word1],fourgramFrequencies[,word2],
                                                fourgramFrequencies[,word3])]$N]
setkey(fourgramFrequencies,word1,word2,word3,word4)
gc()
save.image("~/coursera/Data Science/course work/capstone/.RData")

# prediction algorithm
start.time <- Sys.time()
predict2(c("you","must","be"))

  predict<-function(input){
  matchFourgram<-fourgramFrequencies[.(input[1],input[2],input[3],unigramFrequenciesPruned[,term])]%>%arrange(desc(ml))
  matchTrigram<-trigramFrequencies[.(input[2],input[3],matchFourgram[is.na(N),word4])]%>%arrange(desc(ml))
  matchBigram<-bigramFrequencies[.(input[3],matchTrigram[is.na(N),word3])]%>%arrange(desc(ml))
  matchUnigram<-unigramFrequenciesPruned[.(matchBigram[is.na(N),word2])]%>%arrange(desc(ml))
  data.frame(matchFourgram[1,],matchTrigram[1,],matchBigram[1,],matchUnigram[1,])
}

predict2<-function(input){
  words = c("asleep","insane","insensitive","callous")
  matchFourgram<-fourgramFrequencies[.(input[1],input[2],input[3],words)]%>%arrange(desc(ml))
  matchTrigram<-trigramFrequencies[.(input[2],input[3],matchFourgram[is.na(N),word4])]%>%arrange(desc(ml))
  matchBigram<-bigramFrequencies[.(input[3],matchTrigram[is.na(N),word3])]%>%arrange(desc(ml))
  matchUnigram<-unigramFrequenciesPruned[.(matchBigram[is.na(N),word2])]%>%arrange(desc(ml))
  data.frame(matchFourgram[1,],matchTrigram[1,],matchBigram[1,],matchUnigram[1,])
}

end.time <- Sys.time()
time.taken <- end.time - start.time
message("Run time was ",time.taken," seconds.")


