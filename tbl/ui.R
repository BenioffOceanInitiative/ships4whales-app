shinyUI(fluidPage(
    
    titlePanel("Old Faithful Geyser Data"),

    sidebarLayout(
        sidebarPanel(),

        mainPanel(
            dataTableOutput("mytable")
        )
    )
))
