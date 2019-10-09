//
//  ResonseDataToModel.h
//  ATH
//
//  Created by ATH on 2019/4/16.
//  Copyright © 2019 TShare. All rights reserved.
//  email:2067571454@qq.com

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonUtils : NSObject
//解析的字典中如果包含NSArray，需要将NSArray中所存放的对象所属的类存放到containClass中
@property(nonatomic,strong)NSArray *containClass;

/**
  将json转化为Model对象

 @param json 要转化的json数据
 @param cls Model对象所属的类
 @return Model对象
 */
+(id)parseJson:(NSData *)json toModel:(Class)cls;

/**
 将json转化为Model对象
 
 @param json 要转化的json数据
 @param cls Model对象所属的类
 @param array Model 对象中或Model对象的实例变量中如果包含数组，则这些数组所存放的对象所属的类需要传入到当前array中
 @return Model对象
 */
+(id)parseJson:(NSData *)json toModel:(Class)cls withContainClass:(nullable NSArray *)array;

/**
 将Array中包含的Dictionary转换成对应的Model

 @param array 将要转换的Array
 @param containClasses Array中包含的Dictionary对应的Model
 @return 将Array中包含的Dictionary转换成对应的Model后的Array
 */
+(NSArray *)parseDictArray:(NSArray *)array toModelArrayWithContainClass:(NSArray *)containClasses;
/**
 将字典转化为Model对象

 @param dict 需要转化的字典，一般由json转化而来
 @param cls Model对象所属的类
 @param array Model 对象中或Model对象的实例变量中如果包含数组，则这些数组所存放的对象所属的类需要传入到当前array中
 @return model对象
 */
-(id)convertDictionary:(NSDictionary *)dict toModel:(Class )cls withContainClass:(NSArray *)array;

/**
 将字典转化为Model对象，

 @param dict 需要转化的字典，一般由json转化而来
 @param cls Model对象所属的类
 @return model对象
 */
-(id)convertDictionary:(NSDictionary *)dict toModel:(Class )cls;


@end

NS_ASSUME_NONNULL_END
