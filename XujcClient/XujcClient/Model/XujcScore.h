//
//  XujcScore.h
//  XujcClient
//
//  Created by 田奕焰 on 16/2/26.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

#import "BaseModel.h"

@interface XujcScore : BaseModel

@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, copy) NSString *midTermStatus;
@property (nonatomic, copy) NSString *endTermStatus;
@property (nonatomic, copy) NSString *scoreLevel;
@property (nonatomic, copy) NSString *studyWay;
/**
 *  @brief  学分
 */
@property(nonatomic, assign) NSInteger credit;

@end