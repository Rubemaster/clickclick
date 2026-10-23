\name{clickclick}
\alias{clickclick}
\title{Simulate a Mouse or Keyboard Action}
\description{
  Runs a single cliclick-style command, simulating a mouse move, click,
  drag, key press, or typed text. Available only on macOS.
}
\usage{
clickclick(cmd)
}
\arguments{
  \item{cmd}{A character string giving the command to run, using
    cliclick's command syntax (see \sQuote{Details}).}
}
\details{
  Each command consists of a short identifier and, usually, one or more
  arguments separated from the identifier by a colon. Wherever a command
  expects a pair of coordinates, you may give relative values by
  prefixing the number with \code{+} or \code{-} (e.g. \code{"m:+50,+0"}
  moves 50 pixels to the right of the current position), or force an
  absolute value with \code{=} (useful for negative absolute coordinates
  on a secondary display to the left of the main display).

  Supported commands:
  \describe{
    \item{\code{m:x,y}}{Move the mouse to the point with the given
      coordinates. Example: \code{"m:12,34"}.}
    \item{\code{c:x,y}}{Click at the given coordinates. \code{"."} may be
      used instead of coordinates to mean the current position. Example:
      \code{"c:12,34"}.}
    \item{\code{dc:x,y}}{Double-click at the given coordinates.}
    \item{\code{tc:x,y}}{Triple-click at the given coordinates. If this
      does not work in a target application, try double-click plus
      single-click instead.}
    \item{\code{rc:x,y}}{Right-click at the given coordinates.}
    \item{\code{dd:x,y}}{Press down to start a drag at the given
      coordinates.}
    \item{\code{dm:x,y}}{Continue a drag started with \code{dd} to the
      given coordinates.}
    \item{\code{du:x,y}}{Release to end a drag at the given coordinates.}
    \item{\code{kd:keys}}{Trigger a key-down event for a comma-separated
      list of modifier keys (e.g. \code{"cmd"}, \code{"alt"},
      \code{"ctrl"}, \code{"shift"}, \code{"fn"}). The keys stay down
      until released with \code{ku}. Example: \code{"kd:cmd,alt"}.}
    \item{\code{ku:keys}}{Trigger a key-up event for a comma-separated
      list of modifier keys. Example: \code{"ku:cmd,ctrl"}.}
    \item{\code{kp:key}}{Emulate pressing a single key (key down + key
      up), e.g. \code{"kp:return"}, \code{"kp:tab"}, \code{"kp:esc"}.}
    \item{\code{t:text}}{Type the given text into the frontmost
      application. If the text includes spaces, enclose it in quotes.
      Example: \code{"t:Test"}, \code{"t:'Viele Grusse'"}.}
    \item{\code{w:ms}}{Wait/pause for the given number of milliseconds.
      Example: \code{"w:500"}.}
  }

  The upstream cliclick tool also provides \code{p}/\code{cp} (print the
  current mouse position, or the color under a given point). Neither is
  available in this package: \code{cp} depends on
  \code{CGWindowListCreateImage}, which Apple removed in macOS 15, and
  \code{p} writes to the CLI's own stdout/stderr, which doesn't apply
  when cliclick is called in-process from R. Both raise an error if
  used.
}
\value{
  Invisibly returns \code{NULL}. The function is called for its side
  effect (moving the mouse, posting a click, or typing text).
}
\note{
  Requires Accessibility permission for the calling process (R, RStudio,
  or your terminal app) under System Settings > Privacy & Security >
  Accessibility. Without it, the call returns without doing anything.
}
\examples{
\dontrun{
  # Move the mouse to (300, 300) and click there
  clickclick("m:300,300")
  clickclick("c:300,300")

  # Type some text into the frontmost application
  clickclick("t:Hello world")
}
}
\seealso{
  \link{clickclick-package}
}
