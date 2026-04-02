Shader "Custom/7-2s"//统一到切线空间时的凹凸纹理 由于又隔了几天。。又会注释详细一点
{
    Properties
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
        float3 lightDir: TEXCOORD1;//存储转到切线空间的俩
        float3 viewDir: TEXCOORD2;
    };
    v2f vert(a2v v){
        v2f o;

        o.pos=UnityObjectToClipPos(v.vertex);

        o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
        o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;

        TANGENT_SPACE_ROTATION;//一步到位 形成模型空间到切线空间的矩阵
    
        o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
        o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

        return o;
     };

     fixed4 frag(v2f i): SV_Target{
        fixed3 tangentLightDir =normalize(i.lightDir);
        fixed3 tangentViewDir=normalize(i.viewDir);//先标准化 不过这一步有必要放在这进行吗？感觉放在前面也行吧？
//取法向贴图后rgb转换成xyz 再用bumpscale凹凸缩放 然后求z 这里没看懂啊
        fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
        fixed3 tangentNormal;

        tangentNormal=UnpackNormal(packedNormal);//注意 这么干的前提是在unity里把它标为normalmap 否则用不了内置，只能手动解码
        tangentNormal.xy*=_BumpScale;
        tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
//剩下正常求了 只是当地法线换成了新求的法线
        fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
        fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
        fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));

        fixed3 halfDir = normalize(tangentLightDir + tangentViewDir); 
 fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, 
dot(tangentNormal, halfDir)), _Gloss); 

return fixed4(ambient + diffuse + specular, 1.0); 


      
        }
          ENDCG
    }
   
    }
    FallBack "Diffuse"
     
    
}
