-----------------------------------------------------
--文件名		：	sns_t_tencent.lua
--创建者		：	wangzhiguang
--创建时间		：	2011-03-18
--功能描述		：	腾讯微博的专有实现
------------------------------------------------------

Require("\\script\\sns\\sns_base.lua");

local tbTencent = Lib:NewClass(Sns.tbSnsBase, Sns.SNS_T_TENCENT, "腾讯微博", Sns.OAUTH_HMAC);
Sns.tbSns[Sns.SNS_T_TENCENT] = tbTencent;

tbTencent.nSnsId				= Sns.SNS_T_TENCENT;

tbTencent.URL_HOMEPAGE		= "http://t.qq.com/";

--OAuth相关
tbTencent.URL_REQUEST_TOKEN = "https://open.t.qq.com/cgi-bin/request_token?oauth_callback=";
tbTencent.URL_AUTHORIZE     = "https://open.t.qq.com/cgi-bin/authorize?oauth_token=";
tbTencent.URL_ACCESS_TOKEN  = "https://open.t.qq.com/cgi-bin/access_token?oauth_verifier=";

--获取用户本人的帐号信息
tbTencent.URL_SELF_INFO		= "http://open.t.qq.com/api/user/info?format=json";

--微博相关
tbTencent.URL_TWEET          = "http://open.t.qq.com/api/t/add?format=json&content=";
tbTencent.URL_TWEET_WITH_PIC = "http://open.t.qq.com/api/t/add_pic?format=json&content=";
tbTencent.PARAM_NAME_PIC     = "pic";

--人际相关
tbTencent.URL_FOLLOW	= "http://open.t.qq.com/api/friends/add?format=json&name=";
tbTencent.URL_UNFOLLOW	= "http://open.t.qq.com/api/friends/del?format=json&name=";

--各种请求对应的HTTP METHOD
tbTencent.HTTP_METHOD_REQUEST_TOKEN     = Sns.HTTP_METHOD_GET;
tbTencent.HTTP_METHOD_ACCESS_TOKEN      = Sns.HTTP_METHOD_GET;
tbTencent.HTTP_METHOD_SELF_INFO    		= Sns.HTTP_METHOD_GET;
tbTencent.HTTP_METHOD_TWEET             = Sns.HTTP_METHOD_POST;
tbTencent.HTTP_METHOD_TWEET_WITH_PIC    = Sns.HTTP_METHOD_POST;
tbTencent.HTTP_METHOD_FOLLOW			= Sns.HTTP_METHOD_POST;
tbTencent.HTTP_METHOD_UNFOLLOW			= Sns.HTTP_METHOD_POST;
tbTencent.HTTP_METHOD_IS_FOLLOWING = Sns.HTTP_METHOD_GET;

tbTencent.szFold 		= "tenc";
tbTencent.szSameKey		= "/mbloghead/";
	
tbTencent.tbImgFileName	= {};
tbTencent.tbName2Image		= {};
tbTencent.tbImageName2Http = {};
tbTencent.nFlag_MyImageAddIntoPort = 0;
tbTencent.szMyImgHttpAddress = "";

function tbTencent:GetUrl_RequestToken(szCallbackUrl)
	szCallbackUrl = szCallbackUrl or "null";
	return self.URL_REQUEST_TOKEN .. szCallbackUrl;
end

function tbTencent:GetUrl_Authorize(szTokenKey)
	return self.URL_AUTHORIZE .. szTokenKey;
end

function tbTencent:GetUrl_AccessToken(szVerifier)
	return self.URL_ACCESS_TOKEN .. szVerifier;
end

function tbTencent:GetUrl_SelfInfo()
	return self.URL_SELF_INFO;
end

function tbTencent:GetUrl_Tweet(szTweet)
	return self.URL_TWEET .. szTweet;
end

function tbTencent:GetUrl_TweetWithPic(szTweet, szPicPath)
	return self.URL_TWEET_WITH_PIC .. szTweet;
end

function tbTencent:GetUrl_Follow(szAccount)
	return self.URL_FOLLOW .. (szAccount or "");
end

function tbTencent:GetUrl_Unfollow(szAccount)
	return self.URL_UNFOLLOW .. szAccount;
end

function tbTencent:GetUrl_AccountHome(szAccount)
	return self.URL_HOMEPAGE .. szAccount;
end

function tbTencent:GetUrl_IsFollowing(szAccount)
	return "http://open.t.qq.com/api/friends/check?=json&flag=1&names=" .. szAccount;
end

--解析API调用的响应table,返回成功或失败
function tbTencent:AnalyseResponse(tbResponse)
	local nRet = tbResponse.ret;
	if nRet == 0 then
		return Sns.SNS_RESULT_OK;
	elseif nRet == 3 then
		return Sns.SNS_RESULT_REVOKED;
	else
		return Sns.SNS_RESULT_FAIL, tbResponse.msg;
	end
end

function tbTencent:AnalyseFollowResponse(tbResponse)
	return self:AnalyseResponse(tbResponse);
end

function tbTencent:AnalyseUnfollowResponse(tbResponse)
	return self:AnalyseResponse(tbResponse);
end

--从响应table中获取用户帐号名
function tbTencent:GetUserName(tbResponse)
	return tbResponse and tbResponse.data.name or "";
end

function tbTencent:AnalyseIsFollowingResponse(tbResponse, szAccount)
	local nRet, szError = self:AnalyseResponse(tbResponse);
	if nRet == Sns.SNS_RESULT_OK then
		local szResult = tbResponse.data[szAccount];
		return szResult == true and 1 or 0;
	else
		return nil;
	end
end
function tbTencent:GetTweetId(tbResponse)
	return tostring(tbResponse.data.id);
