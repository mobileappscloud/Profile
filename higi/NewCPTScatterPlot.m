//
//  NewCPTScatterPlot.m
//  higi
//
//  Created by Dan Harms on 6/23/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import "NewCPTScatterPlot.h"

@implementation NewCPTScatterPlot

-(void) setAreaBaseDecimalValue:(double)areaBaseValue {
    [self setAreaBaseValue:CPTDecimalFromDouble(areaBaseValue)];
}

-(CGPathRef)newDataLinePathForViewPoints:(CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineYValue:(CGFloat)baselineYValue
{
    CPTScatterPlotInterpolation theInterpolation = self.interpolation;
    
    if ( theInterpolation == CPTScatterPlotInterpolationCurved ) {
        return [self newCurvedDataLinePathForViewPoints:viewPoints indexRange:indexRange baselineYValue:baselineYValue];
    }
    
    CGMutablePathRef dataLinePath  = CGPathCreateMutable();
    BOOL lastPointSkipped          = YES;
    CGPoint firstPoint             = CGPointZero;
    CGPoint lastPoint              = CGPointZero;
    NSUInteger lastDrawnPointIndex = NSMaxRange(indexRange);
    BOOL drawSpecial = NO;
    
    CGPoint p1 = viewPoints[0];
    CGPoint p2 = viewPoints[1];
    if ( indexRange.length > 2 ) {
        drawSpecial = viewPoints[0].x == viewPoints[1].x;
    }
    if ( lastDrawnPointIndex > 0 ) {
        lastDrawnPointIndex--;
    }
    
    for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
        CGPoint viewPoint = viewPoints[i];
        
        if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
            if ( !lastPointSkipped ) {
                if ( !isnan(baselineYValue) ) {
                    CGPathAddLineToPoint(dataLinePath, NULL, lastPoint.x, baselineYValue);
                    CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, baselineYValue);
                    CGPathCloseSubpath(dataLinePath);
                }
                lastPointSkipped = YES;
            }
        }
        else {
            if ( lastPointSkipped ) {
                CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                lastPointSkipped = NO;
                firstPoint       = viewPoint;
            }
            else {
                switch ( theInterpolation ) {
                    case CPTScatterPlotInterpolationLinear:
                        if (lastPoint.x == viewPoint.x) {
                            CGPathMoveToPoint(dataLinePath, NULL, lastPoint.x, lastPoint.y);
                            CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                        }
                        break;
                        
                    case CPTScatterPlotInterpolationStepped:
                        CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, lastPoint.y);
                        CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                        break;
                        
                    case CPTScatterPlotInterpolationHistogram:
                    {
                        CGFloat x = (lastPoint.x + viewPoint.x) / CPTFloat(2.0);
                        CGPathAddLineToPoint(dataLinePath, NULL, x, lastPoint.y);
                        CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoint.y);
                        CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                    }
                        break;
                        
                    case CPTScatterPlotInterpolationCurved:
                        // Curved plot lines handled separately
                        break;
                        
                    default:
                        [NSException raise:CPTException format:@"Interpolation method not supported in scatter plot."];
                        break;
                }
            }
            lastPoint = viewPoint;
        }
    }
    
    if ( !lastPointSkipped && !isnan(baselineYValue) ) {
        CGPathAddLineToPoint(dataLinePath, NULL, lastPoint.x, baselineYValue);
        CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, baselineYValue);
        CGPathCloseSubpath(dataLinePath);
    }
    
    return dataLinePath;
}

-(CGPathRef)newCurvedDataLinePathForViewPoints:(CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineYValue:(CGFloat)baselineYValue
{
    CGMutablePathRef dataLinePath  = CGPathCreateMutable();
    BOOL lastPointSkipped          = YES;
    CGPoint firstPoint             = CGPointZero;
    CGPoint lastPoint              = CGPointZero;
    NSUInteger firstIndex          = indexRange.location;
    NSUInteger lastDrawnPointIndex = NSMaxRange(indexRange);

    if ( lastDrawnPointIndex > 0 ) {
        CGPoint *controlPoints1 = calloc( lastDrawnPointIndex, sizeof(CGPoint) );
        CGPoint *controlPoints2 = calloc( lastDrawnPointIndex, sizeof(CGPoint) );
        
        lastDrawnPointIndex--;
        
        // Compute control points for each sub-range
        for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
            CGPoint viewPoint = viewPoints[i];
            
            if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
                if ( !lastPointSkipped ) {
                    [self computeControlPoints:controlPoints1
                                       points2:controlPoints2
                                 forViewPoints:viewPoints
                                    indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                    
                    lastPointSkipped = YES;
                }
            }
            else {
                if ( lastPointSkipped ) {
                    lastPointSkipped = NO;
                    firstIndex       = i;
                }
            }
        }
        
        if ( !lastPointSkipped ) {
            [self computeControlPoints:controlPoints1
                               points2:controlPoints2
                         forViewPoints:viewPoints
                            indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
        }
        
        // Build the path
        lastPointSkipped = YES;
        for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
            CGPoint viewPoint = viewPoints[i];
            
            if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
                if ( !lastPointSkipped ) {
                    if ( !isnan(baselineYValue) ) {
                        CGPathAddLineToPoint(dataLinePath, NULL, lastPoint.x, baselineYValue);
                        CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, baselineYValue);
                        CGPathCloseSubpath(dataLinePath);
                    }
                    lastPointSkipped = YES;
                }
            }
            else {
                if ( lastPointSkipped ) {
                    CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                    lastPointSkipped = NO;
                    firstPoint       = viewPoint;
                }
                else {
                    CGPoint cp1 = controlPoints1[i];
                    CGPoint cp2 = controlPoints2[i];
                    
                    CGPathAddCurveToPoint(dataLinePath, NULL, MAX(MIN(cp1.x, viewPoint.x), lastPoint.x), MAX(MIN(cp1.y, viewPoint.y), lastPoint.y), MAX(MIN(MAX(cp1.x, cp2.x), viewPoint.x), lastPoint.x), MAX(MIN(MAX(cp1.y, cp2.y), viewPoint.y), lastPoint.y), viewPoint.x, viewPoint.y);
                }
                lastPoint = viewPoint;
            }
        }
        
        if ( !lastPointSkipped && !isnan(baselineYValue) ) {
            CGPathAddLineToPoint(dataLinePath, NULL, lastPoint.x, baselineYValue);
            CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, baselineYValue);
            CGPathCloseSubpath(dataLinePath);
        }
        
        free(controlPoints1);
        free(controlPoints2);
    }
    
    return dataLinePath;
}

