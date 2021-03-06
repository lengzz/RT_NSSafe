//
//  NSObject+Safe.m
//  RunTimeDemo
//
//  Created by Lzz on 2017/7/7.
//  Copyright © 2017年 Lzz. All rights reserved.
//

#import "NSObject+Safe.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (Safe)

+ (void) swizzleClassSel:(SEL)origSel withSel:(SEL)newSel
{
    Class cls = [self class];
    Method origM = class_getClassMethod(cls, origSel);
    Method newM = class_getClassMethod(cls, newSel);
    
    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        origSel,
                        method_getImplementation(newM),
                        method_getTypeEncoding(newM)) ) {
        /* swizzing super class method, added if not exist */
        class_replaceMethod(metacls,
                            newSel,
                            method_getImplementation(origM),
                            method_getTypeEncoding(origM));
        
    } else {
        method_exchangeImplementations(origM, newM);
    }
}

+ (void) swizzleInstanceSel:(SEL)origSel withSel:(SEL)newSel
{
    Class cls = [self class];
    Method origM = class_getInstanceMethod(cls, origSel);
    Method newM = class_getInstanceMethod(cls, newSel);
    
    if(origM&&newM)
    {
        method_exchangeImplementations(origM, newM);
    }
}

@end

@implementation NSArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //class methods
        [self swizzleClassSel:@selector(arrayWithObjects:count:) withSel:@selector(safeArrayWithObjects:count:)];
        [self swizzleClassSel:@selector(arrayWithObject:) withSel:@selector(safeArrayWithObject:)];
        
        //instance methods
        /* 数组有内容obj类型才是__NSArrayI */
        Class cls = NSClassFromString(@"__NSArrayI");
        [cls swizzleInstanceSel:@selector(objectAtIndex:) withSel:@selector(safeObjectAtIndex:)];
        
        /* iOS10 以上，单个内容类型是__NSArraySingleObjectI */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
            cls = NSClassFromString(@"__NSSingleObjectArrayI");
            [cls swizzleInstanceSel:@selector(objectAtIndex:) withSel:@selector(safeObjectAtIndex1:)];
        }
        
        /* iOS9 以上，没内容类型是__NSArray0 */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
            cls = NSClassFromString(@"__NSArray0");
            [cls swizzleInstanceSel:@selector(objectAtIndex:) withSel:@selector(safeObjectAtIndex0:)];
        }
    });
}

+ (instancetype)safeArrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    id objTmp[cnt];
    for(int i=0;i<cnt;i++)
    {
        if(!objects[i])
            objTmp[i] = [NSNull null];
        else
            objTmp[i] = objects[i];
    }
    return [[self class] safeArrayWithObjects:objTmp count:cnt];
}

+ (instancetype)safeArrayWithObject:(id)obj
{
    if(!obj)
    {
        obj = [NSNull null];
    }
    return [[self class] safeArrayWithObject:obj];
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self safeObjectAtIndex:index];
    }
    return nil;
}

- (id)safeObjectAtIndex1:(NSUInteger)index
{
    if (index < self.count) {
        return [self safeObjectAtIndex1:index];
    }
    return nil;
}

- (id)safeObjectAtIndex0:(NSUInteger)index
{
    return nil;
}

@end

@implementation NSMutableArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"__NSArrayM");
        //instance methods
        [cls swizzleInstanceSel:@selector(objectAtIndex:) withSel:@selector(safeObjectAtIndex:)];
        [cls swizzleInstanceSel:@selector(addObject:) withSel:@selector(safeAddObject:)];
        [cls swizzleInstanceSel:@selector(insertObject:atIndex:) withSel:@selector(safeInsertObject:atIndex:)];
        [cls swizzleInstanceSel:@selector(removeObjectAtIndex:) withSel:@selector(safeRemoveObjectAtIndex:)];
        [cls swizzleInstanceSel:@selector(replaceObjectAtIndex:withObject:) withSel:@selector(safeReplaceObjectAtIndex:withObject:)];
    });
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index < self.count)
    {
        return [self safeObjectAtIndex:index];
    }
    return nil;
}

