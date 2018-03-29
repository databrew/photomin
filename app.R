library(shiny)
library(shinydashboard)
library(magick)

header <- dashboardHeader(title="Photo management example app")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(
      text="Main",
      tabName="main",
      icon=icon("eye")),
    menuItem(
      text = 'About',
      tabName = 'about',
      icon = icon("cog", lib = "glyphicon"))
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  tabItems(
    tabItem(
      tabName="main",
      fluidPage(
        fluidRow(
          column(6,
                 fileInput('photo_upload',
                           'Upload here:',
                           accept=c('.png'))),
          column(6,
                 uiOutput('photo_ui'))
        )
      )
    ),
    tabItem(
      tabName = 'about',
      fluidPage(
        p('Nothing here')
        )
    )
  )
)

# UI
ui <- dashboardPage(header, sidebar, body, skin="blue")

# Server
server <- function(input, output) {
  resourcepath <- paste0(getwd(),"/www")
  addResourcePath("www", resourcepath)
  
  uploaded_photo_path <- reactive({
    inFile <- input$photo_upload
    
    message('upload photo path is:------------------------ ')
    print(inFile)
    
    if (is.null(inFile)){
      return(NULL)
    } else {
      inFile$datapath
    }
  })
  
  output$photo_ui <- renderUI({
    scale <- 100
    upp <- uploaded_photo_path()
    img_url <- upp
    go <- FALSE
    if(!is.null(img_url)){
      if(length(img_url) > 0){
        if(img_url != ''){
          go <- TRUE
        }
      }
    }
    
    if(!go){
      return(NULL)
    }

    file.copy(img_url,
              to = 'www/temp.png',
              overwrite = TRUE)
    img_url <- 'www/temp.png'
    url_text <- paste0("'", img_url, "'")

    url_text <- paste0('url(', img_url, ')')
    message('URL TEXT IS')
    print(url_text)
    html<- list(
      HTML(paste0("<p>Uploaded Image</p>
                  <img src='www/mask.png'
                  id='crop' name='crop' 
                  onmousedown=\"dragstart(event);\" 
                  onmouseup=\"dragend(event);\" 
                  onmousemove=\"dodrag(event);\" 
                  style=\"z-index:-1;background-image:", url_text, ";
                  background-repeat: no-repeat;background-size:",xscale,"px ",yscale,"px;\" width='300px';>"))
    )
    
    print(html)
    return (html)
    
  })
  
  
}

shinyApp(ui, server)