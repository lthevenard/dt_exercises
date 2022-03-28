# Variables ----

dui_exercise_type_choices <- c(
  "Maximin", 
  "Minimax", 
  "Optimism-Pessimism Rule",
  "Principle of Insufficient Reason"
)

dui_solutions_list_item_open <- "<li style = 'line-height: 150%; margin-bottom: 15px;'><b style = 'color: #183d7a;'>"

# Functions ----

describe_dui_problem <- function(exercise_type, level_of_optimism) {
  method <- ifelse(exercise_type %in% dui_exercise_type_choices[1:2],
                   paste("Lexical", exercise_type),
                   exercise_type)
  return(
    paste0(
      UI_mainPanel_title_1,
      "<p style= 'lineheight: 150%; color: #051d45;'><b>",
      "Solve the decision under ignorance problem represented in the table below using the ",
      method, " method.</b></p>",
      ifelse(exercise_type == dui_exercise_type_choices[3], 
             paste0("<p style= 'lineheight: 150%; color: #051d45;'><b>",
                    "In your solution, use a level of optimism of ",
                    level_of_optimism, ".</b></p>"),
             "")
    )
  )
}

generate_columns <- function(name, num_decisions, value_precision) {
  return(
    list(rdunif(num_decisions, 200 / value_precision) * value_precision) %>% 
      setNames(name)
  )
}

create_dui_table <- function(num_decisions, num_states, value_precision) {
  decisions <- map_chr(1:num_decisions, ~paste0("D", .))
  states <- map_chr(1:num_states, ~paste0("S", .))
  states_columns <- map(states, generate_columns, num_decisions, value_precision)
  return(bind_cols(list(Decisions = decisions), states_columns))
}

generate_opr_level <- function() {
  return((rdunif(1, 14, 4) * 5) / 100)
}

solve_dui <- function(problem_table, exercise_type, level_of_optimism) {
  if (exercise_type == "Maximin") {
    return(solve_dui_maximin(problem_table))
  } else if (exercise_type == "Minimax") {
    return(solve_dui_minimax(problem_table))
  } else if (exercise_type == "Optimism-Pessimism Rule") {
    return(solve_dui_opr(problem_table, level_of_optimism))
  } else {
    return(solve_dui_pir(problem_table))
  }
}

solve_lexical_problem <- function(table, decisions, replace_value, FUN_SELECT, FUN_CHOOSE) {
  max_control <- ncol(table) - 1
  solution <- list(steps = 0)
  while(TRUE) {
    selected_values <- map_dbl(1:nrow(table), ~FUN_SELECT(as_vector(table[.,])))
    solution[["results"]] <- FUN_CHOOSE(selected_values)
    solution[["steps"]] <- solution[["steps"]] + 1
    decision_selection <- (selected_values == solution[["results"]])
    table <- table[decision_selection,]
    table <- modify(table, ~ifelse(. == solution[["results"]], replace_value, .))
    decisions <- decisions[decision_selection]
    solution[["best_decision"]] <- decisions
    if (sum(decision_selection) == 1) {
      break()
    } else if (solution[["steps"]] == max_control) {
      break()
    }
  }
  return(solution)
}

solve_non_lexical_problem <- function(table, decisions, FUN_DECISION_VALUE, level_of_optimism = NULL) {
  decision_values <- map_dbl(1:nrow(table), ~FUN_DECISION_VALUE(as_vector(table[.,]), level_of_optimism))
  max_value <- max(decision_values)
  decision_selection <- (decision_values == max_value)
  return(
    list(
      steps = 1,
      results = decision_values,
      best_decision = decisions[decision_selection]
    )
  )
}

add_ordered_values_column <- function(table, reverse) {
  values_table <- table[,2:ncol(table)]
  order_values <- function(values, reverse) {
    if (reverse) {
      return(sort(values) %>% rev() %>% paste(collapse = " ≥ "))
    } else {
      return(sort(values) %>% paste(collapse = " ≤ "))
    }
  }
  return(
    tibble(
      table, 
      `Ordered Values` = map_chr(1:nrow(values_table), ~order_values(as_vector(values_table[.,]), reverse))
    )
  )
}

solve_dui_maximin <- function(problem_table) {
  states_table <- problem_table[,2:ncol(problem_table)]
  solution <- solve_lexical_problem(
    table = states_table, 
    decisions = problem_table$Decisions, 
    replace_value = 201, 
    FUN_SELECT = min, 
    FUN_CHOOSE = max
  )
  solution[["table"]] <- problem_table %>% add_ordered_values_column(reverse = FALSE)
  return(solution)
}

