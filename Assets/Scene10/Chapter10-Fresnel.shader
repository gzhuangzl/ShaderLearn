Shader "Unlit/Chapter10-Fresnel"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5
		_CubeMap("Cube Map", Cube) = "_Skybox"{}
	}

	Subshader
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
					float3 worldPos : TEXCOORD0;
					float3 worldNormal : TEXCOORD1;
				};

				fixed4 _Color;
				fixed _FresnelScale;
				samplerCUBE _CubeMap;

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 normal = normalize(i.worldNormal);
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

					fixed3 ambient = _Color.rgb * UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 diffuse = _Color.rgb * saturate(dot(normal, lightDir));

					fixed3 reflectDir =  reflect(-viewDir, normal);
					fixed3 reflectCol = texCUBE(_CubeMap, reflectDir).rgb;

					fixed fresnel = _FresnelScale + (1.0 - _FresnelScale) * pow(1.0 - dot(viewDir, normal), 5);

					return fixed4(ambient + lerp(diffuse, reflectCol, fresnel), 1);
				}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
