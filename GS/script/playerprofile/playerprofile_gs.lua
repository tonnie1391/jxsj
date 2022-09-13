-------------------------------------------------------------------
--File: playerprofile_gs.lua
--Author: Brianyao
--Date: 2008-9-24 11:17
--Describe: Gameserver玩家信息逻辑
-------------------------------------------------------------------

if not PProfile then --调试需要
	PProfile = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
else
	if not MODULE_GAMESERVER then
		return
	end
end

PProfile.c2sFun = {}
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	PProfile.c2sFun[szName] = fun
end

--修改Profile中的字符串值
--参数nOper: 对应playerprofile_def.lua中的emPF_BUFTASK_[XXX]
--参数szStr: 新值
function PProfile:ApplyEditStrInfo(nOper, szStr, nVersion)
	local bCheckSuc = 0
	local nLen = #szStr

	if nOper == self.emPF_BUFTASK_NAME then
		if nLen <= self.MAX_REAL_NAME_LEN then
			bCheckSuc = 1
		else
			me.Msg("姓名长度不符合要求");
		end
		if IsNamePass(szStr) ~=1 then
			me.Msg("姓名中含有非法语句");
			bCheckSuc = 0;
		end
	
	elseif nOper == self.emPF_BUFTASK_AGNAME then
		if nLen <= self.MAX_NICK_NAME_LEN then 
			bCheckSuc = 1;
		else
			me.Msg("绰号长度不符合要求");
		end
		if IsNamePass(szStr) ~= 1 then
			me.Msg("绰号中含有非法语句");
			bCheckSuc = 0
		end
	
	elseif nOper == self.emPF_BUFTASK_PROFESSION then
		if nLen <= self.MAX_PROFESSION_LEN then 
			bCheckSuc = 1;
		else
			me.Msg("职业长度不符合要求");
		end
		if IsNamePass(szStr) ~= 1 then
			me.Msg("职业中含有非法语句");
			bCheckSuc = 0;
		end
	
	elseif nOper == self.emPF_BUFTASK_CITY then
		if nLen <= self.MAX_CITY_LEN then 
			bCheckSuc = 1;
		else
			me.Msg("城市长度不符合要求");
		end
		if IsNamePass(szStr) ~= 1 then
			me.Msg("城市中含有非法语句");
			bCheckSuc = 0;
		end
	
	elseif nOper == self.emPF_BUFTASK_TAG then
		if nLen <= self.MAX_SLEFTIPS_LEN then 
			bCheckSuc = 1;
		else
			me.Msg("口头禅长度不符合要求");
		end
		if IsNamePass(szStr) ~= 1 then
			me.Msg("口头禅中含有非法语句");
			bCheckSuc = 0;
		end
	
	elseif nOper == self.emPF_BUFTASK_FAVORITE then
		if nLen <= self.MAX_FAVOR_LEN then 
			bCheckSuc = 1;
		else
			me.Msg("爱好长度不符合要求");
		end
		if IsNamePass(szStr) ~= 1 then
			me.Msg("爱好中含有非法语句");
			bCheckSuc = 0;
		end
	
	elseif nOper == self.emPF_BUFTASK_BLOGURL then
		if nLen <= self.MAX_BLOG_LEN then 
			bCheckSuc = 1;
		else
			me.Msg("博客长度不符合要求")
		end
		if IsNamePass(szStr) ~= 1 then
			me.Msg("博客中含有非法语句");
			bCheckSuc = 0;
		end
	
	elseif nOper == self.emPF_BUFTASK_COMMENT then
		if nLen <= self.MAX_DIARY_LEN then 
			bCheckSuc = 1;
		else
			local szMsg = "点点滴滴长度不符合要求";
			if nVersion == 2 then
				szMsg = "签名最多不能超过62个字";
			end
			me.Msg(szMsg);
		end
		if IsNamePass(szStr) ~= 1 then
			local szMsg = "点点滴滴中含有非法语句";
			if nVersion == 2 then
				szMsg = "签名中含有非法语句";
			end
			me.Msg(szMsg);
			bCheckSuc = 0;
		end
	 
	elseif (nOper == self.emPF_BUFTASK_TTENCENT or
			nOper == self.emPF_BUFTASK_TSINA) then
		if nLen <= self.MAX_SNS_ACCOUNT_LEN then
			bCheckSuc = 1;
		else
			print("SNS帐号名过长", nOper, szStr);
			bCheckSuc = 0;
		end
	end

	if bCheckSuc == 1 then
		GCExcute{"PProfile:ApplyEditStrInfoGS", nOper, szStr, me.szName};
		return;
	end
end
RegC2SFun("EditStr", PProfile.ApplyEditStrInfo)

--修改Profile中的int值
--参数nOper: 对应playerprofile_def.lua中的emPF_TASK_[XXX]
--参数nParam: 新值
function PProfile:ApplyEditIntInfo(nOper, nParam)

         local nCheckSuc = 0
         
         if (nOper >= self.emPF_TASK_SEX and nOper <= self.emPF_TASK_FRIEND_ONLY ) then
             nCheckSuc = 1
         end
       
		 --保证此值不能通过客户端修改，
		 --否则会导致客户端刷初次填写个人信息的奖励！
		 assert(nOper ~= self.emPF_TASK_PROFILE_EDITED);
		 
         if (nCheckSuc == 1) then -- 规则通过 then
              GCExcute{"PProfile:ApplyEditIntInfoGS", nOper,me.szName, nParam}
         else
              return 0
         end

	 return 1
