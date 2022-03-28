mod_dui_UI <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        htmlOutput(ns("UI_sidebar_title_1")),
        hr(),
        selectInput(
          ns("exercise_type"), 
          "Solution Method",
          choices = dui_exercise_type_choices,
          selected = dui_exercise_type_choices[1]
        ),
        sliderInput(
          ns("num_decisions"), 
          "Decision Alternatives",
          value = 5,
          min = 2, 
          max = 8,
          step = 1
        ),
        sliderInput(
          ns("num_states"), 
          "States of the World",
          value = 5,
          min = 2, 
          max = 8,
          step = 1
        ),
        selectInput(ns("value_precision"), "Payoff precision", choices = c(1, 2, 4, 5, 10), selected = 5),
        actionButton(ns("go"), paste("Generate Problem", emo::ji("star")))
      ),
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Exercise",
            br(),
            htmlOutput(ns("UI_mainPanel_fill_information")), 
            hr(),
            htmlOutput(ns("problem_presentation")), 
            dataTableOutput(ns("problem_table")),
            br(), br(), br()
          ),
          tabPanel(
            "Solution",
            br(),
            htmlOutput(ns("solution_header")),
            br(),
            dataTableOutput(ns("solution_table")),
            br(), br(), br()
          )
        )
        
      )
    ),
    fluidRow(column(12, HTML(UI_footer)))
  )
}

mod_dui_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      output$UI_sidebar_title_1 <- renderUI({HTML(UI_sidebar_title_1)})
      output$UI_mainPanel_fill_information <- renderUI({HTML(UI_mainPanel_fill_information)})
      
      level_of_optimism <- eventReactive({input$exercise_type}, {
        if (input$exercise_type == "Optimism-Pessimism Rule") {
          return(generate_opr_level())
        } else {
          return(0)
        }
      })
      
      problem_description <- eventReactive({input$go}, {
        level_opr <- level_of_optimism()
        type = input$exercise_type
        description <- list(
          problem_text = describe_dui_problem(type, level_opr),
          problem_table = create_dui_table(
            input$num_decisions,
            input$num_states,
            as.numeric(input$value_precision)
          ),
          level_of_optimism = level_opr,
          type = type
        )
        description[["solution"]] <- solve_dui(description$problem_table, type, description$level_of_optimism)
        return(description)
      })
      
      output$problem_presentation <- renderUI({
        HTML(problem_description()$problem_text)
      })
      
      output$solution_header <- renderUI({
        description <- problem_description()
        HTML(
          build_dui_solution_header(description$type, description$solution, description$level_of_optimism)
        )
      })
      
      output$problem_table <- renderDataTable({
        problem_description()$problem_table %>% 
          simple_datatable()
      })
      
      output$solution_table <- renderDataTable({
        solution_table <- problem_description()$solution$table 
        solution_table %>% 
          simple_datatable(columnDefs = list(list(className = 'dt-center', targets = ncol(solution_table) - 1))) %>% 
          dui_dt_format_according_to_type(problem_description()$type)
      })
    }
  )
}

