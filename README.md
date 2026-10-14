WebGPU Forward+ and Clustered Deferred Shading
======================

**University of Pennsylvania, CIS 565: GPU Programming and Architecture, Project 4**

* Logan Dooley
  * [LinkedIn](https://www.linkedin.com/in/logan-dooley-a205a619a/)
* Tested on: Google Chrome 155.0.8059.40, Windows 11, AMD Ryzen 7 9800X3D, 32GB RAM, NVIDIA GeForce RTX 5060 Ti 16GB

### Live Demo

[![](img/LiveDemoThumbnail.png)](https://logandooley.github.io/Project4-WebGPU-Forward-Plus-and-Clustered-Deferred/)

### Demo Video/GIF

[![](img/video.mp4)](TODO)

## Table of Contents

* [Renderers](#renderers)
  * [Naive](#naive)
  * [Forward+](#forward)
  * [Clustered Deferred](#clustered-deferred)
* [Performance Analysis](#performance-analysis)
  * [Test Setup](#test-setup)
* [Credits](#credits)

## Renderers

### Naive
The naive renderer's structure is as follows:
- For each mesh in the scene, run a vertex + fragment shader
  - For each fragment
    - For each light in the scene
      - Sum the light contribution to the fragment

The benefits of this method are that it is relatively simple to set up. There is little overhead to getting the data to the shaders that is needed. 

However, for many lights, this nested loop can be a performance bottleneck especially when some lights are nowhere near a given fragment.

### Forward+
A forward+ renderer is similar to Naive, except it considers only calculating light contributions for lights that are actually close to the fragments it is shading. The rough outline is:
- Split the view space into clusters
- For each cluster
  - Assign the lights that intersect with it

- For each mesh, run a vertex + fragment shader
  - For each fragment
    - Calculate which cluster it is in
    - For each light in that cluster
      - Sum the light contribution to the fragment

The benefits of this method are that unlike Naive rendering, we do not blindly try to calculate light contributions between every light and every fragment. Instead, we only have to calculate light contributions from lights that are nearby a given fragment, thanks to the clustering step. 

The downsides are mainly in clustering overhead and overdraw. The clustering step is a whole extra shader pass that has to happen each frame prior to the normal rendering steps from the Naive method. In terms of overdraw, the issue with forward rendering in general is that the full lighting calculations will be done for a fragment, even if it is overwritten by a closer fragment from a closer mesh later in the loop.

Another downside with both Forward+ and Clustered Deferred methods is that the clusters can only hold a fixed number of lights. Once the number of lights in a cluster surpasses this cap, there are visible seams in the render.

#### Clustering Implementation Details
For my implementation I used a fixed number of clusters in X, Y, and Z dimensions. In X and Y there are 16 and 9 clusters respectively, evenly distributed across the screen. In Z, there are 24 clusters, which are logarithmically distributed with depth. The equation I used for the logarithmic distribution comes from [this article](https://www.aortiz.me/2018/12/21/CG.html#part-2) and is as follows:
$$Z = Near_z(\frac{Far_z}{Near_z})^{slice/numSlices}$$

$$slice_z = \lfloor \log{(Z)} \frac{numSlices}{\log{Far_z/Near_z}} - \frac{numSlices \times \log{(Near_z)}}{\log{(Far_z / Near_z)}} \rfloor$$

I used a maximum number of lights per cluster of 256. Since the cluster struct stores a number of lights + the light array, this means there are 257 u32s per cluster, so 1028 bytes / cluster. With 16 * 9 * 24 = 3456 total clusters, this leads to 3.553 MB for cluster storage.

Lights are assigned to clusters by a compute shader with one thread per cluster that runs prior to the render passes. For each cluster, the screen position and depth range is converted into view space using the camera's invProjMat to form an AABB. This AABB is then checked against each light in the scene via a Sphere-AABB test to determine if the light could contribute to any fragment in that cluster. Lights are added until either there are no more lights, or if the max cap of 256 lights per cluster is reached.

### Clustered Deferred
A clustered deferred renderer acts similarly to a forward+ renderer, except it does its shading in a deferred manner, only shading each pixel on screen a single time. The rough outline is:
- Split the view space into clusters
- For each cluster
  - Assign the lights that intersect with it

- For each mesh, run a vertex + fragment shader
  - For each fragment
    - Write its position, normal, and albedo into G-Buffers

- Render a fullscreen quad
  - For each pixel
    - Calculate which cluster it is in based on the G-Buffer info
    - For each light in that cluster
      - Sum the light contribution to the pixel

The benefits of this method are that unlike in Forward+, when a fragment is occluded by another fragment on a later mesh, we do not waste time re-computing the lighting contributions to the fragment, since we limit ourselves to one fragment per-pixel. We still do overwrite G-Buffer data when closer fragments are encountered, but the lighting pass which is typically the most expensive is "deferred" until the G-Buffer has been completely finished.

The downsides are that the addition of G-Buffers means there is extra memory cost, as well as deferred rendering not being able to handle transparency very well.

#### G-Buffer Implementation Details
Without any optimizations, I used the following G-Buffer formats:

| G-Buffer | Format | Bytes / Pixel | Memory Size (1920 x 945) |
|:-:|:-:|:-:|:-:
| Position | rgba16float | 8 | 14.52 MB |
| Normal | rgba16float | 8 | 14.52 MB |
| Albedo | rgba8unorm | 4 | 7.258 MB |

For a total of 36.29 MB

## Performance Analysis

### Test Setup
- Resolution: 1920 x 945
- VSync: On (Monitor: 240 Hz)
- Camera Position: Default starting view
- Sampling: Frame time in MS, using exponential moving average with alpha = 0.05, read after settling

## Credits
- [Cluster Slicing](https://www.aortiz.me/2018/12/21/CG.html#part-2)
- [Vite](https://vitejs.dev/)
- [loaders.gl](https://loaders.gl/)
- [dat.GUI](https://github.com/dataarts/dat.gui)
- [stats.js](https://github.com/mrdoob/stats.js)
- [wgpu-matrix](https://github.com/greggman/wgpu-matrix)
