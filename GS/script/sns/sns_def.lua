-----------------------------------------------------
--文件名		：	sns_def.lua
--创建者		：	wangzhiguang
--创建时间		：	2011-03-18
--功能描述		：	SNS功能客户端和服务端的公共定义
------------------------------------------------------

--SnsId,按1递增
Sns.SNS_T_TENCENT = 1;
Sns.SNS_T_SINA    = 2;

Sns.bIsOpen = EventManager.IVER_bOpenSnsSystem;

--OAuth数字签名方式的枚举(为后续扩展预留)
Sns.OAUTH_HMAC      = 1;
Sns.OAUTH_RSA       = 2;
Sns.OAUTH_PLAINTEXT = 3;

Sns.TASK_GROUP       = 2158; -- 整组任务变量，同步客户端、客户端可控
Sns.TASK_ID_SNS_SIZE = 64;   -- 按照不同的SNS对TASK_ID进行编组,每组占用的任务变量数

--token和secret在任务变量中的偏移（均使用8个任务变量进行存储，共32个ASCII字符）
--先存储access_token,再存储access_token_secret
Sns.TASK_ID_TOKEN  = 1;
Sns.TASK_ID_SECRET = 9;

--HTTP请求类型常量
Sns.HTTP_METHOD_GET  = "GET";
Sns.HTTP_METHOD_POST = "POST";

--将SNS服务的响应类型统一如下
Sns.SNS_RESULT_OK		= 1;
Sns.SNS_RESULT_REVOKED	= 2;
Sns.SNS_RESULT_FAIL		= 3;

--客户端通知服务端的事件类型
Sns.EVENT_AUTHORIZED	= 1;	--授权成功
Sns.EVENT_UNAUTHORIZED	= 2;	--取消授权
Sns.EVENT_TWEET			= 3;	--发送文字微博
Sns.EVENT_TWEET_PIC		= 4;	--发送带图片的微博
Sns.EVENT_FOLLOW		= 5;	--收听某人
Sns.EVENT_UNFOLLOW		= 6;	--取消收听某人

Sns.MAX_APPLY_FRIEND_COUNT = 20;

--剑侠世界官方SNS帐号
Sns.tbOfficialAccount =
{
	[Sns.SNS_T_TENCENT]	= "ksjxsj",
	[Sns.SNS_T_SINA]	= "1820315865",
};

-- 剑侠世界官方认证成员
Sns.tbOfficiaGroup = 
{
	[Sns.SNS_T_TENCENT] = 
	{
		{szName = "主策划-佩佩", szAccount = "jxsj_peres", szTitle="西山居《剑侠世界》主策划"},
		{szName = "项目总监-孙多良", szAccount = "sundng", szTitle="西山居《剑侠世界》项目总监"},
		{szName = "项目制作人-吴方浩", szAccount = "artbyte", szTitle="金山·西山居副总裁，同时为《剑侠世界》项目制作人。"},
		--{szName = "运营经理-金国", szAccount = "Gavin_King", szTitle="西山居《剑侠世界》项目经理"},
		{szName = "运营经理-陈炳煌", szAccount = "chenbinghuang", szTitle="西山居 《剑侠世界》运营经理，同时兼数据分析经理"},		
	},
	[Sns.SNS_T_SINA] = 
	{
		{szName = "主策划-佩佩", szAccount = "1914049307", szTitle="西山居《剑侠世界》主策划"},
		{szName = "项目总监-孙多良", szAccount = "1828214110", szTitle="西山居《剑侠世界》项目总监"},
		{szName = "项目制作人-吴方浩", szAccount = "1713632792", szTitle="金山·西山居副总裁，同时为《剑侠世界》项目制作人。"},
		--{szName = "运营经理-金国", szAccount = "2260980042", szTitle="西山居《剑侠世界》项目经理"},
		{szName = "运营经理-陈炳煌", szAccount = "1829848492", szTitle="西山居 《剑侠世界》运营经理，同时兼数据分析经理"},
	},
}

--SNS类型映射到playerprofile中的Buf ID
function Sns:ToProfileParamId(nSnsId)
	local tb =
	{
		[Sns.SNS_T_TENCENT] = PProfile.emPF_BUFTASK_TTENCENT,
		[Sns.SNS_T_SINA] 	= PProfile.emPF_BUFTASK_TSINA,
	};
	return assert(tb[nSnsId]);
end

function Sns:ToSnsId(nProfileParamId)
	local tb =
	{
		[PProfile.emPF_BUFTASK_TTENCENT] 	= Sns.SNS_T_TENCENT,
		[PProfile.emPF_BUFTASK_TSINA] 		= Sns.SNS_T_SINA,
	};
	return assert(tb[nProfileParamId]);
end
