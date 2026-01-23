//
//  LiquidGlass.metal
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

//#include <metal_stdlib>
//using namespace metal;
//
//
//[[ stitchable ]]
//half2 liquidRefraction(
//    float2 position,
//    float time,
//    float intensity
//) {
//    float wave =
//        sin(position.y * 0.04 + time * 1.5) * 6.0 +
//        cos(position.x * 0.03 + time * 1.2) * 4.0;
//
//    return half2(wave * intensity, wave * intensity * 0.6);
//}

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
float2 liquidRefraction(
    float2 position,
    float time,
    float intensity
) {
    // Optimized: Reduced frequency calculations and simplified wave computation
    // Lower frequency means less computation per pixel
    float yWave = sin(position.y * 0.03 + time * 0.8) * 3.5;
    float xWave = cos(position.x * 0.025 + time * 0.7) * 2.5;
    
    // Combine waves more efficiently
    float combinedWave = (yWave + xWave) * 0.5;
    
    return float2(
        combinedWave * intensity,
        combinedWave * intensity * 0.6
    );
}
