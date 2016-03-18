/**
 * @file XujcLessonModel.m
 *
 * @author luckytianyiyan@gmail.com
 * @date 15/11/2
 * @copyright   Copyright © 2015年 luckytianyiyan. All rights reserved.
 */

#import "XujcLessonModel.h"

@implementation XujcLessonModel

- (instancetype)initWithJSONResopnse:(NSDictionary *)json
{
    if (self = [super init]) {
        _name = [self checkForNull:json[kResponseCourseName]];
        _courseClassId = [self checkForNull:json[kResponseCourseClassId]];
        _courseClass = [self checkForNull:json[kResponseCourseClass]];
        _semesterId = [self checkForNull:json[kResponseSemesterId]];
        _teacherDescription = [self checkForNull:json[kResponseTeacherDescription]];
        _credit = [[self checkForNull:json[kResponseCredit]] integerValue];
        _studyWay = [self checkForNull:json[kResponseStudyWay]];
        _studyWeekRange = [self checkForNull:json[kResponseStudyWeekRange]];
        _courseEventDescription = [self checkForNull:json[kResponseCourseCourseEventDescription]];
        NSArray *courseEventDataArray = json[kResponseCourseEvents];
        NSMutableArray *courseEventArray = [NSMutableArray arrayWithCapacity:courseEventDataArray.count];
        for (id courseEventData in courseEventDataArray) {
            XujcLessonEventModel *event = [[XujcLessonEventModel alloc] initWithJSONResopnse:courseEventData];
            event.name = _name;
            [courseEventArray addObject:event];
        }
        _courseEvents = courseEventArray;
        // TODO: unknow kcb_bz, kcb_rs
    }
    return self;
}

@end