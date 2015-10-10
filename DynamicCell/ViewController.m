//
//  ViewController.m
//  DynamicCell
//
//  Created by Maxim Shnirman on 6/30/15.
//  Copyright (c) 2015 Maxim Shnirman. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"

#define cell_min_height             30.0f
#define cell_text_width             272.0f
#define cell_spacing                2.0f
#define max_lines_in_inputview      5
#define min_lines_in_inputview      1
#define initial_inputview_height    30.0f

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
    NSMutableArray * heights;
    NSMutableArray * msgs;
    float rowHeight;
    
    float currentKeyboardHeight;
    BOOL isKeyboardVisible;
    
    CGRect previousRect;
    int inputLinesAmount;
    float initialHeightOrigin;
}
@property (strong, nonatomic) IBOutlet UIView *viewInput;
@property (strong, nonatomic) IBOutlet UITextView *txtfieldBar;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UILabel *lblHidden;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    heights = [[NSMutableArray alloc] init];
    msgs = [[NSMutableArray alloc] init];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;

    UITapGestureRecognizer *closeKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    [self.view addGestureRecognizer:closeKeyboardGesture];
    
    [self.lblHidden setNumberOfLines:0];
    [self.lblHidden setLineBreakMode:NSLineBreakByWordWrapping];
    [self.lblHidden setText:@"test"];
    [self.lblHidden sizeToFit];
    CGRect rect = CGRectMake(0, 0, cell_text_width, self.lblHidden.frame.size.height);
    [self.lblHidden setFrame:rect];
    rowHeight = self.lblHidden.frame.size.height;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    isKeyboardVisible = NO;
    self.txtfieldBar.delegate = self;
    UITextPosition* pos = self.txtfieldBar.endOfDocument;
    previousRect = [self.txtfieldBar caretRectForPosition:pos];
    initialHeightOrigin = previousRect.origin.y;
    inputLinesAmount = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - uitextview
- (void)textViewDidChange:(UITextView *)textView{
    UITextPosition* pos = self.txtfieldBar.endOfDocument;
    CGRect currentRect = [self.txtfieldBar caretRectForPosition:pos];
    
    if (currentRect.origin.y > previousRect.origin.y){
        if(inputLinesAmount < max_lines_in_inputview) {
            previousRect = currentRect;
            [self increaseInputView];
        }
        return;
    }
    
    if (currentRect.origin.y < previousRect.origin.y){
        if(inputLinesAmount > min_lines_in_inputview) {
            previousRect = currentRect;
            [self decreaseInputView];
        }
        return;
    }    
}

-(void) increaseInputView {
    ++inputLinesAmount;
    
    CGRect currentTextViewRect = self.txtfieldBar.frame;
    float deltaHeight = self.txtfieldBar.contentSize.height - currentTextViewRect.size.height;
    CGRect inputViewRect = self.viewInput.frame;
    inputViewRect.size.height += deltaHeight;
    inputViewRect.origin.y -= deltaHeight;
    [self.viewInput setFrame:inputViewRect];
    
    [self.txtfieldBar scrollRangeToVisible:NSMakeRange(0, 0)];
}

-(void) decreaseInputView {
    --inputLinesAmount;
    
    CGRect currentInputViewRect = self.txtfieldBar.frame;
    float deltaHeight = currentInputViewRect.size.height - self.txtfieldBar.contentSize.height;
    CGRect inputViewRect = self.viewInput.frame;
    inputViewRect.size.height -= deltaHeight;
    inputViewRect.origin.y += deltaHeight;
    [self.viewInput setFrame:inputViewRect];
}

#pragma mark - private
-(void) resetInputBar {
    CGRect rect = self.viewInput.frame;
    float removeDelta = rect.size.height - initial_inputview_height;
    rect.size.height = initial_inputview_height;
    rect.origin.y += removeDelta;
    
    [self.viewInput setFrame:rect];
    
    UITextPosition* pos = self.txtfieldBar.endOfDocument;
    previousRect = [self.txtfieldBar caretRectForPosition:pos];
    previousRect.origin.y = initialHeightOrigin;
    inputLinesAmount = 1;
}

-(float) setCellsHeight:(NSUInteger)index {
    CGRect rect = CGRectMake(0, 0, cell_text_width, self.lblHidden.frame.size.height);
    
    [self.lblHidden setFrame:rect];
    [self.lblHidden setText:msgs[index]];
    [self.lblHidden sizeToFit];
    
    int rows = ceil(self.lblHidden.frame.size.height / rowHeight);
    return (rows * rowHeight);
}

#pragma mark - Keyboard methods
- (void)keyboardFrameWillChange:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize currentSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    currentKeyboardHeight = currentSize.height;
    
    if(isKeyboardVisible)
        [self hideKeyboard];
    else
        [self showKeyboard];
}

-(void)showKeyboard {
    isKeyboardVisible = !isKeyboardVisible;
    
    CGRect rect = self.viewInput.frame;
    rect.origin.y -= currentKeyboardHeight;
    [self.viewInput setFrame:rect];
}

-(void)hideKeyboard {
    isKeyboardVisible = !isKeyboardVisible;
    
    CGRect rect = self.viewInput.frame;
    rect.origin.y += currentKeyboardHeight;
    [self.viewInput setFrame:rect];
}

#pragma mark - actions
- (IBAction)sendBtnClick:(id)sender {
    if(sender == self.btnSend && ![self.txtfieldBar.text isEqualToString:@""]) {
        [msgs addObject:self.txtfieldBar.text];
        self.txtfieldBar.text = @"";
        [self resetInputBar];
        [self.tableview reloadData];
    }
}

- (IBAction)onReset:(id)sender {
    [msgs removeAllObjects];
    [self.tableview reloadData];
}

#pragma mark -- Gesture Recognizer
- (void)closeKeyboard:(UITapGestureRecognizer *)recognizer {
    [self.txtfieldBar resignFirstResponder];
}

#pragma mark - datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    TableViewCell * cell = (TableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString * text = [msgs objectAtIndex:indexPath.row];
    cell.lblText.text = text;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return msgs.count;
}

#pragma mark - delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = [self setCellsHeight:indexPath.row];
    
    if(height < cell_min_height)
        return cell_min_height + cell_spacing;

    return height + cell_spacing;
}

@end
