//
//  ResonseDataToModel.m
//  ATH
//
//  Created by ATH on 2019/4/16.
//  Copyright © 2019 ATH. All rights reserved.
//

#import "JsonUtils.h"
#import <objc/runtime.h>
@implementation JsonUtils

+(id)parseJson:(NSData *)json toModel:(Class)cls{
    return [JsonUtils parseJson:json toModel:cls withContainsClass:NULL containsClassKey:nil];
}
+(id)parseJson:(NSData *)json toModel:(Class)cls withContainsClass:(nullable NSDictionary *)containsClass{
    return [JsonUtils parseJson:json toModel:cls withContainsClass:containsClass containsClassKey:nil];
}
+(id)parseJson:(NSData *)json toModel:(Class)cls withContainsClass:(nullable NSDictionary *)containsClass containsClassKey:(nullable NSString *)key{
    if(!json||!cls){
        return nil;
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
    if(!jsonObject){
        return jsonObject;
    }
    JsonUtils *resonseDataToModel = [[JsonUtils alloc]init];
    if([jsonObject isKindOfClass:[NSDictionary class]]){
        return [resonseDataToModel convertDictionary:jsonObject toModel:cls withContainsClass:containsClass];
    }
    [resonseDataToModel setContainsClass:containsClass];
    return [jsonObject convertDictArrayToModelArray:jsonObject containsClassKey:key];
}
-(NSMutableArray *)convertDictArrayToModelArray:(NSArray *)arry containsClassKey:(NSString *)key{
    if(arry){
        NSMutableArray * retModelArray = [[NSMutableArray alloc]init];
        for(int i =0;i<arry.count;i++){
            id jsonObj = [arry objectAtIndex:i];
            if([jsonObj isKindOfClass: [NSString class]]){
                [retModelArray   addObject:jsonObj];
            }else if([jsonObj isKindOfClass:[NSDictionary class]]){
                Class modelClass = [self classFromDictionary:key];
                if(!modelClass){
                    continue;
                }
                id modelArrayItem = [self convertDictionary:jsonObj toModel:modelClass];
                [retModelArray addObject:modelArrayItem];
            }else{
                id modelArrayItem = [self convertDictArrayToModelArray:jsonObj containsClassKey:key];
                [retModelArray addObject:modelArrayItem];
            }
        }
        return retModelArray;
    }
    return nil;
}

/**
通过key获取需要转化为哪个Model
 @param key 与containsClass对应的
 @return 可以转化为的类
 */
-(Class)classFromDictionary:(NSString  *)key{
    if(!self.containsClass||!key){
        return nil;
    }
    return [self.containsClass objectForKey:key];
}

-(id)convertDictionary:(NSDictionary *)dict toModel:(Class )cls withContainsClass:(NSDictionary *)containsClass{
    self.containsClass = containsClass;
    return [self convertDictionary:dict toModel:cls];
    
}
-(id)convertDictionary:(NSDictionary *)dict toModel:(Class )cls{
    if(!dict||!cls){
        return nil;
    }
    id retModel = [[cls alloc]init];
    unsigned int ivarCount;
    Ivar *ivarList = class_copyIvarList(cls,&ivarCount);
    for(int i =0;i<ivarCount;i++){
        const char *ivarNameChar = ivar_getName(ivarList[i]);
        NSString *ivarName = [[NSString stringWithUTF8String:ivarNameChar] substringFromIndex:1];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivarList[i])];
        if([JsonUtils isBasicType:type]){
            id basicTypeObject = [dict objectForKey:ivarName];
            if(!basicTypeObject){
                if([ivarName hasPrefix:@"isnew"]){
                     basicTypeObject = [dict objectForKey:[ivarName substringFromIndex:2]];
                      if(!basicTypeObject){
                          continue;
                      }
                }else{
                  continue;
                }
            }
            [retModel setValue:basicTypeObject forKey:ivarName];;
        }else{
            id memberVariableDictOrArrayForm = [dict objectForKey:ivarName];
            if(!memberVariableDictOrArrayForm){
                continue;
            }
            if([memberVariableDictOrArrayForm isKindOfClass:[NSDictionary class]]){
                type = [JsonUtils typeCheck:type];
                Class modelClass = NSClassFromString(type);
                id memberVariable = [self convertDictionary:memberVariableDictOrArrayForm toModel:modelClass];
                if(!memberVariable){
                    continue;
                }
                [retModel setValue:memberVariable forKey:ivarName];
            }else{//数组
                NSArray *memberVariable =[self convertDictArrayToModelArray:memberVariableDictOrArrayForm containsClassKey:ivarName];
                if(!memberVariable){
                   continue;
                }
                [retModel setValue:memberVariable
                            forKey:ivarName];
            }
        }
    }
    free(ivarList);
    return retModel;
}
+(NSString *)typeCheck:(NSString *)type{
    type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@"@" withString:@""];
    return type;
}

