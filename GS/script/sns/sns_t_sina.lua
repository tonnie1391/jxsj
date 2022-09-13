-----------------------------------------------------
--文件名		：	sns_t_sina.lua
--创建者		：	wangzhiguang
--创建时间		：	2011-03-18
--功能描述		：	新浪微博的专有实现
------------------------------------------------------

Require("\\script\\sns\\sns_base.lua");

local tbSina = Lib:NewClass(Sns.tbSnsBase, Sns.SNS_T_SINA, "新浪微博", Sns.OAUTH_HMAC);
Sns.tbSns[Sns.SNS_T_SINA] = tbSina;

tbSina.URL_HOMEPAGE			= "http://t.sina.com.cn/";	
tbSina.nSnsId				= Sns.SNS_T_SINA;

--OAuth相关
tbSina.URL_REQUEST_TOKEN 	= "http://api.t.sina.com.cn/oauth/request_token?oauth_callback=";
tbSina.URL_AUTHORIZE     	= "http://api.t.sina.com.cn/oauth/authorize?oauth_token=";
tbSina.URL_ACCESS_TOKEN  	= "http://api.t.sina.com.cn/oauth/access_token?oauth_verifier=";

--获取用户本人的帐号信息
tbSina.URL_SELF_INFO		= "http://api.t.sina.com.cn/account/verify_credentials.json";

--微博相关
tbSina.URL_TWEET			= "http://api.t.sina.com.cn/statuses/update.json?status=";
tbSina.URL_TWEET_WITH_PIC	= "http://api.t.sina.com.cn/statuses/upload.json?status=";
tbSina.PARAM_NAME_PIC		= "pic";

--人际相关
tbSina.URL_FOLLOW			= "http://api.t.sina.com.cn/friendships/create/%s.json";
tbSina.URL_UNFOLLOW			= "http://api.t.sina.com.cn/friendships/destroy/%s.json";

--各种请求对应的HTTP METHOD
tbSina.HTTP_METHOD_REQUEST_TOKEN    = Sns.HTTP_METHOD_GET;
tbSina.HTTP_METHOD_ACCESS_TOKEN     = Sns.HTTP_METHOD_POST;
tbSina.HTTP_METHOD_SELF_INFO    	= Sns.HTTP_METHOD_GET;
tbSina.HTTP_METHOD_TWEET            = Sns.HTTP_METHOD_POST;
tbSina.HTTP_METHOD_TWEET_WITH_PIC   = Sns.HTTP_METHOD_POST;
tbSina.HTTP_METHOD_FOLLOW			= Sns.HTTP_METHOD_POST;
tbSina.HTTP_METHOD_UNFOLLOW			= Sns.HTTP_METHOD_POST;
tbSina.HTTP_METHOD_IS_FOLLOWING = Sns.HTTP_METHOD_GET;


tbSina.szFold			= "sina";
tbSina.szSameKey		= "sinaimg.cn/";
tbSina.tbImgFileName	= {};
tbSina.tbName2Image		= {};
tbSina.tbImageName2Http = {};
tbSina.nFlag_MyImageAddIntoPort = 0;
tbSina.szMyImgHttpAddress = "";

function tbSina:GetUrl_RequestToken(szCallbackUrl)
	szCallbackUrl = szCallbackUrl or "oob";
	return self.URL_REQUEST_TOKEN .. szCallbackUrl;
end

function tbSina:GetUrl_Authorize(szTokenKey)
	return self.URL_AUTHORIZE .. szTokenKey;
end

function tbSina:GetUrl_AccessToken(szVerifier)
	return self.URL_ACCESS_TOKEN .. szVerifier;
end

function tbSina:GetUrl_SelfInfo()
	return self.URL_SELF_INFO;
end

function tbSina:GetUrl_Tweet(szTweet)
	return self.URL_TWEET .. szTweet;
end

function tbSina:GetUrl_TweetWithPic(szTweet, szPicPath)
	return self.URL_TWEET_WITH_PIC .. szTweet;
end

function tbSina:GetUrl_Follow(szAccount)
	return string.format(self.URL_FOLLOW, szAccount);
end

function tbSina:GetUrl_Unfollow(szAccount)
	return string.format(self.URL_UNFOLLOW, szAccount);
end

function tbSina:GetUrl_AccountHome(szAccount)
	return self.URL_HOMEPAGE .. szAccount;
end

function tbSina:GetUrl_IsFollowing(szAccount)
	return "http://api.t.sina.com.cn/friendships/show.json?target_id=" .. szAccount;
end

--解析API调用的响应table,返回成功或失败
function tbSina:AnalyseResponse(tbResponse)
	local szError = tbResponse.error;
	if not szError then
		return Sns.SNS_RESULT_OK;
	else
		--40072为新浪微博的“用户取消授权”错误码
		local nIndex = string.find(szError, "40072");
		--40113:Oauth Error: token_rejected!
		local nIndex2 = string.find(szError, "40113");
		if nIndex == 1 or nIndex2 == 1 then
			return Sns.SNS_RESULT_REVOKED;
		else
			return Sns.SNS_RESULT_FAIL, szError, tbResponse.error_code;
		end
	end
end

