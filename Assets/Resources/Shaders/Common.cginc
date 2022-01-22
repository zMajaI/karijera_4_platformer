// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef PBR_COMMON_CGINC
#define PBR_COMMON_CGINC

	/////////////////////////////////////////////////////////
	//
	// Defines custom PBR shaders.
	//
	// Defines:
	// PBR_USE_GLOSSMAP_ON - Use spec gloss map instead of float uniforms
	// PBR_USE_FRESNEL_ON - Use fresnel equation with reflection
	// PBR_USE_NORMALMAP_ON - Use normalmap instead of vertex normals
	// PBR_USE_EMISSION_ON - Use emission
	// PBR_USE_LIGHT_SPECULAR_ON - Add specular from real time lighting
	// PBR_USE_BOX_CORRECTION_ON - Uses box correction when reading cube map
	// PBR_USE_ALBEDO_REFLECTION_ON - make the reflection the same color as albedo
	// PBR_USE_REALTIME_SHADOWS_ON - use realtime shadows
	// PBR_USE_REFLECTIONS_ON - use reflections
	// PBR_USE_ALBEDO_BLENDING_ON - use 2 blended albedo textures
	// PBR_USE_RIM_LIGHT_ON - use rim lights
	//
	// PBR_USE_VERTEX_COLOR_ON - use vertex color
	// PBR_USE_SECOND_UV_ON - use the second uv channel
	//
	// PBR_TRANSPARENCY_FROM_REFLECTION_ON - make alpha from reflection color
	//
	/////////////////////////////////////////////////////////
	
	#include "HLSLSupport.cginc"
	
	
	#ifdef PBR_USE_WORLD_NORMALMAP_ON
		#define PBR_USE_NORMALMAP_WORLD
	#else
		#define PBR_USE_NORMALMAP_TANGENT
	#endif
	
#if defined(PBR_POINT_LIGHT_CALCULATION_FRAGMENT) || defined(PBR_POINT_LIGHT_CALCULATION_VERTEX)
	#include "PointLight.cginc"
