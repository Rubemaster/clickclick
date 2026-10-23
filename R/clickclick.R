clickclick <- function(cmd) {
  .C("r_cliclick_run", cmd = as.character(cmd), PACKAGE = "clickclick")
  invisible(NULL)
}
