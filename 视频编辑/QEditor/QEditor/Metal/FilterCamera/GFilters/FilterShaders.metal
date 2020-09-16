#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>

using namespace metal;

constant float PI = 3.14159;
struct AdjustSaturationUniforms
{
    float saturationFactor;
};

kernel void adjust_saturation(texture2d<float, access::read> inTexture [[texture(0)]],
                              texture2d<float, access::write> outTexture [[texture(1)]],
                              constant AdjustSaturationUniforms &uniforms [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float4 inColor = inTexture.read(gid);
    float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
    float4 grayColor(value, value, value, 1.0);
    float4 outColor = mix(grayColor, inColor, uniforms.saturationFactor);
    outTexture.write(outColor, gid);
}

kernel void gaussian_blur_2d(texture2d<float, access::read> inTexture [[texture(0)]],
                             texture2d<float, access::write> outTexture [[texture(1)]],
                             texture2d<float, access::read> weights [[texture(2)]],
                             uint2 gid [[thread_position_in_grid]])
{
    int size = weights.get_width();
    int radius = size / 2;
    
    float4 accumColor(0, 0, 0, 0);
    for (int j = 0; j < size; ++j)
    {
        for (int i = 0; i < size; ++i)
        {
            uint2 kernelIndex(i, j);
            uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
            float4 color = inTexture.read(textureIndex).rgba;
            float4 weight = weights.read(kernelIndex).rrrr;
            accumColor += weight * color;
        }
    }
    
    outTexture.write(float4(accumColor.rgb, 1), gid);
}

struct RotationUniforms
{
    float width;
    float height;
    float factor;
};

kernel void rotation_around_center(texture2d<float, access::read> inTexture [[texture(0)]],
                                   texture2d<float, access::write> outTexture [[texture(1)]],
                                   constant RotationUniforms &uniforms [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    float centerX = uniforms.width/2.0;
    float centerY = uniforms.height/2.0;
    float factor = uniforms.factor;

    float modX = (gid.x - centerX);
    float modY = (centerY - gid.y);
    float distance = sqrt(modX*modX + modY*modY);
    float centerMinDimension = min(centerX, centerY);
    if (distance <= centerMinDimension) {
        float theta = factor * PI * pow(distance/centerMinDimension, 3);
        uint2 textureIndex(cos(theta) * modX - sin(theta) * modY + centerX, centerY - (sin(theta) * modX + cos(theta) * modY));
        float4 color = inTexture.read(textureIndex).rgba;
        outTexture.write(float4(color.rgb, 1), gid);
    }
    else {
        float4 color = inTexture.read(gid).rgba;
        outTexture.write(float4(color.rgb, 1), gid);
    }
}

struct RGBUniforms {
    float4x4 rotation;
};

kernel void gbr(texture2d<float, access::read> inTexture [[texture(0)]],
                texture2d<float, access::write> outTexture [[texture(1)]],
                constant RGBUniforms &uniforms [[buffer(0)]],
                uint2 gid [[thread_position_in_grid]])
{
    float4 inColor = inTexture.read(gid);
    float4 outColor =  uniforms.rotation * float4(inColor.rgb, 1);
    outTexture.write(outColor, gid);
}

kernel void sepia(texture2d<float, access::read> inTexture [[texture(0)]],
                texture2d<float, access::write> outTexture [[texture(1)]],
                uint2 gid [[thread_position_in_grid]])
{
    float4 inColor = inTexture.read(gid);
    
    float r = dot(inColor.rgb, float3(0.393, 0.769, 0.189));
    float g = dot(inColor.rgb, float3(0.349, 0.686, 0.168));
    float b = dot(inColor.rgb, float3(0.272, 0.534, 0.131));
    float4 outColor(r > 1 ? 1 : r, g > 1 ? 1 : g, b > 1 ? 1 : b, 1.0);
    outTexture.write(outColor, gid);
}

struct PixellationUniforms {
    int32_t width;
    int32_t height;
};

kernel void pixellate(texture2d<float, access::read> inTexture [[texture(0)]],
                texture2d<float, access::write> outTexture [[texture(1)]],
                constant PixellationUniforms &uniforms [[buffer(0)]],
                uint2 gid [[thread_position_in_grid]])
{
    uint width = uint(uniforms.width);
    uint height = uint(uniforms.height);
    
    const uint2 pixelGid = uint2((gid.x / width) * width, (gid.y / height) * height);
    float4 color = inTexture.read(pixelGid);
    outTexture.write(color, gid);
}

kernel void luminance(texture2d<float, access::read> inTexture [[texture(0)]],
                  texture2d<float, access::write> outTexture [[texture(1)]],
                  uint2 gid [[thread_position_in_grid]])
{
    float4 inColor = inTexture.read(gid);
    
    // 0.2126, 0.7152, 0.0722
    float r = dot(inColor.rgb, float3(0.2126, 0.7152, 0.0722));
    float4 outColor(r, r, r, 1.0);
    outTexture.write(outColor, gid);
}

float lumaAtOffset(texture2d<float, access::read> inTexture, uint2 origin, uint2 offset) {
    uint2 transformed = origin + offset;
    float4 inColor = inTexture.read(transformed);
    float luma = dot(inColor.rgb, float3(0.2126, 0.7152, 0.0722));
    return luma;
}

kernel void normalMap(texture2d<float, access::read> inTexture [[texture(0)]],
                      texture2d<float, access::write> outTexture [[texture(1)]],
                      uint2 gid [[thread_position_in_grid]])
{
    float northLuma = lumaAtOffset(inTexture, gid, uint2(0, -1));
    float southLuma = lumaAtOffset(inTexture, gid, uint2(0, 1));
    float westLuma = lumaAtOffset(inTexture, gid, uint2(-1, 0));
    float eastLuma = lumaAtOffset(inTexture, gid, uint2(1, 0));
    
    float horizontalSlope = ((westLuma - eastLuma) + 1.0) * 0.5;
    float verticalSlope = ((northLuma - southLuma) + 1.0) * 0.5;
    float4 outColor(horizontalSlope, verticalSlope, 1, 1.0);
    outTexture.write(outColor, gid);
}

kernel void invert(texture2d<float, access::read> inTexture [[texture(0)]],
                      texture2d<float, access::write> outTexture [[texture(1)]],
                      uint2 gid [[thread_position_in_grid]])
{
    float4 inColor = inTexture.read(gid);

    float4 outColor(1 - inColor.r, 1 - inColor.g, 1 - inColor.b, inColor.a);
    outTexture.write(outColor, gid);
}

kernel void oneStepLaplacianPyramid(texture2d<float, access::read> inTexture0 [[texture(0)]],
                   texture2d<float, access::read> inTexture1 [[texture(1)]],
                   texture2d<float, access::write> outTexture [[texture(2)]],
                   uint2 gid [[thread_position_in_grid]])
{
    float4 inColor0 = inTexture0.read(gid);
    float4 inColor1 = inTexture1.read(gid);

    float limit = 0.01;

    float r = inColor0.r - inColor1.r;
    float g = inColor0.g - inColor1.g;
    float b = inColor0.b - inColor1.b;
    if (r > limit) {
        r = 1;
    }
    else {
        r = 0;
    }
    if (g > limit) {
        g = 1;
    }
    else {
        g = 0;
    }
    if (b > limit) {
        b = 1;
    }
    else {
        b = 0;
    }
    float alpha = 1;
    if (r == 0 && g == 0 && b == 0) {
        alpha = 0;
    }
    float4 outColor(r, g, b, alpha);
    outTexture.write(outColor, gid);

//    float l0 = dot(inColor0.rgb - inColor1.rgb, float3(0.2126, 0.7152, 0.0722));
//    if (l0 > limit) {
//        l0 = 1;
//    }
//    else {
//        l0 = 0;
//    }
//    float4 outColor(l0, l0, l0, l0);
//    outTexture.write(outColor, gid);
}

struct CenterMagnificationUniforms {
    float width;
    float height;
    float minRadius;
    float radius;
};

kernel void magnify_center(texture2d<float, access::read> inTexture [[texture(0)]],
                                   texture2d<float, access::write> outTexture [[texture(1)]],
                                   constant CenterMagnificationUniforms &uniforms [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    float centerX = uniforms.width/2.0;
    float centerY = uniforms.height/2.0;
    
    float modX = (gid.x - centerX);
    float modY = (centerY - gid.y);
    float distance = sqrt(modX*modX + modY*modY);
    float centerMinDimension = min(centerX, centerY) * uniforms.radius;
    if (distance <= centerMinDimension && distance >= centerMinDimension - 5) {
        float4 color = float4(1, 0, 0, 1);
        outTexture.write(color, gid);
    }
    else if (distance <= centerMinDimension) {
        float m = uniforms.minRadius * 2.0 / 3.0;
        float n = uniforms.minRadius * 1.0 / 3.0 + (uniforms.radius - uniforms.minRadius) + pow(1 - distance / centerMinDimension, 2);
        float dx = (gid.x * m + centerX * n) / (m + n);
        float dy = (gid.y * m + centerY * n) / (m + n);
        uint2 textureIndex(dx, dy);
        float4 color = inTexture.read(textureIndex).rgba;
        outTexture.write(float4(color.rgb, 1), gid);
    }
    else {
        float4 color = inTexture.read(gid).rgba;
        outTexture.write(float4(color.rgb, 1), gid);
    }
}

kernel void magnify_weighted_center(texture2d<float, access::read> inTexture [[texture(0)]],
                           texture2d<float, access::write> outTexture [[texture(1)]],
                           constant CenterMagnificationUniforms &uniforms [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    float centerX = uniforms.width/2.0;
    float centerY = uniforms.height/2.0;
    
    float modX = (gid.x - centerX);
    float modY = (centerY - gid.y);
    float distance = sqrt(modX*modX + modY*modY);
    float centerMinDimension = min(centerX, centerY) * uniforms.radius;
//    if (distance <= centerMinDimension && distance >= centerMinDimension - 5) {
//        float4 color = float4(1, 0, 0, 1);
//        outTexture.write(color, gid);
//    }
//    else
    if (distance <= centerMinDimension) {
        float x = modX / centerMinDimension;
        float y = modY / centerMinDimension;
        float d = sqrt(x*x + y*y);
//        float m = d * d;
//        float n = (1 - m);
        float m = sin(d * PI / 2.0);
        float n = 1 - m;
        float dx = (gid.x * m + centerX * n) / (m + n);
        float dy = (gid.y * m + centerY * n) / (m + n);
        uint2 textureIndex(dx, dy);
        float4 color = inTexture.read(textureIndex).rgba;
        outTexture.write(float4(color.rgb, 1), gid);
    }
    else {
        float4 color = inTexture.read(gid).rgba;
        outTexture.write(float4(color.rgb, 1), gid);
    }
}


kernel void slim(texture2d<float, access::sample> inTexture [[texture(0)]],
                                    texture2d<float, access::write> outTexture [[texture(1)]],
                                    constant CenterMagnificationUniforms &uniforms [[buffer(0)]],
                                    uint2 gid [[thread_position_in_grid]])
{
    float centerX = uniforms.width / 2.0;
    
    float centerMinDimension = centerX * uniforms.radius;
    float m = 2;
    float n = 1;
    float limitX = centerMinDimension - n / m * centerMinDimension;
    if (uniforms.radius > 0 && limitX >= fabs(gid.x - centerX)) {
        float factor = centerMinDimension / limitX;
        uint2 textureIndex(centerX + (gid.x - centerX) * factor, gid.y);
        if (gid.x - centerX > 0) {
            int width = inTexture.get_width();
            int height = inTexture.get_height();
            float2 coordinates = float2(textureIndex) / float2(width, height);
            
            constexpr sampler textureSampler(coord::normalized,
                                             address::clamp_to_edge);
            float4 color = inTexture.sample(textureSampler, coordinates);
            outTexture.write(color, gid);
        }
        else {
            float4 color = inTexture.read(textureIndex).rgba;
            outTexture.write(float4(color.rgb, 1), gid);
        }
    }
    else {
        float factor = (centerX - centerMinDimension) / (centerX - limitX);
        if (gid.x - centerX > 0) {
            uint2 textureIndex(2* centerX - (2* centerX - gid.x) * factor, gid.y);
            
            int width = inTexture.get_width();
            int height = inTexture.get_height();
            float2 coordinates = float2(textureIndex) / float2(width, height);
            
            constexpr sampler textureSampler(coord::normalized,
                                             address::clamp_to_edge);
            float4 color = inTexture.sample(textureSampler, coordinates);
            outTexture.write(color, gid);
        }
        else {
            uint2 textureIndex(gid.x * factor, gid.y);
            float4 color = inTexture.read(textureIndex).rgba;
            outTexture.write(float4(color.rgb, 1), gid);
        }
    }
}

kernel void repeat(texture2d<float, access::read> inTexture [[texture(0)]],
                   texture2d<float, access::write> outTexture [[texture(1)]],
                   uint2 gid [[thread_position_in_grid]]) {
    
    uint cellWidth = inTexture.get_width() / 3;
    uint cellHeight = inTexture.get_height() / 3;
    uint2 modGid = uint2((gid.x % cellWidth) * 3, (gid.y % cellHeight) * 3);
    float4 inColor = inTexture.read(modGid);
    float4 outColor;
    uint cellIndex = gid.y / cellHeight * 3 + gid.x / cellWidth;
    float threshold = 0.35;
    float thresholdr_g = 0.5;
    float thresholdr_b = 0.5;
    float thresholdg_r = 0.75;
    float thresholdg_b = 0.75;
    float thresholdb_r = 0.75;
    float thresholdb_g = 0.75;
    float emphasis = 1;
    if (cellIndex == 0) {
        float4 temp = inColor;
        if (temp.r > threshold && temp.g / temp.r < thresholdr_g && temp.b / temp.r < thresholdr_b) {
            outColor = float4(inColor.r * emphasis, 0, 0, 1.0);
        }
        else {
            float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
            outColor = float4(value, value, value, 1.0);
        }
    }
    else if (cellIndex == 1) {
        float4 temp = inColor;
        if (temp.g > 0 && temp.r / temp.g < thresholdg_r && temp.b / temp.g < thresholdg_b) {
            outColor = float4(0, inColor.g * emphasis, 0, 1.0);
        }
        else {
            float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
            outColor = float4(value, value, value, 1.0);
        }
    }
    else if (cellIndex == 2) {
        float4 temp = inColor;
        if (temp.b > 0 && temp.r / temp.b < thresholdb_r && temp.g / temp.b < thresholdb_g) {
            outColor = float4(0, 0, inColor.b * emphasis, 1.0);
        }
        else {
            float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
            outColor = float4(value, value, value, 1.0);
        }
    }
    else if (cellIndex == 3) {
        outColor = float4(1 - inColor.r, 1 - inColor.g, 1 - inColor.b, inColor.a);
    }
    else if (cellIndex == 5) {
        float r = dot(inColor.rgb, float3(0.393, 0.769, 0.189));
        float g = dot(inColor.rgb, float3(0.349, 0.686, 0.168));
        float b = dot(inColor.rgb, float3(0.272, 0.534, 0.131));
        outColor = float4(r > 1 ? 1 : r, g > 1 ? 1 : g, b > 1 ? 1 : b, 1.0);
    }
    else if (cellIndex == 6) {
        outColor.rgba = inColor.gbra;
    }
    else if (cellIndex == 7) {
        outColor.rgb = inColor.brg;
    }
    else if (cellIndex == 8) {
        outColor.rgb = inColor.bgr;
    }
    else {
        outColor = inColor;
    }
    outTexture.write(outColor, gid);
}

kernel void emphasizeRed(texture2d<float, access::read> inTexture [[texture(0)]],
                   texture2d<float, access::write> outTexture [[texture(1)]],
                   uint2 gid [[thread_position_in_grid]]) {
    
    float4 inColor = inTexture.read(gid);
    float4 outColor;
    float threshold = 0.35;
    float thresholdr_g = 0.5;
    float thresholdr_b = 0.5;
    float emphasis = 1;
    float4 temp = inColor;
    if (temp.r > threshold && temp.g / temp.r < thresholdr_g && temp.b / temp.r < thresholdr_b) {
        outColor = float4(inColor.r * emphasis, inColor.g, inColor.b, 1.0);
    }
    else {
        float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
        outColor = float4(value, value, value, 1.0);
    }
    outTexture.write(outColor, gid);
}

kernel void emphasizeGreen(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]]) {
    
    float4 inColor = inTexture.read(gid);
    float4 outColor;
    float threshold = 0.35;
    float threshold_g = 0.75;
    float threshold_b = 0.75;
    float emphasis = 1.1;
    float4 temp = inColor;
    if (temp.g > threshold && temp.r / temp.g < threshold_g && temp.b / temp.g < threshold_b) {
        outColor = float4(inColor.r, inColor.g * emphasis, inColor.b, 1.0);
    }
    else {
        float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
        outColor = float4(value, value, value, 1.0);
    }
    outTexture.write(outColor, gid);
}

kernel void emphasizeBlue(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]]) {
    
    float4 inColor = inTexture.read(gid);
    float4 outColor;
    float threshold = 0.35;
    float threshold_r = 0.75;
    float threshold_b = 0.75;
    float emphasis = 1.1;
    float4 temp = inColor;
    if (temp.b > threshold && temp.r / temp.b < threshold_r && temp.g / temp.b < threshold_b) {
        outColor = float4(inColor.r, inColor.g, inColor.b * emphasis, 1.0);
    }
    else {
        float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
        outColor = float4(value, value, value, 1.0);
    }
    outTexture.write(outColor, gid);
}

