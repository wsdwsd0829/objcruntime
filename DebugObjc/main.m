//
//  main.m
//  DebugObjc
//
//  Created by Max Wang on 5/27/19.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

@protocol FakeProtocol <NSObject>
- (void)fakeMethod;
@end

@interface FakeObj : NSObject <FakeProtocol>
- (void)fakeMethod;
@end
@implementation FakeObj
- (void)fakeMethod {
  //  NSLog(@"^^^ calling fake Method");
}

@end

void fakeMethodx() {
  printf("fakeMethodx");
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    // insert code here...
    NSLog(@"Hello, World!");

    for (int i=0; i<2000; i++) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        FakeObj *_fakeObj = [[FakeObj alloc] init];
        if ([_fakeObj conformsToProtocol:@protocol(FakeProtocol)]) {
          //      kdebug_signpost_end(999, 0, 0, 0, 0);
          [(id<FakeProtocol>)_fakeObj fakeMethod];
        }
      });
    }

    SEL selector = sel_registerName("fakeMethodx");
    IMP imp = fakeMethodx;
    if (sel_isMapped(selector)) {
      class_addMethod([FakeObj class], selector, imp, nil);
      FakeObj *f = [FakeObj new];
      [f performSelector:selector];
    } else {
      NSLog(@"!! not sel_isMapped");
    }
  }
  sleep(4);
  return 0;
}
