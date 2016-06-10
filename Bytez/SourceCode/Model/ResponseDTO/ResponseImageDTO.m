//
//  ResponseImageDTO.m
//  Bytez
//
//  Created by HMSPL on 02/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "ResponseImageDTO.h"
#import "BytezSessionHandler.h"

@implementation ResponseImageDTO

-(NSDate*)createdOnDate
{
    return [NSDate dateWithTimeIntervalSince1970:(self.createdOn/1000.0)];
}


-(NSString*)postedTime
{
    //2015-01-14 11:21:33
    NSDate* date1 = [NSDate date];
    NSDate* date2 = self.createdOnDate;
    
//    NSString *str = @"10/01/2014 12:13:00";
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    
//    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
//    
//    date2 = [dateFormat dateFromString:str];
    
    NSTimeInterval distanceBetweenDates = [date1 timeIntervalSinceDate:date2];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unitFlags = NSWeekCalendarUnit;
    
    NSDateComponents *dateComponents;
    
    NSString *dateDifference;
    NSInteger differenceCount;
    
    if (distanceBetweenDates<0) {
        unitFlags = NSSecondCalendarUnit;
        dateComponents=[calendar components:unitFlags fromDate:date2  toDate:date1 options:0];
        differenceCount=0;
        dateDifference=@"min ago";
    }
    else if(distanceBetweenDates<3600)
    {
        unitFlags = NSMinuteCalendarUnit;
        dateComponents=[calendar components:unitFlags fromDate:date2  toDate:date1 options:0];
        differenceCount=[dateComponents minute];
        dateDifference=@"mins ago";
    }
    else if(distanceBetweenDates<86400)
    {
        unitFlags = NSHourCalendarUnit;
        dateComponents=[calendar components:unitFlags fromDate:date2  toDate:date1 options:0];
        differenceCount=[dateComponents hour];
        dateDifference=@"hours ago";
    }
    else
    {
        unitFlags = NSDayCalendarUnit;
        dateComponents=[calendar components:unitFlags fromDate:date2  toDate:date1 options:0];
        differenceCount=[dateComponents day];
        dateDifference=@"days ago";
    }
//    else if((distanceBetweenDates/604800)<7)
//    {
//        unitFlags = NSWeekCalendarUnit;
//        dateComponents=[calendar components:unitFlags fromDate:date2  toDate:date1 options:0];
//        differenceCount=[dateComponents week];
//        dateDifference=@"weeks ago";
//    }else if((distanceBetweenDates/604800)<53)
//    {
//        unitFlags = NSMonthCalendarUnit;
//        dateComponents=[calendar components:unitFlags fromDate:date2  toDate:date1 options:0];
//        differenceCount=[dateComponents month];
//        dateDifference=@"months ago";
//    }
//    else
//    {
//        unitFlags = NSYearCalendarUnit;
//        dateComponents=[calendar components:unitFlags fromDate:date2  toDate:date1 options:0];
//        differenceCount=[dateComponents year];
//        dateDifference=@"years ago";
//    }
    return [NSString stringWithFormat:@"%ld %@",(long)differenceCount,dateDifference];
}



-(NSString*)createdOnTime
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    return [dateFormat stringFromDate:self.createdOnDate];
}

-(NSString *)displayImage
{
    if (![self.location isKindOfClass:[NSNull class]]) {
        if ([self.location length]>0) {
        return @"locationicon.png";
        }}
    return @"icon-timestamp.png";
}

-(NSString *)displayText{
    if (![self.location isKindOfClass:[NSNull class]]) {
        if ([self.location length]>0) {
            return self.location;
        }
    }
    return self.postedTime;
}

-(BOOL)isEqual:(ResponseImageDTO*)object
{
    if ([object isKindOfClass:[ResponseImageDTO class]]) {
        ResponseImageDTO *obj=(ResponseImageDTO*)object;
        if (obj.imageId==self.imageId) {
            return YES;
        }else
        {
            return NO;
        }
    }
   return [super isEqual:object];
}

-(BOOL)isReportedByMe
{
    if ([self.strReportedByMe isEqualToString:@"False"]) {
        return NO;
    }
    return YES;
}

-(NSUInteger)hash
{
    return [super hash];
}

@end
