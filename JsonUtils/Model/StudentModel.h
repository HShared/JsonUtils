//
//  PersonModel.h
//  JsonUtils
//
//  Created by ATH on 2019/4/16.
//  Copyright © 2019 ath. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StudentModel : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSNumber *age;
@property(nonatomic,copy)NSString *gender;
@end

NS_ASSUME_NONNULL_END
