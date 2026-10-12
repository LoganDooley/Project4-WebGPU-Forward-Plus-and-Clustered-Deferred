// TODO-3: implement the Clustered Deferred fullscreen fragment shader

// Similar to the Forward+ fragment shader, but with vertex information coming from the G-buffer instead.

@group(${bindGroup_gBuffers}) @binding(0) var positionTex: texture_2d<f32>;
@group(${bindGroup_gBuffers}) @binding(1) var normalTex: texture_2d<f32>;
@group(${bindGroup_gBuffers}) @binding(2) var albedoTex: texture_2d<f32>;

@fragment
fn main(@builtin(position) fragPos: vec4f) -> @location(0) vec4f
{
    let pixelCoord = vec2i(fragPos.xy);
    let albedo = textureLoad(albedoTex, pixelCoord, 0);
    return albedo;
}
