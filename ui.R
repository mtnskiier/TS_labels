#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Telemetery labeling UI
#
# INPUT: RodMill Data
#
# OUTPUT: Same data with additional variable with classification 
#

library(shiny)
library(dygraphs)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Telemetry Labeler"),
  
#  sidebarLayout(
      sidebarPanel(
      
      checkboxGroupInput("colchoice", "Displayed metrics", c("p1051","p1052","p1053",
                                                             "p1054" ,"p1294","p1295",
                                                             "p1296","p1297","p1298",
                                                             "p1299","p1300","p1301",
                                                             "p1302","p1303","p1335",
                                                             "p1457","p1951","p1952",
                                                             "p1953","p1954","p1955",
                                                             "p1956"), inline = TRUE),
      
      
      selectInput("label", "Select the label for the highlighted time period:", 
                  choices = c("unknown" = "0", "normal" = "1", "planned_downtime" = "2", "unplanned_downtime" = "3")),

      actionButton("goLabel", "Label Viewable Data"),
      hr(),
      div(strong("From: "), textOutput("from", inline = TRUE)),
      div(strong("To: "), textOutput("to", inline = TRUE)),
      br(),
      helpText("Click and drag to zoom in (double click to zoom back out). Shift-click-drag to pan.")),
#    ),
  
    # Show a plot of the time series data and the current classification 
  
    mainPanel(
      dygraphOutput("dygraph"),
      dygraphOutput("mapped")
  )
))
