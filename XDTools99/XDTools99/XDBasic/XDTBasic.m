//
//  XDTBasic.m
//  XDTools99
//
//  Created by Henrik Wedekind on 12.12.16.
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

#import "XDTBasic.h"

#include <Python/Python.h>

#import "NSErrorPythonAdditions.h"
#import "NSArrayPythonAdditions.h"
#import "NSDataPythonAdditions.h"


#define XDTModuleNameBasic "xbas99"
#define XDTClassNameBasic "BasicProgram"


NS_ASSUME_NONNULL_BEGIN
@interface XDTBasic () {
    const PyObject *basicPythonModule;
    PyObject *basicProgramPythonClass;

    NSArray<NSString *>*_codeLines;
}

- (nullable instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options forModule:(PyObject *)pModule;

- (BOOL)loadData:(NSData *)data usingLongFormat:(BOOL)useLongFormat error:(NSError **)error;

@end
NS_ASSUME_NONNULL_END


@implementation XDTBasic

#pragma mark Initializers

/* This class method initialize this singleton. It takes care of all python module related things. */
+ (instancetype)basicWithOptions:(NSDictionary<NSString *, NSObject *> *)options
{
    assert(NULL != options);

    @synchronized (self) {
        PyObject *pName = PyString_FromString(XDTModuleNameBasic);
        PyObject *pModule = PyImport_Import(pName);
        Py_XDECREF(pName);
        if (NULL == pModule) {
            NSLog(@"ERROR: Importing module '%@' failed!", pName);
            PyObject *exeption = PyErr_Occurred();
            if (NULL != exeption) {
//            if (nil != error) {
//                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
//            }
            }
            return nil;
        }

        XDTBasic *retVal = [[XDTBasic alloc] initWithOptions:options forModule:pModule];
        Py_DECREF(pModule);
#if !__has_feature(objc_arc)
        return [retVal autorelease];
#endif
        return retVal;
    }
}


- (instancetype)initWithOptions:(NSDictionary<NSString *, id> *)options forModule:(PyObject *)pModule
{
    assert(NULL != pModule);

    self = [super init];
    if (nil == self) {
        return nil;
    }

    PyObject *pFunc = PyObject_GetAttrString(pModule, XDTClassNameBasic);
    if (NULL == pFunc || !PyCallable_Check(pFunc)) {
        NSLog(@"Cannot find function \"%s\" in module %s", XDTClassNameBasic, PyModule_GetName(pModule));
        if (PyErr_Occurred()) {
            PyErr_Print();
        }
        Py_XDECREF(pFunc);
#if !__has_feature(objc_arc)
        [self release];
#endif
        return nil;
    }

    /* reading options from dictionary */
    _protect = [[options valueForKey:XDTBasicOptionProtectFile] boolValue];
    _join = [[options valueForKey:XDTBasicOptionJoinLines] boolValue];

    /* creating basic object:
     basic = BasicProgram(data=None, source=None, long_=False)
     
     Comment: This is a bad constructor, it does not exclusevly do instantiating and allocating, it also already
        work with its instance.   So I won't do that, the initializor is for initializing only. After init, call
        methods for work on the instance.
     Behavior: If data is set, longFlag is also used and data will be loaded. If data is not set but source is set,
        the program code in it will be parsed. If non of these parameter are set, a normal initializing is done.
     */
    PyObject *basicObject = PyObject_CallObject(pFunc, NULL);
    Py_XDECREF(pFunc);
    if (NULL == basicObject) {
        NSLog(@"ERROR: calling constructor %@(None, None, False) failed!", pFunc);
        PyObject *exeption = PyErr_Occurred();
        if (NULL != exeption) {
//            if (nil != error) {
//                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
//            }
            PyErr_Print();
        }
#if !__has_feature(objc_arc)
        [self release];
#endif
        return nil;
    }

    basicPythonModule = pModule;
    Py_INCREF(basicPythonModule);
    basicProgramPythonClass = basicObject;

    _codeLines = nil;

    return self;
}


- (void)dealloc
{
    Py_CLEAR(basicProgramPythonClass);
    Py_CLEAR(basicPythonModule);

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}


#pragma mark - Property Wrapper


- (NSDictionary<NSNumber *, NSArray *> *)lines
{
    PyObject *linesObject = PyObject_GetAttrString(basicProgramPythonClass, "lines");
    if (NULL == linesObject) {
        return nil;
    }

    const Py_ssize_t lineCount = PyDict_Size(linesObject);
    NSMutableDictionary *retVal = [NSMutableDictionary dictionaryWithCapacity:lineCount];
    Py_ssize_t i = 0;
    PyObject *key = nil;
    PyObject *value = nil;
    while (PyDict_Next(linesObject, &i, &key, &value)) {
        long lineNumber = PyInt_AsLong(key);
        [retVal setObject:[NSArray arrayWithPyListOfString:value] forKey:[NSNumber numberWithInteger:lineNumber]];
    }

    Py_DECREF(linesObject);

    return retVal;
}


- (NSArray<NSString *> *)warnings
{
    PyObject *warningsObject = PyObject_GetAttrString(basicProgramPythonClass, "warnings");
    if (NULL == warningsObject) {
        return nil;
    }

    const Py_ssize_t warningCount = PyList_Size(warningsObject);
    NSMutableArray *retVal = [NSMutableArray arrayWithCapacity:warningCount];
    for (int i = 0; i < warningCount; i++) {
        PyObject *warningObject = PyList_GetItem(warningsObject, i);
        NSString *warningStr = [[NSString alloc] initWithBytes:PyString_AsString(warningObject) length:PyString_Size(warningObject)
                                                      encoding:NSUTF8StringEncoding];
        [retVal addObject:warningStr];
#if !__has_feature(objc_arc)
        [warningStr autorelease];
#endif
    }

    Py_DECREF(warningsObject);

    return retVal;
}


#pragma mark - Program to source code conversion Method Wrapper


/* load tokenized BASIC program in internal format */
- (BOOL)loadProgramData:(NSData *)data error:(NSError **)error
{
    return [self loadData:data usingLongFormat:NO error:error];
}


/* load tokenized BASIC program in long format */
- (BOOL)loadLongData:(NSData *)data error:(NSError **)error
{
    return [self loadData:data usingLongFormat:YES error:error];
}


- (BOOL)loadData:(NSData *)data usingLongFormat:(BOOL)useLongFormat error:(NSError **)error
{
    /* calling loader:
     load(data, long_)
     */
    PyObject *methodName = PyString_FromString("load");
    PyObject *pData = PyString_FromStringAndSize([data bytes], [data length]);
    PyObject *pLong = PyBool_FromLong(useLongFormat);
    PyObject *pNonValue = PyObject_CallMethodObjArgs(basicProgramPythonClass, methodName, pData, pLong, NULL);
    Py_XDECREF(pLong);
    Py_XDECREF(pData);
    Py_XDECREF(methodName);
    if (NULL == pNonValue) {
        NSLog(@"ERROR: load(%@, %@) returns NULL!", data, useLongFormat? @"true" : @"false");
        PyObject *exeption = PyErr_Occurred();
        if (NULL != exeption) {
            if (nil != error) {
                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
            }
            PyErr_Print();
        }
        return NO;
    }

    assert(Py_None == pNonValue);
    return YES;
}


/* load tokenized BASIC program in merge format */
- (BOOL)loadMergedData:(NSData *)data error:(NSError **)error
{
    /* calling loader:
     merge(data)
     */
    PyObject *methodName = PyString_FromString("merge");
    PyObject *pData = PyString_FromStringAndSize([data bytes], [data length]);
    PyObject *pNonValue = PyObject_CallMethodObjArgs(basicProgramPythonClass, methodName, pData, NULL);
    Py_XDECREF(pData);
    Py_XDECREF(methodName);
    if (NULL == pNonValue) {
        NSLog(@"ERROR: merge(%@) returns NULL!", data);
        PyObject *exeption = PyErr_Occurred();
        if (NULL != exeption) {
            if (nil != error) {
                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
            }
            PyErr_Print();
        }
        return NO;
    }

    assert(Py_None == pNonValue);
    return YES;
}


/* textual representation of token sequence */
- (NSString *)getSource:(NSError **)error
{
    /* calling:
     text = getSource()
     */
    PyObject *methodName = PyString_FromString("getSource");
    PyObject *pSourceCode = PyObject_CallMethodObjArgs(basicProgramPythonClass, methodName, NULL);
    Py_XDECREF(methodName);
    if (NULL == pSourceCode) {
        NSLog(@"ERROR: getSource() returns NULL!");
        PyObject *exeption = PyErr_Occurred();
        if (NULL != exeption) {
            if (nil != error) {
                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
            }
            PyErr_Print();
        }
        return nil;
    }

    NSString *retVal = [NSString stringWithCString:PyString_AsString(pSourceCode) encoding:NSUTF8StringEncoding];
    return retVal;
}


#pragma mark - Source code to program conversion Method Wrapper


/* parse and tokenize BASIC source code */
- (BOOL)parseSourceCode:(NSString *)sourceCode error:(NSError **)error
{
    if (0 == [sourceCode length]) {
        return YES; // an empty source code always parsed into an empty result
    }

    /* preparing source code matching Pythons data structure */
    NSArray<NSString *> *lines = [sourceCode componentsSeparatedByString:@"\n"];    /* TODO: respect other line endings... */
    PyObject *pLinesList = PyList_New(0);
    if (NULL == pLinesList) {
        return NO;
    }
    for (NSString *line in lines) {
        NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n"]];
        if (0 < [trimmedLine length]) { /* skip empty lines */
            PyObject *pLine = PyString_FromString([trimmedLine UTF8String]);
            PyList_Append(pLinesList, pLine);
        }
    }

    if (_join) {
        /* calling static method join:
         lines = BasicProgram.join(lines, maxLinoDelta=delta)
         */
        /* TODO: Make the line delta (here fixed to 10) configurable by UI */
        PyObject *methodName = PyString_FromString("join");
        PyObject *pLineDelta = PyInt_FromLong(10);
        PyObject *joinedLines = PyObject_CallMethodObjArgs(basicProgramPythonClass, methodName, pLinesList, pLineDelta, NULL);
        Py_XDECREF(pLineDelta);
        Py_XDECREF(methodName);
        if (NULL == joinedLines) {  /* if result is null, the line delta could be wrong configured. */
            NSLog(@"ERROR: join(%@, 10) returns NULL!", lines);
            PyObject *exeption = PyErr_Occurred();
            if (NULL != exeption) {
                if (nil != error) {
                    *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:@"Choose another value for the Line Delta, unwrap lines by hand in the integrated source code editor or fix the source file with an external text editor application and reload the file."];
                }
                PyErr_Print();
            }
            return NO;
        }
        Py_DECREF(pLinesList);
        pLinesList = joinedLines;
    }

    /* calling parser:
     parse(lines)
     */
    PyObject *methodName = PyString_FromString("parse");
    PyObject *pNonValue = PyObject_CallMethodObjArgs(basicProgramPythonClass, methodName, pLinesList, NULL);
    Py_DECREF(pLinesList);
    Py_XDECREF(methodName);
    if (NULL == pNonValue) {
        NSLog(@"ERROR: parse(%@) returns NULL!", lines);
        PyObject *exeption = PyErr_Occurred();
        if (NULL != exeption) {
            if (nil != error) {
                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
            }
            PyErr_Print();
        }
        return NO;
    }

    assert(Py_None == pNonValue);
    return YES;
}