#endif
	
	// ------ Sorting out shader features ------
	#define TRANSFER_WORLD_POSITION

	#if L_COUNT > 0 && defined(PBR_POINT_LIGHT_CALCULATION_FRAGMENT)
		#define USE_HIGHT_QUALITY_POINT_LIGHT
	#endif
	
	#if defined(PBR_USE_REFLECTIONS_ON) || defined(PBR_USE_LIGHT_SPECULAR_ON) || defined(USE_HIGHT_QUALITY_POINT_LIGHT) || defined(PBR_USE_RIM_LIGHT_FRESNEL)
		#define USE_SMOOTHNESS_ROUGHNESS
	#endif
	
	#if defined(PBR_LIGHTMAP_ON)
		#undef LIGHTMAP_OFF
		#define LIGHTMAP_ON
	#endif
	
	// --------------------------- Structs ---------------------
	
	#if !defined(PBR_USE_NORMALMAP_ON) || (defined(PBR_USE_NORMALMAP_ON) && defined(PBR_USE_NORMALMAP_TANGENT)) || (defined(PBR_POINT_LIGHT_CALCULATION_VERTEX) && L_COUNT > 0)
		#define PBR_HAS_INPUT_NORMAL
	#endif
	
	struct VInput
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		#if defined(PBR_LIGHTMAP_ON) || defined(PBR_USE_SECOND_UV_ON)
			half2 uv2 : TEXCOORD1;
		#endif
		#ifdef PBR_USE_VERTEX_COLOR_ON
			half4 color : COLOR;
		#endif
		
		#ifdef PBR_HAS_INPUT_NORMAL
			half3 normal : NORMAL;
		#endif
		
		#if defined(PBR_USE_NORMALMAP_ON) && defined(PBR_USE_NORMALMAP_TANGENT)
			half4 tangent : TANGENT;
		#endif
	};
	
	struct FInput
	{
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		#if defined(PBR_LIGHTMAP_ON) || defined(PBR_USE_SECOND_UV_ON)
			half2 uv2 : TEXCOORD1;
		#endif
		
		//float3 viewDir : TEXCOORD2;
		#if defined(PBR_USE_NORMALMAP_ON) && defined(PBR_USE_NORMALMAP_TANGENT)
			half3 rotation0 : TEXCOORD3;
			half3 rotation1 : TEXCOORD4;
			half3 rotation2 : TEXCOORD5;
		#else
			half3 normal : TEXCOORD3;
		#endif
		#ifdef PBR_USE_VERTEX_COLOR_ON
			half4 color : COLOR;
		#endif
		#ifdef PBR_POINT_LIGHT_CALCULATION_VERTEX
			half3 lightColor : COLOR2;
		#endif
		#ifdef PBR_USE_REALTIME_SHADOWS_ON
			float4 shadowCoords : TEXCOORD6;
		#endif
		#ifdef TRANSFER_WORLD_POSITION
			half3 worldPosition : TEXCOORD7;
		#endif
	};
	
	// --------------------------- Uniforms ---------------------
	
	// PBR params
	uniform half _Smoothness;
	uniform half _Reflectivity;
	uniform half _ReflectivityPower;
	uniform half _ReflectionAlbedo;
	uniform half _CutoutThreshold;
	
	uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;
	uniform sampler2D _BumpMap;
	uniform sampler2D _EmissionMap;
	
	uniform half4 _Color;
	uniform half4 _EmissionColor;
	
	// Reflection reading
	uniform half _ReflectionStrength;
	uniform half _ReflectionStrengthMin;

	// Shadow params
	uniform float4x4 _World2ShadowCamera;
	#if defined(SHADER_API_GLES3) || defined(SHADER_API_GLES)
		uniform sampler2D _ShadowMap;
		uniform sampler2D _ShadowMapStatic;
	#else
		uniform UNITY_DECLARE_SHADOWMAP(_ShadowMap);
		uniform UNITY_DECLARE_SHADOWMAP(_ShadowMapStatic);
	#endif
	uniform half4 _ShadowColor;
	
	// Water params
	uniform half4 _MainTransform;
	uniform sampler2D _MaskMap;
	uniform samplerCUBE _CustomCube;
	uniform half _SpecularPower;
	uniform half _EmissionVertexColor;
	uniform half _GrayoutFactor;
	
	uniform sampler2D _SpecGlossMap;
	uniform float4 _SpecGlossMap_ST;
	
	uniform sampler2D _PBRLightmap;
	
	// Albedo blending
	uniform sampler2D _SecondAlbedo;
	uniform half4 _SecondAlbedo_ST;
	// Blending xyz - position | w - 1 / (blending distance)^2
	uniform half4 _AlbedoBlendingPosition;
	// x distance factor multiplier, y mask start blend, z mask end blend
	uniform half4 _AlbedoBlendingParams;

	// Light params
	uniform half3 _DirectionalLightDir;
	uniform half4 _DirectionalLightColor;
	uniform half3 _DirectionalLightDir1;
	uniform half4 _DirectionalLightColor1;
	
	// Rim light params
	uniform half _RimLightCoeff;
	uniform half3 _RimLightDirection;
	uniform half4 _RimLightColor;
	
	// Box correction parameters
	uniform half2 _BoxCorrectionParams;
	
	// Copied from unity cginc
	uniform half4  unity_ColorSpaceLuminance;

	// additive color
	uniform half4  _AdditiveColor;
	
	// ------------------------- Defines ------------------------
	
	// 1024 texture
	#define TEXEL 0.000946
	
	#ifdef PBR_DIR_LIGHT_CHARACTER
		#define LIGHT_DIR _DirectionalLightDir1
		#define LIGHT_COLOR _DirectionalLightColor1
	#else
		#define LIGHT_DIR _DirectionalLightDir
		#define LIGHT_COLOR _DirectionalLightColor
	#endif
	
	#define PBR_CALCULATE_VIEW_DIR half3 viewDir = normalize(i.worldPosition.xyz - _WorldSpaceCameraPos.xyz);
	#define PBR_CALCULATE_NDOTL half NdotL = saturate(dot(normal, -LIGHT_DIR.xyz));
	
	#if defined(PBR_USE_REFLECTIONS_ON) || defined(PBR_USE_LIGHT_SPECULAR_ON) || defined(USE_HIGHT_QUALITY_POINT_LIGHT)
		#define PBR_CALCULATE_RDIR half3 rDir = reflect(viewDir, normal);
	#else
		#define PBR_CALCULATE_RDIR
	#endif
	
	#if defined(PBR_USE_LIGHT_SPECULAR_ON) || (defined(PBR_POINT_LIGHT_CALCULATION_FRAGMENT) && L_COUNT > 0)
		#define PBR_CALCULATE_SPECULAR_POWER float specularPower = pow(512, 1 - roughness);
	#else
		#define PBR_CALCULATE_SPECULAR_POWER float specularPower = 1;
	#endif
	
	// Output reflectivity, roughness
	#ifdef USE_SMOOTHNESS_ROUGHNESS
		#ifdef PBR_USE_GLOSSMAP_ON
			#define PBR_READ_REFLECTIVITY_ROUGHNESS \
				half4 rawGlossMap = tex2D(_SpecGlossMap, TRANSFORM_TEX(i.uv, _SpecGlossMap));\
				rawGlossMap = rawGlossMap * rawGlossMap;\
				half reflectivity = rawGlossMap.r;\
				half roughness = 1 - rawGlossMap.b;
		#else
			#define PBR_READ_REFLECTIVITY_ROUGHNESS \
				half roughness = 1 - _Smoothness;\
				half reflectivity = _Reflectivity;
		#endif
	#else
		#define PBR_READ_REFLECTIVITY_ROUGHNESS
	#endif
	
	#ifdef PBR_USE_NORMALMAP_WORLD
		#define TRANSFORM_NORMAL half3 normal = rawNormal;
	#else // PBR_USE_NORMALMAP_TANGENT
		#define TRANSFORM_NORMAL half3 normal = normalize((i.rotation0.xyz * rawNormal.x + i.rotation1.xyz * rawNormal.y + i.rotation2.xyz * rawNormal.z));
	#endif
	
	// Output: normal
	#ifdef PBR_USE_NORMALMAP_ON
		// Old unpack
		//half3 rawNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
		#define READ_NORMAL \
			half3 rawNormal = tex2D(_BumpMap, i.uv).xyz * 2 - 1;\
			TRANSFORM_NORMAL
	#else
		#define READ_NORMAL half3 normal = normalize(i.normal);
	#endif
	
	
	#if defined(PBR_GLOSSMAP_GREEN_REFLECTION_BRIGHTNESS_ON) && defined(PBR_USE_GLOSSMAP_ON)
		#define REFLECTION_MIN _ReflectionStrengthMin * (1 - rawGlossMap.g)
	#else
		#define REFLECTION_MIN _ReflectionStrengthMin
	#endif
	// Output: reflection
	// UNITY_SPECCUBE_LOD_STEPS is 6 from unity cginc
	#define READ_REFLECTION_PROBE \
			half4 reflection = texCUBElod(_CustomCube, half4(probeDir, roughness * 6));\
			reflection += saturate(reflection - REFLECTION_MIN) * reflection * _ReflectionStrength;
	
	// Applies the diffuse component of the  vertex color to the albedo
	#ifdef PBR_USE_VERTEX_COLOR_ON
		#ifdef PBR_USE_EMISSION_ON
			#define PBR_APPLY_DIFFUSE_VERTEX_COLOR albedo = lerp(albedo * i.color, albedo, _EmissionVertexColor);
		#else
			#define PBR_APPLY_DIFFUSE_VERTEX_COLOR albedo *= i.color;
		#endif
	#else
		#define PBR_APPLY_DIFFUSE_VERTEX_COLOR
	#endif
	
	// Applies emissive component of the shader to the color variable
	#ifdef PBR_USE_EMISSION_ON
		#ifdef PBR_USE_VERTEX_COLOR_ON
			#define PBR_APPLY_EMISSION \
				color += i.color * _EmissionVertexColor;\
				color += tex2D(_EmissionMap, i.uv) * _EmissionColor;
		#else
			#define PBR_APPLY_EMISSION color += tex2D(_EmissionMap, i.uv) * _EmissionColor;
		#endif
	#else
		#define PBR_APPLY_EMISSION
	#endif
	
	// Copied from unity cginc Transforms 2D UV by scale/bias property
