//
//  CoinInfoView.h
//  Silver90
//
//  Created by Simon Williams on 11/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class coinView;

@interface CoinInfoView : UIView
{
    coinView *myCoinView;
}
@property (assign) IBOutlet UILabel *weightInGrams;
@property (assign) IBOutlet UILabel *silverPercentage;
@property (assign) IBOutlet UILabel *netWeightSilverInOz;
@property (assign) IBOutlet UILabel *dates;

- (void)setUpGesturesWithParent:(coinView *)parentView;
- (void)upSwipeDetected:(UIGestureRecognizer *)sender;

@end
