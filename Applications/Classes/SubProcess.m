// SubProcess.m

#import "SubProcess.h"

#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/wait.h>
#include <unistd.h>
#include <util.h>


@implementation SubProcess

static SubProcess *instance = nil;


static void signal_handler(int signal)
{
    NSLog(@"Caught signal: %d", signal);
    [instance dealloc];
    instance = nil;
    exit(1);
}

int start_process(const char *path, char *const args[], char *const env[])
{
    struct stat st;
    if (stat(path, &st) != 0) {
        fprintf(stderr, "%s: File does not exist\n", path);
        return -1;
    }
    if ((st.st_mode & S_IXUSR) == 0) {
        fprintf(stderr, "%s: Permission denied\n", path);
        return -1;
    }
    if (execve(path, args, env) == -1) {
        perror("execlp:");
        return -1;
    }
    // execve never returns if successful
    return 0;
}

- (id)initWithDelegate:(id)inputDelegate identifier:(int)tid
{
    self = [super init];
    if (self) {
        delegate = inputDelegate;
        termid = tid;
		step=0;
		iosRootPwd=@"alpine";
        // Clean up when ^C is pressed during debugging from a console
        signal(SIGINT, &signal_handler);

     //   TerminalConfig *config = [TerminalConfig configForTerminal:tid];

        struct winsize win;
       // win.ws_col = [config width];
       // win.ws_row = DEFAULT_TERMINAL_HEIGHT;
		win.ws_col=320;
		win.ws_row=480;
		
		
        pid = forkpty(&fd, NULL, NULL, &win);
        if (pid == -1) {
         //   log(@"[Failed to fork child process] %d", pid);
            perror("forkpty");
            [self failure:@"[Failed to fork child process]"];
            //exit(0); // sometimes a fork fails. if we exit here, the app hangs -kodi
            return self;
        } else if (pid == 0) {
            // First try to use /bin/login since its a little nicer. Fall back to
            // /bin/sh if that is available.
            char *login_args[] = { "login", "-fp", "mobile", (char *)0, };
            char *sh_args[] = { "sh", (char *)0, };
            char *env[] = { "TERM=vt100", (char *)0 };
            // NOTE: These should never return if successful
            start_process("/usr/bin/login", login_args, env);
            start_process("/bin/login", login_args, env);
            start_process("/bin/sh", sh_args, env);
            exit(0);
        }
        NSLog(@"Child process id: %d", pid);
        [NSThread detachNewThreadSelector:@selector(startIOThread:)
                                 toTarget:self
                               withObject:delegate];
    }
    return self;
}

- (void)setNamePwd:(NSString *)name PPPPwd:(NSString *)pwd iosPwd:(NSString *)rootPwd
{
	pppName=name;
	pppPwd=pwd;
	iosRootPwd=rootPwd;
}



- (void)dealloc
{
    [self close];
    [super dealloc];
}

#pragma mark Delegate methods

- (void)didExitWithCode:(int)code
{
    if ([delegate respondsToSelector:@selector(process:didExitWithCode:)])
        [delegate performSelector:@selector(process:didExitWithCode:)
            withObject:self withObject:[NSNumber numberWithInt:code]];
}

#pragma mark Other

- (void)closeSession { // this is invoked when the user closes that terminal session
    closed = 1;
    kill(pid, SIGHUP);
    int stat;
    waitpid(pid, &stat, WUNTRACED);
    [self close];
}

- (void)close
{
    if (fd != 0) {
        close(fd);
        fd = 0;
    }
}

- (BOOL)isRunning
{
    return (fd != 0) ? YES : NO;
}

- (int)write:(const char *)data length:(unsigned int)length
{
    return write(fd, data, length);
}

- (void)startIOThread:(id)inputDelegate
{
    [[NSAutoreleasePool alloc] init];

	NSLog(@"read return");
    const int kBufSize = 1024;
    char buf[kBufSize];
    ssize_t nread;
    while (1) {
		memset(buf,0,kBufSize);
        // Blocks until a character is ready
        nread = read(fd, buf, kBufSize);
        // On error, give a tribute to OS X terminal
        if (nread == -1) {
            perror("read");
            [self close];
            if(!closed)
                [self failure:@"[Process error]"];
                [self didExitWithCode:1];
            return;
        } else if (nread == 0) {
            [self close];
            if(!closed) {
                [self failure:@"[Process completed]"];
                [self didExitWithCode:0];
            }
            return;
        }
		NSLog(@"read:%s\n",buf);

        [self handleStreamOutput:buf length:nread ];
    }
}


- (void)handleStreamOutput:(const char *)c length:(unsigned int)len 
{	
	
	if (strstr(c, "Login incorrect")) {
		write(fd, "root\n", 5);
		//write(fd, "lvcoffee\n", 9);	
	}
	else if(strstr(c, "Password:"))
	{
		NSString *strPwd=[NSString initWithFormat:@"%@\n",iosRootPwd];
		write(fd, [strPwd UTF8String], [strPwd length]);
	}
	else{
		NSString *pppoeStr=@"pppd pty \"/usr/sbin/pppoe -p /var/tmp/pppoe.pid -I en0 -T 80 -U -m 1412 -D /var/tmp/pppoe.log \" \
					noipdefault noauth default-asyncmap defaultroute hide-password nodetach usepeerdns mtu 1492 mru 1492 \
					noaccomp nodeflate nopcomp novj novjccomp user  ";
		pppoeStr=[pppoeStr stringByAppendingFormat:@"%@ password %@  lcp-echo-interval 20 lcp-echo-failure 3 &\n", pppName ,pppPwd];
		write(fd,[pppoeStr UTF8String] , [pppoeStr length]);
	}
	 
}

- (void)failure:(NSString *)message;
{
    // HACK: Just pretend the message came from the child
    NSLog(message);
    [delegate handleStreamOutput:[message UTF8String] length:[message length]];
}


- (void)setIdentifier:(int)tid
{
    termid = tid;
}

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
