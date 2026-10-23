\name{clickclick-package}
\alias{clickclick-package}
\docType{package}
\title{Keyboard and Mouse Input Simulation for macOS}
\description{
  Control your keyboard and mouse with R code by simulating mouse moves,
  clicks, drags, key presses, and typed text. The input simulation is
  implemented in Objective-C using macOS's CoreGraphics event APIs
  (\code{CGEventCreateMouseEvent}, \code{CGEventCreateKeyboardEvent},
  \code{CGEventPost}), built on top of the open-source \href{https://github.com/BlueM/cliclick}{cliclick}
  command-line tool, compiled directly into the package and invoked
  in-process (no subprocess is spawned per call).

  This package only works on macOS, and only when the host application
  (R, RStudio, or a terminal) has been granted Accessibility permission
  in System Settings > Privacy & Security > Accessibility. Without that
  permission, calls will silently have no effect.
}
\details{
  The single exported function, \code{\link{clickclick}}, takes a command
  string using cliclick's own syntax. See \code{\link{clickclick}} for the
  full list of supported commands.
}
\author{
  Rubemaster (package author); Carsten Bluem (author of the bundled
  cliclick source, see \code{LICENSE})
}
\references{
  \url{https://github.com/BlueM/cliclick}
}
\keyword{package}
