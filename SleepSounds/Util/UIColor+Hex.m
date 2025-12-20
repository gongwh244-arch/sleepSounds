//
//  UIColor+Hex.m
//  color
//
//  Created by Andrew Sliwinski on 9/15/12.
//  Copyright (c) 2012 Andrew Sliwinski. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

/**
 * Creates a new UIColor instance using a hex input and alpha value.
 *
 * @param {UInt32} Hex
 * @param {CGFloat} Alpha
 *
 * @return {UIColor}
 */
+ (UIColor *)colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha
{
    int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
    
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:alpha];
}

/**
 * Creates a new UIColor instance using a hex input.
 *
 * @param {UInt32} Hex
 *
 * @return {UIColor}
 */

+ (UIColor *)colorWithARGBHex:(uint) hex
{
	int red, green, blue, alpha;
	
	blue = hex & 0x000000FF;
	green = ((hex & 0x0000FF00) >> 8);
	red = ((hex & 0x00FF0000) >> 16);
	alpha = ((hex & 0xFF000000) >> 24);
	
	return [UIColor colorWithRed:red/255.0f
						   green:green/255.0f
							blue:blue/255.0f
						   alpha:alpha/255.f];
}

+ (UIColor *)colorWithHex:(UInt32)hex
{
    if (hex > 0xffffff) {
        return [UIColor colorWithARGBHex:hex];
    }
    return [self colorWithHex:hex andAlpha:1.0];
}
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue {
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
                           green:((rgbValue & 0xFF00) >> 8) / 255.0f
                            blue:(rgbValue & 0xFF) / 255.0f
                           alpha:1];
}
/**
 * Creates a new UIColor instance using a hex string input.
 *
 * @param {NSString} Hex string (ie: @"ff", @"#fff", @"ff0000", or @"ff00ffcc")
 *
 * @return {UIColor}
 */
+ (UIColor *)colorWithHexString:(id)hexString
{
    if (![hexString isKindOfClass:[NSString class]] || [hexString length] == 0) {
        return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    }
    
    const char *s = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
    if (*s == '#') {
        ++s;
    }
    unsigned long long value = strtoll(s, nil, 16);
    unsigned long long r, g, b, a;
    switch (strlen(s)) {
        case 2:
            // xx
            r = g = b = value;
            a = 255;
            break;
        case 3:
            // RGB
            r = ((value & 0xf00) >> 8);
            g = ((value & 0x0f0) >> 4);
            b = ((value & 0x00f) >> 0);
            r = r * 16 + r;
            g = g * 16 + g;
            b = b * 16 + b;
            a = 255;
            break;
        case 6:
            // RRGGBB
            r = (value & 0xff0000) >> 16;
            g = (value & 0x00ff00) >>  8;
            b = (value & 0x0000ff) >>  0;
            a = 255;
            break;
        default:
            // RRGGBBAA
            r = (value & 0xff000000) >> 24;
            g = (value & 0x00ff0000) >> 16;
            b = (value & 0x0000ff00) >>  8;
            a = (value & 0x000000ff) >>  0;
            break;
    }
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
}

/**
 * Returns the hex value of the receiver. Alpha value is not included.
 *
 * @return {UInt32}
 */
- (UInt32)hexValue {
    CGFloat r = 0.f,g = 0.f,b = 0.f,a = 0.f;
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    UInt32 ri = r*255.0;
    UInt32 gi = g*255.0;
    UInt32 bi = b*255.0;
    
    return (ri<<16) + (gi<<8) + bi;
}

@end
