//
//  TestViewRouterViewController.m
//  ZIKRouterDemo
//
//  Created by zuik on 2019/6/22.
//  Copyright © 2019 zuik. All rights reserved.
//

#import "TestViewRouterViewController.h"
#import "TestPushViewRouter.h"
#import "TestPresentModallyViewRouter.h"
#import "TestPresentAsPopoverViewRouter.h"
#import "TestPerformSegueViewRouter.h"
#import "TestShowViewRouter.h"
#import "TestShowDetailViewRouter.h"
#import "TestAddAsChildViewRouter.h"
#import "TestAddAsSubviewViewRouter.h"
#import "TestCustomViewRouter.h"
#import "TestMakeDestinationViewRouter.h"
#import "TestAutoCreateViewRouter.h"
#import "TestCircularDependenciesViewRouter.h"
#import "TestClassHierarchyViewRouter.h"
#import "TestURLRouterViewRouter.h"
#import "ZIKRouterDemo-Swift.h"

typedef NS_ENUM(NSInteger,ZIKRouterTestType) {
    ZIKRouterTestTypePush,
    ZIKRouterTestTypePresentModally,
    ZIKRouterTestTypePresentAsPopover,
    ZIKRouterTestTypePerformSegue,
    ZIKRouterTestTypeShow NS_ENUM_AVAILABLE_IOS(8_0),
    ZIKRouterTestTypeShowDetail NS_ENUM_AVAILABLE_IOS(8_0),
    ZIKRouterTestTypeAddAsChildViewController,
    ZIKRouterTestTypeAddAsSubview,
    ZIKRouterTestTypeCustom,
    ZIKRouterTestTypeMakeDestination,
    ZIKRouterTestTypeAutoCreate,
    ZIKRouterTestTypeCircularDependencies,
    ZIKRouterTestTypeSubclassHierarchy,
    ZIKRouterTestTypeSwiftSample,
    ZIKRouterTestTypeURLRouter
};

@interface TestViewRouterViewController () <UIViewControllerPreviewingDelegate>
@property (nonatomic, strong) NSArray<NSString *> *cellNames;
@property (nonatomic, strong) NSArray<Class> *routerTypes;
@end

@implementation TestViewRouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    if ([self respondsToSelector:@selector(registerForPreviewingWithDelegate:sourceView:)]) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    self.cellNames = @[
                       @"Test Push",
                       @"Test PresentModally",
                       @"Test PresentAsPopover",
                       @"Test PerformSegue",
                       @"Test Show",
                       @"Test ShowDetail",
                       @"Test AddAsChildViewController",
                       @"Test AddAsSubview",
                       @"Test Custom",
                       @"Test MakeDestination",
                       @"Test AutoCreate",
                       @"Test Circular Dependencies",
                       @"Test Subclass Hierarchy",
                       @"Swift Sample",
                       @"Test Easy Factory",
                       @"URL Router"
                       ];
    self.routerTypes = @[
                         [TestPushViewRouter class],
                         [TestPresentModallyViewRouter class],
                         [TestPresentAsPopoverViewRouter class],
                         [TestPerformSegueViewRouter class],
                         [TestShowViewRouter class],
                         [TestShowDetailViewRouter class],
                         [TestAddAsChildViewRouter class],
                         [TestAddAsSubviewViewRouter class],
                         [TestCustomViewRouter class],
                         [TestMakeDestinationViewRouter class],
                         [TestAutoCreateViewRouter class],
                         [TestCircularDependenciesViewRouter class],
                         [TestClassHierarchyViewRouter class],
                         ZIKRouterToView(SwiftSampleViewInput),
                         ZIKViewRouter.toIdentifier(@"testEasyFactory"),
                         [TestURLRouterViewRouter class]
                         ];
    
    NSAssert(self.cellNames.count == self.routerTypes.count, nil);
}


#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *name = @"undefined";
    if (self.cellNames.count > indexPath.row) {
        name = self.cellNames[indexPath.row];
    }
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id routerType = [self routerClassForIndexPath:indexPath];
    ZIKViewRoutePath *routePath;
    ZIKRouterTestType testType = indexPath.row;
    switch (testType) {
        case ZIKRouterTestTypePush:
        case ZIKRouterTestTypeShow:
        case ZIKRouterTestTypeShowDetail:
        case ZIKRouterTestTypeAutoCreate:
            routePath = ZIKViewRoutePath.pushFrom(self);
            break;
            
        default:
            routePath = ZIKViewRoutePath.showDetailFrom(self);
            break;
    }
    
    [routerType performPath:routePath];
}

- (Class)routerClassForIndexPath:(NSIndexPath *)indexPath {
    Class routerClass;
    if (self.routerTypes.count > indexPath.row) {
        routerClass = self.routerTypes[indexPath.row];
    }
    return routerClass;
}

#pragma mark UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    Class routerClass = [self routerClassForIndexPath:indexPath];
    UIViewController *destinationViewController = [routerClass makeDestination];
    
    NSAssert(destinationViewController != nil, nil);
    return destinationViewController;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    ZIKAnyViewRouterType *routerType = [ZIKViewRouter.routersToClass([viewControllerToCommit class]) firstObject];
    if (routerType != nil) {
        [routerType performOnDestination:viewControllerToCommit path:ZIKViewRoutePath.pushFrom(self)];
    } else {
        [self.navigationController pushViewController:viewControllerToCommit animated:YES];
    }
}

@end
