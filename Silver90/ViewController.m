//
//  ViewController.m
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "CoinList.h"
#import "Coin.h"

@implementation ViewController

@synthesize waitSpinner;
@synthesize infoButton;

@synthesize coinViewPanel, loadingView;

@synthesize SLVSpotPrice, SLVSpotFetchDate;
@synthesize coinsList;
@synthesize nickels, dimes, quarters, halfDollars, dollars, others;

@synthesize spotLabel, dateLabel;
@synthesize collectionView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (BOOL)connected 
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}

- (void)viewDidLoad
{
    if(![self connected])
    {
        // not connected
        [self fetchOldSpotData];
    } else
    {
        // connected, do some internet stuff
        [self fetchSilverSpotPrice];
    }
    
    [self loadCoinsXML];
    [super viewDidLoad];
    [coinViewPanel initInit];
    
    coinViewPanel.viewCtrlr = self;

    /*
    // swipe detection ... Collection view
    UISwipeGestureRecognizer *upSwipeRecognizer = 
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self 
     action:@selector(upSwipeDetected:)];
    
    upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipeRecognizer];
    
    // swipe detection ... back to home screen
    UISwipeGestureRecognizer *downSwipeRecognizer = 
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self 
     action:@selector(downSwipeDetected:)];
    
    downSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:downSwipeRecognizer];
     */
     
}

- (void)viewDidUnload
{    
    button10 = nil;
    button25 = nil;
    button50 = nil;
    button100 = nil;
    [self setSpotLabel:nil];
    [self setDateLabel:nil];
    
    [self setWaitSpinner:nil];
    [self setInfoButton:nil];
    [self setCollectionView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait); //  UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - touch events

- (IBAction)handleInfoTouch
{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Junk Motherfucking Silver!" message:@"©2012 Roester Industries" delegate:nil cancelButtonTitle:@"Fuck Yeah!" otherButtonTitles:nil];
    [a show];
}

- (IBAction)handleTouchFrom:(UIButton *)buttonSender // from coin name buttons
{
    [self coinViewSlideTo:0 withButtonIndex:buttonSender.tag];
}
- (IBAction)handleCollectionTouch
{
    [collectionView animateCollectionViewTo:0];
}
/*
- (void)leftSwipeDetected:(UIGestureRecognizer *)sender
{
    //CGFloat vel = [sender velocity];
    float coinViewXPos = coinViewPanel.frame.origin.x;
    if (coinViewXPos < 1) { // coinView is in view
        [coinViewPanel nextCoin];
    } else { // coinView is hidden
        NSLog(@"<< swipe left");
    }
    // NSLog(@"swipe left >> %f",);
}
*/

#pragma mark - Animations!
- (void)coinViewSlideTo:(int)xPos withButtonIndex:(int)index
{ 
    self.waitSpinner.hidden = NO;
    // NSLog(@"%i Touched", index);
    coinViewPanel.coinIndex = index;
    coinViewPanel.spotPrice = [SLVSpotPrice floatValue];
    CGRect coinViewFrame = coinViewPanel.frame;
    coinViewFrame.origin.x = xPos;
    
    // prepare coinView
    if (index == 5) coinViewPanel.currentCoins = [NSArray arrayWithArray:nickels];
    if (index == 10) coinViewPanel.currentCoins = [NSArray arrayWithArray:dimes];
    if (index == 25) coinViewPanel.currentCoins = [NSArray arrayWithArray:quarters];
    if (index == 50) coinViewPanel.currentCoins = [NSArray arrayWithArray:halfDollars];
    if (index == 100) coinViewPanel.currentCoins = [NSArray arrayWithArray:dollars];  
    
    // Animate it!
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         coinViewPanel.frame = coinViewFrame;
                         
                     } completion:^(BOOL finished){
                         if (index != 0) [coinViewPanel goNGL3D];
                         self.waitSpinner.hidden = YES;
                     }];
}

- (void)fadeOutLoadingView
{
    [UIView animateWithDuration:0.3 delay:0.1 options: UIViewAnimationCurveLinear
                     animations:^{
                         loadingView.alpha = 0.0;
                     } completion:^(BOOL finished){
                         loadingView.hidden = YES;
                     }];
}
#pragma mark - Load / parse XML stuff

