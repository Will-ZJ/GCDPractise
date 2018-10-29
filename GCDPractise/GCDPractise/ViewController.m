//
//  ViewController.m
//  GCDPractise
//
//  Created by Will on 2018/10/24.
//  Copyright © 2018年 Will. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *test_btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    test_btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:test_btn];
    [test_btn addTarget:self action:@selector(tappedTest:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)tappedTest:(UIButton *)sender{
    NSLog(@"点我了，老铁");
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self testGroup1];
//    [self testSemaphore];
    
}
//group 同步
- (void)testGroup1{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue1 = dispatch_queue_create("test.gcd.com", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"----1---%@",[NSThread currentThread]);
    dispatch_group_async(group, queue1, ^{
        
        [self test1];
    });
    dispatch_group_async(group, queue1, ^{
        [self test2];
    });
    NSLog(@"----4-----%@",[NSThread currentThread]);
    dispatch_group_notify(group, queue1, ^{
        NSLog(@"----5---%@",[NSThread currentThread]);
    });
}
//goup 异步 类似多个网络请求
- (void)testGroup2{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue1 = dispatch_queue_create("test.gcd.com", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"----1---%@",[NSThread currentThread]);
    dispatch_group_async(group, queue1, ^{
        dispatch_async(queue1, ^{
            [self test1];
        });
        
    });
    dispatch_group_async(group, queue1, ^{
        dispatch_async(queue1, ^{
            [self test2];
        });
        
    });
    NSLog(@"----4-----%@",[NSThread currentThread]);
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, queue1, ^{
        NSLog(@"----5---%@",[NSThread currentThread]);
    });
}
//异步 + 信号量
- (void)testGroup3{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue1 = dispatch_queue_create("test.gcd.com", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSLog(@"----1---%@",[NSThread currentThread]);
    dispatch_group_async(group, queue1, ^{
        dispatch_async(queue1, ^{
            [self test1];
            long temp_1 = dispatch_semaphore_signal(sema);
            NSLog(@"temp_1:%ld",temp_1);
        });
        
    });
    
    dispatch_group_async(group, queue1, ^{
        dispatch_async(queue1, ^{
            [self test2];
           long temp_3 = dispatch_semaphore_signal(sema);
            NSLog(@"temp_3:%ld",temp_3);
        });
        
    });
//    2个任务，2个信号等待
    long temp_2 = dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSLog(@"temp_2:%ld",temp_2);

    long temp_4 = dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSLog(@"temp_4:%ld",temp_4);
//    通过打印顺序，发现dispatch_semaphore_wait不只是阻塞当前线程，其他线程也会阻塞？还是说此代码后面的代码都等待执行？
//    当信号量为1的时候会阻塞其他线程
    NSLog(@"----4-----%@",[NSThread currentThread]);
    dispatch_group_notify(group, queue1, ^{
        NSLog(@"----5---%@",[NSThread currentThread]);
    });
}
//异步 group 控制
- (void)testGroup4{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue1 = dispatch_queue_create("test.gcd.com", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"----1---%@",[NSThread currentThread]);
    dispatch_group_enter(group);
    dispatch_group_async(group, queue1, ^{
        dispatch_async(queue1, ^{
            [self test1];
            dispatch_group_leave(group);
        });
        
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, queue1, ^{
        dispatch_async(queue1, ^{
            [self test2];
            dispatch_group_leave(group);
        });
        
    });
    NSLog(@"----4-----%@",[NSThread currentThread]);
    dispatch_group_notify(group, queue1, ^{
        NSLog(@"----5---%@",[NSThread currentThread]);
    });
}
- (void)test1{
//    [NSThread sleepForTimeInterval:3];
    for (int i = 0; i < 1000000000; i++) {

        if (i == 999999999) {
            NSLog(@"----2----%@",[NSThread currentThread]);
        }
    }
}
- (void)test2{

    NSLog(@"----3----%@",[NSThread currentThread]);
}
//dispatch_semaphore_t 控制并发数 3
- (void)testSemaphore{
    dispatch_queue_t workConcurrentQueue = dispatch_queue_create("cccccccc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t serialQueue = dispatch_queue_create("sssssssss",DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(serialQueue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_async(workConcurrentQueue, ^{
                NSLog(@"thread-info:%@开始执行任务%d",[NSThread currentThread],(int)i);
                sleep(1);
                NSLog(@"thread-info:%@结束执行任务%d",[NSThread currentThread],(int)i);
                dispatch_semaphore_signal(semaphore);});
        });
    }
    NSLog(@"主线程...!");
    
    
}
- (void)testSemaphore2{
    dispatch_queue_t queue = dispatch_queue_create("test.semaphore", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"111111-%@",[NSThread currentThread]);
        sleep(2);
        long temp_1 = dispatch_semaphore_signal(sema);
        NSLog(@"temp_1:%ld",temp_1);
    });
    long temp_2 = dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSLog(@"temp_2：%ld",temp_2);
    dispatch_group_async(group, queue, ^{
        NSLog(@"222222-%@--",[NSThread currentThread]);
    });
}

@end
