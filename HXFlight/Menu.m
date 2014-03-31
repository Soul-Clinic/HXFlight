//
//  Menu.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/23/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "Menu.h"

@interface Menu ()

@end

@implementation Menu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)finishedDoingWhatever:(UIStoryboardSegue *)sender
{
    NSLog(@"What ever %@ %@  %@", sender.identifier, sender.sourceViewController, sender.destinationViewController);
}
- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end


@implementation NSArray (ForDebuging)

- (void)_forgetDependentConstraint:(id)nothing
{
    NSLog(@"What the hell?");
}

@end