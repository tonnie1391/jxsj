--注意，本文件包含App密钥，一定要确保只放在服务端
if not MODULE_GAMESERVER then
	print('ERROR loading sns_gs.lua: this file can only be used by gameserver!');
	return;
end

Require("\\script\\sns\\sns_def.lua");

--应用的Key和密钥
Sns.tbKeys =
{
	[Sns.SNS_T_TENCENT] =
	{
		szConsumerKey	= "e1f6af5a6be145659de788885c709886",
		szConsumerSecret = "7e52bd6c1617f775f286212ec2c06030",
	},
	
	[Sns.SNS_T_SINA] =
	{
		szConsumerKey	= "479209980",
		szConsumerSecret = "32484ae6a40951150f3d6171751648cb",
	}
}

Sns.tbc2sFun = {};
local function RegisterC2SFun(szFunName, fun)
	Sns.tbc2sFun[szFunName] = fun;
end

function Sns:GetConsumerKeyTable(nSnsId)
	return assert(self.tbKeys[nSnsId]);
end 

--OAuth计算URL的数字签名,返回得到签名后的完整URL
function Sns:OAuthSignUrl(nSnsId, nSignMethod, szUrl, szHttpMethod, szTokenKey, szTokenSecret, nJobId)
	if (type(nSnsId)        ~= "number" or
        type(nSignMethod)   ~= "number" or
        type(szUrl)         ~= "string" or
        type(szHttpMethod)  ~= "string" or
        type(szTokenKey)    ~= "string" or
        type(szTokenSecret) ~= "string" or
        type(nJobId)	    ~= "number")
    then
        print("Sns:OAuthSignUrl：invalid argument!");
        return;
    end

	local tbKey = self:GetConsumerKeyTable(nSnsId);
	local szSignedUrl;
	if #szTokenKey == 0 or #szTokenSecret == 0 then
		szSignedUrl = OAuthGetSignedUrl_HMACSHA1(
			szUrl,
			szHttpMethod,
			tbKey.szConsumerKey,
			tbKey.szConsumerSecret);
	else
		szSignedUrl = OAuthGetSignedUrl_HMACSHA1(
			szUrl,
			szHttpMethod,
			tbKey.szConsumerKey,
			tbKey.szConsumerSecret,
			szTokenKey,
			szTokenSecret);
	end
	me.CallClientScript({"Sns:OnSignedUrl", szSignedUrl,  nJobId});
end
RegisterC2SFun("OAuthSignUrl", Sns.OAuthSignUrl);

--服务端重新加载SNS相关的脚本
function Sns:Reload()
	DoScript("\\script\\sns\\sns_def.lua");
	DoScript("\\script\\sns\\sns_gs.lua");
	DoScript("\\script\\misc\\c2scall.lua");
end  

--触发客户端弹出气泡提示发送信息到SNS
--其他游戏逻辑调用此接口
function Sns:NotifyClientNewTweet(pPlayer, szPopupMessage, szTweet)
	pPlayer.CallClientScript({"Sns:OnNotifyNewTweet", szPopupMessage, szTweet});
end

--设置Sns授权标记
function Sns:SetSnsBind(nSnsId, bEnable)
    if (type(nSnsId) ~= "number" or 
		bEnable ~= 1 and bEnable ~= 0)
	then
        print("Sns:SetSnsBind：invalid argument:", nSnsId, bEnable);
        return;
    end
	
	if self.tbKeys[nSnsId] then
		local tbInfo = KGCPlayer.GCPlayerGetInfo(me.nId);
		local nSnsBind = tbInfo.nSnsBind;
		local nValue = 2 ^ (nSnsId - 1);
		if bEnable == 1 then
			nSnsBind = KLib.BitOperate(nSnsBind, "|", nValue);
			me.SetSnsBind(nSnsBind);
		else
			--要预先判断当前标志位是否设置,再减
			if KLib.BitOperate(nSnsBind, "&", nValue) > 0 then
				me.SetSnsBind(nSnsBind - nValue);
			end
		end
	end
end
RegisterC2SFun("SetSnsBind", Sns.SetSnsBind);

