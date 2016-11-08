//
//  AlbumViewController.m
//  uPlayer
//
//  Created by liaogang on 15/10/14.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "AlbumViewController.h"
#import "keycode.h"
#import "PlayerMessage.h"
#import "PlayerEngine.h"
#import "FFT.h"



void drawGradientRect(CGContextRef context,CGRect rc);
void drawPeaks(CGContextRef context,CGRect rc,int band);


const int bands = 30;
@interface SpectrumView : NSView
@property (nonatomic,strong) FFTSampleBlock *sampleBlock;
@property (nonatomic,unsafe_unretained) FFT *fft;
@property (nonatomic) CGContextRef myContext;
@end



@interface AlbumViewController ()

@property (weak) IBOutlet NSImageView *imageView;

@property (weak) IBOutlet SpectrumView *spectrumView;

@property (nonatomic) bool viewAppear;
@end


@implementation AlbumViewController

+(instancetype)instanceFromStoryboard
{
    return  [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AlbumViewControllerID"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    addObserverForEvent(self, @selector(drawSpectrum:), EventID_to_draw_spectrum);
}

const int  DEFAULT_SAMPLE_SIZE = 16000;  //one time read from file

-(void)drawSpectrum:(NSNotification*)n
{
    if (self.viewAppear)
    {
        FFTSampleBlock *sampleBlock = n.object;
        self.spectrumView.sampleBlock = sampleBlock;
        
        [self.spectrumView setNeedsDisplay:YES];
    }
    
}

-(void)viewWillAppear
{
    [super viewWillAppear];
    
    self.viewAppear = true;
}

-(void)viewDidDisappear
{
    [super viewDidDisappear];
    
    self.viewAppear = false;
}


-(void)setAlbumImage:(NSImage*)image
{
    [self.imageView setImage:image];
}

-(void)keyDown:(NSEvent *)theEvent
{
    printf("key pressed: %s\n", [[theEvent description] UTF8String]);
    
    NSString *keyString = keyStringFormKeyCode(theEvent.keyCode);
    
    
    if([keyString isEqualToString:@"ESCAPE"])
    {
        [self.w switchViewMode];
    }
   
}




@end

@implementation SpectrumView


-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.fft = new FFT( FFT_SAMPLE_SIZE );
    }
    return self;   
}

-(void)dealloc
{
    delete self.fft;
}

