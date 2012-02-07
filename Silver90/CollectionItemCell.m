//
//  CollectionItemCell.m
//  JunkSilver
//
//  Created by Simon Williams on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CollectionItemCell.h"
// @class CollectionView;

@implementation CollectionItemCell
@synthesize countLabel, denomLabel, valueLabel, expandButton; // , collectionView;

@synthesize countField1, nameLabel1, valueLabel1, countField2, nameLabel2, valueLabel2;
@synthesize countField3, nameLabel3, valueLabel3, countField4, nameLabel4, valueLabel4;
@synthesize countField5, nameLabel5, valueLabel5;
@synthesize estCoinValue1, estCoinValue2, estCoinValue3, estCoinValue4, estCoinValue5;
@synthesize valueLabels, countFields, nameLabels, estCoinValues, ozSilverArray, estMarkupArray;

@synthesize ozSilver1, ozSilver2, ozSilver3, ozSilver4, ozSilver5;
@synthesize estMarkup1, estMarkup2, estMarkup3, estMarkup4, estMarkup5;

@synthesize numSubItems;
/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
} 
 */

- (void) initMe {
    // roeLog(@"INTI");
    numSubItems = 0;
    valueLabels = [NSArray arrayWithObjects:valueLabel1,valueLabel2,valueLabel3,valueLabel4,valueLabel5, nil];
    countFields = [NSArray arrayWithObjects:countField1,countField2,countField3,countField4,countField5, nil];
    nameLabels = [NSArray arrayWithObjects:nameLabel1,nameLabel2,nameLabel3,nameLabel4,nameLabel5,nil];
    estCoinValues = [NSArray arrayWithObjects:estCoinValue1, estCoinValue2, estCoinValue3, estCoinValue4, estCoinValue5, nil];
    
    ozSilverArray = [NSArray arrayWithObjects:ozSilver1, ozSilver2, ozSilver3, ozSilver4, ozSilver5, nil];
    estMarkupArray = [NSArray arrayWithObjects:estMarkup1, estMarkup2, estMarkup3, estMarkup4, estMarkup5, nil];
    
}
#pragma - touch handler
/*
- (IBAction)expandButtonTouched:(UIButton *)button
{
    roeLog(@"ilugwdfhjnbsdvadfg: %i", numSubViews);
    // [collectionView expandButtonTouched];
    
    // [collectionView getForwardedTouch: button];
}
*/

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    // roeLog(@"selected: %@",(selected ? @"YES" : @"NO"));
    expandButton.hidden = selected;
}
*/

@end
