//
//  ConverterViewController.m
//  Currency Converter
//
//  Created by Malcolm McKinney on 3/30/13.
//  Copyright (c) 2013 Malcolm McKinney. All rights reserved.
//

#import "ConverterViewController.h"

//The number of digis a user can enter
#define LIMIT 9
#define NUM_COMPONENTS 1
#define NUM_CURRENCIES 8

//The currency codes used
#define USD 0
#define EUR 1
#define JPY 2
#define GBP 3
#define CHF 4
#define CAD 5
#define AUD 6
#define HKD 7



@interface ConverterViewController()

//A value to check if a button has been pressed since the last conversion
@property (nonatomic) BOOL button_pressed;

//A flag to check if the input has been negated
@property (nonatomic) BOOL isNegative;

//A flag to prevent multiple decimals from being added
@property (nonatomic) BOOL hasDecimal;

//The row of the array that has been selected
@property (nonatomic) int to_selected_row;
@property (nonatomic) int from_selected_row;

//A flag that checks if the text field has been touched
@property (nonatomic) BOOL convert_to_touched;


@property (nonatomic) float** matrix;



@end


@implementation ConverterViewController

@synthesize input_box, output_box, picker_box, currencies, convert_from, convert_to, tool_bar, to_flag, from_flag;


//Is called when user presses the convert button 
- (IBAction)convert:(id)sender {
   
    NSNumberFormatter *formatter;
    NSNumber *num;
    int row = self.from_selected_row;
    int column = self.to_selected_row;
    
    //Checks if user clicked on both text boxes before converting
    if (self.to_flag.image != nil && self.from_flag.image != nil) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: [self getLocale: self.to_selected_row]];
        
        
    float value =[[input_box text] floatValue];
    value *= self.matrix[row][column];
    num = [NSNumber numberWithFloat: value];
        
    formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:locale];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
      
        [output_box setText:[formatter stringFromNumber:num]];
    }
}

//Appends the name of the button to the input string
- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    
    NSString *str = self.input_box.text;
    if ([str length] < LIMIT) {
        
        if (self.button_pressed) {
            str = [str stringByAppendingString:digit];
    }
    else {
        if (![digit isEqualToString:@"0"]) {
            if (self.isNegative) {
                str = [@"-" stringByAppendingString:digit];
            }
            else {
                str = digit;
            }
            self.button_pressed = YES;
        }
    }
    
    self.input_box.text = str;
    }
    
}


//Removes the last character from the input string
- (IBAction)digitDelete:(UIButton *)sender {
    NSString *str = self.input_box.text;
    BOOL neg_situation = ([str length] == 2) && (self.isNegative);
    NSString *decimal_check = [str substringFromIndex: [str length] - 1];
    
    if ( ([str length] > 1) &&  !neg_situation) {
        str = [str substringToIndex:[str length] - 1];
        
    } else {
        if (neg_situation) {
            str = @"-0";
        }
        else {
             str = @"0";
             self.isNegative = NO;
            
        }
        self.button_pressed = NO;        
    }
    
    if ([decimal_check isEqualToString:@"."]){
        self.hasDecimal = NO;
        
        if ([str isEqualToString: @"0"] || ([str isEqualToString: @"-0"])) {
            self.button_pressed = NO;
        }
    }
    
    self.input_box.text = str;

}

//Appends a negative to the input string
- (IBAction)addNegative:(UIButton *)sender {
    NSString *str = self.input_box.text;    
    
    if (self.isNegative) {
        self.input_box.text = [str substringFromIndex:1];
        self.isNegative = NO;
    }
    
    else {
        if ([str length] < (LIMIT + 1)) {
            self.input_box.text = [@"-" stringByAppendingString:str];
            self.isNegative = YES;
        }
    }
    
}

//Appends a decimal to the input string if there is not one
- (IBAction)addDecimal:(id)sender {
    NSString *str = self.input_box.text;
    if (!self.hasDecimal && ([str length] < LIMIT) ) {
        str = [str stringByAppendingString:@"."];
        self.hasDecimal = YES;
        self.button_pressed = YES;
    }
    self.input_box.text = str;
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return NUM_COMPONENTS;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.currencies count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.picker_box.delegate = self;
    self.picker_box.dataSource = self;
    [self.view addSubview:self.picker_box];
    [self.view addSubview:self.tool_bar];
    self.convert_to.inputView = self.picker_box;
    self.convert_from.inputView = self.picker_box;
    self.currencies = [[NSArray alloc] initWithObjects:@"US Dollar (USD)", @"Euro (EUR)", @"Japanese Yen (JPY)", @"British Pound (GBP)", @"Swiss Franc (CHF)", @"Canadian Dollar (CAD)", @"Australian Dollar (AUD)", @"Hong Kong Dollar (HKD)", nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"coin.jpg"]];
    self.matrix = (float**)malloc(sizeof(float*)*NUM_CURRENCIES);
    if (self.matrix == nil) {
        return;
    }
    for (int i = 0; i < NUM_CURRENCIES; i++) {
        
        self.matrix[i] = (float*)malloc(sizeof(float) * NUM_CURRENCIES);
        
        if (self.matrix[i] == nil) {
            for (int k = (i - 1); k >= 0; k--) {
                free(self.matrix[k]);
            }
            free(self.matrix);
            return;
        }
        
        for (int j = 0; j< NUM_CURRENCIES; j++) {
            self.matrix[i][j] = 0;
        }
    }
    
    self.to_selected_row = 0;
    self.from_selected_row = 0;
    [self initMatrix];
    [self fillMatrix];
}

