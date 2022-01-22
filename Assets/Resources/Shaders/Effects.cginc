#ifndef PBR_EFFECTS_CGINC
#define PBR_EFFECTS_CGINC

	#include "Common.cginc"

	uniform half _Alpha;
	uniform float4 _Scroll;
	uniform half4 _FadeParams;
	uniform float4 _SheetParams;
	uniform half4 _SecondSheetParams;
	uniform half _AlphaColorMultiplier;

	uniform half4 _SecondAlphaTiling;

	uniform sampler2D _MainLut;
	uniform sampler2D _SecondAlpha;

	uniform half4 _GradientColor0;
	uniform half4 _GradientColor1;
	uniform half4 _GradientColor2;
	uniform half4 _GradientColor3;

	uniform half _GradientColorPosition0;
	uniform half _GradientColorPosition1;
	uniform half _GradientColorPosition2;
	uniform half _GradientColorPosition3;
	
    uniform sampler2D   _DistortMap;
    uniform Vector      _DistortIntensity;
    uniform float4      _DistortTiling;
    //uniform float2      distortion;

#if defined(PBR_ANIMATED_USE_FLOWMAP_ON)
	uniform sampler2D _FlowMap;
	uniform half _FlowMapStrength;
#endif

	uniform half4 _EmissionColorEnd;

	// Gradient resolving
	#if defined(PBR_ANIMATED_GRADIENT_TYPE_SIMPLE)
		#define RESOLVE_GRADIENT(value) half4 color = lerp(_GradientColor0, _GradientColor1, value);
	#elif defined(PBR_ANIMATED_GRADIENT_TYPE_ADVANCED_2)
		#define RESOLVE_GRADIENT(value) half4 color = lerp(_GradientColor0, _GradientColor1, saturate((value - _GradientColorPosition0) / (_GradientColorPosition1 - _GradientColorPosition0)));
	#elif defined(PBR_ANIMATED_GRADIENT_TYPE_ADVANCED_3)
		#define RESOLVE_GRADIENT(value) \
			half l1 = (value - _GradientColorPosition0) / (_GradientColorPosition1 - _GradientColorPosition0); \
			half l2 = (value - _GradientColorPosition1) / (_GradientColorPosition2 - _GradientColorPosition1); \
			half4 color = lerp(_GradientColor0, _GradientColor1, l1) * (l1 < 1)  + lerp(_GradientColor1, _GradientColor2, l2) * (l2 > 0);
	#elif defined(PBR_ANIMATED_GRADIENT_TYPE_ADVANCED_4)
		// With 3-4 gradient colors might be more expensive then a LUT..
		#define RESOLVE_GRADIENT(value) \
			half l1 = (value - _GradientColorPosition0) / (_GradientColorPosition1 - _GradientColorPosition0); \
			half l2 = (value - _GradientColorPosition1) / (_GradientColorPosition2 - _GradientColorPosition1); \
			half l3 = (value - _GradientColorPosition2) / (_GradientColorPosition3 - _GradientColorPosition2); \
			half4 color = lerp(_GradientColor0, _GradientColor1, l1) * (l1 < 1) + \
				lerp(_GradientColor1, _GradientColor2, l2) * (l2 > 0) * (l2 < 1) + \
				lerp(_GradientColor2, _GradientColor3, l3) * (l3 > 0);
	#elif defined(PBR_ANIMATED_GRADIENT_TYPE_TEXTURE)
		#define RESOLVE_GRADIENT(value) half4 color = tex2D(_MainLut, half2(value, 0));
	#else
		// Fallback - something went wrong
		#define RESOLVE_GRADIENT(value) half4 color = lerp(_GradientColor0, _GradientColor1, value);
	#endif

	float2 spriteSheet(float2 uv, float4 sheetParams)
	{
		// Calculate sprite sheet animation
		float a = floor(sheetParams.z) / sheetParams.x;
		float horizontal = frac(a);
		float vertical = floor(a) / sheetParams.y;
		// Retarded Open GL uv starts at bottom left -.- we need to do that correction
		vertical = 1 - vertical - 1 / sheetParams.y;
		
		// Size + offset
		return uv / float2(sheetParams.x, sheetParams.y) + float2(horizontal, vertical);
	}
	
	half4 fragEffect(FInput i) : SV_Target
	{
		#ifdef PBR_BE_PURPLE
			return half4(0.8, 0, 1.0, 1.0);
		#endif

		// Handle first UVs
		float2 originalUv = i.uv;
		float2 scroll = _Scroll.xy; 

		// sprite sheet
		#ifdef PBR_ANIMATED_USE_SPRITE_SHEET_ON
			i.uv = spriteSheet(originalUv, _SheetParams);
		#endif

		// scroll
		i.uv = i.uv + scroll;
		
		
		// Apply distortion on UV
		#ifdef PBR_USE_DISTORT_MAP_ON
		    float2 distort_uv = originalUv * _DistortTiling.xy + _DistortTiling.zw;
            //distortion = tex2D(_DistortMap, distort_uv) * _DistortIntensity.xy;
		    i.uv += tex2D(_DistortMap, distort_uv) * _DistortIntensity.xy;
		#endif

		
		#ifndef PBR_ANIMATED_USE_FLOWMAP_ON
			// Sample main texture
			half4 main = tex2D(_MainTex, i.uv);
		#else
			// trunc time
			half progress = frac(_SheetParams.z);

			// unpack flowmap
			half3 flowmap = tex2D(_FlowMap, i.uv);
			flowmap.xy = (flowmap.xy - 127.0 / 255.0) * 2;
			
			#ifdef PBR_ANIMATED_USE_SPRITE_SHEET_ON
				// interpolate between last and next frame
				half2 flowdir = _FlowMapStrength * half2(-flowmap.x * flowmap.z, flowmap.y * flowmap.z);
				half2 nextUv = spriteSheet(originalUv, float4(_SheetParams.xy, _SheetParams.z + 1, _SheetParams.w));
				half4 lastFrame = tex2D(_MainTex, i.uv + flowdir.xy * progress);
				half4 nextFrame = tex2D(_MainTex, nextUv - flowdir.xy * (1 - progress));
				half4 main = lerp(lastFrame, nextFrame, progress);
			#else
				// interpolate between phase and +0.5 phase
				half2 flowdir = _FlowMapStrength * half2(flowmap.x * flowmap.z, flowmap.y * flowmap.z);
				half4 lastFrame = tex2D(_MainTex, i.uv + flowdir.xy * progress);
				half4 nextFrame = tex2D(_MainTex, i.uv + flowdir.xy * frac(_SheetParams.z + 0.5));

				// see-saw time.
				half4 main = lerp(lastFrame, nextFrame, 2 * (progress - 0.5) * sign(progress - 0.5));
			#endif
		#endif
		
		
		// Decide on the initial color
		#ifdef PBR_ANIMATED_USE_PURE_RGB_ON
			half4 color = main;
		#else
			// Read the color from gradient data
			#ifdef PBR_ANIMATED_USE_GRAY_SCALE_ON
				RESOLVE_GRADIENT(Luminance(main.rgb))
				color.a *= main.a;
			#else
				RESOLVE_GRADIENT(main.r)
			#endif
			
			#ifdef PBR_ANIMATED_GREEN_LIGHTING
				// Apply tone from green channel
				color.rgb *= main.g;
			#elif defined(PBR_ANIMATED_GREEN_EMISSION)
				color.rgb += main.g * lerp(_EmissionColor.rgb, _EmissionColorEnd.rgb, main.g);
				color.a = max(main.g * _EmissionColor.a, color.a);
			#endif			
		#endif // PBR_ANIMATED_USE_PURE_RGB_ON
		#ifdef PBR_TRANSPARENT_FADE_IN_ON
				// Handle fade in parameters
				half fadeParam = 1 / (_FadeParams.y - _FadeParams.x);
				color.a = saturate((color.a - _FadeParams.x) * fadeParam);
		#endif

		// Handle second alpha UVs
		#ifdef PBR_ANIMATED_USE_SECOND_ALPHA_ON
			#ifdef PBR_USE_SECOND_UV_ON
				#ifdef PBR_ANIMATED_SECOND_ALPHA_SPRITE_SHEET_ON
					float2 secondAlphaUv = spriteSheet(i.uv2 + _Scroll.zw, _SecondSheetParams);
				#else
					float2 secondAlphaUv = i.uv2 + _Scroll.zw;
				#endif
			#else
				float2 secondAlphaUv = i.uv + _Scroll.zw;
			#endif
			#ifdef PBR_TRANSPARENT_FADE_IN_ON
				half secondA = tex2D(_SecondAlpha, secondAlphaUv * _SecondAlphaTiling.xy).r * _SecondAlphaTiling.z;
				secondA = lerp(1, saturate(secondA - _FadeParams.x) * fadeParam, _SecondAlphaTiling.w);
				color.a *= secondA;
			#else
				color.a = lerp(color.a, clamp(tex2D(_SecondAlpha, secondAlphaUv * _SecondAlphaTiling.xy).r * _SecondAlphaTiling.z, 0, color.a), _SecondAlphaTiling.w);
			#endif
		#endif // PBR_ANIMATED_USE_SECOND_ALPHA_ON
		
		color.rgb = color.rgb * _Color.rgb;
		
		#ifdef PBR_ANIMATED_USE_VERTEX_COLOR_AS_EMISSION_ON
			color.rgb += i.color.rgb;
		#else
			color.rgb *= i.color.rgb;
		#endif

		#ifdef PBR_TRANSPARENT_SUBTRACT_ALPHA_ON
			half alpha = color.a - (1 - i.color.a);
			#ifdef PBR_TRANSPARENT_SUBTRACT_ALPHA_WHITE_ON
				half sub = 1 - alpha;
			#else
				half sub = alpha;
			#endif
			color.a = clamp((originalUv.y - _FadeParams.z) / -_FadeParams.w - (sub), 0, alpha);
		#else
			color.a = color.a * i.color.a;
		#endif
		
		#ifdef PBR_TRANSPARENT_DISABLE_TILES_ON
			#ifdef PBR_ANIMATED_USE_SPRITE_SHEET_ON
				half multiplier = _SheetParams.y;
			#else
				half multiplier = 1;
			#endif
			color.a = color.a * (originalUv.y <= -scroll.y*multiplier + 1 && originalUv.y > -scroll.y*multiplier);
		#endif
		
		#ifdef PBR_USE_REALTIME_SHADOWS_ON
			color.a *= 1 - GetShadow(i.shadowCoords);
		#endif
				
		color.a = color.a * _Color.a * _Alpha;
		color.rgb = lerp(color.rgb, color.rgb * color.a, _AlphaColorMultiplier);

		#if defined(PBR_ANIMATED_BLUE_ALPHA) && !defined(PBR_ANIMATED_USE_PURE_RGB_ON)
			color.a *= main.b;
		#endif

		#ifdef PBR_TRANSPARENT_CUTOUT_ON
			if (color.a < _CutoutThreshold) discard;
		#endif
				
		#ifdef PBR_USE_ADDITIVE_COLOR_ON
		color.rgb = lerp(color.rgb, _AdditiveColor.rgb, _AdditiveColor.a);
		#endif
		
		return saturate(color);
	}
#endif 