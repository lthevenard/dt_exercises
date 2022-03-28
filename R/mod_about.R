mod_about_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(2),
      column(
        8,
        h1("About"),
        hr(), br(),
        HTML(about)
      ),
      column(2)
    ),
    br(),
    fluidRow(style = "background-color: #183d7a", column(12, HTML(UI_footer)))
  )
}

mod_about_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
    }
  )
}