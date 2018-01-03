Shader "Unlit/Chapter8-AlphaBlend"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_AlphaScale("Alpha Scale", Range(0,100)) = 1
	}

	SubShader
	{
		Tags{"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			//Cull Off

			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _AlphaScale;

				v2f vert(appdata_base v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
					o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed4 albedo = _Color * tex2D(_MainTex, i.uv);
					fixed4 ambient = UNITY_LIGHTMODEL_AMBIENT.rgba * albedo;
					fixed4 diffuse = _LightColor0.rgba * albedo * saturate(dot(worldNormal, lightDir));

					fixed4 r = ambient + diffuse;
					r.a *= _AlphaScale;
					return r;
				}
			ENDCG
		}
	}
	Fallback "Transparent/VertexLit"
}
