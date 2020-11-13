//
//  ViewController.m
//  HT_RACDemo
//
//  Created by 陈竹青 on 2020/11/13.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self runRACSignalMethod];
    
    [self runRACSubjectMethod];
    
    [self runRACCollection];
    
    [self runRACTimer];
}

#pragma mark - <基础语法和用法>
- (void) runRACSignalMethod{
    //1、初始化一信号
    RACSignal * singnal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"我要发送消息了"];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    //订阅消息
    [singnal subscribeNext:^(id  _Nullable x) {
        NSLog(@"我收到消息了 --%@",x);
    }];
    //总结： 创建是一个block，内部有发送消息，
    //只有订阅了 ，才会触发。
    //**************//
}

- (void)runRACSubjectMethod{
    //1.初始化一个RACSubject,不用creat方法
    
    RACSubject * signal = [[RACSubject alloc] init];
    
    [signal sendNext:@"定月前发松"];
    //2、订阅消息
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"收到：%@",x);
    }];
    //3、发送消息
    [signal sendNext:@"chenzq的消息"];
    
    
    RACReplaySubject * replaySignal = [[RACReplaySubject alloc] init];
    [replaySignal sendNext:@"Repalay:定月前发松"];
    //2、订阅消息
    [replaySignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"Repalay收到：%@",x);
    }];
    //3、发送消息
    [replaySignal sendNext:@"Repalaychenzq的消息"];
    
    //总结：RACSubject 与 RACReplaySubject的区别是：
    //RACSubject 必须是先订阅过再发送消息，才能收到
    //RACReplaySubject： 只要发送消息，任何时候订阅都可以收到。
    
}
- (void)runRACCollection{
    
    //创建元组
    RACTuple * tuple = [RACTuple tupleWithObjects:@1,@2,@3, nil];
    
    NSLog(@"%@",tuple.first);
    
    //遍历数组
    NSArray * array = @[@"a",@"b",@"c",@"d",@"e"];
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    //遍历字典
    NSDictionary * dic = @{@"a":@"1",@"b":@"2"};
    [dic.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        //采用元组将x转成元组。
        RACTupleUnpack(NSString * key, NSString * value) = x;
        NSLog(@"%@:%@",key,value);
    }];
}

- (void)runRACTimer{
    //定时器的写法
    //1、创建一个定时器的信号
    RACSignal * timer = [RACSignal interval:1 onScheduler:RACScheduler.mainThreadScheduler];
    timer = [timer take:3];
    [timer subscribeNext:^(id  _Nullable x) {
        NSLog(@"==");
    } completed:^{
        NSLog(@"完成");
    }];
    //连着写的方式
    [[[RACSignal interval:1 onScheduler:RACScheduler.mainThreadScheduler] take:3] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"######");
    } completed:^{
        NSLog(@"##完成###");
    }];
    
    //延时执行的写法：
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"我迟到了"];
        return [RACDisposable disposableWithBlock:^{
        }];
    }] delay:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"延时2秒收到消息：%@",x);
    }] ;
    
    
}

- (void)runRACCommand{
    
}
@end
