//
//  CollectionView.m
//  Silver90
//
//  Created by Simon Williams on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CollectionView.h"
#import "Coin.h"

@implementation CollectionView
#define kCellHeight 50.0
#define kNumRows 5
@synthesize collectionValueText;
@synthesize value;
@synthesize collectionItems;
@synthesize nickels, dimes, quarters, halfDollars, dollars, others;
@synthesize activeTextField;
@synthesize spotPrice;

- (void) awakeFromNib
{
    [super awakeFromNib];
    selectedIndexes = [[NSMutableDictionary alloc] init];
}

#pragma mark - touch events
- (IBAction)doneButtonTouched
{
    [self animateCollectionViewTo:690];
}

#pragma mark animation!
- (void)animateCollectionViewTo:(int)yPos {
    // Animate it!
    CGRect collectionViewFrame = self.frame;
    collectionViewFrame.origin.y = yPos;
    
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.frame = collectionViewFrame;
                         
                     } completion:^(BOOL finished){
                         [self endEditing:YES];
    }];
}

#pragma mark - save data
- (NSString *)collectionArchivePath
{
    // App load/save directory: Sandbox/Documents/collection.data
    return pathInDocumentDirectory(@"collection.data");
}

- (BOOL)saveCollectionData
{
    int updatedTextFieldIndex = activeTextField.tag;
    int curTotalCoins = 0;
    int curCoinValue = 0;
    float coinValueTotal;
    roeLog(@"saving data ... ");
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    int tempArrayIndex = 0;
    // update denominationItems array
    for (int y = 0; y < [denominationItems count]; y ++) {
        coinValueTotal = 0.0;
        denominationItem *thisItem = (denominationItem *)[denominationItems objectAtIndex:y];
        
        for (int z = 0; z < thisItem.numCoins; z ++) {
            denominationItem *childCoinItem = (denominationItem *)[thisItem.myCoins objectAtIndex:z];
            NSString *countFieldString = (NSString *)childCoinItem.totalCoinCountString;
            if (tempArrayIndex == updatedTextFieldIndex) { 
                countFieldString = activeTextField.text;
                childCoinItem.totalCoinCountString = countFieldString;
                childCoinItem.totalCoinCount = (int)[childCoinItem.totalCoinCountString floatValue];
                
            }
            // 
            curCoinValue = (spotPrice * childCoinItem.silverInOz) + childCoinItem.estimatedMarkup;
            childCoinItem.totalValue = curCoinValue * childCoinItem.totalCoinCount;
            coinValueTotal += childCoinItem.totalValue;
            //
            curTotalCoins += childCoinItem.totalCoinCount;
            
            [tempArray addObject:countFieldString];
            tempArrayIndex ++;
            
        }
        thisItem.totalValue = coinValueTotal;
        thisItem.totalCoinCount = curTotalCoins; 
    }
    
    NSArray *collectionData = [NSArray arrayWithArray:tempArray];
    return [NSKeyedArchiver archiveRootObject:collectionData toFile:[self collectionArchivePath]];

}
- (void)fetchCollectionData
{
    // does the file exist yet?
    NSString *path = [self collectionArchivePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
        NSArray *collectionData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if ([collectionData count] > 0) {
            coinCounts = [NSArray arrayWithArray:collectionData];
            roeLog(@"%i items, fetched",[coinCounts count]);
        }
    } 
    [self generateDenominationList];
}

- (void) setSpotValue:(CGFloat)theValue
{
    spotPrice = theValue;
    [self fetchCollectionData];
}

- (void) updateCollectionTotalValue {
    roeLog(@"updating totals ...");
    float curCoinValue = 0;
    float curTotalValue = 0.0;
    for (int i = 0; i < kNumRows; i ++) {
        denominationItem *thisItem = [denominationItems objectAtIndex:i];
        
        // loop the 'sub' coin values & sum them ...
        curCoinValue = thisItem.totalValue;
        curTotalValue += curCoinValue;
        // loop thru sub coins too
    }
    [value setText:[NSString stringWithFormat:@"$%.2f",curTotalValue]];
    [collectionItems reloadData];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    activeTextField = textField;
    // roeLog(@"editing: texField %i",textField.tag);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
    // roeLog(@"should return");
    BOOL saved = [self saveCollectionData];
    if (saved) [self updateCollectionTotalValue];
    else roeLog(@"NOT saved!");
    [textField resignFirstResponder];
	return YES;
}