kernel void emphasizeRGB(texture2d<float, access::read> inTexture [[texture(0)]],
                          texture2d<float, access::write> outTexture [[texture(1)]],
                          uint2 gid [[thread_position_in_grid]]) {
    
    float4 inColor = inTexture.read(gid);
    float4 outColor;
    float threshold = 0.35;
    float thresholdr_g = 0.5;
    float thresholdr_b = 0.5;
    float thresholdg_r = 0.75;
    float thresholdg_b = 0.75;
    float thresholdb_r = 0.75;
    float thresholdb_g = 0.75;
    float emphasis = 1.1;
    float4 temp = inColor;
    
    if (temp.r > threshold && temp.g / temp.r < thresholdr_g && temp.b / temp.r < thresholdr_b) {
        outColor = float4(inColor.r * emphasis, inColor.g, inColor.b, 1.0);
    }
    else if (temp.g > threshold && temp.r / temp.g < thresholdg_r && temp.b / temp.g < thresholdg_b) {
        outColor = float4(inColor.r, inColor.g * emphasis, inColor.b, 1.0);
    }
    else if (temp.b > threshold && temp.r / temp.b < thresholdb_r && temp.g / temp.b < thresholdb_g) {
        outColor = float4(inColor.r, inColor.g, inColor.b * emphasis, 1.0);
    }
    else {
        float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
        outColor = float4(value, value, value, 1.0);
    }
    outTexture.write(outColor, gid);
}

