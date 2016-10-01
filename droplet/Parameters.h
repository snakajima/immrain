//
//  Parameters.h
//  droplet
//
//  Created by satoshi on 10/24/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#ifndef droplet_Parameters_h
#define droplet_Parameters_h

#define VERTICES_COUNT2 10 // 12 = 12*2 corders + 12*2 subdivision
#define VERTICES_COUNT (VERTICES_COUNT2 * 2)

// Timings
#define TIMING_CLEAR_ALL 3.2
#define TIMING_CLEAR_BLUR 1.5
#define TIMING_SHOW_TEXT_BEGIN 1.4
#define TIMING_SHOW_TEXT_DURATION 1.8
#define TIMING_FADE_OUT 1.2
#define TIMING_FADE_IN 2.8
#define TIMING_AUTO_SWITCH 10.0 // 10.0

// Number of droplets, varieties, etc.
#define DROPLET_COUNT 100
#define DROPLET_SIZE_MIN 0.25
#define DROPLET_SIZE_VAR 0.5
#define FRICTION_BASE 30.0
#define FRICTION_MIN 1.0
#define FRICTION_VAR 10.0

// Smoking Glass Effect
#define SMOKING_GAUSSIAN_RADIUS 30.0
#define SMOKING_BLIGHTNESS 0.05
#define SMOKING_SATURATION 1.0

// Text
#define TEXT_FONT_SIZE 36.0
#define TEXT_PARAGRAPH_SPACING 36.0
#define TEXT_SHADOW_RADIUS 5.0
#define TEXT_SHADOW_OFFSET 2.0
//#define TEXT_PARAGRAPH_WIDTH (4.0/6.0)
//#define TEXT_PARAGRAPH_INDENT (1.0/6.0)
#define TEXT_PARAGRAPH_WIDTH (66.0/100.0)
#define TEXT_PARAGRAPH_INDENT (19.0/100.0)

#define XRATIO 0.8
#define ZRATIO 0.2
#define V_GRAVITY 5.0
#define kTouchMargin 1.0

#endif
