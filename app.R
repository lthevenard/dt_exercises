library(shiny)
library(tidyverse)
library(bslib)
library(DT)

app_theme <- bs_theme(
  bootswatch = "united", 
  primary = deep_blue, 
  secondary = light_blue, 
  info = purple,
  success = pale_green
)

ui <- navbarPage(
  theme = app_theme,
  titlePanel("Decision Theory Exercises", windowTitle = paste(emo::ji("weight"), "DT Exercises")),
  tabPanel(
    paste(emo::ji("person_shrugging"), "Decisions under ignorance"),
    br(), br(),
    mod_dui_UI("dui_maximin")
  ),
  tabPanel(
    paste(emo::ji("open_book"), "About"),
    hr(), br(),
    mod_about_UI("about_ui")
  )
)

server <- function(input, output, session) {
  mod_dui_server("dui_maximin")
  mod_about_server("about_ui")
}

shinyApp(ui, server)