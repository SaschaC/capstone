setwd("~/Arbeit/courses/coursera/Data Science/Course Work/capstone")

require(text2vec)
require(data.table)
library(dplyr)
library(tidytext)
library(tidyr)
library(tokenizers)
library(parallel);
library(doParallel);

######################################
# Read in data #
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)
start.time <- Sys.time()
n<-300000
twitter<-file("../corpora/en_US/en_US.twitter.txt")
blogs<-file("../corpora/en_US/en_US.blogs.txt")
news<-file("../corpora/en_US/en_US.news.txt")
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
sampleSize=0.3
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
prep_fun <-tolower
tok_fun <- word_tokenizer
it_train <- itoken(corpus,
                   preprocessor = prep_fun, 
                   tokenizer = tok_fun, 
                   progressbar = FALSE)
rm(corpus)

trigram_vocab <- create_vocabulary(it_train, ngram=c(3L,3L),sep_ngram=" ")
trigram_vectorizer <- vocab_vectorizer(trigram_vocab)
t1 = Sys.time()
dtm_trigram  = create_dtm(it_train, trigram_vectorizer)
trigramFrequencies<-data.table(term=dtm_trigram@Dimnames[2][[1]],N=dtm_trigram@x)%>%
  separate(term, c("word1", "word2","word3"), sep = " ")
str(trigramFrequencies)

unigramFrequencies<-trigramFrequencies[,.(N=sum(N)),by=.(word3)]
unigramFrequencies<-unigramFrequencies[-(grep("\\d|\\W|_",unigramFrequencies$word3)),]
unigramFrequencies<-unigramFrequencies[order(-rank(N))]

i<-2; cumSum<-unigramFrequencies[1,N]
for(i in 2:nrow(unigramFrequencies)){cumSum=c(cumSum,cumSum[i-1]+unigramFrequencies[i,N])}
unigramFrequencies[,cumSum:=cumSum/sum(N)]
cutoff<-min(which(unigramFrequencies[,cumSum] > 0.95))

unigramFrequencies<-unigramFrequencies[1:5000]

trigramFrequencies<-trigramFrequencies[word1%in%unigramFrequencies[,word3]&
                                               word2%in%unigramFrequencies[,word3]&
                                               word3%in%unigramFrequencies[,word3],]
trigramFrequencies
write.table(trigramFrequencies,file="trigramFrequencies.csv",sep=",",
            row.names=FALSE,quote=FALSE)

stopCluster(cluster)

save.image("./.RData")
