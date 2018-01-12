Shader "Unlit/Chapter10-GlassRefract"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "bump"{}
		_CubeMap("Cube Map", Cube) = "_Skybox"{}
		_Distortion("Distortion", Range(0, 100)) = 10
		_RefractAmount("Refract Amount", Range(0, 1.0))= 1.0
	}

	SubShader
	{
		Tags{"RenderType"="Opaque" "Queue"="Transparent"}

		GrabPass
		{
			"_RefractionTex"
		}

		Pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				struct a2v
				{
					float4 vertex : POSITION;
					float4 tangent : TANGENT;
					float3 normal : NORMAL;
					float2 texcoord : TEXCOORD;
				};


				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 screenPos : TEXCOORD0;
					float3 viewDir : TEXCOORD1;
					float4 uv : TEXCOORD2;
					float3 T2W_0 : TEXCOORD3;
					float3 T2W_1 : TEXCOORD4;
					float3 T2W_2 : TEXCOORD5;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				samplerCUBE _CubeMap;
				float _Distortion;
				fixed _RefractAmount;
				sampler2D _RefractionTex;
				float4 _RefractionTex_TexelSize;

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.screenPos = ComputeGrabScreenPos(o.pos);
					o.viewDir = WorldSpaceViewDir(v.vertex);

					float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;

					float3x3 tangentMatrix = transpose(float3x3(v.tangent.xyz, binormal, v.normal));

					float3x3 T2W = mul((float3x3)unity_ObjectToWorld, tangentMatrix);

					o.T2W_0 = T2W[0];
					o.T2W_1 = T2W[1];
					o.T2W_2 = T2W[2];

					o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					float3x3 T2W = float3x3(i.T2W_0, i.T2W_1, i.T2W_2);
					fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
					fixed3 worldNormal = normalize(mul(T2W, tangentNormal));

					i.screenPos.xy += _Distortion * worldNormal.xy * _RefractionTex_TexelSize.xy;
					fixed3 refractColor = tex2D(_RefractionTex, i.screenPos.xy /i.screenPos.w).rgb;

					fixed3 diffuse = tex2D(_MainTex, i.uv.xy).rgb;

					fixed3 reflectColor = texCUBE(_CubeMap, reflect(-i.viewDir, worldNormal)).rgb * diffuse;

					return fixed4(refractColor * _RefractAmount + reflectColor * (1 - _RefractAmount), 1);
				}
			ENDCG
		}
	}
}
