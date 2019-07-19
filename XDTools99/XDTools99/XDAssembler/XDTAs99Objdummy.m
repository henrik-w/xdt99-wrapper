//
//  XDTAs99Objdummy.m
//  SimpleXDT99
//
//  Created by Henrik Wedekind on 30.06.19.
//
//  XDTools99.framework a collection of Objective-C wrapper for xdt99
//  Copyright © 2016 Henrik Wedekind (aka hackmac). All rights reserved.
//
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as
//  published by the Free Software Foundation; either version 2.1 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with this program; if not, see <http://www.gnu.org/licenses/>
//

#import "XDTAs99Objdummy.h"

#import <Python/Python.h>


#define XDTClassNameObjdummy "Objdummy"


NS_ASSUME_NONNULL_BEGIN

@interface XDTAs99Objdummy () {
    PyObject *objdummyPythonClass;
}

- (nullable instancetype)initWithPythonInstance:(void *)object;

@end

NS_ASSUME_NONNULL_END


@implementation XDTAs99Objdummy

+ (instancetype)objdummyWithPythonInstance:(void *)object
{
    XDTAs99Objdummy *retVal = [[XDTAs99Objdummy alloc] initWithPythonInstance:object];
#if !__has_feature(objc_arc)
    [retVal autorelease];
#endif
    return retVal;
}


- (instancetype)initWithPythonInstance:(void *)object
{
    self = [super init];
    if (nil == self) {
        return nil;
    }

    objdummyPythonClass = object;
    Py_INCREF(objdummyPythonClass);

    return self;
}


- (void)dealloc
{
    Py_CLEAR(objdummyPythonClass);

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}


#pragma mark - Property Wrapper


// Currently no property wrapper for accessors of Objdummy implemented


#pragma mark - Method Wrapper


// Currently no method wrapper for accessors of Objdummy implemented


@end