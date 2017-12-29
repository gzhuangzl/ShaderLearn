Shader "Unlit/Chapter7-NormalMapWorldSpace"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "bump"{}
		_BumpScale("Bump Scale", Float) = 1.0
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8,256)) = 20
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
					float4 tangent : TANGENT;
					float2 uv : TEXCOORD;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					float3 RM_0 : TEXCOORD1;
					float3 RM_1 : TEXCOORD2;
					float3 RM_2 : TEXCOORD3;
					float4 uv : TEXCOORD4;
				};

				uniform fixed4 _Color;
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
				uniform sampler2D _BumpMap;
				uniform float4 _BumpMap_ST;
				uniform float _BumpScale;
				uniform fixed4 _Specular;
				uniform float _Gloss;

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);

					float3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
					float3 worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
					float3 worldBinormal = cross(normalize(worldNormal), normalize(worldTangent)) * v.tangent.w;

					o.RM_0 = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
					o.RM_1 = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
					o.RM_2 = float3(worldTangent.z, worldBinormal.z, worldNormal.z);

					//float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;

					//o.RM_0 = float3(v.tangent.x, binormal.x, v.normal.x);
					//o.RM_1 = float3(v.tangent.y, binormal.y, v.normal.y);
					//o.RM_2 = float3(v.tangent.z, binormal.z, v.normal.z);

					o.uv.xy = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
					o.uv.zw = v.uv * _BumpMap_ST.xy + _MainTex_ST.zw;

					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 halfDir = normalize(lightDir + viewDir);

					fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
					fixed3 tangentNormal = UnpackNormal(packedNormal);
					tangentNormal.xy *= _BumpScale;
					tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

					float3x3 rotation = float3x3(i.RM_0, i.RM_1, i.RM_2);
					//fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld,mul( rotation, tangentNormal)));

					fixed3 worldNormal = normalize(mul( rotation, tangentNormal));

					fixed3 albedo = _Color.rgb * tex2D(_MainTex, i.uv.xy);
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
					fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, lightDir));

					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

					return fixed4(ambient + diffuse + specular, 1);
				}
			ENDCG
		}
	}
	FallBack "Specular"
}
