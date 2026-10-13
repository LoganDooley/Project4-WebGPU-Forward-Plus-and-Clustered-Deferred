WebGL Forward+ and Clustered Deferred Shading
======================

**University of Pennsylvania, CIS 565: GPU Programming and Architecture, Project 4**

* Logan Dooley
  * [LinkedIn](https://www.linkedin.com/in/logan-dooley-a205a619a/)
* Tested on: Google Chrome 155.0.8059.40, Windows 11, AMD Ryzen 7 9800X3D, 32GB RAM, NVIDIA GeForce RTX 5060 Ti 16GB

### Live Demo

[![](img/thumb.png)](https://logandooley.github.io/Project4-WebGPU-Forward-Plus-and-Clustered-Deferred/)

### Demo Video/GIF

[![](img/video.mp4)](TODO)

## Overview

* [Renderers](#renderers)
  * [Naive](#naive)
  * [Forward+](#forward)
  * [Clustered Deferred](#clustered-deferred)
* [Performance Analysis](#performance-analysis)
  * [Test Setup](#test-setup)
* [Credits](#credits)

## Renderers

### Naive

### Forward+

### Clustered Deferred

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
