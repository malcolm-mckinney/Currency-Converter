//
//  ConverterViewController.h
//  Currency Converter
//
//  Created by Malcolm McKinney on 3/30/13.
//  Copyright (c) 2013 Malcolm McKinney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConverterViewController :UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *input_box;

@property (weak, nonatomic) IBOutlet UILabel *output_box;

@property (weak, nonatomic) IBOutlet UIPickerView *picker_box;

@property (nonatomic, strong) NSArray *currencies;

@property (weak, nonatomic) IBOutlet UITextField *convert_from;

@property (weak, nonatomic) IBOutlet UITextField *convert_to;
@property (weak, nonatomic) IBOutlet UIToolbar *tool_bar;

@property (weak, nonatomic) IBOutlet UIImageView *from_flag;

@property (weak, nonatomic) IBOutlet UIImageView *to_flag;




-(IBAction) setPickerBoxAsFirstResponder:(id)sender;

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender;

- (IBAction)convert:(id)sender;

- (IBAction)digitPressed:(UIButton *)sender;

- (IBAction)digitDelete:(UIButton *)sender;

- (IBAction)addNegative:(UIButton *)sender;

- (IBAction)addDecimal:(id)sender;



@end
