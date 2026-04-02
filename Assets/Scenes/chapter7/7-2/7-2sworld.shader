// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/7-2s"//统一到世界空间时的凹凸纹理 比较接近 就不再从头敲了
  {  Properties
    {
       _Color("Color Tint",Color)=(1,1,1,1)//properties的格式 内置专有变量名 面板名称 面板控件类型 默认值

       _MainTex("Main Tex",2D)="White"{}

       _BumpMap("normal map",2D)="bump"{}//bump->unity内置的法线纹理 代表模型自带的法线信息
       _BumpScale("bump scale",Float)=1.0//控制凹凸程度

       _Specular("Specular",Color)=(1,1,1,1)
       _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {
        Pass{
            Tags{
                "LightMode"="ForwardBase"
            }

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "Lighting.cginc"//为了使用unity内置「变量」如_LightColor0
    fixed4 _Color;//和properties中绑定的变量 命名都是受限的

    sampler2D _MainTex;
    float4 _MainTex_ST;

    sampler2D _BumpMap;
    float4 _BumpMap_ST;

    float _BumpScale;

    fixed4 _Specular;
    float _Gloss;

    struct a2v{
        float4 vertex: POSITION;//类型 变量名 语义(告诉从模型的哪部分获取)
        float3 normal: NORMAL;
        float4 tangent: TANGENT;//顶点的切线方向 注意是float4 我们知道切线空间的xyz 是 切线方向 切线和法线的叉乘 法线
        //但是叉乘的先后需要约定一下，一般是建模软件自动导入的w
        float4 texcoord: TEXCOORD0;//模型默认的uv 虽然是float4但只有xy有用
    };
    struct v2f{
        float4 pos: SV_POSITION;
        float4 uv: TEXCOORD0;//很巧妙的用一个纹理坐标存储了两个纹理 xy放纹理的 zw放法线贴图的
        float4 TtoW0: TEXCOORD1;
        float4 TtoW1:TEXCOORD2;//存储切线空间到世界空间的变换矩阵 存方向矢量只要3x3 但这里为了利用差值寄存器的空间 还把世界空间下的顶点位置也存在w分量里了
        float4 TtoW2:TEXCOORD3;
    };
    v2f vert(a2v v){
        v2f o;

        o.pos=UnityObjectToClipPos(v.vertex);

        o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
        o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;

//求出世界顶点和 切线空间->世界空间转换矩阵 为什么这个没有宏直接拿了。。
float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;// //叉乘的先后需要约定一下，建模软件自动导入的w

o.TtoW0 = float4(worldTangent.x, worldBinormal.x, 
worldNormal.x, worldPos.x); 
 o.TtoW1 = float4(worldTangent.y, worldBinormal.y, 
worldNormal.y, worldPos.y); 
 o.TtoW2 = float4(worldTangent.z, worldBinormal.z, 
worldNormal.z, worldPos.z); 

        return o;
     };

     fixed4 frag(v2f i): SV_Target{
        float3 worldPos=float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
        fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos)); 
        fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); 

//剩下正常求了 只是当地法线换成了新求的法线
fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw)); //采样法线纹理
bump.xy *= _BumpScale;
bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy))); //凹凸缩放 至于z依旧没看懂
bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, 
bump), dot(i.TtoW2.xyz, bump)));//转到世界空间
        fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
        fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
        fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(bump,lightDir));

        fixed3 halfDir = normalize(lightDir + viewDir); 
 fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, 
dot(bump, halfDir)), _Gloss); 

return fixed4(ambient + diffuse + specular, 1.0); 


      
        }
          ENDCG
    }
   
    }
    FallBack "Diffuse"
     
    
}
