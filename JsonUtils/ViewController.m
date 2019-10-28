//
//  ViewController.m
//  JsonUtils
//
//  Created by ATH on 2019/10/28.
//  Copyright © 2019 ath. All rights reserved.
//

#import "ViewController.h"
#import "ClassModel.h"
#import "JsonUtils.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建Model
    ClassModel *classModel = [[ClassModel alloc]init];
    [classModel setClassName:@"班级名称"];
    [classModel setGrade:[NSNumber numberWithInteger:9]];//九年级
    NSMutableArray *students = [NSMutableArray array];
    for(int i =0;i<50;i++){
        StudentModel *studentModel = [[StudentModel alloc]init];
        [studentModel setName:[NSString stringWithFormat:@"张%d",i]];
        int rand = arc4random()%5;
        [studentModel setAge:[NSNumber numberWithInt:12+rand]];
        [studentModel setGender:rand%2==0?@"男":@"女"];
        [students addObject:studentModel];
    }
    [classModel setStudents:students];
    //将model转化为Json字符串
    NSString *jsonStr =  [JsonUtils parseModelToJsonStr:classModel];
    NSLog(@"jsonStr:%@",jsonStr);
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //将json转为model；
    //ClassModel中有数组students，需要指定数组students中的元素要转化为哪一个model，
    //此处指定为StudentModel。如果model中没有数组，则此处可以为空
   ClassModel *model = [JsonUtils parseJson:jsonData toModel:[ClassModel class] withContainsClass:@{@"students":[StudentModel class]}];
    if(!model){
        NSLog(@"转化的model为空");
    }else{
        NSLog(@"班级名称:%@",[model className]);
        NSLog(@"年级:%@",[[model grade] stringValue]);
        NSLog(@"学生:");
        for(int i =0;i<model.students.count;i++){
            StudentModel *stModel = [model.students objectAtIndex:i];
            NSLog(@"名字：%@,性别：%@，年龄:%@",stModel.name,stModel.gender,[stModel.age stringValue]);
           
        }
    }
}


@end