-(void)drawRect:(NSRect)dirtyRect
{
    if (self.sampleBlock && self.sampleBlock.pSampleL)
    {
        NSAssert(self.fft, @"");
        
        float* lpFloatFFTData = self.fft ->calculate(self.sampleBlock.pSampleL, FFT_SAMPLE_SIZE);
        
        
        float *m_floatMag = lpFloatFFTData;
//        float m_floatMag[DEFAULT_SAMPLE_SIZE/2];
//        memcpy(m_floatMag, lpFloatFFTData, FFT_SAMPLE_SIZE/2);
        
        
        int m_floatMagDecay[DEFAULT_SAMPLE_SIZE/2];
        
        
        
        
        float c = 0;
        float floatFrrh = 1.0;
        float floatDecay = (float)0.05f;
        float floatSadFrr = (floatFrrh*floatDecay);
        float floatBandWidth = ((float)(self.bounds.size.width)/(float)bands);
        float floatMultiplier = 2.0;
        
        if (self.myContext == nil)
        {
            self.myContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
            //draw background
//            CGContextSetRGBFillColor (self.myContext, 1, 1, 1, 1);
            //CGContextFillRect (self.myContext, self.bounds );
        }
       
        
        //draw bands
        CGContextSetRGBFillColor (self.myContext, 24/255.0, 171/255.0, 237/225.0, 1);

        
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        const CGFloat bandspace = 3;
        
        const CGFloat topSpace = 5;
        
        const CGFloat bottomSpace = 0;
        
        CGFloat bandWidth = (width - bandspace ) / bands - bandspace;
        
        CGFloat bandHeight = height - topSpace - bottomSpace;
        
        
        
        for(int a=0, band=0; band < bands; a+=(int)floatMultiplier, band++)
        {
            float wFs = 0;
            
            // -- Average out nearest bands.
            for (int b = 0; b < floatMultiplier; b++)
                wFs += m_floatMag[a + b];
            
            // -- Log filter.
            wFs = (wFs * (float) log((float)(band + 2.0f)));
            
            //  		if (wFs>0.005f && wFs <0.009f)
            //  			wFs*=1.2f;
            //  		else if (wFs >0.01f && wFs <0.1f)
            //  			wFs*=1.4f;
            // 		else if ( wFs > 0.1f && wFs < 0.5f)
            // 			wFs*=0.8f;
            
            if (wFs > 1.0f)  wFs = 0.9f;
            //        if (wFs > 1.0f)  wFs = 1.0f;
            
            // -- Compute SA decay...
            if(abs(wFs - m_floatMag[a] )>  floatSadFrr*2)
                //if (wFs >= (m_floatMag[a] - floatSadFrr))
            {
                wFs= wFs +(wFs - m_floatMag[a] )/16.0f;
                m_floatMag[a] = wFs;
                m_floatMagDecay[a]=20;
            }
            // -- Compute SA decay...
            if (wFs >= (m_floatMag[a] - floatSadFrr))
            {
                m_floatMag[a] = wFs;
            }
            else
            {
                m_floatMag[a] -= floatSadFrr;
                if (m_floatMag[a] < 0)
                    m_floatMag[a] = 0;
                wFs = m_floatMag[a];
            }
            

            CGRect rcBand = CGRectMake( (bandWidth+bandspace)*band + bandspace , bottomSpace  , bandWidth,   + wFs* bandHeight );
            
            drawGradientRect(self.myContext , rcBand);
            drawPeaks(self.myContext, rcBand, band);
            
            
            
            c += floatBandWidth;
        }
   
    }
    
}




@end



void drawPeaks(CGContextRef context,CGRect rc,int band)
{
    const int fallDelay = 2;
    const int fallingSpeed = 6;
    const int peakHeight = 6;

    static int peaks[bands];
    static int peaksDelay[bands];
    
    CGFloat height = rc.size.height + rc.origin.y;
    
   	if( height > peaks[band])
    {
        //raising
        if (height > peaks[band] * 2 )
            peaksDelay[band] = fallDelay * 2 ;
        else
            peaksDelay[band] = fallDelay;
        
        
        peaks[band] = height;
    }
    else
    {
        //falling
        if (peaksDelay[band] > 0)
        {
            peaksDelay[band]--;
        }
        else
        {
            peaks[band] -= fallingSpeed;
            
            if (peaks[band] < 0)
                peaks[band] = 0;
        }
        
    }
    
    
 
    
    CGRect rcPeak = rc;
    rcPeak.origin.y =  peaks[band];
    rcPeak.size.height = peakHeight;
    
    CGContextFillRect( context, rcPeak );
    
}


void drawGradientRect(CGContextRef context,CGRect rc)
{
//    CGContextClipToRect(context, rc);
    CGContextSaveGState(context);
    CGContextAddRect(context, rc);
    CGContextClip(context);
    
    
    CGColorSpaceRef myColorspace;
    
    size_t num_locations = 2;
    
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGFloat components[8] = { 1.0, 0.5, 0.4, 1.0,  // Start color
        
        0.8, 0.8, 0.3, 1.0 }; // End color
    
    
    myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    
    CGPoint myStartPoint, myEndPoint;
    
    myStartPoint.x = 0.0;
    
    myStartPoint.y = 0.0;
    
    myEndPoint.x = 0.0;
    
    CGFloat height = rc.size.height;
    
    myEndPoint.y = height;

    
    
    CGContextDrawLinearGradient ( context , myGradient, myStartPoint, myEndPoint, 0);
   
    
    
    
    
    
    
    
    
    CGContextRestoreGState(context);
    
    
    CGColorSpaceRelease (myColorspace);
    CGGradientRelease(myGradient);
    
}






