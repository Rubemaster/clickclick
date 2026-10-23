/**
 * Copyright (c) 2007-2021, Carsten Blüm <carsten@bluem.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this
 *   list of conditions and the following disclaimer in the documentation and/or
 *   other materials provided with the distribution.
 * - Neither the name of Carsten Blüm nor the names of his contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#import <Cocoa/Cocoa.h>
#import "ActionExecutor.h"
#import "MoveAction.h"
#import "OutputHandler.h"
#import "ExecutionOptions.h"

void error(void);
void help(void);

NSArray* parseCommandsFile(NSString *filepath);

// Error messages are captured here instead of being printed to stderr, so
// that r_wrapper.m can surface them as a real R error via R's error().
char r_cliclick_error[1024] = "";

static void captureError(NSString *message) {
    strncpy(r_cliclick_error, [message UTF8String], sizeof(r_cliclick_error) - 1);
    r_cliclick_error[sizeof(r_cliclick_error) - 1] = '\0';
}

int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    struct ExecutionOptions executionOptions;
    executionOptions.easing = 0;
    executionOptions.waitTime = 0;
    executionOptions.mode = MODE_REGULAR;
    NSArray *modeOptionArg;
    NSString *verbosityOutputDestination = nil;
    NSString *filepath = nil;
    NSString *commandOutputDestination = nil;
    NSArray *actions;
    CGPoint initialMousePosition;
    BOOL restoreOption = NO;
    int optchar;

    while ((optchar = getopt(argc, (char * const *)argv, "horVne:f:d:m:w:")) != -1) {
        switch(optchar) {
            case 'h':
                help();
                [pool release];
                return EXIT_SUCCESS;
            case 'V':
                [pool release];
                return EXIT_SUCCESS;
            case 'n':
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:DONATIONS_URL]];
                [pool release];
                return EXIT_SUCCESS;
            case 'o':
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HISTORY_URL]];
                [pool release];
                return EXIT_SUCCESS;
            case 'm':
                modeOptionArg = [[NSString stringWithCString:optarg encoding:NSASCIIStringEncoding] componentsSeparatedByString:@":"];
                if ([[modeOptionArg objectAtIndex:0] isEqualToString:@"verbose"]) {
                    executionOptions.mode = MODE_VERBOSE;
                } else if ([[modeOptionArg objectAtIndex:0] isEqualToString:@"test"]) {
                    executionOptions.mode = MODE_TEST;
                } else {
                    captureError(@"Only \"verbose\" or \"test\" are valid values for the -m argument");
                    [pool release];
                    return EXIT_FAILURE;
                }
                if ([modeOptionArg count] > 1 && [modeOptionArg objectAtIndex:1]) {
                    verbosityOutputDestination = [modeOptionArg objectAtIndex:1];
                }
                break;
            case 'e':
                executionOptions.easing = atoi(optarg) > 0 ? atoi(optarg) : 0;
                break;
            case 'f':
                filepath = [NSString stringWithCString:optarg encoding:NSASCIIStringEncoding];
                break;
            case 'd':
                commandOutputDestination = [NSString stringWithCString:optarg encoding:NSASCIIStringEncoding];
                break;
            case 'r':
                restoreOption = YES;
                break;
            case 'w':
                executionOptions.waitTime = atoi(optarg) > 0 ? atoi(optarg) : 0;
                break;
            default:
                [pool release];
                return EXIT_FAILURE;
        }
    }

    @try {
        executionOptions.commandOutputHandler = [[OutputHandler alloc] initWithTarget:commandOutputDestination];
        executionOptions.verbosityOutputHandler = [[OutputHandler alloc] initWithTarget:verbosityOutputDestination];
    }
    @catch (NSException *e) {
        captureError([e reason]);
        [pool release];
        return EXIT_FAILURE;
    }

    if (restoreOption) {
        CGEventRef ourEvent = CGEventCreate(NULL);
        initialMousePosition = CGEventGetLocation(ourEvent);
    }

    if (optind == argc && !filepath) {
        error();
        [pool release];
        return EXIT_FAILURE;
    }

    if (executionOptions.mode == MODE_TEST) {
        [executionOptions.verbosityOutputHandler write:@"Running in test mode. These command(s) would be executed:"];
    }

    if (filepath) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([filepath isEqualToString:@""]) {
            captureError(@"Option -f expects a path: -f /path/to/the/file");
            [pool release];
            return EXIT_FAILURE;
        }
        if (![filepath isEqualToString:@"-"] && ![fm fileExistsAtPath:filepath]) {
            captureError([NSString stringWithFormat:@"There is no file at %@", filepath]);
            [pool release];
            return EXIT_FAILURE;
        }
        actions = parseCommandsFile(filepath);
    } else {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:argc];
        for (int ai = 0; ai < argc; ai++) {
            [arguments addObject:[NSString stringWithUTF8String:argv[ai]]];
        }
        actions = [arguments subarrayWithRange:NSMakeRange(optind, argc - optind)];
    }

    @try {
        [ActionExecutor executeActions:actions withOptions:executionOptions];
    }
    @catch (NSException *e) {
        captureError([e reason]);
        [pool release];
        return EXIT_FAILURE;
    }

    if (restoreOption) {
        // Note: we have to prefix the coordinates with "=" to ensure they are not interpreted
        // as relative values, see https://github.com/BlueM/cliclick/issues/119
        NSString *positionString = [NSString stringWithFormat:@"=%d,=%d", (int)initialMousePosition.x, (int)initialMousePosition.y];
        id moveAction = [[MoveAction alloc] init];
        [moveAction performActionWithData:positionString
                              withOptions:executionOptions];
        [moveAction release];
    }

    [pool release];
    return EXIT_SUCCESS;
}

NSArray* parseCommandsFile(NSString *filepath) {
    NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:32];
    NSArray *lines;

    if ([filepath isEqualToString:@"-"]) {
        // stdin
        NSData *stdinData = [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
        NSString *configString = [[NSString alloc] initWithData:stdinData encoding:NSUTF8StringEncoding];
        lines = [configString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [configString release];
    } else {
        // File
        NSString *fileContents = [NSString stringWithContentsOfFile:filepath
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
        lines = [fileContents componentsSeparatedByString:@"\n"];
    }

    NSUInteger i, count = [lines count];
    for (i = 0; i < count; i++) {
        NSString *command = [[lines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([command isEqualToString:@""]) {
            continue;
        }
        if ([[command substringToIndex:1] isEqualToString:@"#"]) {
            continue;
        }
        [commands addObject:command];
    }

    return [commands autorelease];
}

void error() {
    captureError(@"You did not pass any commands as argument to cliclick. "
                 "Call cliclick with option -h to see usage instructions.");
}

// Printing usage/help text to stdout only makes sense for the standalone
// CLI tool, not when this is called in-process from R, so this is a no-op.
void help() {
}
