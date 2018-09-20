//
//  MainViewController.h
//  PPPOE
//
//  Created by liu edwin on 12-5-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
@class SubProcess;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	UIAlertView *waitingDialog;
	SubProcess *process;
	UITextField *name;
	UITextField *pwd;
	UITextField *rootPwd;
}
@property(nonatomic, readonly) SubProcess *process;
- (IBAction)showInfo:(id)sender;
- (IBAction) textDoneEditing:(id)sender;
- (IBAction)dialUp:(id)sender;
- (void)showWaiting;
- (void) hideWaiting;
@property (nonatomic,retain) IBOutlet UITextField *name;
@property (nonatomic,retain) IBOutlet UITextField *pwd;
@property (nonatomic,retain) IBOutlet UITextField *rootPwd;
@end
