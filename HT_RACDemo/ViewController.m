//
//  ViewController.m
//  HT_RACDemo
//
//  Created by 陈竹青 on 2020/11/13.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController ()
@property (nonatomic, strong)  RACCommand * command;
@property (nonatomic, strong) UIButton * mBtn;
@property (nonatomic, strong) NSString * mTestValue;
@property (nonatomic, strong) UILabel * mTitleLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mTitleLabel];
    [self.view addSubview:self.mBtn];
    // Do any additional setup after loading the view.
//    [self runRACSignalMethod];
//
//    [self runRACSubjectMethod];
//
//    [self runRACCollection];
//
//    [self runRACTimer];
    
//    [self runRACCommand];
//
//    [self runMutiRequestAndReturn];
    
//    [self runMarcoConst];
//
//    [self runCombinReduceSignals];
//
    [self rundZipSignal];
}

#pragma mark - <基础语法和用法>
- (void) runRACSignalMethod{
    //1、初始化一信号
    RACSignal * singnal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"开始发送消息==");
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
    
    [singnal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二次订阅消息 --%@",x);
    }];
    
    //上面我们订阅两次，就会导致发送两次消息。那么我们如何以只调用一次发送消息呢，
    //1，我们可以使用下面的RACSubject 或者RACReplaySubject。不用block的方式，主动发送
    //2、如果使用block的方式，那就可以使用RACMulticastConnection
    RACSignal * singnal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"singnal2开始发送消息==");
        [subscriber sendNext:@"我要发送消息了"];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    RACMulticastConnection * connect = [singnal2 publish];
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第一个订阅信号==");
    }];
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二个订阅信号==");
    }];
    [connect connect];
    
}

- (void)runRACSubjectMethod{
    //1.初始化一个RACSubject,不用creat方法
    
    RACSubject * signal = [[RACSubject alloc] init];
    
    [signal sendNext:@"定月前发松"];
    //2、订阅消息
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"收到：%@",x);
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二次订阅：%@",x);
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
    RACCommand * command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [subscriber sendNext:@"请求数据"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    self.command = command;
    //订阅消息
    [self.command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"收到消息%@",x);
    }];
    //监听是否执行完毕，默认会来一次，所以第一次可以忽略掉
    
    [[self.command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue] ==  YES) {
            NSLog(@"正在执行");
        }else {
            NSLog(@"执行完毕");
        }
    }];
    
    //执行command命令
    [self.command execute:@"执行命令"];
}
//同时多个请求，等待全部返回执行
- (void)runMutiRequestAndReturn{
    //网络请求1
    RACSignal  * signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"网络请求1");
        [subscriber sendNext:@"网络请求1"];
        return nil;
    }];
    RACSignal * signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"网络请求2");
        [subscriber sendNext:@"网络请求2"];
        return nil;
    }];
    RACSignal * signal3 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"网络请求3");
        [subscriber sendNext:@"网络请求3"];
        return nil;
    }];
    [self rac_liftSelector:@selector(handleData1:data2:data3:) withSignalsFromArray:@[signal1,signal2,signal3]];
}

- (void)handleData1:(id)data1 data2:(id)data2 data3: (id) data3 {
    NSLog(@"%@-%@ -%@",data1,data2,data3);
}

//常用的宏定义
- (void)runMarcoConst{
    RACSubject * signal = [RACSubject subject];
    RAC(self.mBtn, enabled) = signal;
    [signal sendNext:@NO];
    
    RACSubject * signal2 = [RACSubject subject];
    RAC(self.mTitleLabel,text) = signal2;
    self.mTestValue = @"testValue";
    [signal2 sendNext:@"我要改变"];
    
    NSLog(@"2:%@", self.mTestValue);
    
    
    [RACObserve(self, mTestValue) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"唱歌"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RAC(self,self.mTitleLabel.text) = [signalA map:^id _Nullable(id  _Nullable value) {
        if ([value isEqualToString:@"唱歌"]) {
            return @"跳舞";
        }
        return @"";
    }];
}

- (void)runCombinReduceSignals{
    RACSubject * signalA = [RACSubject subject];
    RACSubject * signalB = [RACSubject subject];
    
    [[RACSignal combineLatest:@[signalA,signalB] reduce:^id _Nonnull(NSString * a,NSString * b){
        return @[a,b];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [signalA sendNext:@"SignalA"];
    [signalA sendNext:@"SignalA1"];
    [signalB sendNext:@"SignalB"];
    [signalB sendNext:@"SignalB1"];
    
    //输出结果为【SignalA1，SignalB1】
    //这个是因为我们合并的是最新的信号，并且是两个最新信号都有触发的时候才会执行。
}

- (void)rundZipSignal{
    //合并信号
    RACSubject * signalA = [RACSubject subject];
    RACSubject * signalB = [RACSubject subject];
    
    [[signalA zipWith:signalB] subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString * a,NSString * b) = x;
        NSLog(@"a=%@,b=%@",a,b);
    }];
    [signalA sendNext:@"SignalA1"];
    [signalB sendNext:@"SignalB1"];
}


#pragma mark - <getter>
- (UIButton *)mBtn {
    if (!_mBtn) {
        _mBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 100, 40)];
        [_mBtn setTitle:@"按键" forState:UIControlStateNormal];
        _mBtn.backgroundColor = [UIColor greenColor];
        [[_mBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            NSLog(@"按键点击");
        }];
    }
    return _mBtn;
}

- (UILabel *)mTitleLabel{
    if (!_mTitleLabel) {
        _mTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, 100, 40)];
        _mTitleLabel.textColor = UIColor.blackColor;
    }
    return  _mTitleLabel;
}
@end
