import Stats from 'stats.js';
import { GUI } from 'dat.gui';

import { initWebGPU, Renderer } from './renderer';
import { NaiveRenderer } from './renderers/naive';
import { ForwardPlusRenderer } from './renderers/forward_plus';
import { ClusteredDeferredRenderer } from './renderers/clustered_deferred';

import { setupLoaders, Scene } from './stage/scene';
import { Lights } from './stage/lights';
import { Camera } from './stage/camera';
import { Stage } from './stage/stage';

await initWebGPU();
setupLoaders();

let scene = new Scene();
await scene.loadGltf('./scenes/sponza/Sponza.gltf');

const camera = new Camera();
const lights = new Lights(camera);

const stats = new Stats();
stats.showPanel(0);
document.body.appendChild(stats.dom);

// Adding a custom ms per frame counter using exponential moving average
const avgMsPerFramePanel = stats.addPanel(new Stats.Panel('avg MS', '#ff8', '#221'));
stats.showPanel(stats.dom.children.length - 1); // Show avgMsPerFramePanel by default

const alpha = 0.05;
let avgMsPerFrame = 0;
let lastTime = performance.now();

function updateAvgMsPerFrame(now: number) {
    const currMsPerFrame = now - lastTime;
    lastTime = now;

    avgMsPerFrame = avgMsPerFrame === 0 ? currMsPerFrame : avgMsPerFrame + alpha * (currMsPerFrame - avgMsPerFrame);
    avgMsPerFramePanel.update(avgMsPerFrame, 100);
    
    requestAnimationFrame(updateAvgMsPerFrame);
}
requestAnimationFrame(updateAvgMsPerFrame);

const gui = new GUI();
gui.add(lights, 'numLights').min(1).max(Lights.maxNumLights).step(1).onChange(() => {
    lights.updateLightSetUniformNumLights();
});

const stage = new Stage(scene, lights, camera, stats);

var renderer: Renderer | undefined;

function setRenderer(mode: string) {
    renderer?.stop();

    switch (mode) {
        case renderModes.naive:
            renderer = new NaiveRenderer(stage);
            break;
        case renderModes.forwardPlus:
            renderer = new ForwardPlusRenderer(stage);
            break;
        case renderModes.clusteredDeferred:
            renderer = new ClusteredDeferredRenderer(stage);
            break;
    }
}

const renderModes = { naive: 'naive', forwardPlus: 'forward+', clusteredDeferred: 'clustered deferred' };
let renderModeController = gui.add({ mode: renderModes.naive }, 'mode', renderModes);
renderModeController.onChange(setRenderer);

setRenderer(renderModeController.getValue());