- (BOOL)saveProgramFormatFile:(NSURL *)fileURL error:(NSError **)error
{
    return [self saveFile:fileURL usingLongFormat:NO error:error];
}


- (BOOL)saveLongFormatFile:(NSURL *)fileURL error:(NSError **)error
{
    return [self saveFile:fileURL usingLongFormat:YES error:error];
}


- (BOOL)saveFile:(NSURL *)fileURL usingLongFormat:(BOOL)useLongFormat error:(NSError **)error
{
    /* calling:
     data = getImage(long_=opts.long_, protected=opts.protect)
     */
    PyObject *methodName = PyString_FromString("getImage");
    PyObject *pLongOpt = PyBool_FromLong(useLongFormat);
    PyObject *pProtectOpt = PyBool_FromLong(_protect);
    PyObject *pProgramData = PyObject_CallMethodObjArgs(basicProgramPythonClass, methodName, pLongOpt, pProtectOpt, NULL);
    Py_XDECREF(pProtectOpt);
    Py_XDECREF(pLongOpt);
    Py_XDECREF(methodName);
    if (NULL == pProgramData) {
        NSLog(@"ERROR: getImage(%@, %@) returns NULL!", useLongFormat? @"true" : @"false", _protect? @"true" : @"false");
        PyObject *exeption = PyErr_Occurred();
        if (NULL != exeption) {
            if (nil != error) {
                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
            }
            PyErr_Print();
        }
        return NO;
    }

    NSData *fileData = [NSData dataWithPythonString:pProgramData];
    BOOL retVal = [fileData writeToURL:fileURL atomically:YES];

    Py_DECREF(pProgramData);

    return retVal;
}


- (BOOL)saveMergedFormatFile:(NSURL *)fileURL error:(NSError **)error
{
    if (nil != error) {
        *error = [NSError errorWithDomain:XDTErrorDomain code:-1
                                 userInfo:@{NSLocalizedDescriptionKey: @"Operation not supported",
                                            NSLocalizedFailureReasonErrorKey: @"Program creation in MERGE format is not supported by xbas99."}];
    }
    return NO;
}


- (NSString *)dumpTokenList:(NSError **)error
{
    /* calling:
     result = dumpTokens()
     */
    PyObject *methodName = PyString_FromString("dumpTokens");
    PyObject *pDumpString = PyObject_CallMethodObjArgs(basicProgramPythonClass, methodName, NULL);
    Py_XDECREF(methodName);
    if (NULL == pDumpString) {
        NSLog(@"ERROR: dumpTokens() returns NULL!");
        PyObject *exeption = PyErr_Occurred();
        if (NULL != exeption) {
            if (nil != error) {
                *error = [NSError errorWithPythonError:exeption code:-2 RecoverySuggestion:nil];
            }
            PyErr_Print();
        }
        return nil;
    }

    NSString *retVal = [NSString stringWithUTF8String:PyString_AsString(pDumpString)];
    return retVal;
}

@end