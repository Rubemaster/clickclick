#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

extern void r_cliclick_run(char **cmd);

static const R_CMethodDef cMethods[] = {
    {"r_cliclick_run", (DL_FUNC) &r_cliclick_run, 1},
    {NULL, NULL, 0}
};

void R_init_clickclick(DllInfo *dll) {
    R_registerRoutines(dll, cMethods, NULL, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
