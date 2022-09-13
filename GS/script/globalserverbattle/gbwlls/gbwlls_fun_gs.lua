--武林联赛
--孙多良
--2008.10.13
local Fun = {};
GbWlls.Fun = Fun;

Fun.tbParamFun = 
{
	["exp"] 	= "ExeExp",			--经验,单位万
	expbase 	= "ExeExpbase",		--基准经验
	repute 		= "ExeRepute",		--声望
	item 		= "ExeItem", 		--物品
	title 		= "ExeTitle", 		--称号
	binditem 	= "ExeBindItem", 	--绑定物品
	prestige	= "ExePrestige",	--江湖威望
	stock		= "ExeStock",		--股份
	honor		= "ExeHonor",		--荣誉
	statuary	= "ExeStatuary",	--给予树立雕像的资格
	zonespetitle = "ExeZoneSpeTitle", -- 自定义带有区服名的称号
	zonetitle	= "ExeZoneTitle",	-- 带有区服名的指定称号
	effect		= "ExeEffect",		-- 效果
	fourtime	= "ExeFourTime",	-- 4倍时间
	playerskill	= "ExePlayerSkill",	-- 磨刀石护甲片五行石
	factiontitle= "ExeFactionTile",
	itemex		= "ExeItemEx",		-- 只负责能叠加的物品
	chengzhubox	= "ExeChengZhuBox",			--城主箱子
	chengzhanbox	= "ExeChengZhanBox",	--城战箱子
}
function Fun:GetNeedFree(tbParam)
	local nNeedFree = 0;
	for szFun, tbFun in pairs(tbParam) do
		for _, value in pairs(tbFun) do
			if szFun == "item" or szFun == "binditem" then
				local tbItem = {};
				for nId, nNum in ipairs(value) do
					tbItem[nId] = tonumber(nNum);
				end
				nNeedFree = nNeedFree + 1;
			elseif (szFun == "itemex") then  -- TODO: 前提是所加的物品能叠加
				local tbItem = {};
				for nId, nNum in ipairs(value) do
					tbItem[nId] = tonumber(nNum);
				end				
				nNeedFree = nNeedFree + KItem.GetNeedFreeBag(tbItem[1], tbItem[2], tbItem[3], tbItem[4], nil, tbItem[5]);
			end
		end
	end
	return nNeedFree;
end

function Fun:DoExcute(pPlayer, tbParam)
	for szFun, tbFun in pairs(tbParam) do
		for _, value in pairs(tbFun) do
			if self.tbParamFun[szFun] and self[self.tbParamFun[szFun]] then
				self[self.tbParamFun[szFun]](self, pPlayer, value);
			end
		end
	end
end

--时间显示转换
function Fun:Number2Time(nTime)
	local nMin = math.mod(nTime, 100);
	local nHour = math.floor(nTime/ 100);
	local szMin = nMin;
	if nMin < 10 then
		szMin = "0" .. nMin;
	end
	local szTime = nHour .. ":" .. szMin;
	return szTime
end 

function Fun:ExeExp(pPlayer, value)
	pPlayer.AddExp(tonumber(value*10000));
end

function Fun:ExeExpbase(pPlayer, value)
	pPlayer.AddExp(pPlayer.GetBaseAwardExp() * value);
end

function Fun:ExeRepute(pPlayer, value)
	--增加声望
	local nReputeExt = Item:GetClass("reputeaccelerate"):GetAndUseExtRepute(pPlayer, 7, 1, value, 1);
	pPlayer.AddRepute(7, 1, value + nReputeExt);
end

function Fun:ExeItem(pPlayer, value)
	--获得物品
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg(string.format("由于您的背包空间已满，无法获得<color=yellow>%s<color>", KItem.GetNameById(unpack(value))));
		return 0;
	end
	for nId, nNum in ipairs(value) do
		value[nId] = tonumber(nNum);
	end
	pPlayer.AddItem(unpack(value))
end

function Fun:ExeTitle(pPlayer, value)
	--获得称号.
	for nId, nNum in ipairs(value) do
		value[nId] = tonumber(nNum);
	end
	pPlayer.AddTitle(unpack(value));
	pPlayer.SetCurTitle(unpack(value));
end

function Fun:ExeBindItem(pPlayer, value)
	--获得物品
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg(string.format("由于您的背包空间已满，无法获得<color=yellow>%s<color>", KItem.GetNameById(unpack(value))));
		return 0;
	end
	for nId, nNum in ipairs(value) do
		value[nId] = tonumber(nNum);
	end
	local pItem = pPlayer.AddItem(unpack(value));
	if pItem then
		pItem.Bind(1);
	end
end

