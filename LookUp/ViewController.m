//
//  ViewController.m
//  LookUp
//
//  Created by cyan on 1/7/26.
//

#import "ViewController.h"

@implementation ViewController

- (IBAction)lookUp:(id)sender {
  NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/LookUp.framework"];
  if (![bundle isLoaded]) {
    [bundle load];
  }

  id presenter = [NSClassFromString(@"LUPresenter") valueForKey:@"sharedPresenter"];
  NSInvocation *invocation = [self invocationWithTarget:presenter selectorString:@"animationControllerForTerm:relativeToRect:ofView:options:"];

  NSAttributedString *term = [[NSAttributedString alloc] initWithString:@"Hello"];
  [invocation setArgument:&term atIndex:2];

  CGRect rect = CGRectZero;
  [invocation setArgument:&rect atIndex:3];
  [invocation setArgument:&sender atIndex:4];

  NSDictionary *options = [NSDictionary dictionary];
  [invocation setArgument:&options atIndex:5];
  [invocation invoke];

  __unsafe_unretained id controller = nil;
  [invocation getReturnValue:&controller];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  [controller performSelector:sel_getUid("showPopover")];
#pragma clang diagnostic pop

  for (NSWindow *window in NSApp.windows) {
    if ([window.className isEqualToString:@"_NSTextFinderOverlayWindow"]) {
      [window close];
    }
  }
}

- (NSInvocation *)invocationWithTarget:(id)target selectorString:(NSString *)selectorString {
  SEL selector = NSSelectorFromString(selectorString);
  if (![target respondsToSelector:selector]) {
    NSLog(@"Missing method selector for: %@, %@", target, selectorString);
    return nil;
  }

  NSMethodSignature *signature = [target methodSignatureForSelector:selector];
  if (signature == nil) {
    NSAssert(NO, @"Missing method signature for: %@, %@", target, selectorString);
    return nil;
  }

  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  invocation.target = target;
  invocation.selector = selector;
  return invocation;
}

@end
