// TODO-2: implement the Forward+ fragment shader

// See naive.fs.wgsl for basic fragment shader setup; this shader should use light clusters instead of looping over all lights

// ------------------------------------
// Shading process:
// ------------------------------------
// Determine which cluster contains the current fragment.
// Retrieve the number of lights that affect the current fragment from the cluster’s data.
// Initialize a variable to accumulate the total light contribution for the fragment.
// For each light in the cluster:
//     Access the light's properties using its index.
//     Calculate the contribution of the light based on its position, the fragment’s position, and the surface normal.
//     Add the calculated contribution to the total light accumulation.
// Multiply the fragment’s diffuse color by the accumulated light contribution.
// Return the final color, ensuring that the alpha component is set appropriately (typically to 1).

// Temporary debug
@group(${bindGroup_scene}) @binding(0) var<uniform> cameraUniforms: CameraUniforms;
@group(${bindGroup_scene}) @binding(1) var<storage, read> lightSet: LightSet;

@group(${bindGroup_material}) @binding(0) var diffuseTex: texture_2d<f32>;
@group(${bindGroup_material}) @binding(1) var diffuseTexSampler: sampler;


struct FragmentInput
{
    @builtin(position) fragPos: vec4f,
    @location(0) pos: vec3f,
    @location(1) nor: vec3f,
    @location(2) uv: vec2f
}


@fragment
fn main(in: FragmentInput) -> @location(0) vec4f
{
    let uv = in.fragPos.xy / cameraUniforms.screenSize;
    let viewPos = cameraUniforms.viewMat * vec4(in.pos, 1);
    let viewZ = -viewPos.z;

    // Debug for screen space coords
    //return vec4f(uv, 0, 1);

    // Debug for view space depth
    //return vec4f(vec3f(viewZ / 50.0), 1);

    // Debug for identical behavior to naive
    /*
    let diffuseColor = textureSample(diffuseTex, diffuseTexSampler, in.uv);
    if (diffuseColor.a < 0.5f) {
        discard;
    }

    var totalLightContrib = vec3f(0, 0, 0);
    for (var lightIdx = 0u; lightIdx < lightSet.numLights; lightIdx++) {
        let light = lightSet.lights[lightIdx];
        totalLightContrib += calculateLightContrib(light, in.pos, normalize(in.nor));
    }

    var finalColor = diffuseColor.rgb * totalLightContrib;
    return vec4(finalColor, 1);
    */

    // Debug for clusters
    let xSlice = floor(uv.x * ${clusterCountX});
    let ySlice = floor(uv.y * ${clusterCountY});

    // z slicing from https://www.aortiz.me/2018/12/21/CG.html#part-2
    let logFarNear = log(cameraUniforms.far / cameraUniforms.near);
    let zSlice = floor(log(viewZ) * ${clusterCountZ} / logFarNear - ${clusterCountZ} * log(cameraUniforms.near) / logFarNear);
    let cx = u32(clamp(xSlice, 0.0, f32(${clusterCountX} - 1)));
    let cy = u32(clamp(ySlice, 0.0, f32(${clusterCountY} - 1)));
    let cz = u32(clamp(zSlice, 0.0, f32(${clusterCountZ} - 1)));
    return vec4f(
        f32(cx) / f32(${clusterCountX}), 
        f32(cy) / f32(${clusterCountY}), 
        f32(cz) / f32(${clusterCountZ}),
        1);
}
