//
//  ClassModel.h
//  JsonUtils
//
//  Created by ATH on 2019/10/28.
//  Copyright © 2019 ath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StudentModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ClassModel : NSObject
@property(nonatomic,copy)NSString *className;
@property(nonatomic,strong)NSNumber *grade;
@property(nonatomic,copy)NSArray<StudentModel*> *students;
@end

NS_ASSUME_NONNULL_END