solve_dui_minimax <- function(problem_table) {
  states_table <- problem_table[,2:ncol(problem_table)]
  regret_table <- map_dfc(states_table, ~max(.x) - .x )
  names(regret_table) <- map_chr(1:ncol(regret_table), ~paste0("RS", .))
  solution <- solve_lexical_problem(
    table = regret_table, 
    decisions = problem_table$Decisions, 
    replace_value = 0, 
    FUN_SELECT = max, 
    FUN_CHOOSE = min
  )
  solution[["table"]] <- bind_cols(select(problem_table, Decisions), regret_table) %>% 
    add_ordered_values_column(reverse = TRUE)
  return(solution)
}

solve_dui_opr <- function(problem_table, a) {
  states_table <- problem_table[,2:ncol(problem_table)]
  calc_opr <- function(row_values, a) {
    max_value <- max(row_values)
    min_value <- min(row_values)
    result <- (a * max_value) + ((1 - a) * min_value)
    return(result)
  }
  solution <- solve_non_lexical_problem(
    table = states_table, 
    decisions = problem_table$Decisions, 
    FUN_DECISION_VALUE = calc_opr, 
    level_of_optimism = a
  )
  solution[["table"]] <- bind_cols(problem_table, tibble(`Decision Evaluation` = solution[["results"]]))
  return(solution)
}


solve_dui_pir <- function(problem_table) {
  states_table <- problem_table[,2:ncol(problem_table)]
  calc_pri <- function(row_values, a) {
    result <- mean(row_values)
    return(result)
  }
  solution <- solve_non_lexical_problem(
    table = states_table, 
    decisions = problem_table$Decisions, 
    FUN_DECISION_VALUE = calc_pri, 
    level_of_optimism = a
  )
  solution[["table"]] <- bind_cols(problem_table, tibble(`Decision Evaluation` = round(solution[["results"]], digits = 2)))
  return(solution)
}

build_dui_solution_header <- function(exercise_type, solution, level_of_optimism) {
  if (exercise_type == "Maximin") {
    describe_dui_solution_for_maximin(solution, exercise_type)
  } else if (exercise_type == "Minimax") {
    return(describe_dui_solution_for_minimax(solution, exercise_type))
  } else if (exercise_type == "Optimism-Pessimism Rule") {
    return(describe_dui_solution_for_opr(solution, exercise_type, level_of_optimism))
  } else {
    return(describe_dui_solution_for_pir(solution, exercise_type))
  }
}

describe_dui_solution_for_maximin <- function(solution, exercise_type, list_item_open = dui_solutions_list_item_open) {
  case_single_solution <- length(solution$best_decision) == 1
  solution_type <- ifelse(case_single_solution,
                          "Problem resolution status</b>: A single best Lexical Maximin solution was found.",
                          "Problem resolution status</b>: Lexical Maximin method was unable to produce a single best decision.")
  best_decision <- ifelse(case_single_solution,
                          paste0("Best Decision</b>:<b> ", solution$best_decision, "</b>"),
                          paste0("Tied Solutions</b>: ", solution$best_decision))
  maximin_value <- ifelse(case_single_solution,
                          paste0("Maximin Value</b>: ", solution$results),
                          paste0("Last Maximin Value Used</b>: ", solution$results))
  paste0(
    "<div style = 'border-radius: 25px; background: #f7f7f7; padding: 60px; margin-right: 8px;'>", 
    "<h3 style = 'text-align: center;'>Solution for '", exercise_type, "' problem</h3></br>", hr(), "</br>",
    "<ul>",
    list_item_open, solution_type, "</li>",
    list_item_open, best_decision, "</li>",
    list_item_open, "Steps Taken</b>: ", solution$steps, "</li>",
    list_item_open, maximin_value, "</li>",
    "</ul></div></br>",
    "<h3>Problem Table with Values Ordered by Minimums</h3></hr>"
  )
}