+(BOOL)isBasicType:(NSString *)type{
    type =[JsonUtils typeCheck:type];
    if([type isEqualToString:@"NSString"]){
        return true;
    }
    if([type isEqualToString:@"NSNumber"]){
        return true;
    }
    if([type containsString:@"^"]){
       type = [type stringByReplacingOccurrencesOfString:@"^" withString:@""];
    }
    if([type isEqualToString:@"i"]){
        return true;
    }
    if([type isEqualToString:@"B"]){
        return true;
    }
    if([type isEqualToString:@"f"]){
        return true;
    }
    if([type isEqualToString:@"d"]){
        return true;
    }
    if([type isEqualToString:@"q"]){
        return true;
    }
    if([type isEqualToString:@"c"]){
        return true;
    }
    return false;
}

/**
 将model转化为json字符串

 @param model 要转化的model
 @return json
 */
+(NSString *)parseModelToJsonStr:(id)model{
    if(!model){
        return nil;
    }
    NSString *className = [[NSString alloc]initWithUTF8String: object_getClassName(model)];
    if([JsonUtils isBasicType:className]){
        return nil;
    }
    NSString *ret = nil;
    if([model isKindOfClass:[NSArray class]]){
        NSArray *array = [JsonUtils parseModelArrayToJsonArray:model];
        ret = [JsonUtils convertArrayToJSonStr:array];
    }else{
         NSDictionary *retDict = [JsonUtils parseModelToDictionary:model];
        ret = [JsonUtils convertDictToJSonStr:retDict];
    }
    return ret;
}

/**
 将model转为NSDictionary，变量名将作为变量值的key

 @param model 要转化的model
 @return model转化成的NSDictionary
 */
+(NSDictionary *)parseModelToDictionary:(id)model{
    Class modelCls =  [model class];
    unsigned int ivarCount = 0;
    Ivar *ivarList = class_copyIvarList(modelCls,&ivarCount);
    NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
    for(int i =0;i<ivarCount;i++){
        const char *ivarNameChar = ivar_getName(ivarList[i]);
        NSString *ivarName = [[NSString stringWithUTF8String:ivarNameChar] substringFromIndex:1];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivarList[i])];
        id obj =[model valueForKey:ivarName];
        if(!obj){
            continue;
        }
        id dictOrArrayObj = nil;
        if([JsonUtils isBasicType:type]){//基本数据类型、NSSString、NSNumber
            dictOrArrayObj = obj;
        }else if([obj isKindOfClass:[NSArray class]]){
            dictOrArrayObj = [JsonUtils parseModelArrayToJsonArray:obj];
        }else{
            dictOrArrayObj = [JsonUtils parseModelToDictionary:obj];
        }
         [retDict setObject:dictOrArrayObj forKey:ivarName];
    }
    free(ivarList);
    
    return retDict;
}

/**
 将存放model的数组转化为存放model对应的Dictionary的数组
 即将数组中的model转为Dictionary
 @param array 存放model的数组
 @return 存放model对应的Dictionary的数组
 */
+(NSArray *)parseModelArrayToJsonArray:(NSArray *)array{
    if(!array||array.count==0){
        return nil;
    }
    NSMutableArray *retArray = [NSMutableArray array];
    for(int i =0;i<array.count;i++){
        id obj = [array objectAtIndex:i];
        id jsonObj = nil;
        if([obj isKindOfClass:[NSArray class]]){
            jsonObj = [JsonUtils parseModelArrayToJsonArray:obj];
        }else{
            jsonObj = [JsonUtils parseModelToDictionary:obj];
        }
        [retArray addObject:jsonObj];
    }
    return [retArray copy];
}

/**
 将数组转化为json字符串
 
 @param array 要转化的数组
 @return json字符串
 */
+(NSString *)convertArrayToJSonStr:(NSArray *)array{
    NSMutableString *ret = [[NSMutableString alloc]init];
    [ret appendString:@"["];
    for(int i=0;i<array.count;i++){
        NSDictionary *dict = [array objectAtIndex:i];
        NSString *jsonStr = [JsonUtils convertDictToJSonStr:dict];
        [ret appendString:jsonStr];
        if(i!=array.count-1){
            [ret appendString:@","];
        }
    }
    [ret appendString:@"]"];
    return ret;
}

/**
 将字典转化为json字符串

 @param dict 要转化的字典
 @return json字符串
 */
+(NSString *)convertDictToJSonStr:(NSDictionary *)dict{
    if(!dict){
        return @"{}";
    }
    NSArray *allKeys = [dict allKeys];
    NSMutableString *ret = [[NSMutableString alloc]initWithString: @"{"];
    for(int i =0;i<[allKeys count];i++){
        NSString *key = [allKeys objectAtIndex:i];
        NSObject *obj =[dict objectForKey:key];
        [ret appendFormat:@"\"%@\"",key];
        [ret appendString:@":"];
        if([obj isKindOfClass:[NSArray class]]){
            [ret appendString:[JsonUtils convertArrayToJSonStr:(NSArray*)obj]];
        }else{
            if([obj isKindOfClass:[NSNumber class]]){
                [ret appendFormat:@"%@",obj];
            }else{
                [ret appendFormat:@"\"%@\"",obj];
            }
            if(i!=allKeys.count-1){
                [ret appendString:@","];
            }
        }
    }
    [ret appendString:@"}"];
    return ret;
}

@end
