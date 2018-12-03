#
# Function:  To train classification models, the training data must be labeled. This shiny app 
# reads in a cleaned telemetry stream, normalizes the data and displays the data for classification 
# by human users.
#
# Input: RodMill_joined31_32.csv is a cleaned set of data extracted from the Cassandra DB. Still 
#     utilizes the column names of the original data.
#
# Output: <filename> is output as a xts object with the normalized data that was used in the 
#     classification AND a dlabel factor variable <NOT IMPLEMENTED IN THIS VERSION>
#

library(shiny)
library(BBmisc)
library(dygraphs)
library(xts)

shinyServer(function(input, output) {
# Initialization code - gets run on start ONLY  
   df <- read.csv("./RodMill_joined31_32.csv")
   df$logdate <- as.POSIXct(strptime(df$logdate, "%Y-%m-%d %H:%M:%S"))
   normdf <- normalize(df[,2:ncol(df)], method = "standardize")
   dlabel <- factor(rep(1, nrow(df)), ordered = TRUE,
                    labels = "unknown", "normal", "planned_downtime", "unplanned_downtime")
   label_colors <- c("white", "green", "yellow", "red")
   mapping <- xts(x=as.integer(dlabel), order.by = df$logdate)
   
  
  output$dygraph <- renderDygraph({
    # select the data columns to include for labling 
    # convert to timeseries
    inputcols <- input$colchoice
    z <- xts(x=normdf[,inputcols], order.by = df$logdate)
    dygraph(z, main = "Time series labeling tool", group = "telemetry") %>% 
      dyRangeSelector(height = 20, strokeColor = "orange", retainDateWindow = TRUE) 
    
    })
  
  output$mapped <- renderDygraph({
      dygraph(mapping, main = "Current labels", group = "telemetry") %>%
        dyOptions(fillGraph = TRUE)
      })
  
  output$from <- renderText({
    sub("T", " ", substr(input$dygraph_date_window[[1]], 
                         1, nchar(input$dygraph_date_window[[1]]) - 5))
  })
  
  output$to <- renderText({
    sub("T", " ", substr(input$dygraph_date_window[[2]], 
                         1, nchar(input$dygraph_date_window[[2]]) - 5))
  })
  
  observeEvent(input$goLabel, {
    # User selected to assign a label to the currently visable date_window
    fr_win <- sub("T", " ", substr(input$dygraph_date_window[[1]], 
                                   1, nchar(input$dygraph_date_window[[1]]) - 5))
    to_win <- sub("T", " ", substr(input$dygraph_date_window[[2]], 
                                   1, nchar(input$dygraph_date_window[[2]]) - 5))
    lwindow <- paste0(fr_win, "/", to_win)
    cat("before", summary(mapping[,1]))
    mapping[lwindow] <<- factor(input$label, levels=c(1,2,3,4), 
                               labels = c("unknown", "normal", "planned_downtime", "unplanned_downtime"))
    cat("mapping str", summary(mapping[,1]))
    
    output$mapped <- renderDygraph({
      dygraph((mapping), main = "Current labels", group = "telemetry") %>% 
        dyAxis("y", label = "Operational State", 
          valueRange = c("unknown", "normal", "planned_downtime", "unplanned_downtime")) %>%
        dyOptions(fillGraph = TRUE)
    })
    
  })
  
 
})
