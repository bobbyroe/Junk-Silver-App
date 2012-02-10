//
//  denominationItem.h
//  JunkSilver
//
//  Created by Simon Williams on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface denominationItem : NSObject

@property (assign) int numCoins;
@property (strong,nonatomic) NSString *totalCoinCountString;
@property (strong,nonatomic) NSString *denominationName;
@property (assign) CGFloat totalValue;
@property (assign) int denomIndex;
@property (assign) float silverInOz;
@property (assign) float estimatedMarkup;
@property (assign) int totalCoinCount;
@property (strong,nonatomic) NSMutableArray *myCoins;

// @property (assign) NSString *totalValueString;
// @property (assign) int numDifferentCoins;

@end
