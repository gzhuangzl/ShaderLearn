Shader "Unlit/Chapter7-NormalMapTangentSpace"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
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

				float3x3 inverse(float3x3 input) {
					#define minor(a,b) determinant(float2x2(input.a,input.b))
					
					float3x3 cofactors = float3x3(
					     minor(_22_23, _32_33), 
					    -minor(_21_23, _31_33),
					     minor(_21_22, _31_32),
					    
					    -minor(_12_13, _32_33),
					     minor(_11_13, _31_33),
					    -minor(_11_12, _31_32),
					    
					     minor(_12_13, _22_23),
					    -minor(_11_13, _21_23),
					     minor(_11_12, _21_22)
					);
					#undef minor
					return transpose(cofactors) / determinant(input);
				}
				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 texcoord : TEXCOORD;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 lightDir : TEXCOORD0;
					float3 viewDir : TEXCOORD1;
					float4 uv : TEXCOORD2;
				};

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				float _BumpScale;
				fixed4 _Specular;
				float _Gloss;

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);

					float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;

					float3x3 tangentToObject = transpose(float3x3(v.tangent.xyz, binormal, v.normal));

					float3x3 objectToTangent = inverse(tangentToObject);

					o.lightDir = mul(objectToTangent, ObjSpaceLightDir(v.vertex));
					o.viewDir = mul(objectToTangent, ObjSpaceViewDir(v.vertex));

					o.uv.xy = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
					o.uv.zw = v.texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;

					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 tangentLightDir = normalize(i.lightDir);
					fixed3 tangentViewDir = normalize(i.viewDir);
					fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

					fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
					fixed3 tangentNormal = UnpackNormal(packedNormal);
					tangentNormal.xy *= _BumpScale;
					tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

					fixed3 albedo = _Color.rgb * tex2D(_MainTex, i.uv.xy);

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
					fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)), _Gloss);

					return fixed4(ambient + diffuse + specular, 1);
				}
			ENDCG
		}
	}
}
