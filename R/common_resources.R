# Colors and theming ----

darker_blue <- "#051d45"
deep_blue <- "#183d7a"
light_blue <- "#3f8ccb"
purple <- "#50327c"
pale_green <- "#52C663"

# Titles and UI structures ----

lorem <- paste0(
  "<p style = 'line-height: 180%; margin-bottom: 15px;'>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>",
  "<p style = 'line-height: 180%; margin-bottom: 15px;'>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?</p>"
)

about <- paste0(
  "<p style = 'line-height: 180%; margin-bottom: 15px;'>",
  "This app was design so that Law students at <a href = 'https://direitorio.fgv.br/'>FGV's Rio de Janeiro Law School</a> could practice some of the concepts they are learning in their course on Decision Theory. ", 
  "Because it is a course designed for students that do not possess graduate-level math skills, the idea of the course is not to develop a deep mathematical understanding of Decision Theory. ", 
  "The focus of the course is to provide a general view of the field, and introduce the students to some of the merits and challenges of Decision Theory, specially as it potentially relates to legal considerations regarding the consequences of legal decisions and public policy choices. ", 
  "</p>",
  "<p style = 'line-height: 180%; margin-bottom: 15px;'>",
  "Nevertheless, the course does provide a general overview of the typical decision problems and solution methods presented by Decision Theory, including a brief introduction to Game Theory. ", 
  "By dealing with simple, discrete examples, and focusing more on the conceptual foundations of the discipline, our goal is to create and interesting and effective introduction to Decision Theory. ", 
  "By not shying away completely from the analytical foundations of the discipline, we intend to guide students towards a better understanding of rational choice theory and of the applications of Decision Theory in Law.", 
  "</p>",
  "<p style = 'line-height: 180%; margin-bottom: 15px;'>",
  "Given these circumstances, this app is intended to be a <i>playground</i> or <i>testing field</i> where students can go to practice some of the concepts they learned during classes. ",
  "It is an ambitious project, that will be implemented gradually and will probably have to be revised many times in the future by it's sole developper. ",
  "Currently, the app only has a couple of exercise types dealing with decisions under ignorance. ",
  "In the future, I hope to include many more exercise options, making the experience a little richer for the students that decide to visit the app. ",
  "</p>",
  "<p style = 'line-height: 180%; margin-bottom: 15px;'>",
  "In any case, if you find this project interesting and want to be involved, please access the app's <a href = 'https://direitorio.fgv.br/'>Github Page</a> or contact me at <a href = 'mailto: lucas.gomes@fgv.br'>lucas.gomes@fgv.br</a>. ",
  "I hope you like what has been accomplished so far.",
  "</p>"
)

UI_footer <- paste0(
  "</br></br><p style = 'text-align: center; font-size:0.8em; color: lightgray;'>",
  "<b>Created by</b>: Lucas Thevenard    |    <b>Last update</b>: 28/03/2022</br>" 
)

UI_sidebar_title_1 <- paste0(
    "<h3 style ='lineheight: 150%; color: ", 
    darker_blue, 
    ";'>Exercise parameters</h3>"
)

UI_mainPanel_title_1 <- paste0(
    "<h1 style ='lineheight: 150%; color: ", 
    darker_blue, 
    ";'>Problem</h3>"
)

UI_mainPanel_fill_information <- paste0(
    "<p style ='lineheight: 150%; color: gray;'><i>",
    "Choose the desired exercise parameters and press the button ",
    "'Generate Problem' to begin the exercise.</i></p>"
)


# Functions ----

simple_datatable <- function(table, ...) {
  table %>% 
    DT::datatable(
      class="compact", 
      rownames = FALSE,
      selection = "single",
      options = list(searching = FALSE,
                     paging = FALSE, 
                     ordering = FALSE,
                     info = FALSE,
                     ...)
    )
}