//Fills in values from rates.txt
-(void)initMatrix {

    NSArray *rows;
    NSArray *columns;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"rates"
                                                     ofType:@"txt"];
    rows = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < NUM_CURRENCIES; i++) {
        columns = [rows[i] componentsSeparatedByString:@" "];
        for (int j = 0; j < NUM_CURRENCIES; j++) {
           self.matrix[i][j] = [[columns[j] stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]] floatValue];
        }
    }
}

//Fills in values from getRate function
-(void)fillMatrix {
    
    for (int from = 0; from < NUM_CURRENCIES; from++) {
        for (int to = 0; to < NUM_CURRENCIES; to++) {
            [self getRate: from: to];
        }
    }
}

//Pings Google's currency calculator to get more up to date rates
-(void) getRate: (int) from : (int) to {
   
    if ((from < 0 || from > NUM_CURRENCIES) || (to < 0) || (to > NUM_CURRENCIES)) {
        return;
    }
    
    NSString *curr_from = [[self getCode:from] stringByAppendingString:
    @"=?" ];
    NSString *curr_to = [curr_from stringByAppendingString : [self getCode:to]];
    NSString *url_str = [@"http://www.google.com/ig/calculator?hl=en&q=1"stringByAppendingString: curr_to];
    
    NSURL *url = [NSURL URLWithString:url_str];
    if (url == nil) {
        return;
    }
    NSData *data = [NSData dataWithContentsOfURL: url];
    if (data == nil) {
        return;
    }
    NSString *str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
    int index = [self indexOf:str:YES];
    NSString *sub = [str substringFromIndex:index];
    index = [self indexOf:sub:NO];
    self.matrix[from][to] = [[sub substringToIndex:index] floatValue];

}

//Returns the string that repesents the country code
-(NSString *)getCode: (int)code {
    
    switch(code) {
        case USD: return @"USD";
        case EUR: return @"EUR";
        case JPY: return @"JPY";
        case GBP: return @"GBP";
        case CHF: return @"CHF";
        case CAD: return @"CAD";
        case AUD: return @"AUD";
        case HKD: return @"HKD";
        default : return @"NULL";
    }
    return @"NULL";
}

//Returns the string that represents the country's locale
-(NSString *)getLocale: (int)locale {
    switch(locale) {
        case USD: return @"en_US";
        case EUR: return @"de_DE";
        case JPY: return @"ja_JP";
        case GBP: return @"en_GB";
        case CHF: return @"sv_SE";
        case CAD: return @"en_CA";
        case AUD: return @"en_AU";
        case HKD: return @"zh_HK";
        default : return @"NULL";
    }
    return @"NULL";
}

//Used to find "rhs" in the JSON response and to get the float from the string
-(int)indexOf: (NSString *)str : (BOOL)findRHS  {
    char a, b, c;
    
    if (findRHS) {
        for (int i=0; i<[str length] - 2; i++) {
            a = [str characterAtIndex:i];
            b = [str characterAtIndex:i + 1];
            c = [str characterAtIndex:i + 2];
            if ((a == 'r') && (b == 'h') && (c == 's')) {
                return i + 6;
            }
        }
        return -1;
    }
    for (int i= 0; i < [str length]; i++) {
        a = [str characterAtIndex:i];
        if (a == ' ') {
            return i;
        }
    }
    return -1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.convert_to_touched) {
        self.to_selected_row = row;
    } else {
        self.from_selected_row = row;
    }
    
}

//Makes the picker box appear instead of the keyboard
-(IBAction) setPickerBoxAsFirstResponder:(id)sender {
    [self.view addSubview:self.picker_box];
    [self.view addSubview:self.tool_bar];
    
    self.picker_box.hidden = NO;
    self.tool_bar.hidden = NO;
    
    if (sender == self.convert_to) {
        self.convert_to_touched = YES;
        convert_to.inputAccessoryView = self.tool_bar;
    } else {
       convert_from.inputAccessoryView = self.tool_bar;
    }
    
    [sender becomeFirstResponder];
    
}

//Draws the selected flag above the textfield pressed
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    
    UIImage *newImage;
    NSString *str;
    
    if (self.convert_to_touched) {
        [self.convert_to resignFirstResponder];
        self.convert_to.text = [self getCode: self.to_selected_row];
        str = [[self getCode: self.to_selected_row] stringByAppendingString: @".png"];
        newImage = [UIImage imageNamed:str];
        [to_flag setImage:newImage];
    
    } else {
        [self.convert_from resignFirstResponder];
        self.convert_from.text = [self getCode: self.from_selected_row];
        str = [[self getCode: self.from_selected_row] stringByAppendingString: @".png"];
        newImage = [UIImage imageNamed:str];
        [from_flag setImage:newImage];
    }
    
    self.convert_to_touched = NO;
    self.picker_box.hidden = YES;
    self.tool_bar.hidden = YES;
    [self.picker_box removeFromSuperview];
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{return [self.currencies objectAtIndex:row];}

@end