- (void)safeAddObject:(id)obj
{
    if (obj)
    {
        [self safeAddObject:obj];
    }
    else
    {
        
    }
}

- (void)safeInsertObject:(id)obj atIndex:(NSUInteger)index
{
    if (index <= self.count && obj)
    {
        [self safeInsertObject:obj atIndex:index];
    }
    else
    {
    
    }
}

- (void)safeRemoveObjectAtIndex:(NSUInteger)index
{
    if (index < self.count)
    {
        [self safeRemoveObjectAtIndex:index];
    }
    else
    {
    
    }
}

- (void)safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)obj
{
    if (index<self.count && obj)
    {
        [self safeReplaceObjectAtIndex:index withObject:obj];
    }
    else
    {
    
    }
}

@end

@implementation NSDictionary(Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //class methods
        [self swizzleClassSel:@selector(dictionaryWithObject:forKey:) withSel:@selector(safeDictionaryWithObject:forKey:)];
        [self swizzleClassSel:@selector(dictionaryWithObjects:forKeys:count:) withSel:@selector(safeDictionaryWithObjects:forKeys:count:)];
        
        //instance methods
        /* 字典有内容obj类型才是__NSDictionaryI */
        Class cls = NSClassFromString(@"__NSDictionaryI");
        [cls swizzleInstanceSel:@selector(objectForKey:) withSel:@selector(safeObjectForKey:)];
        
        /* iOS10 以上，单个内容类型是__NSSingleEntryDictionaryI */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
            cls = NSClassFromString(@"__NSSingleEntryDictionaryI");
            [cls swizzleInstanceSel:@selector(objectForKey:) withSel:@selector(safeObjectForKey1:)];
        }
        
        /* iOS9 以上，没内容类型是__NSDictionary0 */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
            cls = NSClassFromString(@"__NSDictionary0");
            [cls swizzleInstanceSel:@selector(objectForKey:) withSel:@selector(safeObjectForKey0:)];
        }
    });
}

+ (instancetype)safeDictionaryWithObject:(id)obj forKey:(id)key
{
    if (obj && key) {
        return [self safeDictionaryWithObject:obj forKey:key];
    }
    return nil;
}

+ (instancetype)safeDictionaryWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
{
    NSInteger index = 0;
    id ks[cnt];
    id objs[cnt];
    for (NSInteger i = 0; i < cnt; i++)
    {
        if (objects[i] && keys[i]) {
            ks[index] = keys[i];
            objs[index] = objects[i];
            index++;
        }
        else
        {
        
        }
    }
    return [self safeDictionaryWithObjects:objs forKeys:ks count:index];
}

- (id)safeObjectForKey:(id)aKey
{
    if (aKey)
    {
        return [self safeObjectForKey:aKey];
    }
    return nil;
}

- (id)safeObjectForKey1:(id)aKey
{
    if (aKey)
    {
        return [self safeObjectForKey1:aKey];
    }
    return nil;
}

- (id)safeObjectForKey0:(id)aKey
{
    if (aKey)
    {
        return [self safeObjectForKey0:aKey];
    }
    return nil;
}

@end

@implementation NSMutableDictionary(Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"__NSDictionaryM");
        //instance methods
        [cls swizzleInstanceSel:@selector(objectForKey:) withSel:@selector(safeObjectForKey:)];
        [cls swizzleInstanceSel:@selector(setObject:forKey:) withSel:@selector(safeSetObject:forKey:)];
        [cls swizzleInstanceSel:@selector(removeObjectForKey:) withSel:@selector(safeRemoveObjectForKey:)];
    });
}

- (id)safeObjectForKey:(id)aKey
{
    if (aKey)
    {
        return [self safeObjectForKey:aKey];
    }
    return nil;
}

- (void)safeRemoveObjectForKey:(id)aKey
{
    if (aKey)
    {
        [self safeRemoveObjectForKey:aKey];
    }
}

- (void)safeSetObject:(id)obj forKey:(id)aKey
{
    if (obj && aKey)
    {
        [self safeSetObject:obj forKey:aKey];
    }
}

@end
