// TODO-2: implement the light clustering compute shader

// ------------------------------------
// Calculating cluster bounds:
// ------------------------------------
// For each cluster (X, Y, Z):
//     - Calculate the screen-space bounds for this cluster in 2D (XY).
//     - Calculate the depth bounds for this cluster in Z (near and far planes).
//     - Convert these screen and depth bounds into view-space coordinates.
//     - Store the computed bounding box (AABB) for the cluster.

// ------------------------------------
// Assigning lights to clusters:
// ------------------------------------
// For each cluster:
//     - Initialize a counter for the number of lights in this cluster.

//     For each light:
//         - Check if the light intersects with the cluster’s bounding box (AABB).
//         - If it does, add the light to the cluster's light list.
//         - Stop adding lights if the maximum number of lights is reached.

//     - Store the number of lights assigned to this cluster.

@group(0) @binding(0) var<uniform> cameraUniforms: CameraUniforms;
@group(0) @binding(1) var<storage, read> lightSet: LightSet;
@group(0) @binding(2) var<storage, read_write> clusterSet: ClusterSet;

@compute @workgroup_size(${clusterWorkgroupSize}, ${clusterWorkgroupSize}, ${clusterWorkgroupSize})
fn main(@builtin(global_invocation_id) id: vec3u) {
    if(id.x >= ${clusterCountX} || id.y >= ${clusterCountY} || id.z >= ${clusterCountZ}){
        return;
    }

    let clusterIdx = id.x + id.y * ${clusterCountX} + id.z * ${clusterCountX} * ${clusterCountY};

    // Compute this cluster's Z bounds. From https://www.aortiz.me/2018/12/21/CG.html#part-2
    let farOverNear = cameraUniforms.far / cameraUniforms.near;
    let depthNear = cameraUniforms.near * pow(farOverNear, f32(id.z) / f32(${clusterCountZ}));
    let depthFar = cameraUniforms.near * pow(farOverNear, f32(id.z + 1) / f32(${clusterCountZ}));


    // For now put lights in clusters just based on Z
    var clusterNumLights = 0u;
    for (var i = 0u; i < lightSet.numLights && clusterNumLights < ${maxLightsPerCluster}; i++){
        let light = lightSet.lights[i];
        let lightViewPos = cameraUniforms.viewMat * vec4(light.pos, 1);
        let lightViewZ = -lightViewPos.z;

        if (lightViewZ + ${lightRadius} < depthNear || lightViewZ - ${lightRadius} > depthFar){
            continue;
        }

        clusterSet.clusters[clusterIdx].lightIndices[clusterNumLights] = i;
        clusterNumLights++;
    }
    clusterSet.clusters[clusterIdx].numLights = clusterNumLights;
}