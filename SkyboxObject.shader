Shader "LensError/SkyboxObject"
{
    Properties
    {
        // ========================================================
        // CUBEMAP & COLOR GRADING
        // ========================================================
        [Header(Cubemap and Lighting)]
        [NoScaleOffset] _Tex ("Cubemap", Cube) = "grey" {}
        _Tint ("Tint Color", Color) = (0.5, 0.5, 0.5, 1.0)
        [Gamma] _Exposure ("Exposure", Range(0.0, 8.0)) = 1.0
        _MipBias ("Mip Bias", Range(0.0, 8.0)) = 0.0

        // ========================================================
        // ROTATION & ORIENTATION
        // ========================================================
        [Header(Rotation and Orientation)]
        _Rotation ("Rotation", Range(0, 360)) = 0.0
        _Pitch ("Pitch", Range(-90, 90)) = 0.0
        [Toggle] _FollowCubeRotation ("Rotate With Transform", Float) = 0

        // ========================================================
        // RENDER PIPELINE & MESH BEHAVIOR
        // ========================================================
        [Header(Render State and Depth)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
        [Toggle] _ZWrite ("ZWrite", Float) = 1
        [Toggle] _ForceFarPlaneDepth ("Force Far Plane Depth", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry+510"
            "RenderType" = "Background"
            "PreviewType" = "Skybox"
            "IgnoreProjector" = "True"
            "DisableBatching" = "True"
        }

        Cull [_Cull]
        ZWrite [_ZWrite]
        ZTest [_ZTest]
        Blend Off

        Pass
        {
            Name "CubemapSkyboxPass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            // Single Pass Instanced (SPI) VR compatibility
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            UNITY_DECLARE_TEXCUBE(_Tex);
            half4 _Tex_HDR;

            half4 _Tint;
            half  _Exposure;
            half  _MipBias;
            half  _Rotation;
            half  _Pitch;
            fixed _FollowCubeRotation;
            fixed _ForceFarPlaneDepth;
            fixed _ZWrite;

            #define PI 3.14159265359

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);

                // When ForceFarPlaneDepth is enabled, push clip Z to the far plane
                // so the cube acts as a pure infinite background skybox behind all world geometry
                if (_ForceFarPlaneDepth > 0.5)
                {
                    #if defined(UNITY_REVERSED_Z)
                        o.pos.z = 1.0e-7f;
                    #else
                        o.pos.z = o.pos.w - 1.0e-5f;
                    #endif
                }

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                // In Single Pass Instanced (SPI) VR, _WorldSpaceCameraPos is the per-eye world position
                float3 camPos = _WorldSpaceCameraPos;

                // View ray from camera eye through this point on the cube surface
                float3 rayDir = normalize(i.worldPos - camPos);

                // Optional: follow the cube transform rotation
                if (_FollowCubeRotation > 0.5)
                {
                    rayDir = normalize(mul((float3x3)unity_WorldToObject, rayDir));
                }

                // Global skybox yaw rotation
                float radYaw = _Rotation * (PI / 180.0);
                float sY = sin(radYaw);
                float cY = cos(radYaw);
                rayDir = float3(rayDir.x * cY + rayDir.z * sY, rayDir.y, -rayDir.x * sY + rayDir.z * cY);

                // Optional pitch tilt
                if (abs(_Pitch) > 0.001)
                {
                    float radPitch = _Pitch * (PI / 180.0);
                    float sP = sin(radPitch);
                    float cP = cos(radPitch);
                    rayDir = float3(rayDir.x, rayDir.y * cP - rayDir.z * sP, rayDir.y * sP + rayDir.z * cP);
                }

                // Sample cubemap (with optional Mip/Blur level)
                half4 tex;
                if (_MipBias > 0.001)
                {
                    tex = UNITY_SAMPLE_TEXCUBE_LOD(_Tex, rayDir, _MipBias);
                }
                else
                {
                    tex = UNITY_SAMPLE_TEXCUBE(_Tex, rayDir);
                }

                // Standard Unity HDR decoding for HDR cubemaps (RGBM / dLDR / Float)
                half3 c = DecodeHDR(tex, _Tex_HDR);

                // Apply tint and color space compensation
                c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
                c *= _Exposure;

                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Skybox/Cubemap"
}
