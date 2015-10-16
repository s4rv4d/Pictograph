//
//  UIImageCoder.m
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "UIImageCoder.h"

#define bitCountForCharacter 8
#define bitCountForSize 16
#define bytesPerPixel 4

@implementation UIImageCoder

//Decodes UIImage image. Returns the encoded message in the image.
- (NSString *)decodeImage:(UIImage *)image {
    
    NSMutableString *decodedString = [[NSMutableString alloc] init];
    
    NSMutableArray *sizeArrayInBits = [[NSMutableArray alloc] init];
    
    //The first thing that needs to be done is get the size of the message, encoded in the first 8 pixels
    for (int sizeCounter = 0; sizeCounter < bitCountForSize / 2; sizeCounter++) { //2 bits per pixel
        NSArray *pixelBitArray = [self getRGBABitsFromImage:image atX:sizeCounter andY:0 count:1]; //TODO: Implement going to next line
        
        [sizeArrayInBits addObjectsFromArray:[pixelBitArray subarrayWithRange:NSMakeRange(6, 2)]]; //2 bits per pixel
    }
    
    long numberOfBitsNeededForImage = [self longFromBits:sizeArrayInBits];
    
    
    
    return decodedString;
    
}

//Encodes UIImage image with message message. Returns the modified UIImage
- (UIImage *)encodeImage:(UIImage *)image withMessage:(NSString *)message {

    /* Note: the actual number of pixels needed is higher than this because the length of the string needs to be
     stored, but this isn't included in the calculations */
    long numberOfBitsNeeded = [message length] * bitCountForCharacter; //8 bits to a char
    long numberOfPixelsNeeded = numberOfBitsNeeded / 2; //Storing 2 bits per pixel, so 4 pixels per char
    
    //TODO: Check if image is large enough
    
    /* Adding the size of the message here. Always using 16 bits for the size, even though it might only require 8,
     giving a maximum size of 2^16 bits, or 65536 chars */
    NSMutableArray *arrayOfBits = [[NSMutableArray alloc] init];
    [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:(int)numberOfBitsNeeded withSpaceFor:bitCountForSize]]; //16 bits for spacing
    
    for (int charIndex = 0; charIndex < [message length]; charIndex++) {
        //Going through each character
        
        char curChar = [message characterAtIndex:charIndex];
        [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:curChar withSpaceFor:bitCountForCharacter]]; //Only 8 bits needed for chars
        
    }
    
    //Right here we have all the bits that are needed to encode the data in the image
    
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Save current status of graphics context
    CGContextSaveGState(context);
    CGContextDrawImage(context, imageRect, image.CGImage);
    
    
    int encodeCounter = 0; //Counter which bit we are encoding, goes up 2 with each inner loop
    //for (int encodeCounter = 0; encodeCounter < [arrayOfBits count]; encodeCounter += 2) {
    for (int heightCounter = 0 ; heightCounter < image.size.height; heightCounter++) {
        for (int widthCounter = 0 ; widthCounter < image.size.width ; widthCounter++){
            //Going through each bit 2 by 2, that means we need to encode the pixel at position
            //(encodeCounter/2 [assuming it's an array]) with data at encodeCounter and encodeCounter + 1
        
            if (encodeCounter >= [arrayOfBits count]) {
                //If the message has been fully encoded, break
                break;
            }
            
            UIColor *colorOfCurrentPixel = [[self getRBGAFromImage:image atX:widthCounter andY:heightCounter count:1] firstObject];
            CGFloat red, green, blue, alpha ;
            [colorOfCurrentPixel getRed:&red green:&green blue:&blue alpha:&alpha];
            
            //Changing the value of the blue byte
            NSMutableArray *arrayOfBitsFromBlue = [[NSMutableArray alloc] initWithArray:[self binaryStringFromInteger:blue * 255 withSpaceFor:bitCountForCharacter]];
            
            //Changing the least significant bits of the blue byte
            [arrayOfBitsFromBlue replaceObjectAtIndex:6 withObject:arrayOfBits[encodeCounter]];
            [arrayOfBitsFromBlue replaceObjectAtIndex:7 withObject:arrayOfBits[encodeCounter + 1]];
            
            long newBlueValue = [self longFromBits:arrayOfBitsFromBlue];
            
            CGContextSetRGBFillColor(context, red, green, newBlueValue, alpha);
            CGContextFillRect(context, CGRectMake(widthCounter, heightCounter, 1, 1)); //Only filling in 1 pixel
        
            encodeCounter += 2; //2 bits per pixel, so increase by 2
        }
    }
    
    CGContextRestoreGState(context);
    
    UIImage *encodedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return encodedImage;

}

