//
//  ResonseDataToModel.m
//  ATH
//
//  Created by ATH on 2019/4/16.
//  Copyright © 2019 TShare. All rights reserved.
//  email:2067571454@qq.com

#import "JsonUtils.h"
#import <objc/runtime.h>
@implementation JsonUtils

+(id)parseJson:(NSData *)json toModel:(Class)cls{
    return [JsonUtils parseJson:json toModel:cls withContainClass:NULL];
}
+(id)parseJson:(NSData *)json toModel:(Class)cls withContainClass:(nullable NSArray *)array{
    if(!json||!cls){
        return nil;
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
    if(!jsonObject){
        return nil;
    }
    JsonUtils *resonseDataToModel = [[JsonUtils alloc]init];
    if([jsonObject isKindOfClass:[NSDictionary class]]){
        return [resonseDataToModel convertDictionary:jsonObject toModel:cls withContainClass:array];
    }
    [resonseDataToModel setContainClass:array];
    return [resonseDataToModel convertDictArrayToModelArray:jsonObject];
}

+(NSArray *)parseDictArray:(NSArray *)array toModelArrayWithContainClass:(NSArray *)containClasses{
    JsonUtils *resonseDataToModel = [[JsonUtils alloc]init];
    [resonseDataToModel setContainClass:containClasses];
    return [resonseDataToModel convertDictArrayToModelArray:array];
}

-(NSMutableArray *)convertDictArrayToModelArray:(NSArray *)arry{
    if(arry){
        NSMutableArray * retModelArray = [[NSMutableArray alloc]init];
        for(int i =0;i<arry.count;i++){
            id jsonObj = [arry objectAtIndex:i];
            if([jsonObj isKindOfClass: [NSString class]]){
                [retModelArray   addObject:jsonObj];
            }else if([jsonObj isKindOfClass:[NSDictionary class]]){
                Class modelClass = [self classFromDictionary:jsonObj];
                if(!modelClass){
                    continue;
                }
                id modelArrayItem = [self convertDictionary:jsonObj toModel:modelClass];
                [retModelArray addObject:modelArrayItem];
            }else{
                id modelArrayItem = [self convertDictArrayToModelArray:jsonObj];
                [retModelArray addObject:modelArrayItem];
            }
        }
        return retModelArray;
    }
    return nil;
}

/**
 判断dict所包含的数据可以转化为哪个类的实例对象
 @param dict json数据转化而成
 @return 可以转化为的类
 */
-(Class)classFromDictionary:(NSDictionary  *)dict{
    if(!self.containClass||!dict){
        return nil;
    }
    if(self.containClass.count==1){
        return [self.containClass firstObject];
    }
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
    for(int i =0;i<self.containClass.count;i++){
        Class modelClass = [self.containClass objectAtIndex:i];
        unsigned int varCount;
        Ivar *ivarList = class_copyIvarList(modelClass,&varCount);
         NSMutableArray *ivarArray = [[NSMutableArray alloc]init];
        for(int i =0;i<varCount;i++){
            const char *ivarNameChar = ivar_getName(ivarList[i]);
            NSString *ivarName = [[NSString stringWithUTF8String:ivarNameChar] substringFromIndex:1];
            [ivarArray addObject:ivarName];
        }
        free(ivarList);
        NSArray *dictKeyArray = [mDict allKeys];
        BOOL isCurrentModelClass = true;
        for(int i =0;i<[dictKeyArray count];i++){
            if(![ivarArray containsObject:[dictKeyArray objectAtIndex:i]]){
                if(![[dictKeyArray objectAtIndex:i] isEqualToString:@"id"]){
                    isCurrentModelClass = false;
                      NSLog(@"少字段：%@",[dictKeyArray objectAtIndex:i]);
                     continue;
                }
               
            }
        }
        if(isCurrentModelClass){
            return modelClass;
        }
    }
    NSLog(@"=============findClasssFail fromDict:%@",dict);
    return nil;
}

-(id)convertDictionary:(NSDictionary *)dict toModel:(Class )cls withContainClass:(NSArray *)array{
    self.containClass = array;
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
            
            id basicTypeObject = nil;
           
            basicTypeObject= [dict objectForKey:ivarName];
            if(!basicTypeObject&&[ivarName isEqualToString:@"Id"]){
                basicTypeObject= [dict objectForKey:@"id"];
            }
            if(!basicTypeObject){
                continue;
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
                NSArray *memberVariable =[self convertDictArrayToModelArray:memberVariableDictOrArrayForm];
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
    if([type isEqualToString:@""]){
        return true;
    }
    
    return false;
}

@end