#pragma mark - Tableview Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumRows;
}


/*****
 *  THIS METHOD IS CALLED AGAIN & AGAIN TO REUSE CELLS
 *
 *  so cell's state must be reset everytime
 ****/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // roeLog(@"reloading, %i",[indexPath row]);
    int i = [indexPath row];
    denominationItem *thisItem = (denominationItem *)[denominationItems objectAtIndex:i];
    // BOOL denominationItemExists = ([thisItem.myCoins count] != 0);
    
    static NSString *CellIdentifier = @"Cell";
    CollectionItemCell *cell = (CollectionItemCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CollectionItemCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell =  (CollectionItemCell *) currentObject;
                [cell initMe];
                /*
                if (denominationItemExists) {
                    if ([collectionCells containsObject:cell]) [collectionCells removeObjectAtIndex:i];
                    [collectionCells insertObject:cell atIndex:i];
                }
                */
                break;
			}
		}
    }
    
    
    [cell.denomLabel setText:[thisItem denominationName]]; // LIKE THIS!!!
    
    for (int h = 0; h < thisItem.numCoins; h ++) {
        denominationItem *childCoinItem = (denominationItem *)[thisItem.myCoins objectAtIndex:h];
        
        // set the text for some cell labels & fields
        [[cell.countFields objectAtIndex:h] setText:childCoinItem.totalCoinCountString]; 
        [[cell.countFields objectAtIndex:h] setDelegate:self];
        // Tag
        int thisIndex = childCoinItem.denomIndex;
        [[cell.countFields objectAtIndex:h] setTag:thisIndex];
        // roeLog(@"%@: i:%i",childCoinItem.denominationName, thisIndex);
        
        [[cell.nameLabels objectAtIndex:h] setText:[NSString stringWithFormat: @"%@", childCoinItem.denominationName]]; 
        
        [[cell.valueLabels objectAtIndex:h] setText:[NSString stringWithFormat: @"$%.2f", childCoinItem.totalValue]];        
    }
    
    [cell.countLabel setText:[NSString stringWithFormat:@"%i",thisItem.totalCoinCount]]; // LIKE THIS!!!
    [cell.valueLabel setText:[NSString stringWithFormat:@"$%.2f",thisItem.totalValue]]; // LIKE THIS!!!
    // roeLog(@"%@ %@",[cell.countLabel text],[cell.valueLabel text]);
    
    cell.numSubItems = thisItem.numCoins;
    
    return cell;
}

