fluidPage(
  #shinythemes::themeSelector(),
  tags$head(
    tags$link(rel = "stylesheet", href = "//fonts.googleapis.com/css?family=Raleway|Cormorant"),
    tags$script(src="script_c.js"),
    tags$link(rel = "stylesheet", href="style.css")
    
    
  ),
  tags$h1("Shiny Autocomplete"),
  tags$div(class="box",
           tags$div(class="content",
                    textAreaInput("text", width="100%", label="", value = "A piece of "),
                    tags$div(id="button-container",
                             uiOutput("predictionButtons")
                    )
           )
  ),
  tags$div(id="link-container",
           tags$a(href="http://rpubs.com/SaschaC/shinyAutocomplete",target="_blank", "about the app"),
           tags$a(href="https://github.com/SaschaC/capstone",target="_blank", "source code on Github", style="float:right;")
           )
)
