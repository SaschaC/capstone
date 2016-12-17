setwd("~/coursera/Data Science/course work/capstone")

require(quanteda)
require(text2vec)
require(data.table)
require(ggplot2)
library(dplyr)
library(tidytext)
library(tidyr)
library(tokenizers)

######################################
# Read in data #
n<-100000
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
sampleSize=0.01
twitter_sample<-get_sample(twitter_f,sampleSize)%>%paste(collapse=" ")
twitter_sample<-iconv(twitter_sample, from="UTF-8", to="ASCII", sub="")
blogs_sample<-get_sample(blogs_f,sampleSize)%>%paste(collapse=" ")
blogs_sample<-iconv(blogs_sample, from="UTF-8", to="ASCII", sub="")
news_sample<-get_sample(news_f,sampleSize)%>%paste(collapse=" ")
news_sample<-iconv(news_sample, from="UTF-8", to="ASCII", sub="")
#rm(blogs,news,twitter)
# Create df
token_df1<- function(text,corpus_name,ngrams){
  t=tokenize(toLower(text),what = "fastestword", removeNumbers = T, removePunct = T,ngrams=ngrams, concatenator=" ")
  name_vector=rep(corpus_name,length(t[[1]]))
  d=data.table(term=t[[1]], corpus=name_vector)
}
token_df<- function(text,corpus_name,ngrams){
  t=tokenize_ngrams(text, lowercase = TRUE, n = ngrams,
                    stopwords = character(), ngram_delim = " ", simplify = F) 
  name_vector=rep(corpus_name,length(t[[1]]))
  d=data.table(term=t[[1]], corpus=name_vector)
}
start.time <- Sys.time()
unigramTokens<-rbind(token_df(twitter_sample,"twitter",1),token_df(blogs_sample,"blogs",1),token_df(news_sample,"news",1))
bigramTokens<-rbind(token_df(twitter_sample,"twitter",2),token_df(blogs_sample,"blogs",2),token_df(news_sample,"news",2))
trigramTokens<-rbind(token_df(twitter_sample,"twitter",3L),token_df(blogs_sample,"blogs",3L),token_df(news_sample,"news",3L))
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
#unigramTokens[grep("â",unigramTokens[,term]),]
# Overall term frequencies
unigramFrequencies<-unigramTokens[,.(.N),by=term]
unigramFrequencies[,ml:=N/sum(N)]
setkey(unigramFrequencies,term)
bigramFrequencies<-bigramTokens[,.(.N),by=term]%>%
  separate(term, c("word1", "word2"), sep = " ")
bigramFrequencies[,ml:=N/unigramFrequencies[.(word1)]$N]
setkey(bigramFrequencies,word1,word2)
trigramFrequencies<-trigramTokens[,.(.N),by=term]%>%
  separate(term, c("word1", "word2","word3"), sep = " ")
trigramFrequencies[,ml:=N/bigramFrequencies[.(trigramFrequencies[,word1],trigramFrequencies[,word2])]$N]
setkey(trigramFrequencies,word1,word2,word3)
# prediction algorithm
start.time <- Sys.time()
input<-c("coffee","and")
matchTrigram<-trigramFrequencies[.(input[1],input[2],unigramFrequencies[,term])]%>%arrange(desc(ml))
matchBigram<-bigramFrequencies[.(input[2],matchTrigram[is.na(N),word3])]%>%arrange(desc(ml))
matchUnigram<-unigramFrequencies[.(matchBigram[is.na(N),word2])]%>%arrange(desc(ml))
matchTrigram[1:5,];matchBigram[1:5,];matchUnigram[1:5,]
end.time <- Sys.time()
time.taken <- end.time - start.time
message("Run time was ",time.taken," seconds.")
# Text coverage 
unigramFrequencies<-unigramFrequencies[order(-rank(N))]
i<-2; cumSum<-unigramFrequencies[1,N]
for(i in 2:nrow(unigramFrequencies)){cumSum=c(cumSum,cumSum[i-1]+unigramFrequencies[i,N])}
unigramFrequencies[,cumSum:=cumSum/sum(N)]
# Plot cumulative sum of frequency ordered unigrams
plotFrequencies<-ggplot(unigramFrequencies[1:100,], aes(as.integer(rownames(unigramFrequencies[1:100])), cumSum))+
  geom_point()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_x_continuous(breaks=seq(0,nrow(unigramFrequencies),10))+xlab("Frequency rank")
plotFrequencies
min(which(unigramFrequencies[,cumSum] > 0.9))
# Plot term frequencies
plotFrequencies<-ggplot(unigramFrequencies, aes(as.integer(rownames(unigramFrequencies)), log(N+1)))+
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_x_continuous(breaks=seq(0,nrow(unigramFrequencies),1000))+xlab("Frequency rank")+
  ylab("log-Frequency")+ggtitle("Word log-Frequency vs. frequency rank")
plotFrequencies
# Document-term frequencies
dtFrequencies<-unigramTokens[,.(.N),by=.(term,corpus)]
dtFrequencies[,total:=(sum(N)),by=corpus]
dtFrequencies
plotDtFrequencies<-ggplot(dtFrequencies, aes(N/total,fill=corpus)) +
  geom_histogram(show.legend = FALSE)+
  xlim(NA, 0.0025) +
  facet_wrap(~corpus, ncol = 1, scales = "free_y")
plotDtFrequencies
# tf_idf 
dtFrequencies<- dtFrequencies %>%
  bind_tf_idf(term, corpus, N)%>%
  group_by(corpus) %>% 
  arrange(desc(tf_idf))%>% 
  top_n(10) %>% ungroup %>%
  mutate(term = factor(term, levels =unique(term)))
plotTfIdfFrequencies<-ggplot(dtFrequencies, aes(term, tf_idf, fill = corpus)) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  labs(title = "Highest tf-idf words in Corpora",
       x = NULL, y = "tf-idf") +
  facet_wrap(~corpus, ncol = 3,scales="free")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
plotTfIdfFrequencies
dtFrequencies
