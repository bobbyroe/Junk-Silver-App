//
//  Coin.h
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coin : NSObject <NSXMLParserDelegate>
{
    NSMutableString *currentString;
}

@property (nonatomic, assign) id parentParserDelegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *dates;
@property (nonatomic, strong) NSString *denominationIndex;
@property (nonatomic, strong) NSString *weightInGrams;
@property (nonatomic, strong) NSString *silverPercentage;
@property (nonatomic, strong) NSString *netWeightSilverInOz;
@property (nonatomic, strong) NSString *estimatedMarkupOverSpot;
@property (nonatomic, strong) NSString *coinTexture;

@property (assign) int *numCoins;
@end
