Shader "Unlit/Chapter10-Refraction"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_RefractColor("Refract Color", Color) = (1,1,1,1)
		_RefractAmount("Refract Amount", Range(0,1)) = 1
		_RefractRatio("Refract Ratio", Range(0.01, 1)) = 0.5
		_CubeMap("Cube Map", Cube) = "_Skybox"{}
	}

	SubShader
	{
		Tags{"RenderType"="Opaque" "Queue"="Geometry"}
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float3 refractDir : TEXCOORD2;
				};
				fixed4 _Color;
				fixed4 _RefractColor;
				fixed _RefractAmount;
				fixed _RefractRatio;
				samplerCUBE _CubeMap;

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
					o.refractDir = refract(-viewDir, o.worldNormal, _RefractRatio);
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 worldNormal = normalize(i.worldNormal);

					fixed3 ambient = _Color.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;
					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(lightDir, worldNormal));

					fixed3 refractColor = _RefractColor.rgb * texCUBE(_CubeMap, i.refractDir).rgb;

					return fixed4(ambient + lerp(diffuse, refractColor, _RefractAmount), 1);
				}
			ENDCG
		}
	}

	Fallback "Specular"
}
