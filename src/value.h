#ifndef clox_value_h
#define clox_value_h
#include "common.h"
#include "stdio.h"

typedef struct Obj       Obj;
typedef struct ObjString ObjString;

typedef enum { VAL_BOOL, VAL_NIL, VAL_NUMBER, VAL_OBJ } ValueType;

typedef struct {
    ValueType type;
    union {
        bool   boolean;
        double number;
        Obj   *obj;
    } as;
} Value;

#define IS_BOOL(value)   ((value).type == VAL_BOOL)
#define IS_NIL(value)    ((value).type == VAL_NIL)
#define IS_NUMBER(value) ((value).type == VAL_NUMBER)
#define IS_OBJ(value)    ((value).type == VAL_OBJ)

#define AS_BOOL(value)   ((value).as.boolean)
#define AS_NUMBER(value) ((value).as.number)
#define AS_OBJ(value)    ((value).as.obj)

static inline Value boolValue(bool value) {
    Value result;
    result.type       = VAL_BOOL;
    result.as.boolean = value;
    return result;
}

static inline Value nilValue(void) {
    Value result;
    result.type      = VAL_NIL;
    result.as.number = 0;
    return result;
}

static inline Value objValue(Obj *object) {
    Value result;
    result.type   = VAL_OBJ;
    result.as.obj = object;
    return result;
}

static inline Value numberValue(double value) {
    Value result;
    result.type      = VAL_NUMBER;
    result.as.number = value;
    return result;
}

#define BOOL_VAL(value)   (boolValue(value))
#define NIL_VAL           (nilValue())
#define OBJ_VAL(object)   (objValue((Obj *)object))
#define NUMBER_VAL(value) (numberValue(value))

typedef struct {
    int    capacity;
    int    count;
    Value *values;
} ValueArray;

bool valuesEqual(Value a, Value b);
void initValueArray(ValueArray *array);
void writeValueArray(ValueArray *array, Value value);
void freeValueArray(ValueArray *array);
void printValue(FILE *f, Value value);

#endif
