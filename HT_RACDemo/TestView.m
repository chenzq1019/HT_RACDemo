//
//  TestView.m
//  HT_RACDemo
//
//  Created by 陈竹青 on 2021/2/4.
//

#import "TestView.h"
#import <ReactiveObjC/ReactiveObjC.h>
@implementation TestView

- (instancetype)init{
    self  = [super init];
    return self;
}

- (void)setModel:(TestModel *)model{
    _model = model;
    
    [RACObserve(_model, isFinished) subscribeNext:^(NSNumber * x) {
        if (x && [x boolValue]) {
            NSLog(@"===isFiniesed == %@",x);
        }
    }];
    
    [RACObserve(_model, name) subscribeNext:^(NSNumber * x) {
        if (x ) {
            NSLog(@"===name ==  %@",x);
        }
    }];
}

@end
