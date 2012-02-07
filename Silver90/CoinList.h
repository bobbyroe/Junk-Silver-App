//
//  Coin.h
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoinList : NSObject <NSXMLParserDelegate>
{
    NSMutableString *currentString;
}

@property (nonatomic, assign) id parentParserDelegate;
@property (nonatomic, strong) NSMutableArray *coins;

@property (nonatomic, strong) NSString *title;

@end
