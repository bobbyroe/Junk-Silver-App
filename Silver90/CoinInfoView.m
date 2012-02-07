//
//  CoinInfoView.m
//  Silver90
//
//  Created by Simon Williams on 11/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CoinInfoView.h"
#import "coinView.h"

@implementation CoinInfoView

@synthesize weightInGrams;
@synthesize silverPercentage;
@synthesize netWeightSilverInOz;
@synthesize dates;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setUpGesturesWithParent:(coinView *)parentView
{
    // UP
    UISwipeGestureRecognizer *upSwipeRecognizer = 
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self 
     action:@selector(upSwipeDetected:)];
    
    upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:upSwipeRecognizer];
    
    // parent
    myCoinView = parentView;

}

- (void)upSwipeDetected:(UIGestureRecognizer *)sender
{
    [myCoinView animateCoinInfoViewOntoScreen:NO];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