function tbSina:AnalyseFollowResponse(tbResponse)
	local nRet, szError, szErrorCode = self:AnalyseResponse(tbResponse);
	if nRet == Sns.SNS_RESULT_FAIL then
		--已关注此人
		if szErrorCode == "403" then
			nRet = Sns.SNS_RESULT_OK;
			szError = nil;
			szErrorCode = nil;
		end
	end
	return nRet, szError, szErrorCode;
end

function tbSina:AnalyseUnfollowResponse(tbResponse)
	return self:AnalyseFollowResponse(tbResponse);
end

--从响应table中获取用户帐号名
function tbSina:GetUserName(tbResponse)
	return tbResponse and tostring(tbResponse.id) or "";
end

function tbSina:AnalyseIsFollowingResponse(tbResponse, szAccount)
	local nRet, szError = self:AnalyseResponse(tbResponse);
	if nRet == Sns.SNS_RESULT_OK then
		local szResult = tbResponse.source.following;
		return szResult == true and 1 or 0;
	else
		return nil;
	end
end
function tbSina:GetTweetId(tbResponse)
	return tostring(tbResponse.id);
end
function tbSina:GetTweetUrl(szAccount, szTweetId)
	return string.format("http://api.t.sina.com.cn/%s/statuses/%s", szAccount, szTweetId);
end
tbSina.tbMonth =
{
	Jan = 1,
	Feb = 2,
	Mar = 3,
	Apr = 4,
	May = 5,
	Jun = 6,
	Jul = 7,
	Aug = 8,
	Sep = 9,
	Oct = 10,
	Nov = 11,
	Dec = 12,
};
--新浪时间格式（狂鄙视！）
--"created_at" : "Tue Nov 30 16:21:13 +0800 2010"
function tbSina:ParseSinaTime(szDateTime)
	local tb = {};
	for w in string.gmatch(szDateTime, "([^ ]+)") do
		tb[#tb + 1] = w;
	end
	local szTime = tb[4];
	tb.year		 = tonumber(tb[6]);
	tb.month	 = self.tbMonth[tb[2]];
	tb.day		 = tonumber(tb[3]);
	tb.hour		 = tonumber(string.sub(szTime, 1, 2));
	tb.min		 = tonumber(string.sub(szTime, 4, 5));
	tb.sec		 = tonumber(string.sub(szTime, 7, 8));
	return os.time(tb);
end
function tbSina:ParseTimelineResponse(tbResponse)
	local tbTimeline = {};
	for n, tbTweet in ipairs(tbResponse) do
		local tb		= {};
		tb.szId			= tostring(tbTweet.id);
		tb.nTime		= self:ParseSinaTime(tbTweet["created_at"]);
		tb.szTweet		= tbTweet.text;
		tb.szAccount	= tostring(tbTweet.user.id);
		tb.bOriginal	= 1;
		tbTimeline[#tbTimeline + 1] = tb;
	end	
	return tbTimeline;
end
--注意：用feature=1指定了只获取原创
function tbSina:GetTimelineUrl(bFirstPage, tbTimeline)
	if bFirstPage == 1 then
		return "http://api.t.sina.com.cn/statuses/friends_timeline.json?feature=1&count=20&page=1";
	else
		local tbLastTweet = tbTimeline[#tbTimeline];
		return "http://api.t.sina.com.cn/statuses/friends_timeline.json?feature=1&count=20&max_id=" .. tbLastTweet.szId;
	end
end
function tbSina:GetAccountTweetPageUrl(szAccount)
	return self.URL_HOMEPAGE .. szAccount .. "/profile";
end

-- 获取自定义头像信息
function tbSina:GetProfileImageUrl(tbResponse)
	return tbResponse and tostring(tbResponse.profile_image_url) or "";
end

function tbSina:GetHttpImgFileName(szName)
	local szGateWayName = GetClientLoginGateway();
	local szEncode = UrlEncode(szName);
	
	return szGateWayName .. szEncode .. ".jpg"
end

function tbSina:ResetImgTable()
	self.tbImgFileName		= {};
	self.tbName2Image		= {};
	self.tbImageName2Http	= {};
	self.nFlag_MyImageAddIntoPort = 0;
	self.tbFriendApplyImgCount = {};
	self.szMyFileName = nil;
	self.szMyImgHttpAddress = "";	
end

function tbSina:CheckAllImgDuringFold()
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

function tbSina:ProcessMySnsImg()
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

function tbSina:ProcessAllPlayerImg()
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

function tbSina:DownloadPlayerImg(szHttpAddress, szMyFileName)
	AddSnsImgFilePath(szHttpAddress, GetRootPath() .. self.szPathFold .. "\\" .. szMyFileName);
end

function tbSina:AddMySnsImgFilePath(szHttpAddress)
	local szImgFile = self:GetHttpImgFileName(me.szName);	
	local szFilePath = self.szPathFold .. "\\" .. szImgFile;
	AddSnsPortrait(me.nSex, self.nSnsId, szFilePath);

	if (not szHttpAddress) then
		return 0;
	end
	
	self.szMyImgHttpAddress = szHttpAddress;
	AddSnsImgFilePath(szHttpAddress, GetRootPath() .. szFilePath);	
end

function tbSina:OnCleanFold()
	ClearPrivateOneFold(self.szFold);
end
