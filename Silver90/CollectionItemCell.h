//
//  CollectionItemCell.h
//  JunkSilver
//
//  Created by Simon Williams on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
// @class CollectionView;

@interface CollectionItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UILabel *denomLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UIButton *expandButton;
//
@property (strong, nonatomic) IBOutlet UITextField *countField1;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel1;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel1;
@property (assign) NSString *estCoinValue1;
@property (assign) NSString *ozSilver1;
@property (assign) NSString *estMarkup1;

@property (strong, nonatomic) IBOutlet UITextField *countField2;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel2;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel2;
@property (assign) NSString *estCoinValue2;
@property (assign) NSString *ozSilver2;
@property (assign) NSString *estMarkup2;

@property (strong, nonatomic) IBOutlet UITextField *countField3;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel3;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel3;
@property (assign) NSString *estCoinValue3;
@property (assign) NSString *ozSilver3;
@property (assign) NSString *estMarkup3;

@property (strong, nonatomic) IBOutlet UITextField *countField4;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel4;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel4;
@property (assign) NSString *estCoinValue4;
@property (assign) NSString *ozSilver4;
@property (assign) NSString *estMarkup4;

@property (strong, nonatomic) IBOutlet UITextField *countField5;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel5;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel5;
@property (assign) NSString *estCoinValue5;
@property (assign) NSString *ozSilver5;
@property (assign) NSString *estMarkup5;

@property (assign) int numSubItems;
@property (strong, nonatomic) NSArray *countFields;
@property (strong, nonatomic) NSArray *valueLabels;
@property (strong, nonatomic) NSArray *nameLabels;
@property (strong, nonatomic) NSArray *estCoinValues;
@property (strong, nonatomic) NSArray *ozSilverArray;
@property (strong, nonatomic) NSArray *estMarkupArray;

- (void) initMe;
// @property (strong, nonatomic) CollectionView *collectionView;

// - (IBAction)expandButtonTouched:(UIButton *)buttonSender;

@end
