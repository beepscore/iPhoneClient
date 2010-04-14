//
//  RootViewController.m
//  iPhoneClient
//
//	HW3_1
//
//  Copyright 2010 Chris Parrish

#import "RootViewController.h"
#import "ServiceDetailController.h"


@implementation RootViewController

// Ref Dalrymple Advanced Mac OS X Programming Ch 19 p 465
// Ref http://stackoverflow.com/questions/25746/whats-the-difference-between-a-string-constant-and-a-string-literal
NSString* const kServiceTypeString = @"_uwcelistener._tcp.";
NSString* const kSearchDomain = @"local.";
#define kTimeoutSeconds 5.0

#pragma mark properties


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
}


- (void)dealloc
{
	[services_ release], services_ = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark NSNetService

// < YOU NEED TO MAKE ALL THESE METHODS DO THE RIGHT THING >

- (void) startServiceSearch
{	
	NSLog(@"Started browsing for services: %@", browser_);
    
    // Ref http://stackoverflow.com/questions/166712/how-to-show-the-loading-indicator-in-the-top-status-bar
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    [browser_ searchForServicesOfType:kServiceTypeString inDomain:kSearchDomain];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser 
           didFindService:(NSNetService *)aNetService 
               moreComing:(BOOL)moreComing 
{
    NSLog(@"Adding new service");
    [services_ addObject:aNetService];
    
	[aNetService setDelegate:self];
	// timeout is in seconds
    [aNetService resolveWithTimeout:kTimeoutSeconds];
	
    if (!moreComing)
	{
        // update user interface
        [self.tableView reloadData];        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser 
         didRemoveService:(NSNetService *)aNetService 
               moreComing:(BOOL)moreComing 
{
    // Ref Dalrymple Advanced Mac OS X Programming Ch 19 p 468
    NSLog(@"Removing service");
    NSEnumerator *enumerator = [services_ objectEnumerator];
    NSNetService *currentNetService;
    
    // ????: Why doesn't Dalrymple just remove aNetService?
    // could aNetService not have been in services_?
    while (currentNetService = [enumerator nextObject]) {
        if ([[currentNetService name] isEqual:[aNetService name]] &&
            [[currentNetService type] isEqual:[aNetService type]] &&
            [[currentNetService domain] isEqual:[aNetService domain]]) {
            [services_ removeObject:currentNetService];
            break;
        }
    }
    
    if (!moreComing)
	{
        // update user interface
        [self.tableView reloadData];        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }	
}


- (void)netServiceWillResolve:(NSNetService *)sender
{
	NSLog(@"RESOLVING net service with name %@ and type %@", [sender name], [sender type]);
}


- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"RESOLVED net service with name %@ and type %@", [sender name], [sender type]);
	[self.tableView reloadData];
}


- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"DID NOT RESOLVE net service with name %@ and type %@", [sender name], [sender type]);
	NSLog(@"Error Dict:", [errorDict description]);
    
	// ????: should we do anything else?
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// SB moved comment from viewDidUnload
    // <ADD SOME CODE HERE : Create the service browser and start looking for services>
    
    // Ref Dalrymple Advanced Mac OS X Programming Ch 19 p 467
    browser_ = [[NSNetServiceBrowser alloc] init];
    [browser_ setDelegate:self];
    
    services_ = [[NSMutableArray alloc] init];
    
    [self startServiceSearch];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [services_ count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSNetService* service = [services_ objectAtIndex:indexPath.row];
	NSArray* addresses = [service addresses];
	
	if ([addresses count] == 0)
	{
		cell.textLabel.text = @"Could not resolve address";
	}
	else
	{
		cell.textLabel.text = [service hostName];
	}
	
	cell.detailTextLabel.text = [service name]; 
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSNetService* selectedService = [services_ objectAtIndex:indexPath.row];
	
	// <ADD SOME CODE HERE : 
	// if the selection was not resolved, try to resolve it again, but don't attempt
	// to bring up the details >
    
    if (nil == [selectedService addresses])
    {
        // timeout is in seconds
        [selectedService resolveWithTimeout:kTimeoutSeconds];
    } else
    {
        ServiceDetailController* detailController = [[ServiceDetailController alloc] initWithNibName:@"ServiceDetailController" bundle:nil];
        
        detailController.service = selectedService;
        [[self navigationController] pushViewController:detailController animated:YES];
        [detailController release];	
    }
}


@end

