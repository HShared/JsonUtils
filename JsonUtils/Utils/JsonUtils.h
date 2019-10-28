//
//  ResonseDataToModel.h
//  ATH
//
//  Created by ATH on 2019/4/16.
//  Copyright © 2019 ATH. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface JsonUtils : NSObject
//解析的字典中如果包含NSArray，需要将NSArray中所存放的对象所属的类存放到containClass中
@property(nonatomic,copy)NSDictionary *containsClass;

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
 @param containsClass Model 对象中或Model对象的实例变量中如果包含数组，则这些数组所存放的对象所属的类需要传入到当前containsClass中
 @return Model对象
 */
+(id)parseJson:(NSData *)json toModel:(Class)cls withContainsClass:(nullable NSDictionary *)containsClass;
/**
 将json转化为Model对象
 @param json 要转化的json数据
 @param cls Model对象所属的类
 @param containsClass Model 对象中或Model对象的实例变量中如果包含数组，则这些数组所存放的对象所属的类需要传入到当前containsClass中
 @param key 可为空，当当前cls为一个数组时，数组存放的model的class可通过key从containsClass中获取得到
 @return Model对象
 */
+(id)parseJson:(NSData *)json toModel:(Class)cls withContainsClass:(nullable NSDictionary *)containsClass containsClassKey:(nullable NSString *)key;
/**
 将字典转化为Model对象

 @param dict 需要转化的字典，一般由json转化而来
 @param cls Model对象所属的类
 @param containsClass Model 对象中或Model对象的实例变量中如果包含数组，则这些数组所存放的对象所属的类需要传入到当前containsClass中
 @return model对象
 */
-(id)convertDictionary:(NSDictionary *)dict toModel:(Class )cls withContainsClass:(NSDictionary *)containsClass;

/**
 将字典转化为Model对象，

 @param dict 需要转化的字典，一般由json转化而来
 @param cls Model对象所属的类
 @return model对象
 */
-(id)convertDictionary:(NSDictionary *)dict toModel:(Class )cls;

/**
 将model转化为json字符串
 
 @param model 要转化的model
 @return json
 */
+(NSString *)parseModelToJsonStr:(id)model;
@end

NS_ASSUME_NONNULL_END
