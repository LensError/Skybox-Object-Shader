# SkyboxObject

Simple Unity Built-in Render Pipeline shader that projects a cubemap onto any standard 3D object (cube, sphere, mesh) so it looks like an infinite skybox.

## Installation (UPM)
In Unity: **Window > Package Manager** > click **`+`** > **Add package from git URL...** and paste:
```
https://github.com/LensError/SkyboxObject.git
```

## Usage
1. Create a material using shader **`LensError/SkyboxObject`** (or use `SkyboxObject_Default.mat`).
2. Assign your cubemap.
3. Drop it on any cube, sphere, or mesh and scale it however you want.
