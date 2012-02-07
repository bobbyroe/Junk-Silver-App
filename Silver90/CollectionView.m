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
    [self fetchCollectionData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];	
    collectionCells = [[NSMutableArray alloc] initWithCapacity:kNumRows];
}

#pragma mark - touch events

- (IBAction)doneButtonTouched
{
    [self animateCollectionViewTo:690];
}

- (void)doneButton:(id)sender {
    [self updateLabels:activeTextField.tag];
    [activeTextField resignFirstResponder];
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
    collectionValueText = [value text];
    NSArray *collectionData = [NSArray arrayWithObjects:collectionValueText, nil];
    return [NSKeyedArchiver archiveRootObject:collectionData toFile:[self collectionArchivePath]];
}

- (void)fetchCollectionData
{
    // does the file exist yet?
    NSString *path = [self collectionArchivePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
        NSArray *collectionData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        // roeLog(@"$%@, fetched:%@",[oldSpotData objectAtIndex:0],[oldSpotData objectAtIndex:1]);
        NSString *collectionValue = [collectionData objectAtIndex:0];
        [value setText:collectionValue];

    } 
}

- (void) updateLabels:(int)denomIndex {

    int cellIndex = floor(denomIndex *0.1); // get the collectionCell index
    CollectionItemCell *curCell = (CollectionItemCell *)[collectionCells objectAtIndex:cellIndex];
    // roeLog(@"%@: c: %i, v: %i",[curCell.denomLabel text],[curCell.countFields count],[curCell.valueLabels count]);
    
    
    // loop through the TextFields for this cell and sum them
    int curTotal = 0;
    for (int i = 0; i < [curCell.countFields count]; i++ ) {
        UITextField *thisField = [curCell.countFields objectAtIndex:i];
        NSString *countString = thisField.text;
        int countValue = (int)[countString floatValue];
        
        // also calculate the value and assign to all value labels
        // [[curCell.valueLabels objectAtIndex:i] setText:@"$0.00"];
        
        
        curTotal += countValue;
    }
    // assign this value to the cell's total countlabel
    NSString *totalCount = [NSString stringWithFormat:@"%i",curTotal];
    [curCell.countLabel setText:totalCount];
    //roeLog(@"(%i) total:%i",[curCell.countFields count],curTotal);
}

- (void) setSpotValue:(CGFloat)theValue
{
    spotPrice = theValue;
    [self generateDenominationList];
}

- (void) updateCollectionTotalValue {
    roeLog(@"Placeholder Method");
        
    float curCoinValue = 0;
    float curTotalValue = 0.0;
    for (int i = 0; i < kNumRows; i ++) {
        denominationItem *thisItem = [denominationItems objectAtIndex:i];
        
        // loop the 'sub' coin values & sum them ...
        curCoinValue = thisItem.totalValue;
        curTotalValue += curCoinValue;
    }
    [value setText:[NSString stringWithFormat:@"$%.2f",curTotalValue]];
    [collectionItems reloadData];
}


#pragma mark - UITextFieldDelegate
- (void)keyboardDidShow:(NSNotification *)note {
    [self addButtonToKeyboard];
}

- (void)addButtonToKeyboard {
	// create custom button
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(0, 163, 106, 53);
	doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"DoneUp3.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"DoneDown3.png"] forState:UIControlStateHighlighted];
	
	[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
	// locate keyboard view
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboard;
	for(int i=0; i<[tempWindow.subviews count]; i++) {
		keyboard = [tempWindow.subviews objectAtIndex:i];
		// keyboard found, add the button
        if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
            [keyboard addSubview:doneButton];
		
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    activeTextField = textField;
    // roeLog(@"{%i}",textField.tag);
    return YES;
}
/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
    
    [self updateLabels:textField.tag];
    // [self saveCollectionData];
	return YES;
}
*/

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
    
    int i = [indexPath row];
    static NSString *CellIdentifier = @"Cell";
    CollectionItemCell *cell = (CollectionItemCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CollectionItemCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell =  (CollectionItemCell *) currentObject;
                [cell initMe];
                if (![collectionCells containsObject:cell]) { // the cell is not yet in the array
                    [collectionCells addObject:cell];
                }
                break;
			}
		}
    }
    denominationItem *thisItem = [denominationItems objectAtIndex:i];
    
    [cell.denomLabel setText:[thisItem denominationName]]; // LIKE THIS!!!
    
    int curTotalCoins = 0;
    float curCoinValue = 0;
    float curTotalValue = 0.0;
    for (int h = 0; h < thisItem.numCoins; h ++) {
        denominationItem *childCoinItem = (denominationItem *)[thisItem.myCoins objectAtIndex:h];
        
        // set the text for some cell labels
        [[cell.countFields objectAtIndex:h] setDelegate:self];
        [[cell.nameLabels objectAtIndex:h] setText:[NSString stringWithFormat: @"%@", childCoinItem.denominationName]]; /// ***
        
        // loop thru the 'sub' coins numbers & sum them
        curTotalCoins += childCoinItem.numCoins;
        
        // loop the 'sub' coin values & sum them ...
        curCoinValue = (spotPrice * childCoinItem.silverInOz) + childCoinItem.estimatedMarkup;
        curTotalValue += curCoinValue;
        
        [[cell.valueLabels objectAtIndex:h] setText:[NSString stringWithFormat: @"$%.2f", curCoinValue]];
    }
    [cell.countLabel setText:[NSString stringWithFormat:@"%i",curTotalCoins]]; // LIKE THIS!!!
    [cell.valueLabel setText:[NSString stringWithFormat:@"$%.2f",curTotalValue]]; // LIKE THIS!!!
    
    return cell;
}

#pragma mark -
- (void)generateDenominationList
{
    NSArray *coinNames = [NSArray arrayWithObjects:@"$1",@".50¢",@".25¢",@".10¢",@".05¢", nil]; // @"Other",
    int denominationIndices[6] = {100,50,25,10,5,0};
    
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
        if (thisItem.numCoins > 0) {
            
            for (int j = 0; j < thisItem.numCoins; j++) {
                denominationItem *thisCoinItem = [denominationItem alloc];
                
                thisCoinItem.numCoins = 1;
                
                thisCoinItem.denominationName = [NSString stringWithFormat: @"%@", [[currentCoins objectAtIndex:j] name]];
                
                NSString *ozSilverString = [NSString stringWithFormat: @"%@",[[currentCoins objectAtIndex:j] netWeightSilverInOz]];
                thisCoinItem.silverInOz = [ozSilverString floatValue];
                
                NSString *estMarkupString = [NSString stringWithFormat: @"%@",[[currentCoins objectAtIndex:j] estimatedMarkupOverSpot]];
                thisCoinItem.estimatedMarkup = [estMarkupString floatValue];
             
                curCoinValue = (spotPrice * thisCoinItem.silverInOz) + thisCoinItem.estimatedMarkup;
                thisCoinItem.totalValue = curCoinValue * thisCoinItem.numCoins;
                curCoinTotals += thisCoinItem.totalValue;
                
                // thisCoinItem.totalValueString = [NSString stringWithFormat:@"$%f",thisCoinItem.totalValue];
                thisCoinItem.denomIndex = denominationIndices[d];
                [thisItem.myCoins addObject:thisCoinItem];
            }   
            
            thisItem.denominationName = [NSString stringWithFormat: @"%@", [coinNames objectAtIndex:d]];
            
            thisItem.denomIndex = denominationIndices[d];
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
    // roeLog(@": %@",indexPath);
    
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
