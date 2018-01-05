Shader "Unlit/Chapter9-FowardRendering"
{
	Properties
	{
		_Color("MainColor", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}

	SubShader
	{
		Tags{"RenderType"="Opaque" "Queue"="Geometry"}
		CGINCLUDE
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}

			fixed3 diffuseAndSpecular(v2f i)
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir= normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(lightDir + viewDir);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
						float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos,1)).xyz;
						fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined (SPOT)
						float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos,1));
						fixed atten = (lightCoord.w > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#else
						fixed atten = 1.0;
					#endif
				#endif

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(lightDir, worldNormal));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);
				return diffuse + specular;
			}

			fixed4 forwardBaseFrag(v2f i) : SV_TARGET
			{
				fixed3 col = diffuseAndSpecular(i);
				col += Shade4PointLights (
    				unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    				unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3],
   					 unity_4LightAtten0,i.worldPos, normalize(i.worldNormal));
   				col += UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
    			return fixed4(col, 1);
			}

			fixed4 forwardAddFrag(v2f i) : SV_TARGET
			{
				fixed3 col = diffuseAndSpecular(i);
				return fixed4(col, 1);
			}
		ENDCG

		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment forwardBaseFrag
				#pragma multi_compile_fwdadd
			ENDCG
		}

		Pass
		{
			Blend One One
			Tags{"LightMode"="ForwardAdd"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment forwardAddFrag
				#pragma multi_compile_fwdadd
			ENDCG
		}
	}

	Fallback "Specular"
}
