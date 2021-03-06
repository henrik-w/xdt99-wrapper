//
//  NSSetPythonAdditions.m
//  XDTools99
//
//  Created by henrik on 22.06.19.
//
//  XDTools99.framework a collection of Objective-C wrapper for xdt99
//  Copyright © 2019 Henrik Wedekind (aka hackmac). All rights reserved.
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

#import "NSSetPythonAdditions.h"

#import "NSDataPythonAdditions.h"
#import "NSArrayPythonAdditions.h"
#import "NSStringPythonAdditions.h"


@implementation NSSet (NSSetPythonAdditions)

+ (nullable NSSet<id> *)setWithPyTuple:(PyObject *)dataTuple
{
    assert(NULL != dataTuple && PyTuple_Check(dataTuple));

    const Py_ssize_t dataCount = PyTuple_Size(dataTuple);
    if (0 > dataCount) {
        return nil;
    }
    NSMutableSet<id> *retVal = [NSMutableSet setWithCapacity:dataCount];
    for (Py_ssize_t i = 0; i < dataCount; i++) {
        PyObject *dataItem = PyTuple_GetItem(dataTuple, i);
        if (NULL != dataItem) {
            if (PyInt_Check(dataItem)) {
                NSNumber *object = [NSNumber numberWithLong:PyInt_AsLong(dataItem)];
                [retVal addObject:object];
            } else if (PyString_Check(dataItem)) {
                NSData *object = [NSData dataWithPythonString:dataItem];
                [retVal addObject:object];
            } else if (PyList_Check(dataItem)) {
                NSArray *object = [NSArray arrayWithPyList:dataItem];
                [retVal addObject:object];
            } else if (PyTuple_Check(dataItem)) {
                NSArray *object = [NSArray arrayWithPyTuple:dataItem];
                [retVal addObject:object];
            } else if (Py_None == dataItem) {
                NSNull *object = [NSNull null];
                [retVal addObject:object];
            } else {
                PyTypeObject *dataType = dataItem->ob_type;
                NSLog(@"%s ERROR: Cannot convert Python type '%s' to an Objective-C type", __FUNCTION__, dataType->tp_name);
            }
        }
    }

    return retVal;
}


+ (nullable NSSet<id> *)setWithPyList:(PyObject *)dataList
{
    assert(NULL != dataList && PyList_Check(dataList));

    const Py_ssize_t dataCount = PyTuple_Size(dataList);
    if (0 > dataCount) {
        return nil;
    }
    NSMutableSet<id> *retVal = [NSMutableSet setWithCapacity:dataCount];
    for (Py_ssize_t i = 0; i < dataCount; i++) {
        PyObject *dataItem = PyTuple_GetItem(dataList, i);
        if (NULL != dataItem) {
            if (PyInt_Check(dataItem)) {
                NSNumber *object = [NSNumber numberWithLong:PyInt_AsLong(dataItem)];
                [retVal addObject:object];
            } else if (PyString_Check(dataItem)) {
                NSData *object = [NSData dataWithPythonString:dataItem];
                [retVal addObject:object];
            } else if (PyList_Check(dataItem)) {
                NSArray *object = [NSArray arrayWithPyList:dataItem];
                [retVal addObject:object];
            } else if (PyTuple_Check(dataItem)) {
                NSArray *object = [NSArray arrayWithPyTuple:dataItem];
                [retVal addObject:object];
            } else if (Py_None == dataItem) {
                NSNull *object = [NSNull null];
                [retVal addObject:object];
            } else {
                PyTypeObject *dataType = dataItem->ob_type;
                NSLog(@"%s ERROR: Cannot convert Python type '%s' to an Objective-C type", __FUNCTION__, dataType->tp_name);
            }
        }
    }

    return retVal;
}


+ (nullable NSSet<NSArray<id> *> *)setWithPyListOfTuple:(PyObject *)dataList
{
    assert(NULL != dataList && PyList_Check(dataList));

    const Py_ssize_t dataCount = PyList_Size(dataList);
    if (0 > dataCount) {
        return nil;
    }
    NSMutableSet<NSArray<id> *> *retVal = [NSMutableSet setWithCapacity:dataCount];
    if (0 == dataCount) {
        return retVal;
    }

    PyObject *dataItem = PyList_GetItem(dataList, 0);
    if (NULL == dataItem || !PyTuple_Check(dataItem)) {
        return retVal;
    }
    for (Py_ssize_t i = 0; i < dataCount; i++) {
        PyObject *dataTupel = PyList_GetItem(dataList, i);
        if (NULL != dataTupel) {
            NSArray<id> *dataArray = [NSArray arrayWithPyTuple:dataTupel];
            [retVal addObject:dataArray];
        }
    }

    return retVal;
}


+ (nullable NSMutableSet<NSData *> *)setWithPyListOfData:(PyObject *)dataList
{
    assert(NULL != dataList && PyList_Check(dataList));

    const Py_ssize_t dataCount = PyList_Size(dataList);
    if (0 > dataCount) {
        return nil;
    }
    NSMutableSet<NSData *> *retVal = [NSMutableSet setWithCapacity:dataCount];

    for (Py_ssize_t i = 0; i < dataCount; i++) {
        PyObject *dataItem = PyList_GetItem(dataList, i);
        if (NULL != dataItem) {
            NSData *imageData = [NSData dataWithPythonString:dataItem];
            if (nil != imageData) {
                [retVal addObject:imageData];
            }
        }
    }

    return retVal;
}


+ (nullable NSMutableSet<NSString *> *)setWithPyListOfString:(PyObject *)dataList
{
    assert(NULL != dataList && PyList_Check(dataList));

    const Py_ssize_t dataCount = PyList_Size(dataList);
    if (0 > dataCount) {
        return nil;
    }
    NSMutableSet<NSString *> *retVal = [NSMutableSet setWithCapacity:dataCount];
    if (0 == dataCount) {
        return retVal;
    }

    PyObject *dataItem = PyList_GetItem(dataList, 0);
    if (NULL == dataItem || !PyString_Check(dataItem)) {
        return retVal;
    }
    for (Py_ssize_t i = 0; i < dataCount; i++) {
        PyObject *dataItem = PyList_GetItem(dataList, i);
        if (NULL != dataItem) {
            [retVal addObject:[NSString stringWithPythonString:dataItem encoding:NSUTF8StringEncoding]];
        }
    }

    return retVal;
}

@end
