//
//  Coin.m
//  Silver90
//
//  Created by Simon Williams on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CoinList.h"
#import "Coin.h"

@implementation CoinList

@synthesize parentParserDelegate;
@synthesize coins;

@synthesize title;
- (id)init
{
    self = [super init];
    
    if (self) {
        coins = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    // NSLog(@"\t%@ found a %@ element",self, elementName);
    if ([elementName isEqualToString:@"title"]) {
        currentString = [[NSMutableString alloc] init];
        title = currentString;
        
    } else if ([elementName isEqualToString:@"entry"]) {
        // When we find an item, create an instance of RSSItem
        Coin *aCoin = [[Coin alloc] init];
        
        // Set up its parent as ourselves so we can regain control of the parser
        [aCoin setParentParserDelegate:self];
        
        // Turn the parser to the RSSItem 
        [parser setDelegate:aCoin];
        
        // Add the item to our array and release our hold on it
        [coins addObject:aCoin];
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
    
    if ([elementName isEqualToString:@"feed"]) { // I THINK this means we're DONE parsing the XML
        [parser setDelegate:parentParserDelegate];
    } 
}

@end
