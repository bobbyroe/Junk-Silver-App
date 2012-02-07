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
    cellHeightMults = [[NSMutableArray alloc] init];
    [self fetchCollectionData];
    [self generateDenominationList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];	
    collectionCells = [[NSMutableArray alloc] initWithCapacity:kNumRows];
    // [self initTable];
    
    
}
/*
- (void) initTable 
{
    NSMutableArray *currentCoins;
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CollectionItemCell" owner:self options:nil];
    CollectionItemCell *cell = nil;
    for (int i = 0; i < kNumRows; i++) {
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell =  (CollectionItemCell *)currentObject;
                break;
            }
        }
        
        if (i == 4) currentCoins = [NSArray arrayWithArray:nickels];
        if (i == 3) currentCoins = [NSArray arrayWithArray:dimes];
        if (i == 2) currentCoins = [NSArray arrayWithArray:quarters];
        if (i == 1) currentCoins = [NSArray arrayWithArray:halfDollars];
        if (i == 0) currentCoins = [NSArray arrayWithArray:dollars]; 
        
        if ([currentCoins count] > 0) {
            [cell initMe];

            [cell.denomLabel setText:[[denominationItems objectAtIndex:i] denominationName]];
            cell.numSubItems = [currentCoins count];
            // int myIndex = [[denominationItems objectAtIndex:i] denomIndex];
            // [cell.countLabel setTag:myIndex];
            
            for (int j = 0; j < [currentCoins count]; j++) {
                
                [[cell.nameLabels objectAtIndex:j] setText:[NSString stringWithFormat: @"%@", [[currentCoins objectAtIndex:j] name]]];
                [[cell.countFields objectAtIndex:j] setDelegate:self];
                
                int thisIndex = (i*10) + j;
                [[cell.countFields objectAtIndex:j] setTag:thisIndex];
            }

            // store the current denomination array size as a string
            NSString *curCellHeightMult = [NSString stringWithFormat:@"%i",[currentCoins count]];
            [cellHeightMults addObject:curCellHeightMult];
            
            [collectionCells addObject:cell];
        }
    } // end honking for loop
}
*/
#pragma mark - touch events
- (IBAction)doneButtonTouched
{
    [self animateCollectionViewTo:690];
}

- (void)doneButton:(id)sender {
	// roeLog(@"doneButton");
    // roeLog(@"Input: %@", textField.text);
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
    [self initializeValueLabels];
}

