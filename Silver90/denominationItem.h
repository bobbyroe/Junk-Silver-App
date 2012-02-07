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
@property (assign) NSString *denominationName;
@property (assign) CGFloat totalValue;
@property (assign) NSString *totalValueString;
@property (assign) int denomIndex;

@property (assign) float silverInOz;
@property (assign) float estimatedMarkup;
@property (strong,nonatomic) NSArray *myCoins;
// @property (assign) int numDifferentCoins;

@end
