// SubProcess.h

#import <Foundation/Foundation.h>

@interface SubProcess : NSObject
{
    int fd;
    id delegate;
    int termid;
	int step;
    pid_t pid;
    int closed;
	@public NSString *pppName;
	@public NSString *pppPwd;
	@public NSString *iosRootPwd;
}

// Delegate should support InputDelegateProtocol
- (id)initWithDelegate:(id)inputDelegate identifier:(int)termid;
- (void)dealloc;
- (void)closeSession;
- (void)close;
- (void)setNamePwd:(NSString *)name PPPPwd:(NSString *)pwd iosPwd:(NSString *)rootPwd;
- (BOOL)isRunning;
- (int)write:(const char *)c length:(unsigned int)len;
- (void)startIOThread:(id)inputDelegate;
- (void)failure:(NSString *)message;
- (void)setIdentifier:(int)termid;
- (void)handleStreamOutput:(const char *)c length:(unsigned int)len ;
@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