- (void) updateCollectionTotalValue {
    roeLog(@"Placeholder Method");
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
    /*
     NSMutableArray *currentCoins;
     int i = [indexPath row];
     static NSString *CellIdentifier = @"Cell";
     CollectionItemCell *cell = (CollectionItemCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     // BOOL weHaveSpotPrice = NO;
     // weHaveSpotPrice = (spotPrice > 0.0);
     
     // CollectionItemCell *cell = nil;
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
     if (i == 4) currentCoins = [NSArray arrayWithArray:nickels];
     if (i == 3) currentCoins = [NSArray arrayWithArray:dimes];
     if (i == 2) currentCoins = [NSArray arrayWithArray:quarters];
     if (i == 1) currentCoins = [NSArray arrayWithArray:halfDollars];
     if (i == 0) currentCoins = [NSArray arrayWithArray:dollars]; 
     
     // NSString *labelText;
     if ([currentCoins count] > 0) {
     [cell.denomLabel setText:[[denominationItems objectAtIndex:i] denominationName]]; // LIKE THIS!!!
     cell.numSubItems = [currentCoins count];
     // int myIndex = [[denominationItems objectAtIndex:i] denomIndex];
     // [cell.countLabel setTag:myIndex];
     
     for (int j = 0; j < [currentCoins count]; j++) {
     
     [[cell.nameLabels objectAtIndex:j] setText:[NSString stringWithFormat: @"%@", [[currentCoins objectAtIndex:j] name]]];
     [[cell.countFields objectAtIndex:j] setDelegate:self];
     
     // calculate coinValue
     NSString *ozSilverString = [NSString stringWithFormat: @"%@",[[currentCoins objectAtIndex:j] netWeightSilverInOz]];
     float ozSilver = [ozSilverString floatValue];
     
     NSString *estMarkupString = [NSString stringWithFormat: @"%@",[[currentCoins objectAtIndex:j] estimatedMarkupOverSpot]];
     float estMarkup = [estMarkupString floatValue];
     
     float myValue = (ozSilver * spotPrice) + estMarkup;
     
     // set value labels
     NSString *curCountString = [NSString stringWithFormat: @"%@", [[cell.countFields objectAtIndex:j] text]];
     int curCount = [curCountString floatValue];
     
     float totalValue = myValue * curCount;
     NSString *valueString = [NSString stringWithFormat:@"$%.2f",totalValue];
     [[cell.valueLabels objectAtIndex:j] setText:valueString];
     //
     
     
     int thisIndex = (i*10) + j;
     [[cell.countFields objectAtIndex:j] setTag:thisIndex];
     }   
     
     // store the current denomination array size as a string
     NSString *curCellHeightMult = [NSString stringWithFormat:@"%i",[currentCoins count]];
     [cellHeightMults addObject:curCellHeightMult];
     
     
     // set the top valueLabel
     //
     // loop thru the sub value labels ... add them up
     //
     NSString *valueString = [NSString stringWithFormat:@"$%.2f",spotPrice];
     [cell.valueLabel setText:valueString];
     } 
     [self updateCollectionTotalValue];
     
    */
    int i = [indexPath row];
    static NSString *CellIdentifier = @"Cell";
    CollectionItemCell *cell = (CollectionItemCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // BOOL weHaveSpotPrice = NO;
    // weHaveSpotPrice = (spotPrice > 0.0);
    
    // CollectionItemCell *cell = nil;
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
     
    [cell.denomLabel setText:[[denominationItems objectAtIndex:i] denominationName]]; // LIKE THIS!!!
    // cell.numSubItems = [currentCoins count];
    ///////////        
    // [self updateCollectionTotalValue];

    return cell;
}
- (void) initializeValueLabels
{
    // loop thru cells
    // for each calculate value
    //  & value for each sub value label
    int numCells = [collectionCells count];
    roeLog(@"numValues: %i", numCells);
    for (int v = 0; v < numCells; v++) {
        CollectionItemCell *curCell = (CollectionItemCell *)[collectionCells objectAtIndex:v];
        // float silverValue;
        // float markup;
        // float estimatedCoinValue;
        //
        // NSString *weightInOz = [NSString stringWithFormat: @"%@oz", [[currentCoins objectAtIndex:j] netWeightSilverInOz]];
        // CGFloat ozsSilver = [weightInOz floatValue];
        // NSString *estimatedMarkUp = [NSString stringWithFormat: @"%@oz", [[currentCoins objectAtIndex:j] estimatedMarkupOverSpot]];
        // CGFloat markUpFloat = [estimatedMarkUp floatValue];
        // CGFloat curVal = spotPrice * ozsSilver + markUpFloat;
        //
        // NSArray *curArray = [[collectionCells objectAtIndex:v] estCoinValues];
        int numValues = [[collectionCells objectAtIndex:v] numSubItems];
        roeLog(@"numValues: %i", numValues);
        for (int e = 0; e < numValues; e++) {
            roeLog(@"looping: %i", e);
            NSString *valueString = [NSString stringWithFormat:@"$%.2f",spotPrice];
            [[curCell.valueLabels objectAtIndex:e] setText:valueString];
        }
        [curCell.valueLabel setText:[NSString stringWithFormat:@"$%.2f",spotPrice]];
    }
    
    
}
#pragma mark -
- (void)generateDenominationList
{
    
    NSArray *coinNames = [NSArray arrayWithObjects:@"$1",@".50¢",@".25¢",@".10¢",@".05¢", nil]; // @"Other",
    int denominationIndices[6] = {100,50,25,10,5,0};
    
    denominationItems = [[NSMutableArray alloc] init];
    for (int d = 0; d < kNumRows; d++) {
        denominationItem *thisItem = [denominationItem alloc];
        
        //
        if (d == 4) thisItem.myCoins = [NSArray arrayWithArray:nickels];
        if (d == 3) thisItem.myCoins = [NSArray arrayWithArray:dimes];
        if (d == 2) thisItem.myCoins = [NSArray arrayWithArray:quarters];
        if (d == 1) thisItem.myCoins = [NSArray arrayWithArray:halfDollars];
        if (d == 0) thisItem.myCoins = [NSArray arrayWithArray:dollars];
        
        thisItem.numCoins = [thisItem.myCoins count];
        if (thisItem.numCoins > 0) {
            
            for (int j = 0; j < thisItem.numCoins; j++) {
                denominationItem *thisCoinItem = [denominationItem alloc];
                
                thisCoinItem.numCoins = 1;
                
                thisCoinItem.denominationName = [NSString stringWithFormat: @"%@", [[thisItem.myCoins objectAtIndex:j] name]];
                
                NSString *ozSilverString = [NSString stringWithFormat: @"%@",[[thisItem.myCoins objectAtIndex:j] netWeightSilverInOz]];
                thisCoinItem.silverInOz = [ozSilverString floatValue];
                
                NSString *estMarkupString = [NSString stringWithFormat: @"%@",[[thisItem.myCoins objectAtIndex:j] estimatedMarkupOverSpot]];
                thisCoinItem.estimatedMarkup = [estMarkupString floatValue];
             
                thisCoinItem.totalValue = 0;
                thisCoinItem.totalValueString = [NSString stringWithFormat:@"$%f",thisCoinItem.totalValue];
                thisCoinItem.denomIndex = denominationIndices[d];
                             
            }   
            
            thisItem.denominationName = [NSString stringWithFormat: @"%@", [coinNames objectAtIndex:d]];
            
            thisItem.denomIndex = denominationIndices[d];
        } 

        thisItem.denominationName = [NSString stringWithString:[coinNames objectAtIndex:d]];
        thisItem.totalValue = 0;
        thisItem.totalValueString =[NSString stringWithString:@"$x.00"];
        thisItem.denomIndex = denominationIndices[d];
        
        [denominationItems addObject:thisItem];
    }
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
    NSString *heightString = [cellHeightMults objectAtIndex:[indexPath row]];
    int multiplier = (int)[heightString floatValue] + 1;
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
