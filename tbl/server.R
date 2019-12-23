library(shiny)

shinyServer(function(input, output, session) {
    
    output$mytable = DT::renderDataTable({
        ships
        # TODO: [Using DT in Shiny](https://rstudio.github.io/DT/shiny.html) retrieve pages as needed
    })

})
