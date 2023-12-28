Shader "Custom/CelShading" {
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_ETex ("Emission", 2D) = "white" {}
		_RampTex ("Ramp Texture", 2D) = "white"{}
		[IntRange]_Sections ("Sections", Range (1,10)) = 5
		_Glossiness ("Glossy", Range (0,1)) = .5
		_RimColor ("RIMColor", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 3)) = 0.1	
    
	}
	
	SubShader
	{
	
		CGPROGRAM
		#pragma surface surf ToonRamp
		
		float4 _Color;
		sampler2D _RampTex;
		float _Sections;
		float _Glossiness;
		sampler2D _MainTex;
		sampler2D _ETex;
		float4 _RimColor;
		float _RimAmount;
	    float _RimThreshold;	


		
	
		float4 LightingToonRamp (SurfaceOutput s, fixed3 lightDir, fixed atten, float3 viewDir)
		{
			//diffuse lighting will be the dot product between the normal and ligth dir
			float diff = dot(s.Normal, lightDir);
			float3 H = normalize( lightDir + viewDir);
			float3 specularLight = saturate(dot( H, s.Normal)) * (diff > 0.5);
			float3 specularpow = specularLight * _Glossiness;
			//the "h" value will be used as uv to for pulling the ramp texture below in "rh"
			//the way this works is that when the normal and lighting are aligned the uv we pull is 1,1 if the dot is 0 the uv will be 0,0 
			//the math is to avoid negative values
			float fv = floor(diff * _Sections) * (_Sections / 100.0);
			float h = fv * 0.5 + 0.5;
			//this is then applied to rh which is a float2 to set the uv coordinates well be using from the ramp texture 
			float2 rh = h;
			float3 ramp = tex2D(_RampTex, rh).rgb;                
			
			
			
			//rimLigthting stuff
			float rimDot = 1 - dot(viewDir, s.Normal);
			// We only want rim to appear on the lit side of the surface,
			// so multiply it by NdotL (in this case variable is called "diff"), raised to a power to blend it.
			float rimIntensity = rimDot * pow(diff, _RimThreshold);
			rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
			float4 rim = rimIntensity * _RimColor;
			
			
			
			float4 c;
			//float4 emissivem = tex2D(_ETex, uv_MainTex);
			c.rgb = (s.Albedo + rim) * _LightColor0.rgb * (ramp) * specularpow;
			c.a = 1;
			return c;
		}
		                                                        
		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_ETex;
			float3 viewDir;
			
		};
		

		
		void surf (Input IN, inout SurfaceOutput o)
		{
		
		    o.Gloss = _Glossiness;
		    fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		    fixed4 etex = tex2D(_ETex, IN.uv_MainTex);
			o.Albedo =  c.rgb;
			o.Emission = etex.rgb;
			
		}
		
		ENDCG
	}
	
	Fallback "Diffuse"

}
