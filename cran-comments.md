## Test environments

* local macOS (Tahoe 26.5.1), R 4.5.1, x86_64-apple-darwin20, via
  `R CMD check --as-cran`

R-hub and win-builder have not been run yet.

## R CMD check results

0 errors | 0 warnings* | 2 notes

\* A local `R CMD check --as-cran` run additionally reports one ERROR
and one WARNING caused by `pdflatex` not being installed on this
development machine (PDF manual generation fails as a result). This
is a local tooling gap, not an issue with the package's Rd
documentation.

NOTEs:

* "New submission" -- this is the first submission of this package.

* "Non-FOSS package license (file LICENSE)" -- clickclick compiles the
  source of 'cliclick' (<https://github.com/BlueM/cliclick>), a
  BSD-3-clause licensed macOS command-line tool, directly into the
  package rather than depending on it as an external binary. LICENSE
  reproduces cliclick's original license text and copyright notice
  verbatim, as its license requires, rather than CRAN's BSD_3_clause
  template, because the copyright holder of the bundled code (Carsten
  Bluem) differs from the package maintainer. Both are credited with
  their respective roles in Authors@R.

## Other notes

* This package is macOS-only by nature: it simulates mouse and
  keyboard input using macOS's CoreGraphics event APIs (CGEventPost),
  which have no equivalent on other platforms.

* There are no automated tests. The package's entire effect is
  simulating mouse/keyboard input on a live GUI session that has been
  granted Accessibility permission (System Settings > Privacy &
  Security > Accessibility) -- neither of which is available on CRAN's
  check machines, CI, or R-hub/win-builder. Examples are wrapped in
  \dontrun{} for the same reason.