--增加江湖威望
function Fun:ExePrestige(pPlayer, value)
	pPlayer.AddKinReputeEntry(value, "wlls");
end

--增加建设资金和个人、族长、帮主股份
function Fun:ExeStock(pPlayer, value)
	Tong:AddStockBaseCount_GS1(pPlayer.nId, value, 0.75, 0.15, 0.05, 0, 0.05);
end

--增加联赛荣誉
function Fun:ExeHonor(pPlayer, value)
	Wlls:AddHonor(pPlayer.szName, value);
end

function Fun:ExeStatuary(pPlayer, value)
	GbWlls:WriteLog("ExeStatuary", pPlayer.szName, "Get a Statuary", value);
	StatLog:WriteStatLog("stat_info", "kfwlls", "effigy", pPlayer.nId, "0");
	Domain.tbStatuary:AddStatuaryCompetence(pPlayer.szName, tonumber(value));
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_STATUARY_TYPE, tonumber(value));
	pPlayer.Msg("您获得了树立雕像的资格，请到跨服联赛报名官那里树立！");
end

function Fun:ExeZoneSpeTitle(pPlayer, value)
	local tbInfo = GbWlls:GetZoneInfo(GetGatewayName());
	if (not tbInfo) then
		GbWlls:WriteLog("ExeZoneSpeTitle", pPlayer.szName, "There is no ZoneInfo");
		return 0;
	end
	local szTitle = tbInfo[1] .. value[1];
	pPlayer.AddSpeTitle(szTitle, GetTime() + tonumber(value[2]), value[3]);
	GbWlls:WriteLog("ExeZoneSpeTitle", pPlayer.szName, "give zone spetitle", value[2], value[3]);
end

function Fun:ExeZoneTitle(pPlayer, value)
	local tbInfo = GbWlls:GetZoneInfo(GetGatewayName());
	if (not tbInfo) then
		GbWlls:WriteLog("ExeZoneTitle", pPlayer.szName, "There is no ZoneInfo");
		return 0;
	end
	pPlayer.AddTitle(tonumber(value[1]), tonumber(value[2]), tbInfo[2], 0);
	GbWlls:WriteLog("ExeZoneTitle", pPlayer.szName, "give zone title", value[1], value[2], tbInfo[2]);
end

function Fun:ExeEffect(pPlayer, value)
	for nId, nNum in ipairs(value) do
		value[nId] = tonumber(nNum);
	end
	pPlayer.AddSkillState(unpack(value));
end

function Fun:ExeFourTime(pPlayer, value)
	local nTime = tonumber(value);
	local nRemainTime = pPlayer.GetTask(1023, 2);
	nRemainTime = nRemainTime + nTime;
	if (nRemainTime > 140) then
		nRemainTime = 140;
	end
	pPlayer.SetTask(1023,2,nRemainTime);
end

function Fun:ExePlayerSkill(pPlayer, value)
	for nId, nNum in ipairs(value) do
		value[nId] = tonumber(nNum);
	end	
	pPlayer.CastSkill(value[1], value[2], value[3], pPlayer.GetNpc().nIndex);
end

function Fun:ExeFactionTile(pPlayer, value)
	for nId, nNum in ipairs(value) do
		value[nId] = tonumber(nNum);
	end	
	local nFaction = GbWlls:GetPlayerSportTask(pPlayer.szName, GbWlls.GBTASKID_MATCH_TYPE_PAREM);
	if (nFaction > 0) then
		me.AddTitle(value[1], value[2], nFaction, 0);
	end
end

function Fun:ExeItemEx(pPlayer, value)
	for nId, nNum in ipairs(value) do
		value[nId] = tonumber(nNum);
	end
	pPlayer.AddStackItem(value[1], value[2], value[3], value[4], {bForceBind=value[6]}, value[5]);
end

function Fun:ExeChengZhuBox(pPlayer, value)
	local nNum = tonumber(value);
	local nTotalNum = nNum + pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_CHENGZHUBOX_NUM);
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_CHENGZHUBOX_NUM, nTotalNum);
	pPlayer.Msg("您获得了兑换辉煌战功箱的资格，请到跨服联赛报名官那里兑换！");
	GbWlls:WriteLog("ExeChengZhuBox", pPlayer.szName, "give cheng zhu box", nNum);
end

function Fun:ExeChengZhanBox(pPlayer, value)
	local nNum = tonumber(value);
	local nTotalNum = nNum + pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_CHENGZHANBOX_NUM);
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_CHENGZHANBOX_NUM, nTotalNum);
	pPlayer.Msg("您获得了兑换卓越战功箱的资格，请到跨服联赛报名官那里兑换！");
	GbWlls:WriteLog("ExeChengZhanBox", pPlayer.szName, "give cheng zhan box", nNum);
end


