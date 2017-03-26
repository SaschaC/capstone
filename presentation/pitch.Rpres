<head>
<style>

.reveal{ 
font-size: 24px;
}

.inp{
color: red;
background-color: rgb(230, 233, 239);
}
.reveal section img {
float: right;
}

.section .reveal .state-background {
    background-image: radial-gradient(ellipse farthest-corner at center, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.4) 70%,#FFFFFF 100%);  
     background-color: hsl(0, 62%, 95%);
    }

.section .reveal p {
margin:74px 0px !important;
color:rgb(53, 54, 56)!important;

}

h1{
margin:74px 0px !important;
font-size:74px !important;
color:black !important;
font-family:"Times New Roman", Times, serif !important;
}
</style>
</head>


Shiny Autocomplete 
========================================================
author: Sascha Coridun
date: March 2017
transition: rotate

A word prediction and completion app <a href="https://saschac.shinyapps.io/shinyAutocomplete/" target="_blank">(link)</a>, programmed in R Shiny, source code on <a href="https://github.com/SaschaC/capstone" target="_blank">Github</a>

Created as the <a href="https://www.coursera.org/learn/data-science-project" target="_blank">Capstone Project for the Datascience Coursetrack on Coursera</a>

App description
========================================================
![app screenshot](screenshot.png)

__Features:__
- Word prediction AND completion
- Three prediction buttons update as you type!
- Fast performance through caching and binary search

__How it was made:__
- I sampled a total of 300,000 lines from blogs, Twitter, and news articles and normalized the text removing punctuation and digits.
- I computed frequency counts of ~3.02 Million 3-grams (only those 3-grams with the 5,000 most frequent words in the sample; token coverage: ~87%). 
- Based on the 3-gram frequency counts, the app predicts predicts words using Stupid Backoff <span style="font-size:16px">([Jurafsky D., Martin J.H., 2014. Ch4, pp. 19](https://lagunita.stanford.edu/c4x/Engineering/CS-224N/asset/slp4.pdf))</span>. It computes bigram and unigram frequencies from the 3-gram frequencies on-the-fly.

Functionality
========================================================

__How the app works:__

1. User inputs words
2. App decides whether to _predict_ new word or _complete_ current word:
    * If a space ends the input, _predict_: App calculates the probabilities of 5,000 words and _caches_ results
    * If no space ends the input, _complete_:  App finds words in the cached results that match the current word at their beginnings
4. Prediction buttons show the three most probable words
<br><br>
__How to use the app:__

It takes <span style="color:red">~5 seconds</span> until the app has been fully launched. Now, simply type away and click the prediction buttons for autocompletion. Just like in a smartphone (well, almost)!

The algorithm: Description
========================================================

Stupid Backoff <span style="font-size:16px">([Jurafsky D., Martin J.H., 2014. Ch4, pp. 19](https://lagunita.stanford.edu/c4x/Engineering/CS-224N/asset/slp4.pdf))</span> assigns a probability to the occurrence of a word given the preceding words.  The probability _S_ of a word _w_ at position _i_ is calculated as:

$$S(w_i|w^{i-1}_{i-k+1}) = \begin{cases} \frac {count(w_i)} {count(w_{i-k+1}^{i-1})} & \text{if count}(w^i_{i-k+1})  > 0 \\ \lambda S(w_i|w^{i-1}_{i-k+2})  & \text{otherwise} \end{cases}$$

The app uses 3-grams, so k=3. Importantly, when a higher order n-gram has a zero count, the algorithm backs off to the next lower order n-gram weighed by a fixed value $\lambda$ (set to 0.4).

**Example:** the input is <span class="inp">"piece of"</span>. The probability of <span class="inp">"cake"</span> as being the next word is calculated as:

$$S(\text{cake}|\text{piece of}) = \begin{cases} \frac {count(\text{piece of cake})} {count(\text{piece of})} & \text{if count}(\text{piece of cake})  > 0 \\ \lambda S(\text{cake}|\text{of})  & \text{otherwise} \end{cases}$$

If the count of <span class="inp">"of cake"</span> were zero, the algorithm terminates in the unigram probability which is $S\frac{count(\text{cake})}{N}$, where _N_ is the overall sum of unigram counts.  

The algorithm: Step-by-step example
========================================================

User inputs <span class="inp">"piece of "</span>:

- Input is normalized, non-alphanumeric characters are removed and all characters converted to lower case. Sentence beginnings are converted to <span class="inp">"0 0"</span>

- The algorithm searches the  ~3.02 Million 3-gram frequencies. It uses [fast binary search with keys](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-keys-fast-subset.html)  for table  subsetting.

- Backoff procedure:   
  - **3-gram matching:** All 3-grams starting with <span class="inp">"piece of"</span> are selected. Trigram maximum likelihood estimates (MLE) and overall score are computed for every word that occurs as third word of the selected trigrams.

  - **Bigram matching:** Bigram frequency counts are computed by summarizing over all trigrams with <span class="inp">"of"</span> as second word. Bigram MLE and overall scores are computed for every word that occurs as the second word in the selected bigrams and that has not received a score in the previous step.  
  
  - **Unigram matching:** Unigram frequency counts are computed by summarizing over all trigrams that contain those words as third words that have not received a score in the previous two steps. For these words, unigram MLE and overall scores are computed.

- Results are cached and the 3 words with the highest scores are selected as output.
