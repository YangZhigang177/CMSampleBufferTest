//
//  AlphaFrameFilter.metal
//  CMSampleBufferTest
//
//  Created by 杨志刚 on 2022/3/7.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

extern "C" {

    float4 alphaFrame(coreimage::sampler source, coreimage::sampler mask) {
            float4 color = source.sample(source.coord());
            float opacity = mask.sample(mask.coord()).r;
            return float4(color.rgb, opacity);
        }

}