describe_dui_solution_for_minimax <- function(solution, exercise_type, list_item_open = dui_solutions_list_item_open) {
  case_single_solution <- length(solution$best_decision) == 1
  solution_type <- ifelse(case_single_solution,
                          "Problem resolution status</b>: A single best Lexical Minimax solution was found.",
                          "Problem resolution status</b>: Lexical Minimax method was unable to produce a single best decision.")
  best_decision <- ifelse(case_single_solution,
                          paste0("Best Decision</b>:<b> ", solution$best_decision, "</b>"),
                          paste0("Tied Solutions</b>: ", solution$best_decision))
  minimax_value <- ifelse(case_single_solution,
                          paste0("Minimax Regret Value</b>: ", solution$results),
                          paste0("Last Minimum Regret Value Used</b>: ", solution$results))
  paste0(
    "<div style = 'border-radius: 25px; background: #f7f7f7; padding: 60px; margin-right: 8px;'>", 
    "<h3 style = 'text-align: center;'>Solution for '", exercise_type, "' problem</h3></br>", hr(), "</br>",
    "<ul>",
    list_item_open, solution_type, "</li>",
    list_item_open, best_decision, "</li>",
    list_item_open, "Steps Taken</b>: ", solution$steps, "</li>",
    list_item_open, minimax_value, "</li>",
    "</ul></div></br>",
    "<h3>Regret Table and Values Ordered by Maximum Regret</h3></hr>"
  )
}

describe_dui_solution_for_opr <- function(solution, exercise_type, level_of_optimism, list_item_open = dui_solutions_list_item_open) {
  case_single_solution <- length(solution$best_decision) == 1
  solution_type <- ifelse(case_single_solution,
                          "Problem resolution status</b>: A single best solution was found by the Optimism-Pessimism Rule.",
                          "Problem resolution status</b>: The Optimism-Pessimism Rule was unable to produce a single best decision.")
  best_decision <- ifelse(case_single_solution,
                          paste0("Best Decision</b>:<b> ", solution$best_decision, "</b>"),
                          paste0("Tied Solutions</b>: ", solution$best_decision))
  best_value <- ifelse(case_single_solution,
                          paste0("Best Decision Value</b>: ", max(solution$results)),
                          paste0("Value of Best Decisions</b>: ", max(solution$results)))
  paste0(
    "<div style = 'border-radius: 25px; background: #f7f7f7; padding: 60px; margin-right: 8px;'>", 
    "<h3 style = 'text-align: center;'>Solution for a '", exercise_type, "' problem</h3></br>", hr(), "</br>",
    "<ul>",
    list_item_open, solution_type, "</li>",
    list_item_open, "Level of Optimism</b>: ", level_of_optimism, "</li>",
    list_item_open, best_decision, "</li>",
    list_item_open, best_value, "</li>",
    "</ul></div></br>",
    "<h3>Problem Table with Decision Evaluations</h3></hr>"
  )
}

describe_dui_solution_for_pir <- function(solution, exercise_type, list_item_open = dui_solutions_list_item_open) {
  case_single_solution <- length(solution$best_decision) == 1
  solution_type <- ifelse(case_single_solution,
                          "Problem resolution status</b>: A single best solution was found by the Optimism-Pessimism Rule.",
                          "Problem resolution status</b>: The Optimism-Pessimism Rule was unable to produce a single best decision.")
  best_decision <- ifelse(case_single_solution,
                          paste0("Best Decision</b>:<b> ", solution$best_decision, "</b>"),
                          paste0("Tied Solutions</b>: ", solution$best_decision))
  best_value <- ifelse(case_single_solution,
                       paste0("Best Decision Value</b>: ", max(solution$results)),
                       paste0("Value of Best Decisions</b>: ", max(solution$results)))
  paste0(
    "<div style = 'border-radius: 25px; background: #f7f7f7; padding: 60px; margin-right: 8px;'>", 
    "<h3 style = 'text-align: center;'>Solution for a '", exercise_type, "' problem</h3></br>", hr(), "</br>",
    "<ul>",
    list_item_open, solution_type, "</li>",
    list_item_open, best_decision, "</li>",
    list_item_open, best_value, "</li>",
    "</ul></div></br>",
    "<h3>Problem Table with Decision Evaluations</h3></hr>"
  )
}

dui_dt_format_according_to_type <- function(table, type) {
  if (type %in% dui_exercise_type_choices[1:2]) {
    return(
      table %>% 
        formatStyle(
          'Ordered Values',
          backgroundColor = "#3f8ccb",
          fontWeight = "bold",
          color = "white"
        )
    ) 
  } else {
    table %>% 
      formatStyle(
        'Decision Evaluation',
        backgroundColor = "#3f8ccb",
        fontWeight = "bold",
        color = "white"
      )
  }
}
