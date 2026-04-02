Shader "Custom/7-3s"//渐变纹理 
{
    Properties
    {
       _Color("Color Tint",Color)=(1,1,1,1)
       _RampTex("Ramp Tex",2D)="white"{}
       _Specular("specular",Color)=(1,1,1,1)
       _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {Pass{
        Tags{"LightMode"="ForwardBase"}
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
    
    #include "Lighting.cginc"
    #include "UnityCG.cginc"

    fixed4 _Color;

    sampler2D _RampTex;
    float4 _RampTex_ST;

    fixed4 _Specular;

    float _Gloss;

    struct a2v{
        float4 vertex : POSITION;
        float3 normal :NORMAL;
        float4 texcoord: TEXCOORD0;

    };

    struct v2f{
        float4 pos : SV_POSITION; 
        float3 worldNormal : TEXCOORD0; 
        float3 worldPos : TEXCOORD1; //这仨基本必要 一不用多说 而只要想要光照二三就必不可少

        float2 uv : TEXCOORD2;
    };
    v2f vert(a2v v){
        v2f o;
        o.pos=UnityObjectToClipPos(v.vertex);
        o.worldNormal=UnityObjectToWorldNormal(v.normal);
       o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;//好像是唯一没有内置函数的..
        o.uv=TRANSFORM_TEX(v.texcoord,_RampTex);//内置函数 处理uvS T
        return o;
    }
    fixed4 frag(v2f i) : SV_Target{//我之前居然一直没发现这还有个target 他是系统值语义 告诉gpu这个输出的颜色就是最终渲染的值
        fixed3 worldNormal=normalize(i.worldNormal);
        fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
        //半兰伯特的漫反射和bliinphong的高光反射
        fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
        fixed halfLambert=0.5*dot(worldNormal,worldLightDir)+0.5;
        fixed3 diffuseColor=tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb*_Color.rgb;//求出的hallambert正比于亮度 被映射到[0,1]上，再用其当uv坐标去渐变纹理上采样
        //感觉简单来说就是把原来单色的暗到明的光映射到了一个渐变色的光上 虽然想想很简单但功能很强大 也很难想出来

        fixed3 diffuse = _LightColor0.rgb * diffuseColor; 
 
        fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); 
        fixed3 halfDir = normalize(worldLightDir + viewDir); 
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, 
        dot(worldNormal, halfDir)), _Gloss); 
 
        return fixed4(ambient + diffuse + specular, 1.0); 

    }
    
    ENDCG

    }
    }
    FallBack "Diffuse"
}
