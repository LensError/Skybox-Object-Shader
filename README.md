# SkyboxObject

Simple Unity Built-in Render Pipeline (BiRP) shader that projects a cubemap onto any standard 3D object (cube, sphere, mesh) so it looks like an infinite skybox.

Works from the outside (sky portal / window / crystal ball) or from the inside (infinite sky dome).

## Installation (UPM)
In Unity: **Window > Package Manager** > click **`+`** > **Add package from git URL...** and paste:
```
https://github.com/LensError/SkyboxObject.git
```

## Usage
1. Create a material using shader **`LensError/SkyboxObject`** (or use `SkyboxObject_Default.mat`).
2. Assign your cubemap.
3. Drop it on any cube, sphere, or mesh and scale it however you want.

## Features
- **VR Ready:** Single Pass Instanced (SPI) stereo support with zero eye distortion.
- **HDR:** Native HDR cubemap decoding, exposure, and tint.
- **Transforms:** Yaw & Pitch rotation, plus optional follow transform rotation.
- **Depth:** Proper ZWrite & depth testing so objects and transparency behind it don't bleed through.
