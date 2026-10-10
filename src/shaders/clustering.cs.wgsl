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

    let lightCount = min(lightSet.numLights, ${maxLightsPerCluster});
    
    // For now put every light in every cluster
    clusterSet.clusters[clusterIdx].numLights = lightCount;
    for (var i = 0u; i < lightCount; i++){
        clusterSet.clusters[clusterIdx].lightIndices[i] = i;
    }
}