--SNS客户端事件通知
function Sns:OnClientEvent(nSnsId, nEventKind, tbData)
    if (type(nSnsId) ~= "number" or 
		type(nEventKind) ~= "number" or
		tbData ~= nil and type(tbData) ~= "table")
	then
        print("Sns:OnClientEvent: invalid argument:", nSnsId, nEventKind, tbData);
        return;
    end
	
	local tbSns = self:GetSnsObject(nSnsId);
	tbData = tbData or {};
	if nEventKind == self.EVENT_AUTHORIZED then
		self:BroadcastAuth(tbSns);
		--数据埋点
		if type(tbData.szAccount) == "string" then
			StatLog:WriteStatLog("stat_info", "sns", "auth", me.nId, me.GetHonorLevel(), tbSns.nId, tbData.szAccount, "auth");
		end;
		
	elseif nEventKind == self.EVENT_UNAUTHORIZED then
		if type(tbData.szAccount) == "string" then
			StatLog:WriteStatLog("stat_info", "sns", "auth", me.nId, me.GetHonorLevel(), tbSns.nId, tbData.szAccount, "unauth");
		end
		
	elseif nEventKind == self.EVENT_TWEET or nEventKind == self.EVENT_TWEET_PIC then
		if type(tbData.szAccount) == "string" then
			local szMsgType = nEventKind == self.EVENT_TWEET and "text" or "pic";
			StatLog:WriteStatLog("stat_info", "sns", "tweet", me.nId, me.GetHonorLevel(), tbSns.nId, tbData.szAccount, szMsgType);
			tbData.bWithPic = nEventKind == self.EVENT_TWEET_PIC and 1 or 0;
			self:SendMsgToFriendChannel(tbSns, tbData);
		end
		
	elseif nEventKind == self.EVENT_FOLLOW or nEventKind == self.EVENT_UNFOLLOW then
		if (type(tbData.szTargetPlayerName) ~= "string" or
			type(tbData.szTargetAccount) ~= "string" or
			type(tbData.szMyAccount) ~= "string") then
			return;
		end
		local szOpType = nEventKind == self.EVENT_FOLLOW and "follow" or "unfollow";
		local szPlayerName = tbData.szTargetPlayerName;
		local szPlayerAccount = "";
		if self:IsPlayerAccount(tbData.szTargetAccount, nSnsId) == 1 then
			local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
			szPlayerAccount = KGCPlayer.GetPlayerAccount(nPlayerId);
		end
		StatLog:WriteStatLog("stat_info", "sns", "relation", me.nId, me.GetHonorLevel(), tbSns.nId,
			tbData.szMyAccount, szOpType, tbData.szTargetAccount, szPlayerAccount, szPlayerName);
	end
end
RegisterC2SFun("OnClientEvent", Sns.OnClientEvent);

function Sns:BroadcastAuth(tbSns, tbData)
	--向好友、家族、帮会频道发公告
	local szSex = me.nSex == 0 and "他" or "她";
	local szMsg = string.format("【%s】已和%s的<color=red>%s<color>建立关联，可以在游戏中分享信息给朋友们了。", me.szName, szSex, tbSns.szName);
	--好友频道
	me.SendMsgToFriend(szMsg);
	--家族频道
	if me.dwKinId ~= 0 then
		KKin.Msg2Kin(me.dwKinId, szMsg);
	end
	--帮会频道
	if me.dwTongId ~= 0  then
		KTong.Msg2Tong(me.dwTongId, szMsg);
	end
end

function Sns:SendMsgToFriendChannel(tbSns, tbData)
	if type(tbData.szTweetId) == "string" then
		local szAction = tbData.bWithPic == 1 and "发布了一条有趣的微博，有图有真相哦！" or "发布了一条有趣的微博！";
		local szMsg = string.format("<color=red>%s<color>在<color=red>%s<color>%s <tweet=%d,%s,%s>",
			me.szName, tbSns.szName, szAction, tbSns.nId, tbData.szAccount, tbData.szTweetId);
		me.SendMsgToFriend(szMsg);
	end
end
function Sns:Test()
	local szPopupMessage = "祝贺您武器强化成功，把这个好消息和朋友们共享吧！";
	local szTweet = "#剑侠世界# 武器强16成功啦，呵呵呵。。";
	self:NotifyClientNewTweet(szPopupMessage, szTweet);
end

function Sns:IsPlayerAccount(szAccount, nSnsId)
	if (szAccount == Sns.tbOfficialAccount[nSnsId]) then
		return 0;
	end
	for _, tbInfo in ipairs(Sns.tbOfficiaGroup[nSnsId]) do
		if (szAccount == tbInfo.szAccount) then
			return 0;
		end
	end
	return 1;
end

function Sns:SendSnsImg(szDstPlayer, nSnsId, szSrcPlayer, szHttpAddress)
	local pPlayer = KPlayer.GetPlayerByName(szDstPlayer);
	if (not pPlayer) then
		return;
	end
	
	pPlayer.CallClientScript({"Sns:SendSnsImg_Client", nSnsId, szSrcPlayer, szHttpAddress});
end

function Sns:ApplyPlayerImg_GS(szDstPlayerName, nSnsId, szSrcPlayer)
	local pPlayer = KPlayer.GetPlayerByName(szSrcPlayer);
	if (not pPlayer) then
		return;
	end
	pPlayer.CallClientScript({"Sns:ApplyMySnsImg_Client", nSnsId});
end
