Shader "UnityShaderBook/Chapter5/5-2" //名称和路径 本shader为第一个shader 实现了一个彩虹方块 学习了基础的shader工作原理
{
    Properties//材质属性 不是必须的
    {
        _Color ("Color Tint",Color)=(1,1,1,1)
    }
    SubShader
    {
       Pass{
        CGPROGRAM
        #pragma vertex vert //定义第一个函数 顶点着色器代码
        #pragma fragment frag //定义第二个函数 片段着色器代码
        uniform fixed4 _Color;
        struct a2v{
            float4 vertex: POSITION;//顶点位置
            float3 normal: NORMAL;//法线向量
            float4 texcoord:TEXCOORD0;//纹理坐标
        };

        struct v2f{
            float4 pos:SV_POSITION;
            fixed3 color:COLOR0;
        };
        v2f vert(a2v v){//会自动获取application的数据并转入到a2v结构体中 再把a2v结构体当参数
            
            v2f o;
            o.pos=UnityObjectToClipPos(v.vertex);//把顶点位置转换为裁剪空间坐标
            o.color=v.normal*0.5+fixed3(0.5,0.5,0.5);//把法线向量转换为颜色值 0.5是为了把范围从-1~1转换为0~1
            return o;

        }
        fixed4 frag(v2f i):SV_Target{
            fixed3 o=i.color;
            o *=_Color.rgb;
            return fixed4(o,1.0);
        }
        ENDCG
       }
    }
    FallBack "Diffuse"
}