#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
	
	// -------------------------- Functions ----------------------
	
	// Copied from unity cginc
	inline float DecodeFloatRGBA( float4 enc )
	{
		float4 kDecodeDot = float4(1.0, 1/255.0, 1/65025.0, 1/16581375.0);
		return dot( enc, kDecodeDot );
	}
	
	// Copied from unity cginc
	// Encoding/decoding [0..1) floats into 8 bit/channel RGBA. Note that 1.0 will not be encoded properly.
	inline float4 EncodeFloatRGBA( float v )
	{
		float4 kEncodeMul = float4(1.0, 255.0, 65025.0, 16581375.0);
		float kEncodeBit = 1.0/255.0;
		float4 enc = kEncodeMul * v;
		enc = frac (enc);
		enc -= enc.yzww * kEncodeBit;
		return enc;
	}
	
	// Copied from unity cginc
	inline half Luminance( half3 c )
	{
		// In Gamma space equation is simple
		return dot(c, half3(56 / 255.0, 180 / 255.0, 18 / 255.0));
	}
	
	float Fresnel(float3 N, float3 V, float X)
	{
		float Fresnel = 1.0 - saturate(dot(N, V));
		return pow(Fresnel, X);
	}
	
	inline half3 BoxCorrection(half3 worldRefl, half3 worldPos, half2 correctionParams)
	{
		half3 nrdir = worldRefl;

		half2 rbminmax = half2(sign(nrdir.x) * correctionParams.x, correctionParams.y);
		rbminmax = (rbminmax - worldPos.xz) / nrdir;
		
		half fa = min(rbminmax.x, rbminmax.y);
		
		// Reflection probes have to be baked in (0,0,0)
		//worldPos -= cubemapCenter.xyz;
		worldRefl = worldPos + nrdir * fa;
		return worldRefl;
		
		// Old high quality box correction
		// #if 1				
			// OLD
			// half3 rbmax = (boxMax.xyz - worldPos) / nrdir;
			// half3 rbmin = (boxMin.xyz - worldPos) / nrdir;

			// half3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;

			// This does all components separately (making 3 if operations)
			// half3 rbminmax = (nrdir > 0.0f) ? boxMax.xyz : boxMin.xyz;
			// rbminmax = (rbminmax - worldPos) / nrdir;
		// #else // Optimized version
			// half3 rbmax = (boxMax.xyz - worldPos);
			// half3 rbmin = (boxMin.xyz - worldPos);

			// half3 select = step (half3(0,0,0), nrdir);
			// half3 rbminmax = lerp (rbmax, rbmin, select);
			// rbminmax /= nrdir;
		// #endif

		// half fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);

		// worldPos -= cubemapCenter.xyz;
		// worldRefl = worldPos + nrdir * fa;
		// return worldRefl;
	}
	
	#define EXP_SHADOW_FACTOR	(-30.0)
	#if !defined(SHADER_API_GLES3) && !defined(SHADER_API_GLES)
		#define SHADOW_BIAS 0.004
	#else
		#define SHADOW_BIAS -0.004
	#endif

	inline half GetShadow(half3 shadowCoords)
	{
		#if defined(SHADER_API_GLES3) || defined(SHADER_API_GLES)
			float distance = shadowCoords.z - DecodeFloatRGBA(tex2D(_ShadowMap, shadowCoords.xy));
			float shadow = saturate(exp(EXP_SHADOW_FACTOR * distance));
		#else
			float shadow = UNITY_SAMPLE_SHADOW(_ShadowMap, float3(shadowCoords.xy, shadowCoords.z + SHADOW_BIAS));
		#endif
		
		return shadow;
	}
	
	#define DIRECTIONAL_LIGHT_DIFFUSE_MULTIPLIER 2
	inline half3 CalculateDiffuse(in FInput i, in half NdotL, inout half shadowMask)
	{
		#ifdef PBR_USE_REALTIME_SHADOWS_ON
			half shadow = GetShadow(i.shadowCoords);
			half DminS = saturate(min(NdotL, shadow));
			half3 diffuseColor = lerp(LIGHT_COLOR.xyz * DIRECTIONAL_LIGHT_DIFFUSE_MULTIPLIER, _ShadowColor, shadowMask * (1 - DminS));
			shadowMask *= DminS;
		#else
			// Without shadows we should apply the diffuse, so the shaders do not look so different
			half3 diffuseColor = lerp(LIGHT_COLOR.xyz * DIRECTIONAL_LIGHT_DIFFUSE_MULTIPLIER, _ShadowColor, shadowMask * (1 - NdotL));
			shadowMask *= NdotL;
		#endif
		
		return diffuseColor;
	}
	
	inline void ApplyLightmap(in FInput i, inout half4 albedo, inout half shadowMask)
	{
		#ifdef PBR_LIGHTMAP_ON
			half4 lightmap = tex2D(_PBRLightmap, i.uv2);
			lightmap = lightmap *lightmap;
			albedo.rgb *= lightmap.rgb;
			shadowMask = lightmap.a;
		#endif
	}
		
	inline void ApplyPointLights(in FInput i, inout half3 color, in half3 rDir, in half3 normal, in half specularPower)
	{
		#ifdef USE_HIGHT_QUALITY_POINT_LIGHT
			#ifdef PBR_USE_REFLECTIONS_ON
				color.rgb += CalculatePointLightSpecular(normal, i.worldPosition, rDir, specularPower);
			#else
				color.rgb += CalculatePointLight(normal, i.worldPosition, 1);
			#endif
		#endif

		#if defined(PBR_POINT_LIGHT_CALCULATION_VERTEX) && L_COUNT > 0
			color.rgb += i.lightColor;
		#endif
	}
	
	inline half3 ApplyRimLight(inout half3 color, in half3 viewDir, in half3 normal, in half roughness, in half reflectivity)
	{
		#if defined(PBR_USE_RIM_LIGHT_DIRECTIONAL)
			half3 rimLight = Fresnel(normal, -normalize(viewDir), _RimLightCoeff);
			rimLight *= saturate(dot(normal, -normalize(_RimLightDirection)));

			half3 result = rimLight * _RimLightColor.rgb * _RimLightColor.a;
			color.rgb += result;
			return result;
		#elif defined(PBR_USE_RIM_LIGHT_FRESNEL)
				half grazingF90 = 1;
				//half3 finalFresnel = lerp(half3(0,0,0), grazingF90 * _RimLightColor.rgb * _RimLightColor.a * 4, pow(1 - dot(normal, -viewDir), _RimLightCoeff));
				half finalFresnel = pow(1 - dot(normal, -viewDir), _RimLightCoeff);
				color.rgb = lerp(color.rgb, _RimLightColor, finalFresnel);
				return finalFresnel;
		#else
				return 0;
		#endif
	}
	
	// ------------------------ Shader programs --------------------
	
	FInput vertPBR(VInput v)
	{
		FInput o = (FInput)0;
		o.vertex = UnityObjectToClipPos(v.vertex);
		
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		
		// Calculate view direction
		float4 positionWorld = mul(unity_ObjectToWorld, v.vertex);
		positionWorld /= positionWorld.w;
		
		#if defined(PBR_HAS_INPUT_NORMAL)
			// Calculate normals, and what is needed for normal map
			half3 normalWorld = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		#endif

		#ifdef PBR_USE_NORMALMAP_ON
			#if defined(PBR_USE_NORMALMAP_TANGENT)
				half4 tangentWorld = half4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)), v.tangent.w);
				
				o.rotation0 = tangentWorld;
				o.rotation1 = cross(normalWorld, tangentWorld) * tangentWorld.w * unity_WorldTransformParams.w;
				o.rotation2 = normalWorld;
			#endif
		#else
			o.normal = normalWorld;
		#endif
		
		#ifdef PBR_LIGHTMAP_ON
			o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
		#elif defined(PBR_USE_SECOND_UV_ON)
			o.uv2 = TRANSFORM_TEX(v.uv2, _MainTex);
		#endif

		#ifdef PBR_USE_REALTIME_SHADOWS_ON
			o.shadowCoords = mul(_World2ShadowCamera, positionWorld);
			o.shadowCoords /= o.shadowCoords.w;
			
			o.shadowCoords.xy = (o.shadowCoords.xy + 1) * 0.5;
			#if defined(SHADER_API_GLES3) || defined(SHADER_API_GLES) || defined(SHADER_API_METAL)
				// Normalize to range [0-1]
				o.shadowCoords.z = o.shadowCoords.z * 0.5 + 0.5;
			#endif
			#if !defined(SHADER_API_GLES3) && !defined(SHADER_API_GLES)
				// The techniques that use the depth buffer have to be flipped, since the
				// depth texture uses reverse depth buffer
				o.shadowCoords.z = 1 - o.shadowCoords.z;
			#endif
		#endif
		#ifdef TRANSFER_WORLD_POSITION
			o.worldPosition.xyz = positionWorld;
		#endif
		#if defined(PBR_POINT_LIGHT_CALCULATION_VERTEX) && L_COUNT > 0
			o.lightColor = CalculatePointLight(normalWorld, positionWorld, 1);
		#endif
		#ifdef PBR_USE_VERTEX_COLOR_ON
			o.color = v.color;
		#endif
		
		return o;
	}
	
	half4 fragPBR(FInput i) : SV_Target
	{
		#ifdef PBR_BE_PURPLE
			return half4(0.8, 0, 1, 1);
		#endif

		// ===================================================================================
		// ========================== Initial albedo, discard check ==========================
		// ===================================================================================
	
		// Sample textures
		half4 albedo = tex2D(_MainTex, i.uv);
		albedo = albedo * albedo * _Color;
		PBR_APPLY_DIFFUSE_VERTEX_COLOR
		
		#ifdef PBR_TRANSPARENT_CUTOUT_ON
			// Discard instruction should come as early as possible, that is why we are doing it
			// in the beginning of the shader
			if (albedo.a < _CutoutThreshold) discard;
		#endif
	
		// ===================================================================================
		// =========================== Sampling input params =================================
		// ===================================================================================
		half shadowMask = 1;
		half specularMultiplier = 1;
		
		READ_NORMAL
		
		PBR_CALCULATE_VIEW_DIR
		PBR_CALCULATE_RDIR
		PBR_CALCULATE_NDOTL

		PBR_READ_REFLECTIVITY_ROUGHNESS

		PBR_CALCULATE_SPECULAR_POWER

		// =======================================================================================
		// ====================== Shadows, Lightmaps ====================================
		// =======================================================================================
		
		// Lightmaps
		ApplyLightmap(i, albedo, shadowMask);
		
		// Shadow & diffuse
		half3 diffuseColor = CalculateDiffuse(i, NdotL, shadowMask);
		albedo.rgb *= diffuseColor;

		#if defined(PBR_LIGHTMAP_ON) || defined(PBR_USE_REALTIME_SHADOWS_ON)
			specularMultiplier = saturate(shadowMask - 0.5) * 2;
		#endif
				
		// ========================================================================================
		// ================================= Reflection calculations ==============================
		// ========================================================================================
		
		#ifdef PBR_USE_REFLECTIONS_ON
			#ifdef PBR_USE_BOX_CORRECTION_ON
				// Box Correction
				half3 probeDir = BoxCorrection(rDir, i.worldPosition, _BoxCorrectionParams);
			#else
				half3 probeDir = rDir;
			#endif
			READ_REFLECTION_PROBE
			reflection.rgb *= saturate(diffuseColor.rgb);
			
			#if defined(PBR_USE_ALBEDO_REFLECTION_ON)
				#if defined(PBR_USE_GLOSSMAP_ON) && defined(PBR_GLOSSMAP_GREEN_METALNESS_ON)
					reflection = lerp(reflection, Luminance(reflection) * albedo, _ReflectionAlbedo * rawGlossMap.g);
				#else
					reflection = lerp(reflection, Luminance(reflection) * albedo, _ReflectionAlbedo);
				#endif
			#endif
			
			half f = reflectivity;
			half3 color = albedo.xyz + (reflection.xyz - albedo.xyz) * f;
			
			#if defined(PBR_TRANSPARENCY_FROM_REFLECTION_ON)
				half reflectionTransparency = (reflection.x + reflection.y + reflection.z) * 0.333;
			#endif
		#else
			half3 color = albedo.xyz;
		#endif // PBR_USE_REFLECTIONS_ON
		
		// ====================================================================================
		// ============================== Additive light calculations =========================
		// ====================================================================================

		// Directional Light
		#ifdef PBR_USE_LIGHT_SPECULAR_ON
			// stupid workaround for stupid Galaxy S8 bug, check with misaj before changing
			half a = LIGHT_COLOR.a * LIGHT_COLOR.xyz;
			half b = pow(saturate(dot(rDir, -LIGHT_DIR.xyz)), specularPower) * (specularPower + 8) / (8 * 3.1415) * a;
			half c = b * (1.04 - roughness);
			half directionalSpecular = saturate(c);
			color += directionalSpecular;

			#if defined(PBR_USE_REFLECTIONS_ON) && defined(PBR_TRANSPARENCY_FROM_REFLECTION_ON) && defined(PBR_TRANSPARENCY_GLASS_ON)
				reflectionTransparency = max(reflectionTransparency, directionalSpecular);
			#endif
		#endif

		// Point lights
		#ifdef USE_HIGHT_QUALITY_POINT_LIGHT
			ApplyPointLights(i, color, rDir, normal, clamp(specularPower, 1, 6.5));
		#else
			ApplyPointLights(i, color, 1, normal, 1);
		#endif

		// Rimlights
		#ifdef USE_SMOOTHNESS_ROUGHNESS
			half3 rim = ApplyRimLight(color, viewDir, normal, roughness, reflectivity);
			#if defined(PBR_USE_REFLECTIONS_ON) && defined(PBR_TRANSPARENCY_FROM_REFLECTION_ON) && defined(PBR_TRANSPARENCY_GLASS_ON)
				reflectionTransparency = max(reflectionTransparency, (rim.x + rim.y + rim.z) * 0.3333);
			#endif
		#endif
		
		PBR_APPLY_EMISSION
		
		#if defined(PBR_USE_REFLECTIONS_ON) && defined(PBR_TRANSPARENCY_FROM_REFLECTION_ON)
			albedo.a *= reflectionTransparency;
		#endif

		#if defined(PBR_USE_LINEAR_COLOR_SPACE_ON)
			// Assuming gamma of 2.2
			half4 finalColor = half4(pow(color, 0.45454545), albedo.a);
		#else
			half4 finalColor = half4(color, albedo.a);
		#endif
		
#ifndef PBR_DIR_LIGHT_ENVIRONMENT
		finalColor.rgb = lerp(finalColor.rgb, _AdditiveColor.rgb, _AdditiveColor.a);
#endif

#if defined(PBR_USE_GRAYOUT_ON)
	    finalColor.rgb = lerp(finalColor.rgb, Luminance(finalColor.rgb), _GrayoutFactor);
#endif
		return finalColor;
	}	
#endif 