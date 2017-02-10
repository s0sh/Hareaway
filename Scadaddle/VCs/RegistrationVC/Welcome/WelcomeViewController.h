

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface WelcomeViewController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSArray *pageDescriptions;
@property (strong, nonatomic) UIImageView *scadLogo;
@property (weak, nonatomic)IBOutlet UIButton *navButton;
@end