#pragma mark -
- (void)generateDenominationList
{
    // roeLog(@"generating denomination Items array");
    NSArray *coinNames = [NSArray arrayWithObjects:@"$1",@".50¢",@".25¢",@".10¢",@".05¢", nil]; // @"Other",
    int denominationIndices[6] = {100,50,25,10,5,0};
    
    int savedCoinIndex = 0;
    denominationItems = [[NSMutableArray alloc] init];
    NSMutableArray *currentCoins;
    for (int d = 0; d < kNumRows; d++) {
        denominationItem *thisItem = [denominationItem alloc];
        
        //
        if (d == 4) currentCoins = [NSMutableArray arrayWithArray:nickels];
        if (d == 3) currentCoins = [NSMutableArray arrayWithArray:dimes];
        if (d == 2) currentCoins = [NSMutableArray arrayWithArray:quarters];
        if (d == 1) currentCoins = [NSMutableArray arrayWithArray:halfDollars];
        if (d == 0) currentCoins = [NSMutableArray arrayWithArray:dollars];
        
        thisItem.numCoins = [currentCoins count];
        thisItem.myCoins = [NSMutableArray arrayWithCapacity:thisItem.numCoins];
        float curCoinValue = 0.0;
        float curCoinTotals = 0.0;
        int totalCoinCount;
        if (thisItem.numCoins > 0) {
            
            totalCoinCount = 0;
            
            for (int j = 0; j < thisItem.numCoins; j++) {
                denominationItem *thisCoinItem = [denominationItem alloc];
                
                NSString *myCoinCount = [NSString stringWithFormat:@"%@",[coinCounts objectAtIndex:savedCoinIndex]];
                thisCoinItem.totalCoinCountString = myCoinCount;
                thisCoinItem.totalCoinCount = (int)[thisCoinItem.totalCoinCountString floatValue];
                totalCoinCount += thisCoinItem.totalCoinCount;
                
                thisCoinItem.denominationName = [NSString stringWithFormat: @"%@", [[currentCoins objectAtIndex:j] name]];
                
                NSString *ozSilverString = [NSString stringWithFormat: @"%@",[[currentCoins objectAtIndex:j] netWeightSilverInOz]];
                thisCoinItem.silverInOz = [ozSilverString floatValue];
                
                NSString *estMarkupString = [NSString stringWithFormat: @"%@",[[currentCoins objectAtIndex:j] estimatedMarkupOverSpot]];
                thisCoinItem.estimatedMarkup = [estMarkupString floatValue];
             
                curCoinValue = (spotPrice * thisCoinItem.silverInOz) + thisCoinItem.estimatedMarkup;
                thisCoinItem.totalValue = curCoinValue * thisCoinItem.totalCoinCount;
                curCoinTotals += thisCoinItem.totalValue;
                
                thisCoinItem.denomIndex = savedCoinIndex; // denominationIndices[d]; // 
                savedCoinIndex++;
                [thisItem.myCoins addObject:thisCoinItem];
            }   
            
            thisItem.denominationName = [NSString stringWithFormat: @"%@", [coinNames objectAtIndex:d]];
            
            thisItem.denomIndex = denominationIndices[d];
            
            thisItem.totalCoinCount = totalCoinCount;
            thisItem.totalCoinCountString = [NSString stringWithFormat:@"%i",thisItem.totalCoinCount];
            // roeLog(@"%@: %i",thisItem.denominationName, totalCoinCount);
        } 

        thisItem.denominationName = [NSString stringWithString:[coinNames objectAtIndex:d]];
        
        thisItem.totalValue = curCoinTotals;
        // thisItem.totalValueString =[NSString stringWithString:@"$x.00"];
        thisItem.denomIndex = denominationIndices[d];
        
        [denominationItems addObject:thisItem];
    }
    [self updateCollectionTotalValue];
}

- (void)divideCoinListByDenomination:(NSArray *)mainCoinArray
{
    nickels = [[NSMutableArray alloc] init];
    dimes = [[NSMutableArray alloc] init];
    quarters = [[NSMutableArray alloc] init];
    halfDollars = [[NSMutableArray alloc] init];
    dollars = [[NSMutableArray alloc] init];
    
    // NSString *coinName = [NSString stringWithFormat: @"%@", [aCoin name]];
    for(int i = 0; i < [mainCoinArray count]; i++){
        Coin *aCoin = [mainCoinArray objectAtIndex:i];
        if ([aCoin.denominationIndex isEqualToString:@"5"]) [nickels addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"10"]) [dimes addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"25"]) [quarters addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"50"]) [halfDollars addObject:aCoin];
        if ([aCoin.denominationIndex isEqualToString:@"100"]) [dollars addObject:aCoin];
    }
}

#pragma mark - Tableview Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // roeLog(@"selected: %i",indexPath.row);
    
	// Deselect cell
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
	
	// Toggle 'selected' state
	BOOL isSelected = ![self cellIsSelected:indexPath]; // !
	
	// Store cell 'selected' state keyed on indexPath
	NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
	[selectedIndexes setObject:selectedIndex forKey:indexPath];	
        
	// This is where magic happens...
	[collectionItems beginUpdates];
	[collectionItems endUpdates]; 
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        
	// If our cell is selected, return double height
	if([self cellIsSelected:indexPath]) {
		return kCellHeight * [self cellHeightMult:indexPath]; // 4.0;
	}
    
	// Cell isn't selected so return single height
	return kCellHeight;
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	// Return whether the cell at the specified index path is selected or not
	NSNumber *selectedIndex = [selectedIndexes objectForKey:indexPath];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (int) cellHeightMult:(NSIndexPath *)indexPath {
    denominationItem *theItem = [denominationItems objectAtIndex:[indexPath row]];
    int multiplier = theItem.numCoins + 1;
    return multiplier;
}
#pragma mark Unused code
/*
 - (id)initWithFrame:(CGRect)frame
 {
 self = [super initWithFrame:frame];
 if (self) {
 // collectionValueText = [value text];
 
 [self fetchCollectionData];
 }
 return self;
 } */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
