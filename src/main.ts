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

const gui = new GUI();
gui.add(lights, 'numLights').min(1).max(Lights.maxNumLights).step(1).onChange(() => {
    lights.updateLightSetUniformNumLights();
});

// Add a gui button to run a simple benchmark
const benchmark = {
    avgMs: '',
    runBenchmark: () => {
        const frameTimes: number[] = [];
        let lastTime = performance.now();
        let framesPassed = 0;

        function tick(now: number) {
            const currentFrameTime = now - lastTime;
            lastTime = now;

            if (framesPassed < 20){
                // Skip the first 20 frames for a warmup
                framesPassed++;
                requestAnimationFrame(tick);
                return;
            }

            frameTimes.push(currentFrameTime);

            if (frameTimes.length < 100) {
                requestAnimationFrame(tick);
                return;
            } 

            // Compute the average frame time
            var totalFrameTime = 0.0
            for (const frameTime of frameTimes) {
                totalFrameTime += frameTime;
            }
            const avgFrameTime = totalFrameTime / frameTimes.length;

            // Store the result as a string
            benchmark.avgMs = `${avgFrameTime.toFixed(2)}`;
            resultGuiController.updateDisplay();
        }
        requestAnimationFrame(tick);
    }
};

gui.add(benchmark, 'runBenchmark').name('Run Benchmark'); // Add a benchmark button to the gui
const resultGuiController = gui.add(benchmark, 'avgMs').name('Avg ms:'); // Add the benchmark result to the gui

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
