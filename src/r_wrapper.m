#import <Foundation/Foundation.h>

extern int main(int argc, const char *argv[]);

void r_cliclick_run(char **cmd) {
    const char *argv[3] = {"cliclick", cmd[0], NULL};
    main(2, argv);
}
