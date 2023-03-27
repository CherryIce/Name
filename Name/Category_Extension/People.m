//
//  People.m
//  Name
//
//  Created by hubin on 2023/3/12.
//

#import "People.h"
#import "People+Exten.h"

#import <objc/runtime.h>

@implementation People

- (void)extensionFunc {
    NSLog(@"people do extensionFunc");
}

- (void) privateFunc:(id) object {
    NSLog(@"%@ privateFunc %@",self.class,object);
}

- (instancetype)initModleWithDictionary:(NSDictionary *) dic {
    if(self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

//让打印显示属性值
- (NSString *)description {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    unsigned int count;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for(unsigned int i = 0; i < count; i++){
        const char * propertyName = property_getName(propertyList[i]);
        NSString * propertyNameStr = [NSString stringWithUTF8String:propertyName];
        id value = [self valueForKey:propertyNameStr]?:@"nil";
        [dict setObject:value forKey:propertyNameStr];
    }
    free(propertyList);
    return [NSString stringWithFormat:@"%@ --- %@",self.class,dict];
}

@end
