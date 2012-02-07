//
//  ViewController.h
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "coinView.h"
@class CoinList;
#import "Reachability.h"
#import "CollectionView.h"

@interface ViewController : UIViewController <NSXMLParserDelegate>
{
    NSURLConnection *connection;
    NSMutableData *xmlData;
    NSArray *buttons;
    
    IBOutlet UIButton *button100, *button50, *button25, *button10;
    
    CoinList *coinsList;
}

@property (strong, nonatomic) IBOutlet coinView *coinViewPanel;
@property (strong, nonatomic) NSString *SLVSpotPrice; // SPOT PRICE
@property (strong, nonatomic) NSString *SLVSpotFetchDate;
@property (strong, nonatomic) CoinList *coinsList;

@property (strong, nonatomic) NSMutableArray *nickels;
@property (strong, nonatomic) NSMutableArray *dimes;
@property (strong, nonatomic) NSMutableArray *quarters;
@property (strong, nonatomic) NSMutableArray *halfDollars;
@property (strong, nonatomic) NSMutableArray *dollars;
@property (strong, nonatomic) NSMutableArray *others;

@property (strong, nonatomic) IBOutlet UILabel *spotLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitSpinner;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIImageView *loadingView;
@property (strong, nonatomic) IBOutlet CollectionView *collectionView;

- (void)fetchSilverSpotPrice;

- (IBAction)handleInfoTouch;
// - (IBAction)handleTouchFrom:(UIButton *)buttonSender; // from coin name buttons
- (IBAction)handleCollectionTouch;

// - (void)leftSwipeDetected:(UIGestureRecognizer *)sender; // NEXT coin

- (void)coinViewSlideTo:(int)xPos withButtonIndex:(int)index;

- (void)loadCoinsXML;
- (void)parseCoinsXMLWithData:(NSData *)data;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)divideCoinListByDenomination;

- (NSString *)spotPriceArchivePath;
- (BOOL)saveSpotData;
- (void)fetchOldSpotData;
- (BOOL)connected;
- (void)updateLabels;
- (void)fadeOutLoadingView;

@end
