#import <Foundation/Foundation.h>
#include <R.h>
#include <stdlib.h>

extern int main(int argc, const char *argv[]);
extern char r_cliclick_error[1024];

void r_cliclick_run(char **cmd) {
    const char *argv[3] = {"cliclick", cmd[0], NULL};
    r_cliclick_error[0] = '\0';
    int status = main(2, argv);
    if (status != EXIT_SUCCESS) {
        error("%s", r_cliclick_error[0] ? r_cliclick_error : "clickclick: command failed");
    }
}