end
RegC2SFun("EditInt", PProfile.ApplyEditIntInfo)

function PProfile:ApplyEditAllInfo(nSex,nBirth,nReins,nOnline,nFriendOnly,szRealName,szAGName,szProfession,szCity,szTag,szFavorite,szBLOGURL,szComment)
         
         if ( szRealName~= "" and szAGName~="" and szProfession~="" and szCity~="" and szTag~="" and szFavorite~="" and szBLOGURL~="" and szComment~="") then 
            --First Time Gift Here
            GCExcute{"PProfile:ApplyFirstTimeGift", me.szName}
         end       
         PProfile:ApplyEditIntInfo(self.emPF_TASK_SEX,nSex)
         PProfile:ApplyEditIntInfo(self.emPF_TASK_BIRTHD,nBirth)
         PProfile:ApplyEditIntInfo(self.emPF_TASK_REINS,nReins)
         PProfile:ApplyEditIntInfo(self.emPF_TASK_ONLINE,nOnline)
         PProfile:ApplyEditIntInfo(self.emPF_TASK_FRIEND_ONLY,nFriendOnly)
         
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_NAME,szRealName)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_AGNAME,szAGName)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_PROFESSION,szProfession)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_CITY,szCity)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_TAG,szTag)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_FAVORITE,szFavorite)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_BLOGURL,szBLOGURL)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_COMMENT,szComment)
         
end
RegC2SFun("EditAll", PProfile.ApplyEditAllInfo)

-- 新版本修改个人信息的接口
function PProfile:ApplyEditAllInfo2(szRealName, nSex, nBirth,szCity,nReins,szQianming, nFriendOnly)
         if type(szRealName) ~= "string" or type(nSex) ~= "number" or type(nBirth) ~= "number" or type(szCity) ~= "string" or 
         type(nReins) ~= "number" or type(szQianming) ~= "string" or type(nFriendOnly) ~= "number" then
         	return;
        end
         if ( szRealName ~= "" and szCity ~="" and szQianming~="") then 
            --First Time Gift Here
            GCExcute{"PProfile:ApplyFirstTimeGift", me.szName}
         end       
         PProfile:ApplyEditIntInfo(self.emPF_TASK_SEX,nSex)
         PProfile:ApplyEditIntInfo(self.emPF_TASK_BIRTHD,nBirth)
         PProfile:ApplyEditIntInfo(self.emPF_TASK_REINS,nReins)
         PProfile:ApplyEditIntInfo(self.emPF_TASK_FRIEND_ONLY,nFriendOnly)
         
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_NAME,szRealName)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_CITY,szCity)
         PProfile:ApplyEditStrInfo(self.emPF_BUFTASK_COMMENT,szQianming, 2)
         
end
RegC2SFun("EditAll2", PProfile.ApplyEditAllInfo2)

function PProfile:ApplyFirstTimeGiftRet(szPlayerName)
    local pPlayer = KPlayer.SearchPlayer(szPlayerName)
    if   (pPlayer~=nil) then
          pPlayer.AddBindCoin(100, Player.emKBINDCOIN_ADD_HELP_QUESTION) --第一次的奖励
          pPlayer.Msg(string.format("您完整地填写您的真实信息，系统给予了您奖励100绑定%s!", IVER_g_szCoinName))
    end
end

--异步请求任务存储
PProfile.tbSnsInfo = {["nId"] = 1};

--向GC获取玩家SNS信息
function PProfile:GetSnsInfo(nClientRequestId, tbPlayerName)
	if (type(nClientRequestId) ~= "number" or
		type(tbPlayerName) ~= "table") or
		#tbPlayerName == 0 then
		print("PProfile:GetSnsInfo: invalid argument!");
		return;
	end
	local function GetNextRequestId(nClientRequestId)
		local nId = PProfile.tbSnsInfo.nId;
		PProfile.tbSnsInfo[nId] = {me.szName, nClientRequestId};
		PProfile.tbSnsInfo.nId = nId + 1;
		return nId;
	end
	local nServerRequestId = GetNextRequestId(nClientRequestId);
	local nServerId = GetServerId();
	GCExcute{"PProfile:GetSnsInfo", nServerId, nServerRequestId, tbPlayerName};
end
RegC2SFun("GetSnsInfo", PProfile.GetSnsInfo);

--GC回调此函数来将SNS信息发给客户端
function PProfile:OnSnsInfoReceived(nServerId, nServerRequestId, tbInfo)
	--因为是广播
	if GetServerId() ~= nServerId then
		return;
	end
	local tbRequest = self.tbSnsInfo[nServerRequestId];
	if not tbRequest then
		return;
	else
		self.tbSnsInfo[nServerRequestId] = nil;
	end
	--确认玩家存在且在线
	local pPlayer = KPlayer.GetPlayerByName(tbRequest[1]);
	if not pPlayer then
		return;
	end
	pPlayer.CallClientScript{"PProfile:OnSnsInfoReceived", tbRequest[2], tbInfo};
end
