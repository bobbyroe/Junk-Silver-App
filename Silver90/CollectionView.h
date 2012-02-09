//
//  CollectionView.h
//  Silver90
//
//  Created by Simon Williams on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "denominationItem.h"
#import "CollectionItemCell.h"

@interface CollectionView : UIView <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableDictionary *selectedIndexes;
    NSMutableArray *denominationItems;
    NSMutableArray *collectionCells;
    NSArray *coinCounts;
    
}
@property (strong, nonatomic) IBOutlet UILabel *value;
@property (strong, nonatomic) IBOutlet UITableView *collectionItems;
@property (strong, nonatomic) NSString *collectionValueText;
//
@property (strong, nonatomic) NSMutableArray *nickels;
@property (strong, nonatomic) NSMutableArray *dimes;
@property (strong, nonatomic) NSMutableArray *quarters;
@property (strong, nonatomic) NSMutableArray *halfDollars;
@property (strong, nonatomic) NSMutableArray *dollars;
@property (strong, nonatomic) NSMutableArray *others;
//
@property (assign) UITextField *activeTextField;
@property (assign) CGFloat spotPrice;

- (BOOL)saveCollectionData;
- (void)fetchCollectionData;

// - (void)addButtonToKeyboard;

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;
- (IBAction)doneButtonTouched;

- (void)animateCollectionViewTo:(int)yPos;

- (void)generateDenominationList;
- (void)divideCoinListByDenomination:(NSArray *)mainCoinArray;
- (int)cellHeightMult:(NSIndexPath *)indexPath;
- (void)setSpotValue:(CGFloat)theValue;

- (void)updateCollectionTotalValue;
@end