# Shiny Autocomplete App

This repository holds the files for my capstone project. The app is hosted here: [https://saschac.shinyapps.io/shinyAutocomplete/](https://saschac.shinyapps.io/shinyAutocomplete/)

1. /presentation: contains the R files for the presentation of the app [http://rpubs.com/SaschaC/shinyAutocomplete](http://rpubs.com/SaschaC/shinyAutocomplete)

2. /milestoneReport: contains the R markdown files for an exploratory report about the corpus used for the app. The report can be found here: [https://rpubs.com/SaschaC/CourseraCapstoneProject](https://rpubs.com/SaschaC/CourseraCapstoneProject). 
The corpus can be downloaded [here](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip)

3. getTrigrams.R: the R script for reading in the corpora, sampling lines and computing the trigram frequency counts (app/trigramFrequencies.csv) for the app

3. /app: the files for the app
  * R Shiny files: server.R and ui.R, and the /www folder, which contains the .css and .js files that are used by the app
  * trigramFrequencies.csv: contains the trigram frequency counts used by the app