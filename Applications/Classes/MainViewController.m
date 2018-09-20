//
//  MainViewController.m
//  PPPOE
//
//  Created by liu edwin on 12-5-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController
@synthesize process;
@synthesize name;
@synthesize pwd;
@synthesize rootPwd;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	process=[[SubProcess alloc] initWithDelegate:self identifier:0];
}



- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}


- (IBAction)dialUp:(id)sender{
	printf("dialUp\n");
	[self showWaiting];
	
	[process setNamePwd:name.text :pwd.text :rootPwd.text];
	
	[process write:@"root\n" length:5];
	//[self hideWaiting];
	
	//[self showInfo:sender];
}


- (void) showWaiting
{
    waitingDialog = [[[UIAlertView alloc] initWithTitle:nil
											 message:NSLocalizedString(@"正在拨号，请稍等......", @"TitleCaptionWattingDialog") 
											delegate:self
								   cancelButtonTitle:nil
								   otherButtonTitles:nil] autorelease];
	UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] 
												initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[activityIndicator setCenter:CGPointMake(132.0f,60.0f)];
	[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicator startAnimating];
	[waitingDialog addSubview:activityIndicator];
	[waitingDialog show];
}	

- (void) hideWaiting{
	[waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
}
	
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	[process release];
	[name release];
	[pwd release];
	[rootPwd release];
    [super dealloc];
}

- (IBAction) textDoneEditing:(id)sender
{
	[sender resignFirstResponder];
}

@end
