Shader "PBR/FX/Animated"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Alpha ("Alpha", Range(0, 1)) = 1
		_MainTex ("Main Texture", 2D) = "white" {}
		[Toggle] PBR_USE_ADDITIVE_COLOR ("Use aditive color", Float) = 0
		[HideWhenOff(PBR_USE_ADDITIVE_COLOR)] _AdditiveColor ("Additive Color", Color) = (1, 1, 1, 0)
		[Toggle] PBR_ANIMATED_USE_PURE_RGB ("Use main rgb for color", Float) = 0
		[Toggle] PBR_ANIMATED_USE_GRAY_SCALE ("Use grayscale", Float) = 0
		[FeatureEnum(OFF, LIGHTING, EMISSION)] PBR_ANIMATED_GREEN("Green channel usage", Float) = 0
		[FeatureEnum(OFF, TRANSLUCENCY, ALPHA)] PBR_ANIMATED_BLUE("Blue channel usage", Float) = 0
		[HideWhenOff(PBR_ANIMATED_GREEN)] _EmissionColor("Emission color", Color) = (1, 1, 1, 1)
		[HideWhenOff(PBR_ANIMATED_GREEN)] _EmissionColorEnd("Emission color end", Color) = (1, 1, 1, 1)
		
		[Header(Color)]
		[Toggle] PBR_ANIMATED_USE_LUT("Use LUT", Float) = 0
		[HideWhenOff(PBR_ANIMATED_USE_LUT)] _MainLut("LUT", 2D) = "white" {}
		[Toggle] PBR_ANIMATED_USE_VERTEX_COLOR_AS_EMISSION("Use vertex color as emission", Float) = 0
		
		[FeatureEnum(SIMPLE, ADVANCED_2, ADVANCED_3, ADVANCED_4, TEXTURE)] PBR_ANIMATED_GRADIENT_TYPE("Gradient type", Float) = 0
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColor0("Gradient color 0", Color) = (0, 0, 0, 0)
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColorPosition0("Gradient color position 0", Range(0, 1)) = 0
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColor1("Gradient color 1", Color) = (1, 1, 1, 1)
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColorPosition1("Gradient color position 1", Range(0, 1)) = 1
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColor2("Gradient color 2", Color) = (1, 1, 1, 1)
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColorPosition2("Gradient color position 2", Range(0, 1)) = 1
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColor3("Gradient color 3", Color) = (1, 1, 1, 1)
		[HideWhenOff(PBR_ANIMATED_GRADIENT_TYPE, 4)] _GradientColorPosition3("Gradient color position 3", Range(0, 1)) = 1
		
		_AlphaColorMultiplier("How much alpha impacts color. 0 no, 1 completely", Range(0, 1)) = 0
		
		[Toggle] PBR_TRANSPARENT_CUTOUT("Be cutout shader", Float) = 0
		[HideWhenOff(PBR_TRANSPARENT_CUTOUT)] _CutoutThreshold ("Cutout threshold", Range(0, 1)) = 0.5
		
		// [Header(Normal Map)]
		// [Toggle] PBR_USE_NORMALMAP("Use Normal map", Float) = 0
		// [HideWhenOff(PBR_USE_NORMALMAP)] _BumpMap("Normal map", 2D) = "bump" {}
		// [HideWhenOff(PBR_USE_NORMALMAP)] _BumpScale("Bump Scale", Float) = 1
		
		[Header(Subtract settings)]
		[Toggle] PBR_TRANSPARENT_SUBTRACT_ALPHA("Subtract alpha", Float) = 0
		[Toggle] PBR_TRANSPARENT_SUBTRACT_ALPHA_WHITE ("Subtract alpha from white", Float) = 0
		[Toggle] PBR_TRANSPARENT_FADE_IN("use fade in", Float) = 0
		_FadeParams("X-fade in start, Y-fade in end, Z-subtract start, W-subtract width", Vector) = (0, 1, 0, 1)
		
		[Header(Distort)]
		[Toggle] PBR_USE_DISTORT_MAP("Use Distort Map", Float) = 0
		[HideWhenOff(PBR_USE_DISTORT_MAP)] _DistortMap("DistortMap", 2D) = "white" {}
		[HideWhenOff(PBR_USE_DISTORT_MAP)] _DistortIntensity("Distort Intensity", Vector) = (1, 1, 0, 0)
		[HideWhenOff(PBR_USE_DISTORT_MAP)] _DistortTiling ("Distort XY Tiling, ZW Scroll", Vector) = (1, 1, 0, 0)
		
		[Header(Animation settings)]
		[FeatureEnum(OFF, ON)] PBR_TRANSPARENT_DISABLE_TILES("Disable tiling", Float) = 0
		_Scroll ("Scroll XY main scroll, ZW second alpha scroll", Vector) = (0, 0, 0, 0)
		
		[Header(Sprite sheet)]
		[Toggle] PBR_ANIMATED_USE_SPRITE_SHEET("Use sprite sheet", Float) = 0
		[HideWhenOff(PBR_ANIMATED_USE_SPRITE_SHEET, PBR_ANIMATED_USE_FLOWMAP)] _SheetParams("X-rows, Y-Columns, Z-Current frame", Vector) = (1, 1, 1, 0)

		[Header(Flow map)]
		[Toggle] PBR_ANIMATED_USE_FLOWMAP("Use flow map", Float) = 0
		[HideWhenOff(PBR_ANIMATED_USE_FLOWMAP)] _FlowMap("Flow map", 2D) = "white" {}
		[HideWhenOff(PBR_ANIMATED_USE_FLOWMAP)] _FlowMapStrength("Flow map strength", float) = 1
		
		[Header(Second Alpha)]
		[Toggle] PBR_ANIMATED_USE_SECOND_ALPHA("Use second alpha", Float) = 0
		[Toggle] PBR_USE_SECOND_UV("Use second uv channel for second alpha", Float) = 0
		[HideWhenOff(PBR_ANIMATED_USE_SECOND_ALPHA)] _SecondAlpha("Second alpha (red channel)", 2D) = "white" {}
		[HideWhenOff(PBR_ANIMATED_USE_SECOND_ALPHA)] _SecondAlphaTiling("XY-tiling, Z-transparency, W-Influence", Vector) = (1, 1, 1, 1)
		[Toggle] PBR_ANIMATED_SECOND_ALPHA_SPRITE_SHEET("Use sprite sheet for second alpha", Float) = 0
		[HideWhenOff(PBR_ANIMATED_SECOND_ALPHA_SPRITE_SHEET)] _SecondSheetParams("Second alpha sprite sheet. X-rows, Y-Columns, Z-Current frame", Vector) = (1, 1, 1, 0)
		
		[Header(Hardware settings)]
		[Enum(UnityEngine.Rendering.CullMode)] HARDWARE_CullMode ("Cull faces", Float) = 2
		[Enum(UnityEngine.Rendering.BlendMode)] HARDWARE_BlendSrc ("Blend Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] HARDWARE_BlendDst ("Blend Destination", Float) = 10
		[Enum(UnityEngine.Rendering.BlendOp)] HARDWARE_BlendOp ("Blend Operation", Float) = 0
		
		[Enum(On, 1, Off, 0)] HARDWARE_ZWrite ("Depth write", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] HARDWARE_ZTest("Depth test", Float) = 4
		[BitmaskEnum(UnityEngine.Rendering.ColorWriteMask, All)] HARDWARE_ColorWrite ("Color write mask", Float) = 15
		
		[Header(Hardware stencil)]
		_Stencil ("Stencil REF", Range(0, 255)) = 0
		_StencilReadMask ("Stencil Read Mask", Range(0, 255)) = 255
		_StencilWriteMask ("Stencil Write Mask", Range(0, 255)) = 255
		
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil comparison", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Pass", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil Z Fail", Float) = 0
	
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "LightMode" = "ForwardBase" "Queue"="Transparent"}
		LOD 100

		Pass
		{
			Cull [HARDWARE_CullMode]
			ZWrite [HARDWARE_ZWrite]
			ZTest [HARDWARE_ZTest]
			Blend [HARDWARE_BlendSrc] [HARDWARE_BlendDst]
			BlendOp [HARDWARE_BlendOp]
			
			Stencil
			{
				Ref [_Stencil]
				Comp [_StencilComp]
				
				Pass [_StencilOp]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}
		
			CGPROGRAM
			//!ShaderVersion: 7
			
			#pragma vertex vertPBR
			#pragma fragment fragEffect

			// Shader features
			#pragma shader_feature PBR_TRANSPARENT_SUBTRACT_ALPHA_ON
			#pragma shader_feature PBR_TRANSPARENT_SUBTRACT_ALPHA_WHITE_ON
			#pragma shader_feature PBR_TRANSPARENT_DISABLE_TILES_ON
			#pragma shader_feature PBR_TRANSPARENT_FADE_IN_ON
			#pragma shader_feature PBR_ANIMATED_USE_SPRITE_SHEET_ON
			#pragma shader_feature PBR_ANIMATED_USE_SECOND_ALPHA_ON
			#pragma shader_feature PBR_ANIMATED_USE_LUT_ON // Check if removing this breaks anything
			#pragma shader_feature PBR_USE_ADDITIVE_COLOR_ON
			#pragma shader_feature PBR_TRANSPARENT_CUTOUT_ON
			#pragma shader_feature PBR_USE_SECOND_UV_ON
			#pragma shader_feature PBR_ANIMATED_USE_PURE_RGB_ON
			#pragma shader_feature PBR_ANIMATED_SECOND_ALPHA_SPRITE_SHEET_ON
			#pragma shader_feature PBR_ANIMATED_USE_VERTEX_COLOR_AS_EMISSION_ON
			#pragma shader_feature PBR_ANIMATED_USE_GRAY_SCALE_ON
			#pragma shader_feature PBR_USE_DISTORT_MAP_ON
			
			// Gradient types
			#pragma shader_feature PBR_ANIMATED_GRADIENT_TYPE_SIMPLE
			#pragma shader_feature PBR_ANIMATED_GRADIENT_TYPE_ADVANCED_2
			#pragma shader_feature PBR_ANIMATED_GRADIENT_TYPE_ADVANCED_3
			#pragma shader_feature PBR_ANIMATED_GRADIENT_TYPE_ADVANCED_4
			#pragma shader_feature PBR_ANIMATED_GRADIENT_TYPE_TEXTURE
			
			// Green channel usage
			#pragma shader_feature PBR_ANIMATED_GREEN_LIGHTING
			#pragma shader_feature PBR_ANIMATED_GREEN_EMISSION
			// Blue channel usage
			#pragma shader_feature PBR_ANIMATED_BLUE_TRANSLUCENCY
			#pragma shader_feature PBR_ANIMATED_BLUE_ALPHA
			
			#pragma shader_feature PBR_ANIMATED_USE_FLOWMAP_ON
			
			#define PBR_USE_VERTEX_COLOR_ON
			#define PBR_POINT_LIGHT_TRANSPARENT

			#include "Effects.cginc"
			
			ENDCG
		}
	}
}
