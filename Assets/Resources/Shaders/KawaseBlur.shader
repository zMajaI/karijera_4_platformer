// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/KawaseBlur" {

	CGINCLUDE
	#include "UnityCG.cginc"
	inline float3 KawaseBlur(sampler2D tex, float2 uv, float4 texelSize, int pixelOffset)
	{
		float3 o = 0;
		float offset = (pixelOffset + 0.5) * texelSize;
		o += tex2D(tex, uv + float2(offset, offset));
		o += tex2D(tex, uv + float2(-offset, offset));
		o += tex2D(tex, uv + float2(offset, -offset));
		o += tex2D(tex, uv + float2(-offset, -offset));
		o *= 0.25;
		return o;
	}
	ENDCG
	
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Offset ("Offset", int) = 0
	}
    SubShader 
	{		
        Pass 
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag 
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			int _Offset;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			half4 frag(v2f i) : COLOR
			{
				fixed4 col = fixed4(0,0,0,1);
				half darkeningFactor = 0.95;
				col.xyz = KawaseBlur(_MainTex, i.uv, _MainTex_TexelSize, _Offset);
				return col * darkeningFactor;
			}
			ENDCG
        }
    }

Fallback Off
} 