struct DivideUniforms {
    int32_t divider;
};

kernel void divide(texture2d<float, access::read> inTexture [[texture(0)]],
                   texture2d<float, access::write> outTexture [[texture(1)]],
                   constant DivideUniforms &uniforms [[buffer(0)]],
                   uint2 gid [[thread_position_in_grid]]) {

    uint cellWidth = inTexture.get_width() / uniforms.divider;
    uint cellHeight = inTexture.get_height() / uniforms.divider;
    float2 modGid = float2((gid.x % cellWidth), (gid.y % cellHeight));
    float4 inColor = inTexture.read(gid);
    float xRatio = fabs(modGid.x - float(cellWidth) / 2) / (float(cellWidth) / 2);
    float yRatio = fabs(modGid.y - float(cellHeight) / 2) / (float(cellHeight) / 2);
    float rr = sqrt(xRatio * xRatio + yRatio * yRatio) * 0.5;
//    float3 out = inColor.rgb*(1-rr) + float3(0.439, 0.259, 0.078) * rr;
    float3 out = inColor.rgb*(1-rr) + float3(0) * rr;
    float4 outColor = float4(out, 1.0);
    outTexture.write(outColor, gid);
}

//
struct CarnivalMirrorUniforms {
    int32_t wavelength;
    int32_t amount;
};