/* Returns the binary representation of a character */
//http://stackoverflow.com/questions/655792/how-to-convert-nsinteger-to-a-binary-string-value
//Used the above link as information, but instead decided to use an int array and remove spacing
-(NSArray *)binaryStringFromInteger:(int)number withSpaceFor:(int)numberOfBits{
    NSMutableArray *bitArray = [[NSMutableArray alloc] init];
    int binaryDigit = 0;
    int integer = number;
    
    while(binaryDigit < numberOfBits) {
        //Going through each binary digit
        binaryDigit++;
        
        [bitArray insertObject:((integer & 1) ? @1 : @0) atIndex:0];
        
        integer = integer >> 1;
    }
    
    return bitArray;
}

/* Returns the string based on the length provided in the first 16 bits of the bit array */
-(NSString *)stringFromBits:(NSArray *)bitArray {
    NSMutableString *message = [[NSMutableString alloc] init];
    
    NSArray *sizeInBits = [bitArray subarrayWithRange:NSMakeRange(0, bitCountForSize)];
    NSMutableString *sizeInBitsString = [[NSMutableString alloc] init];
    
    //TODO: We need to know the size before we get to this stage, but this is just for building the function
    for (int sizeCounter = 0; sizeCounter < bitCountForSize; sizeCounter++) {
        //Creating a single string with the size, easily convertible to an int
        [sizeInBitsString appendString:[NSString stringWithFormat:@"%@", [sizeInBits objectAtIndex:sizeCounter]]];
    }
    
    NSArray *characterArrayInBits = [bitArray subarrayWithRange:NSMakeRange(bitCountForSize, [bitArray count] - bitCountForSize)]; //TODO: This won't be necessary, we can use whole string when done
    for (int charBitCounter = 0; charBitCounter < [bitArray count] - bitCountForSize; charBitCounter += bitCountForCharacter) {
        //Going through each character
        NSArray *singleCharacterArray = [characterArrayInBits subarrayWithRange:NSMakeRange(charBitCounter, bitCountForCharacter)];

        long decimalRepresentationOfChar = [self longFromBits:singleCharacterArray];
        char curChar = (char)decimalRepresentationOfChar;
        
        [message appendFormat:@"%c", curChar];
    }
    
    
    return message;
}

/* Returns the long representation of a bit array */
// For example ("1101" -> 13)
-(long)longFromBits:(NSArray *)bitArray {
    
    NSMutableString *singleCharacterArrayInBits = [[NSMutableString alloc] init];
    
    for (int singleCharCounter = 0; singleCharCounter < [bitArray count]; singleCharCounter++) {
        //Creating a string of the bits that make up this one character, this is easily convertible to a char
        [singleCharacterArrayInBits appendString:[NSString stringWithFormat:@"%@", [bitArray objectAtIndex:singleCharCounter]]];
    }
    
    long longRep = strtol([singleCharacterArrayInBits UTF8String], NULL, 2);
    
    return longRep;
}

/* Returns the bit representation of the RBGA values for pixels starting at x, y for count number of pixels*/
//http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
//Used the above link as inspiration, but heavily modified
-(NSArray*)getRGBABitsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count {
    
    //Getting the raw data
    unsigned char *rawData = [self getRawPixelDataForImage:image];
    
    NSUInteger width = CGImageGetWidth(image.CGImage);
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;

    NSMutableArray *bitArrayOfPixels = [[NSMutableArray alloc] init];
    
    for (int counter = 0; counter < count; counter++) {
        
        //Getting the bits for each color space red, green, blue, and alpha
        [bitArrayOfPixels addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 0] * 1.0) withSpaceFor:bitCountForCharacter]]; //Red
        [bitArrayOfPixels addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 1] * 1.0) withSpaceFor:bitCountForCharacter]]; //Green
        [bitArrayOfPixels addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 2] * 1.0) withSpaceFor:bitCountForCharacter]]; //Blue
        [bitArrayOfPixels addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 3] * 1.0) withSpaceFor:bitCountForCharacter]]; //Alpha
        byteIndex += bytesPerPixel;
    
    }
    
    free(rawData);
    
    return bitArrayOfPixels;
}

/* Returns an array of UIColors for the pixels starting at x, y for count number of pixels */
-(NSArray *)getRBGAFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count {
    
    //Getting the raw data
    unsigned char *rawData = [self getRawPixelDataForImage:image];

    NSUInteger width = CGImageGetWidth(image.CGImage);
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    
    for (int counter = 0; counter < count; counter++) {
        //Getting the bits for each color space red, green, blue, and alpha
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += bytesPerPixel;
        
        UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        
        [colorArray addObject:newColor];
        
    }
    
    free(rawData);
    
    return colorArray;
}

/* Returns the raw pixel data for a UIImage image */
-(unsigned char *)getRawPixelDataForImage:(UIImage *)image {
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}

@end