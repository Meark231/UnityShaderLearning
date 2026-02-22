Shader "Custom/6-4s" //实现逐顶点光照 并进行了更详细的shader学习  gauround模型
{
    Properties
    {
      _Diffuse("Diffuse",Color)=(1,1,1,1)//内部变量名 面板名 属性类型 默认值
    }
    SubShader
    {
        Pass{//物体渲染通道 代表进行一次渲染
            Tags{"LightMode"="ForwardBase"}//Tag是表明pass的使用方式 lightmode是常用标签代表前向渲染中的角色 forwardbase代表其是basepass也就是主要的pass 还有其他附加的pass
        

        CGPROGRAM
        #pragma vertex vert//声明一个顶点着色器
        #pragma fragment frag//声明一个片段着色器

        #include "Lighting.cginc"
        fixed4 _Diffuse;
        struct a2v{
            float4 vertex:POSITION;
            float3 normal:NORMAL;
        };
        struct v2f{
            float4 pos:SV_POSITION;
            fixed3 color: COLOR;
        };
        v2f vert(a2v v){//第一步 获取模型位置和模型法线
            v2f o;
            o.pos=UnityObjectToClipPos(v.vertex);//必做的一步 空间坐标转裁剪坐标
       
            fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光

            fixed3 worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));//标准化的转化到世界空间的法线向量
            fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);//标准化的光照向量

            fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));//漫反射计算公式
            //光线颜色*材质颜色*max(0，法向量和光照向量的点积)
            
            o.color=ambient+diffuse;

            return o;
       
        }
        fixed4 frag(v2f i):SV_Target{
            return fixed4(i.color,1);//前面为了节省计算省去了alpha 这里加上
        }

        ENDCG
    }}
    FallBack "Diffuse"
}