end
function tbTencent:GetTweetUrl(szAccount, szTweetId)
	return "http://t.qq.com/p/t/" .. szTweetId;
end
function tbTencent:ParseTimelineResponse(tbResponse)
	local tbTimeline = {};
	for n, tbTweet in ipairs(tbResponse.data.info) do
		local tb		= {};
		tb.szId			= tostring(tbTweet.id);
		tb.nTime		= tbTweet.timestamp;
		tb.szTweet		= tbTweet.text;
		tb.szAccount	= tbTweet.name;
		tb.bOriginal	= tbTweet.type == 1 and 1 or 0;
		tbTimeline[#tbTimeline + 1] = tb;
	end
	return tbTimeline;
end
function tbTencent:GetTimelineUrl(bFirstPage, tbTimeline)
	if bFirstPage == 1 then
		return "http://open.t.qq.com/api/statuses/home_timeline?format=json&reqnum=20&pageflag=0&pagetime=0";
	else
		local tbLastTweet = tbTimeline[#tbTimeline];
		return "http://open.t.qq.com/api/statuses/home_timeline?format=json&reqnum=20&pageflag=1&pagetime=" .. tbLastTweet.nTime;
	end	
end
function tbTencent:GetAccountTweetPageUrl(szAccount)
	return self.URL_HOMEPAGE .. szAccount .. "/mine";
end

-- 获取自定义头像信息
function tbTencent:GetProfileImageUrl(tbResponse)
	local szTemp = tbResponse and tbResponse.data and tostring(tbResponse.data.head) or "";
	local szHttp = "";
	if (szTemp and szTemp ~= "") then
		local nStart, szEnd = string.find(szTemp, "http://app.qlogo.cn/mbloghead/");
		if (szEnd) then
			local szKeyImg = string.sub(szTemp, szEnd + 1, -1);
			szHttp = string.format("http://t2.qlogo.cn/mbloghead/%s/50", szKeyImg);
		end
	end
	return szHttp;
end

function tbTencent:GetHttpImgFileName(szName)
	local szGateWayName = GetClientLoginGateway();
	local szEncode = UrlEncode(szName);
	
	return szGateWayName .. szEncode .. ".jpg"
end

function tbTencent:ResetImgTable()
	self.tbImgFileName		= {};
	self.tbName2Image		= {};
	self.tbImageName2Http	= {};
	self.nFlag_MyImageAddIntoPort = 0;
	self.tbFriendApplyImgCount = {};
	self.szMyFileName = nil;
	self.szMyImgHttpAddress = "";
end

function tbTencent:CheckAllImgDuringFold()
	local szFilePathFold = GetPlayerPrivatePath()	.. self.szFold;
	self.szPathFold = szFilePathFold;
	KFile.CreatePath(szFilePathFold);
	local szPathFold = self.szPathFold;
	local tbFile = KFile.GetCurDirAllFile(szPathFold);
	if (tbFile) then
		for i, szPath in ipairs(tbFile) do
			local nFind, nEndFind = string.find(szPath, "\\" .. self.szFold .. "\\")
			if nEndFind then
				local szFileName = string.sub(szPath, nEndFind+1, -1);
				self.tbImgFileName[szFileName] = 1;
			end
		end
	end
end

function tbTencent:ProcessMySnsImg()
	local szMyFileName = self:GetHttpImgFileName(me.szName);
	if (szMyFileName) then
		local szMyPath = self.szPathFold .. "\\" .. szMyFileName;
		if (IsDownLoadFileExist(szMyPath) == 1) then
			if (not self.nFlag_MyImageAddIntoPort or self.nFlag_MyImageAddIntoPort ~= 1) then
				AddSnsPortrait(me.nSex, self.nSnsId, szMyPath);
				self.nFlag_MyImageAddIntoPort			= 1;
				self.tbImgFileName[szMyFileName]		= 1;
				self.tbName2Image[me.szName]			= szMyFileName;
				self.tbImageName2Http[szMyFileName]		= self.szMyImgHttpAddress;
				self.szMyFileName						= szMyFileName;
				CoreEventNotify(UiNotify.emCOREEVENT_SYNC_PORTRAIT);
			end
		else
			AddSnsImgFilePath(self.szMyImgHttpAddress, GetRootPath() .. szMyPath);
		end
	end	
end

function tbTencent:ProcessAllPlayerImg()
	for szName, nValue in pairs(self.tbImgFileName) do
		if (IsDownLoadFileExist(self.szPathFold .. "\\" .. szName) == 0) then
			local szHttpAddress = self.tbImageName2Http[szName];
			if (szHttpAddress) then
				AddSnsImgFilePath(szHttpAddress, GetRootPath() .. self.szPathFold .. "\\" .. szName);
			end
			self.tbImgFileName[szName] = 0;
		else
			self.tbImgFileName[szName] = 1;
		end
	end
end

function tbTencent:DownloadPlayerImg(szHttpAddress, szMyFileName)
	AddSnsImgFilePath(szHttpAddress, GetRootPath() .. self.szPathFold .. "\\" .. szMyFileName);
end

function tbTencent:AddMySnsImgFilePath(szHttpAddress)
	local szImgFile = self:GetHttpImgFileName(me.szName);	
	local szFilePath = self.szPathFold .. "\\" .. szImgFile;
	AddSnsPortrait(me.nSex, self.nSnsId, szFilePath);

	if (not szHttpAddress) then
		return 0;
	end
	
	self.szMyImgHttpAddress = szHttpAddress;
	AddSnsImgFilePath(szHttpAddress, GetRootPath() .. szFilePath);	
end

function tbTencent:OnCleanFold()
	ClearPrivateOneFold(self.szFold);
end
