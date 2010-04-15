//
//  ServiceDetailController.m
//  iPhoneClient
//
//	HW3_1
//
//  Copyright 2010 Chris Parrish

#import "ServiceDetailController.h"

@interface ServiceDetailController ()
- (void) connectToService;
@end

@implementation ServiceDetailController

@synthesize	service = service_;
@synthesize statusLabel = statusLabel_;
@synthesize messageTextView = messageTextView_;

- (void)viewDidLoad
{
    [super viewDidLoad];

	[messageTextView_ becomeFirstResponder];
	messageTextView_.returnKeyType = UIReturnKeySend;
	messageTextView_.enablesReturnKeyAutomatically = YES;

    // Root view controller sets detailController.service = selectedService
    // ServiceDetailController doesn't neet to alloc/init a service    
	if (service_)
		[self connectToService];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
	self.statusLabel = nil;
	self.messageTextView = nil;
	self.service = nil;
	[outputStream_ close];
	[outputStream_ release];
	outputStream_ = nil;
}


- (void)dealloc
{
	[service_ release];
	[outputStream_ close];
	[outputStream_ release];
		
    [super dealloc];
}


#pragma mark - 
#pragma mark Service

- (void) connectToService
{
	// We assume the NSNetService has been resolved at this point	
	// NSNetService makes it easy for us to connect, we don't have to do any socket management		
	// < ADD CODE HERE : get the output stream from the service >
    
    [service_ getInputStream:NULL outputStream:&outputStream_];
	
    // if we wanted, we could scheduled notifcations or other run loop
	// based reading of the input stream to get messages back from the
	// service we connected to
	    
    // < ADD CODE HERE : statusLabel to reflect if we connected or not. 
    //    if we could not get the output stream, we could not connect >    
	if ( outputStream_ != nil )
	{
		[outputStream_ open];
		statusLabel_.text = @"Connected to service.";
	}
	else
	{
		statusLabel_.text = @"Could not connect to service";
	}
}


#pragma mark -
#pragma mark Actions

- (IBAction)sendMessage:(id)sender
{
	if ( nil == outputStream_ )
	{
		statusLabel_.text = @"Failed to send message, not connected.";
		return;
	}
		
	// < ADD CODE HERE : Get the message from the view and write it out to the
	//  outputStream_. You can do a synchronous write >
    
    NSString* messageText = [[NSString alloc] initWithString:messageTextView_.text];    
	NSLog(@"in sendMessage: messageText = %@", messageText);
        
	const uint8_t* messageBuffer = (const uint8_t*)[messageText UTF8String];
    
    // add 1 to length to ensure null terminator is sent.  Ref Chris UW Moodle post
	NSUInteger length = [messageText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    [messageText release];
    
	[outputStream_ write:messageBuffer maxLength:length];
    // NOTE: After the user tapped the "Send Message" button, the UI was "freezing" here
    // because a firewall on the computer running DesktopService listener was blocking communication
    // out from the computer 
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self sendMessage:textField];
	return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	return YES;
}

@end