kernel void carnivalMirror(texture2d<float, access::read> inTexture [[texture(0)]],
                   texture2d<float, access::write> outTexture [[texture(1)]],
                   constant CarnivalMirrorUniforms &uniforms [[buffer(0)]],
                   uint2 gid [[thread_position_in_grid]]) {

    int y = gid.y + int(sin(gid.y / float(uniforms.wavelength)) * uniforms.amount);
    int x = gid.x + int(sin(gid.x / float(uniforms.wavelength)) * uniforms.amount);
    int width = int(inTexture.get_width());
    int height = int(inTexture.get_height());
    if (x < 0) {
        x = 0;
    }
    else if (width <= x) {
        x = width - 1;
    }
    if (y < 0) {
        y = 0;
    }
    else if (height <= y) {
        y = height - 1;
    }
    float4 inColor = inTexture.read(uint2(x, y));
    outTexture.write(inColor, gid);
}

struct KuwaharaUniforms {
    int32_t radius;
};

kernel void kuwahara(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::write> outTexture [[texture(1)]],
                     constant KuwaharaUniforms &uniforms [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
    
    int radius = uniforms.radius;
    float n = float((radius + 1) * (radius + 1));
    
    float3 means[4];
    float3 stdDevs[4];
    
    float3 zero3 = float3(0.0);
    for (int i = 0; i < 4; i++)
    {
        means[i] = zero3;
        stdDevs[i] = zero3;
    }
    
    for (int x = -radius; x <= radius; x++)
    {
        for (int y = -radius; y <= radius; y++)
        {
            uint2 transformed = gid + uint2(x,y);
            float3 color = inTexture.read(transformed).rgb;
            
            float3 colorA = float3(float(x <= 0 && y <= 0)) * color;
            means[0] += colorA;
            stdDevs[0] += colorA * colorA;
            
            float3 colorB = float3(float(x >= 0 && y <= 0)) * color;
            means[1] +=  colorB;
            stdDevs[1] += colorB * colorB;
            
            float3 colorC = float3(float(x <= 0 && y >= 0)) * color;
            means[2] += colorC;
            stdDevs[2] += colorC * colorC;
            
            float3 colorD = float3(float(x >= 0 && y >= 0)) * color;
            means[3] += colorD;
            stdDevs[3] += colorD * colorD;
            
        }
    }
    
    float minSigma2 = 1e+2;
    float3 returnColor = float3(0.0);
    
    for (int j = 0; j < 4; j++)
    {
        means[j] /= n;
        stdDevs[j] = abs(stdDevs[j] / n - means[j] * means[j]);
        
        float sigma2 = stdDevs[j].r + stdDevs[j].g + stdDevs[j].b;
        
        returnColor = (sigma2 < minSigma2) ? means[j] : returnColor;
        minSigma2 = (sigma2 < minSigma2) ? sigma2 : minSigma2;
    }
    
    float4 outColor = float4(returnColor, 1.0);
    outTexture.write(outColor, gid);
}
