Shader "Unlit/Chapter8-AlphaTest"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_Cutoff("Cutoff", Range(0,1.001)) = 0.1
	}

	SubShader
	{
		Tags{"RenderType"="TransparentCutout" "Queue"="AlphaTest" "IgnoreProjector"="True"}
		Pass
		{
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
					float2 uv : TEXCOORD0;
					float3 worldNormal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
				};

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _Cutoff;

				v2f vert(appdata_base v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;

					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					clip(col.a - _Cutoff);
					//if((col.a - _Cutoff) < 0){ //if(any(col.a - _Cutoff))
					//	discard;
					//}
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed3 albedo = _Color.rgb * col.rgb;
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
					fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(lightDir, worldNormal));
					return fixed4(ambient + diffuse, 1);
				}
			ENDCG
		}
	}

	Fallback "Transparent/Cutout/VertexLit"
}
