//
//  Coin.m
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Coin.h"

@implementation Coin

@synthesize parentParserDelegate;

@synthesize name, dates, denominationIndex, weightInGrams, silverPercentage, netWeightSilverInOz, estimatedMarkupOverSpot, coinTexture;
@synthesize numCoins;

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    // NSLog(@"found %@ : %@ , %@", elementName, qName, attributeDict);
    if ([elementName isEqual:@"name"]) {
        currentString = [[NSMutableString alloc] init];
        name = currentString;    
        
    } else if ([elementName isEqualToString:@"dates"]) {
        currentString = [[NSMutableString alloc] init];
        dates = currentString;
        
    } else if ([elementName isEqualToString:@"denominationIndex"]) {
        currentString = [[NSMutableString alloc] init];
        denominationIndex = currentString;
        
    } else if ([elementName isEqualToString:@"weightInGrams"]) {
        currentString = [[NSMutableString alloc] init];
        weightInGrams = currentString;
        
    } else if ([elementName isEqualToString:@"percentageSilver"]) {
        currentString = [[NSMutableString alloc] init];
        silverPercentage = currentString;
        
    } else if ([elementName isEqualToString:@"netWeightSilverInOz"]) {
        currentString = [[NSMutableString alloc] init];
        netWeightSilverInOz = currentString;
        
    } else if ([elementName isEqualToString:@"estimatedMarkupOverSpot"]) {
        currentString = [[NSMutableString alloc] init];
        estimatedMarkupOverSpot = currentString;
        
    } else if ([elementName isEqualToString:@"coinTexture"]) {
        currentString = [[NSMutableString alloc] init];
        coinTexture = currentString;
    }  
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    [currentString appendString:str];
}

- (void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    currentString = nil;
    
    if ([elementName isEqualToString:@"entry"]) {
        [parser setDelegate:parentParserDelegate];
    } 
}

@end
