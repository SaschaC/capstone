# Shiny Autocomplete App

This repository holds the files for my capstone project. The app is hosted here: [https://saschac.shinyapps.io/shinyAutocomplete/](https://saschac.shinyapps.io/shinyAutocomplete/)

1. /presentation: contains the R files for the presentation of the app [http://rpubs.com/SaschaC/shinyAutomcomplete](http://rpubs.com/SaschaC/shinyAutomcomplete)

2. /milestoneReport: contains the R markdown files for a report about the corpus that has been used for the app. The corpus can be downloaded here [link](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip)

3. getTrigrams.R: the R script to read in the corpora, sampling lines and computing the trigram frequency counts(app/trigramFrequencies.csv) for the app

3. /app: the files for the app
  * R Shiny files: server.R and ui.R, and the /www folder, which contains the .css and .js files that are used by the app
  * trigramFrequencies.csv: contains the trigram frequency counts used by the app