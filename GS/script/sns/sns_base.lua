-----------------------------------------------------
--文件名		：	sns_base.lua
--创建者		：	wangzhiguang
--创建时间		：	2011-03-18
--功能描述		：	不同SNS类型的基类/公共逻辑
------------------------------------------------------

Require("\\script\\sns\\sns_def.lua");

local tbSnsBase = {};
Sns.tbSnsBase = tbSnsBase;
Sns.tbSns = {};

--获取sns对象
function Sns:GetSnsObject(nSnsId)
	return assert(self.tbSns[nSnsId]);
end

function tbSnsBase:init(nId, szName, nSignMethod)
	self.nId = nId;	   				--对应到SNS类型枚举
	self.szName = szName;
	self.nSignMethod = nSignMethod;	--数字签名方式
	self.szToken = nil;
	self.szTokenSecret = nil;
	self.nMyDownLoadCount = 0;
	self.tbImgFileName		= {};
	self.tbName2Image		= {};
	self.tbImageName2Http	= {};
	self.tbFriendApplyImgCount = {};
	self.nFlag_MyImageAddIntoPort = 0;
	self.szMyFileName = nil;
	self.szMyImgHttpAddress = "";
end

--读取access_token
function tbSnsBase:GetTokenKey()
	local nTaskId = (self.nId - 1) * Sns.TASK_ID_SNS_SIZE + Sns.TASK_ID_TOKEN;
	return me.GetTaskStr(Sns.TASK_GROUP, nTaskId);
end

--保存读取access_token
function tbSnsBase:SetTokenKey(szTokenKey)
	local nTaskId = (self.nId - 1) * Sns.TASK_ID_SNS_SIZE + Sns.TASK_ID_TOKEN;
	me.SetTaskStr(Sns.TASK_GROUP, nTaskId, szTokenKey);
end

--读取access_token_secret
function tbSnsBase:GetTokenSecret()
	local nTaskId = (self.nId - 1) * Sns.TASK_ID_SNS_SIZE + Sns.TASK_ID_SECRET;
	return me.GetTaskStr(Sns.TASK_GROUP, nTaskId);
end

--保存access_token_secret
function tbSnsBase:SetTokenSecret(szTokenSecret)
	local nTaskId = (self.nId - 1) * Sns.TASK_ID_SNS_SIZE + Sns.TASK_ID_SECRET;
	me.SetTaskStr(Sns.TASK_GROUP, nTaskId, szTokenSecret);
end

--从HTTP响应中提取oauth_token和oauth_token_secret
--szResponse示例：
--"oauth_token=8ldIZyxQeVrFZXFOZH5tAwj6vzJYuLQpl0WUEYtWc&oauth_token_secret=x6qpRnlEmW9JbQn4PQVVeVG8ZLPEx6A0TOebgwcuA&oauth_callback_confirmed=true"
function tbSnsBase:ExtractTokenAndSecret(szResponse)
	local tb = Sns:ParseQueryString(szResponse);
	if tb == nil then
		print("tbSnsBase:ExtractTokenAndSecret: Invalid http response:", szResponse);
		return;
	end
	return tb["oauth_token"], tb["oauth_token_secret"];
end

function Sns:ParseQueryString(szQueryString)
	if (type(szQueryString) ~= "string" or
		#szQueryString == 0) then
		return nil;
	else
		local tb = {};
		for k, v in string.gmatch(szQueryString, "([^&]+)=([^&]+)") do
			tb[k] = v;
		end
		return tb;
	end
end