// Compute the control points using the algorithm described at http://www.particleincell.com/blog/2012/bezier-splines/
// cp1, cp2, and viewPoints should point to arrays of points with at least NSMaxRange(indexRange) elements each.
-(void)computeControlPoints:(CGPoint *)cp1 points2:(CGPoint *)cp2 forViewPoints:(CGPoint *)viewPoints indexRange:(NSRange)indexRange
{
    if ( indexRange.length == 2 ) {
        NSUInteger rangeEnd = NSMaxRange(indexRange) - 1;
        cp1[rangeEnd] = viewPoints[indexRange.location];
        cp2[rangeEnd] = viewPoints[rangeEnd];
    }
    else if ( indexRange.length > 2 ) {
        NSUInteger n = indexRange.length - 1;
        
        // rhs vector
        CGPoint *a = malloc( n * sizeof(CGPoint) );
        CGPoint *b = malloc( n * sizeof(CGPoint) );
        CGPoint *c = malloc( n * sizeof(CGPoint) );
        CGPoint *r = malloc( n * sizeof(CGPoint) );
        
        // left most segment
        a[0] = CGPointZero;
        b[0] = CPTPointMake(2.0, 2.0);
        c[0] = CPTPointMake(1.0, 1.0);
        
        CGPoint pt0 = viewPoints[indexRange.location];
        CGPoint pt1 = viewPoints[indexRange.location + 1];
        r[0] = CGPointMake(pt0.x + CPTFloat(2.0) * pt1.x,
                           pt0.y + CPTFloat(2.0) * pt1.y);
        
        // internal segments
        for ( NSUInteger i = 1; i < n - 1; i++ ) {
            a[i] = CPTPointMake(1.0, 1.0);
            b[i] = CPTPointMake(4.0, 4.0);
            c[i] = CPTPointMake(1.0, 1.0);
            
            CGPoint pti  = viewPoints[indexRange.location + i];
            CGPoint pti1 = viewPoints[indexRange.location + i + 1];
            r[i] = CGPointMake(CPTFloat(4.0) * pti.x + CPTFloat(2.0) * pti1.x,
                               CPTFloat(4.0) * pti.y + CPTFloat(2.0) * pti1.y);
        }
        
        // right segment
        a[n - 1] = CPTPointMake(2.0, 2.0);
        b[n - 1] = CPTPointMake(7.0, 7.0);
        c[n - 1] = CGPointZero;
        
        CGPoint ptn1 = viewPoints[indexRange.location + n - 1];
        CGPoint ptn  = viewPoints[indexRange.location + n];
        r[n - 1] = CGPointMake(CPTFloat(8.0) * ptn1.x + ptn.x,
                               CPTFloat(8.0) * ptn1.y + ptn.y);
        
        // solve Ax=b with the Thomas algorithm (from Wikipedia)
        for ( NSUInteger i = 1; i < n; i++ ) {
            CGPoint m = CGPointMake(a[i].x / b[i - 1].x,
                                    a[i].y / b[i - 1].y);
            b[i] = CGPointMake(b[i].x - m.x * c[i - 1].x,
                               b[i].y - m.y * c[i - 1].y);
            r[i] = CGPointMake(r[i].x - m.x * r[i - 1].x,
                               r[i].y - m.y * r[i - 1].y);
        }
        
        cp1[indexRange.location + n] = CGPointMake(r[n - 1].x / b[n - 1].x,
                                                   r[n - 1].y / b[n - 1].y);
        for ( NSUInteger i = n - 2; i > 0; i-- ) {
            cp1[indexRange.location + i + 1] = CGPointMake( (r[i].x - c[i].x * cp1[indexRange.location + i + 2].x) / b[i].x,
                                                           (r[i].y - c[i].y * cp1[indexRange.location + i + 2].y) / b[i].y );
        }
        cp1[indexRange.location + 1] = CGPointMake( (r[0].x - c[0].x * cp1[indexRange.location + 2].x) / b[0].x,
                                                   (r[0].y - c[0].y * cp1[indexRange.location + 2].y) / b[0].y );
        
        // we have p1, now compute p2
        NSUInteger rangeEnd = NSMaxRange(indexRange) - 1;
        for ( NSUInteger i = indexRange.location + 1; i < rangeEnd; i++ ) {
            cp2[i] = CGPointMake(CPTFloat(2.0) * viewPoints[i].x - cp1[i + 1].x,
                                 CPTFloat(2.0) * viewPoints[i].y - cp1[i + 1].y);
        }
        
        cp2[rangeEnd] = CGPointMake( CPTFloat(0.5) * (viewPoints[rangeEnd].x + cp1[rangeEnd].x),
                                    CPTFloat(0.5) * (viewPoints[rangeEnd].y + cp1[rangeEnd].y) );
        
        // clean up
        free(a);
        free(b);
        free(c);
        free(r);
    }
}

@end
