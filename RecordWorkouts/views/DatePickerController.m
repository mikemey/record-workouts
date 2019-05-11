#import "DatePickerController.h"
#import "../WRFormat.h"

@implementation DatePickerController {
    void (^_callbackHandler)(NSDate *date);
    UITextField *_field;
    DatePickerController *_instance;
}

- (id) init: (UITextField *)field
    toolbar: (UIToolbar *) toolbar
   callback: (void (^)(NSDate *)) callback; {
    self = [super init];
    _instance = self;
    _field = field;
    _callbackHandler = callback;
    _field.tintColor = [UIColor clearColor];
    [_field setInputAccessoryView:toolbar];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [_field setInputView:datePicker];
    [datePicker addTarget:_instance action:@selector(updateNewDate:) forControlEvents:UIControlEventValueChanged];
    return self;
}

- (void) updateNewDate: (UIDatePicker *) sender {
    [self setNewDate:sender.date];
}

- (void) setNewDate: (NSDate *) date {
    _field.text = [WRFormat formatDate:date];
    _callbackHandler(date);
}

@end
