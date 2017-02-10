

#import "WelcomeViewController.h"
#import "emsRegistrationVC.h"
#import "ScadaddlePopup.h"
#import "emsScadProgress.h"
@interface WelcomeViewController ()
{
ScadaddlePopup *popup;
    int currentIndex;
     emsScadProgress * subView;
}
@end

@implementation WelcomeViewController
@synthesize navButton;

-(void)progress{
    subView = [[emsScadProgress alloc] initWithFrame:self.view.frame screenView:self.view andSize:CGSizeMake(320, 580)];
    [self.view addSubview:subView];
    subView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 1;
    }];
}

-(void)stopSubview{
    
    [UIView animateWithDuration:0.5 animations:^{
        subView.alpha = 0;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
        subView = nil;
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Create the data model
    _pageTitles = @[@"Welcome To Scadaddle", @"First Step", @"Second Step", @"Third Step"];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];
    _pageDescriptions = @[@"Follow or decline people and activities by cross interests", @"Build your profile", @"Define your interests", @"Start Scadaddling"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    
    self.pageViewController.dataSource = self;
    
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    navButton.tag = 1;
    [navButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    self.pageViewController.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextPagethrough:(UIButton*)sender
{

    [self viewControllerAtIndex:sender.tag];
    

}
- (IBAction)startWalkthrough:(UIButton*)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:sender.tag];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}
- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
        
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.descriptionText = self.pageDescriptions[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    navButton.tag=(unsigned long)((PageContentViewController*) viewController).pageIndex;
    NSLog(@"button index = %lu",navButton.tag);
    [navButton removeTarget:self action:@selector(goToRegistration) forControlEvents:UIControlEventTouchUpInside];
    [navButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [navButton setTitle:@"NEXT" forState:UIControlStateNormal];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    
    --index;
   
    return [self viewControllerAtIndex:index];
}
-(void)startUpdating
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:@"Loading..." withProgress:YES andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [self.view addSubview:popup];
}

/*!
 * @discussion to opens custom Popup with title
 * @param title desired message to display on popup
 * @param show YES/NO YES to display OK button
 */
-(void)messagePopupWithTitle:(NSString*)title hideOkButton:(BOOL)show
{
    
    popup = [[ScadaddlePopup alloc] initWithFrame:self.view.frame withTitle:title withProgress:NO andButtonsYesNo:NO forTarget:self andMessageType:-1];
    [popup hideDisplayButton:show];
    [self.view addSubview:popup];
    
}
/*!
 * @discussion to dismiss popup [slowly disappears]
 * @param title desired message to display on popup
 * @param duration time while disappearing
 * @param exit YES/NO YES to dismiss this controller
 */

-(void)dismissPopupActionWithTitle:(NSString*)title andDuration:(double)duration andExit:(BOOL)exit
{
    
    [popup updateTitleWithInfo:title];
    [UIView animateWithDuration:duration animations:^{
        
        popup.alpha=0.9;
    } completion:^(BOOL finished) {
        
        [popup removeFromSuperview];
        if(exit)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
    }];
    
    
}
-(void)popupThread
{

    //[NSThread detachNewThreadSelector:@selector(startUpdating) toTarget:self withObject:nil];

}
-(IBAction)dismissPopup
{
    
    [self dismissPopupActionWithTitle:@"" andDuration:0 andExit:NO];
    
    
}
/*!
 * Redirect user to Update/Edit information page
 * @see emsRegistrationVC
 */
-(void)goToRegistration
{
  
    [self progress];
    [self presentViewController:[[emsRegistrationVC alloc] init] animated:YES completion:^{
         [self stopSubview];
    }];

}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    navButton.tag=(unsigned long)((PageContentViewController*) viewController).pageIndex;
    NSLog(@"button index = %lu",navButton.tag);
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index == [self.pageTitles count]-1) {
        
            navButton.alpha=1;
            [navButton setTitle:@"LET'S START!" forState:UIControlStateNormal];
            [navButton addTarget:self action:@selector(goToRegistration) forControlEvents:UIControlEventTouchUpInside];
                    return nil;
    }
    else
    {
    
        navButton.alpha=1;
        [navButton setTitle:@"NEXT" forState:UIControlStateNormal];
        [navButton removeTarget:self action:@selector(goToRegistration) forControlEvents:UIControlEventTouchUpInside];
        [navButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
       
    }
    
    ++index;
    return [self viewControllerAtIndex:index];
}
-(IBAction)next:(UIButton*)sender
{
   
    
    if (sender.tag == 3) {
        
        navButton.alpha=1;
        [navButton setTitle:@"LET'S START!" forState:UIControlStateNormal];
        navButton.tag=sender.tag;
        [navButton addTarget:self action:@selector(goToRegistration) forControlEvents:UIControlEventTouchUpInside];
        PageContentViewController *startingViewController = [self viewControllerAtIndex:sender.tag];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        return;
    }
    if (sender.tag<3)
    {
        PageContentViewController *startingViewController = [self viewControllerAtIndex:sender.tag];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        navButton.alpha=1;
        [navButton setTitle:@"NEXT" forState:UIControlStateNormal];
        navButton.tag=sender.tag;
        [navButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    navButton.tag=sender.tag+1;
    NSLog(@"Tag = %ld",(long)navButton.tag);
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    NSUInteger index = [pageViewController.viewControllers[0] pageIndex];
    return index;
}

@end