- (void)fetchSilverSpotPrice 
{
    // [xmlData release];
    xmlData = [[NSMutableData alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://www.monex.com/data/prices.dat"];
    
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [xmlData appendData:data];    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn 
{
    NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSArray *textLines = [xmlCheck componentsSeparatedByString:@"\n"];
    NSString *SLVSpotLine = [textLines objectAtIndex:(3)];
    SLVSpotPrice = [SLVSpotLine substringFromIndex:9];
    SLVSpotPrice = [SLVSpotPrice substringToIndex:5];    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    SLVSpotFetchDate = [dateFormatter stringFromDate:now];
    
    [self updateLabels];
    [self saveSpotData];
    
    connection = nil;
    xmlData = nil;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    connection = nil;
    xmlData = nil;
    
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", [error localizedDescription]];
    
    NSLog(@"Err: %@", errorString);
    [self fetchOldSpotData];
}

- (void)updateLabels 
{   
    spotLabel.text = [NSString stringWithFormat: @"$%@", SLVSpotPrice]; // currentSpot];
    [dateLabel setText:SLVSpotFetchDate];
    [collectionView setSpotValue:[SLVSpotPrice floatValue]]; // sent the spot price to the collection view
    
    // FADE OUT THE DEFAULT SPLASH SCREEN
    [self fadeOutLoadingView];
}

#pragma mark - Coins XML from bundle
- (void)loadCoinsXML
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"JunkCoins2" ofType:@"xml"];  
    NSData *coinData = [NSData dataWithContentsOfFile:filePath];  
    
    if (coinData) {
        [self parseCoinsXMLWithData:coinData];
        coinData = nil;
    }
}

- (void)parseCoinsXMLWithData:(NSData *)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    [parser setDelegate:self];
    
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:@"feed"]) {
        
        coinsList = [[CoinList alloc] init];
        
        [coinsList setParentParserDelegate:self];
        
        [parser setDelegate:coinsList];
        
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
    [self divideCoinListByDenomination];
    [collectionView divideCoinListByDenomination:[coinsList coins]];
}
- (void)divideCoinListByDenomination
{
    nickels = [[NSMutableArray alloc] init];
    dimes = [[NSMutableArray alloc] init];
    quarters = [[NSMutableArray alloc] init];
    halfDollars = [[NSMutableArray alloc] init];
    dollars = [[NSMutableArray alloc] init];
    
    // NSString *coinName = [NSString stringWithFormat: @"%@", [aCoin name]];
    for(int i = 0; i < [[coinsList coins] count]; i++){
        Coin *aCoin = [[coinsList coins] objectAtIndex:i];
        if ([aCoin.denominationIndex isEqualToString:@"5"]) [nickels addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"10"]) [dimes addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"25"]) [quarters addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"50"]) [halfDollars addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"100"]) [dollars addObject:aCoin];
    }
    // roeLog(@"%i, %i, %i, %i, %i",[nickels count], [dimes count], [quarters count], [halfDollars count], [dollars count]);
}
#pragma mark - save silver fetched silver spot price
- (NSString *)spotPriceArchivePath
{
    // App load/save directory: Sandbox/Documents/silver90.data
    return pathInDocumentDirectory(@"silver90.data");
}

- (BOOL)saveSpotData
{
    // save the spot price and date fetched ...
    NSArray *spotData = [NSArray arrayWithObjects:SLVSpotPrice, SLVSpotFetchDate, nil];
    return [NSKeyedArchiver archiveRootObject:spotData toFile:[self spotPriceArchivePath]];
}

- (void)fetchOldSpotData
{
    NSString *path = [self spotPriceArchivePath];
    NSArray *oldSpotData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    // roeLog(@"$%@, fetched:%@",[oldSpotData objectAtIndex:0],[oldSpotData objectAtIndex:1]);
    SLVSpotPrice = [oldSpotData objectAtIndex:0];
    SLVSpotFetchDate = [oldSpotData objectAtIndex:1];
    [self updateLabels];
}



@end
