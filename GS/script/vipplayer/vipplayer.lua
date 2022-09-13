------------------------------------------
--	文件名  ：	vipplayer.lua
--	创建者  ：	ZouYing@kingsoft.com
--	创建时间：	2009-3-11 11:12 
------------------------------------------
local TASK_VIPPLAYER_TASKID = 2083
local tbVipPlayerData = {};
local FILE_PATH  = "\\setting\\event\\vipplayerlist\\08vipplayerlist.txt";

local MAX_COUNT = 4;

function  VipPlayer:Init()
	self.tbTxt = {};
	self:ReadData();	
end

function VipPlayer:ReadData()
	local tbFile = Lib:LoadTabFile(FILE_PATH);
	if not tbFile then
		print(FILE_PATH, "File open Fail!!!!!!!!!!!!!!");
		return;
	end
	
	for nId = 1, #tbFile do
		local tbParam = tbFile[nId];
		local szGateWay = tbParam.GATEWAY;
	
		if (not self.tbTxt[szGateWay] ) then
			self.tbTxt[szGateWay] = {};
		end
		
		local szRoleName = tbParam.ROLENAME;
		if (not self.tbTxt[szGateWay][szRoleName]) then
			self.tbTxt[szGateWay][szRoleName] = {};
		end
		local szAccount = tbParam.ACCOUNT;
		szAccount = string.lower(szAccount);
		local nYearPoints = tbParam.YEARPOINT;
		if (not nYearPoints) then
			print(szAccount, szRoleName, " this line error!!!!!!!!!!!");
			assert(false);
		end		
		self.tbTxt[szGateWay][szRoleName][szAccount] = nYearPoints;
	end
end

ServerEvent:RegisterServerStartFunc(VipPlayer.Init, VipPlayer);

----======================= 之前是初始化====================------------------------

local szDialogMsg = [[
	从即日起到2009年7月17日0点为止，
	符合条件的《剑侠世界》VIP玩家角色可以到我这里领取相当于2008年总充值积分20%的绑定金币的道具：
	返还卷。共4个月分4次领取，每个月领取相当于总积分5%的绑定金币的1张返还卷。如果未领取以自动放弃处理。
	如果想要了解详情请访问网址：vip.xoyo.com。 
]]

local szReturnVol = [[
返还卷是具有返还资格的VIP玩家可领取的一种凭证，
每月领1个共可领取4个，每个价值相当与你整个2008年充值金币5%的绑金。
凭此卷在奇珍阁消费，能获得50%的绑金返还，返还的数额将从返还卷中扣除，扣完为止。
该卷有效期1个月，所以请尽快用完以免浪费。
]]


function VipPlayer:OnDialog()
	local tbOpt = 
	{
		{"我要领取本月返还卷",  self.DrawGiveBack,     self},
		{"什么是“返还卷”",     self.WhatIsReturnVol, self},
		{"Để ta suy nghĩ thêm吧"},
	}
	Dialog:Say(szDialogMsg, tbOpt);
end

function VipPlayer:DrawGiveBack()
	local tbOpt = {};
	local szMsg = "";
	if (1~= self:CheckPlayerIsVip(me.szAccount, me.szName)) then
		tbOpt = {	{"下次做回VIP！"},}
		szMsg = "你不具备获得返还的资格，领取返还卷失败。";
	end;
	local nRet = self:CheckHaveDraw();
	if (1 == nRet) then
		szMsg = "你本月已经领过返还卷了，下个月再来。"..
		"您还可以领取<color=yellow>".. MAX_COUNT - me.GetTask(TASK_VIPPLAYER_TASKID, 2) .."<color>次";
		tbOpt = {	{"下个月再来领吧！"},}
	elseif (-1 == nRet) then
		szMsg = "你的返还卷已经领完，不用再来领取了。";
	elseif (-2 == nRet) then
		szMsg = "活动已经结束，不能领取返还卷。";
	end
	if (szMsg == "") then
		self:AddItemToBag();
		return ;
	end
	Dialog:Say(szMsg, tbOpt);
end

function VipPlayer:WhatIsReturnVol()
	local tbOpt = 
	{
		{"Ta hiểu rồi（返回上层）", self.OnDialog, self},
		{"随便逛逛"},
	}
	Dialog:Say(szReturnVol, tbOpt);
end

function VipPlayer:CheckPlayerIsVip(szAccount, szName)
	local szLocalGateWay = string.sub(GetGatewayName(), 1, 6);
	if (not self.tbTxt[szLocalGateWay]) then
		return 0;	
	elseif (not self.tbTxt[szLocalGateWay][szName]) then
		return 0
	elseif (not self.tbTxt[szLocalGateWay][szName][szAccount]) then 
		return 0;
	else
		return 1;
	end
end

function VipPlayer:CheckHaveDraw()
	local szTime = GetTime();
	local szDate = GetLocalDate("%Y%m%d")
	-- 2009年7月17日0点为止
	if (szDate >= "20090717") then
		return -2;
	end
	local nMonth = tonumber( GetLocalDate("%m"));
	if (nMonth == me.GetTask(TASK_VIPPLAYER_TASKID, 1)) then
		return 1;
	end
	local nCount = me.GetTask(TASK_VIPPLAYER_TASKID, 2);
	if (nCount >= 4) then
		return -1;
	end
	return 0;
end

function VipPlayer:AddItemToBag()
	local szMsg = "";
	local nCount = me.GetTask(TASK_VIPPLAYER_TASKID, 2) + 1;
	if (nCount > 4) then
		return 0;
	end
	local pItem = me.AddItem(18, 1, 307, nCount);
	if (pItem) then
		me.SetItemTimeout(pItem, 30 * 24 * 60, 0)
		pItem.Sync();
		local szLocalGateWay = string.sub(GetGatewayName(), 1, 6);
		
		local nTotal = self.tbTxt[szLocalGateWay][me.szName][me.szAccount];
		if (not nTotal) then
			assert(false);
			return 0;
		end
		
		nTotal = nTotal * 5;
		local nLevel = nCount + 2;
		me.SetTask(TASK_VIPPLAYER_TASKID, nLevel , nTotal);
		me.SetTask(TASK_VIPPLAYER_TASKID, 2, nCount);
		local nMonth = tonumber(GetLocalDate("%m"));
		me.SetTask(TASK_VIPPLAYER_TASKID, 1, nMonth);
		szMsg = "你获得返还卷（1月有效期），请尽快使用，以免过期。";
	else
		szMsg = "领取失败，请检查您的背包是否已满！";
	end
	me.Msg(szMsg);
end

function VipPlayer._SortCmp(tbItemA, tbItemB)
	return tbItemA.pItem.nLevel < tbItemB.pItem.nLevel;
end

--每个月可领取积分的5％额度
--返还绑金 ＝ 返还额度 × 100
function VipPlayer:VipReturnBindCoin(pPlayer, nTotalCoin)
	if (not pPlayer or not nTotalCoin or nTotalCoin <= 0) then
		return 0;
	end
	local nCanGetBindCoin = math.floor(nTotalCoin / 2);
	
	if (nCanGetBindCoin <= 0) then
		return 0;
	end
	
	local nLeft = nCanGetBindCoin;	
	local tbVipRetuntVol = pPlayer.FindClassItemOnPlayer("fanhuanjuan");
	local nTotalBindCoin = 0;
	
	table.sort(tbVipRetuntVol,  self._SortCmp);
	for _, tbItem in pairs(tbVipRetuntVol) do
		local pItem = tbItem.pItem;
		if (pItem.nLevel ~= 0) then	
			local nTaskSubId = pItem.nLevel + 2; -- 等级偏移2位，成为任务变量id
			
			local nValue = pPlayer.GetTask(TASK_VIPPLAYER_TASKID, nTaskSubId);
			if ( nValue >= nLeft) then
				nValue = nValue - nLeft;
				pPlayer.SetTask(TASK_VIPPLAYER_TASKID, nTaskSubId, nValue);
				self:ShowMsg(pPlayer, nValue, nLeft);
				pPlayer.AddBindCoin(nLeft, Player.emKBINDCOIN_ADD_VIP_REBACK);
				nTotalBindCoin = nTotalBindCoin + nLeft;
				break;
			else
				KItem.DelPlayerItem(pPlayer, pItem); -- 删除返还券
				pPlayer.SetTask(TASK_VIPPLAYER_TASKID, nTaskSubId, 0);
				self:ShowMsg(pPlayer, 0, nValue);
				pPlayer.AddBindCoin(nValue, Player.emKBINDCOIN_ADD_VIP_REBACK);
				nTotalBindCoin = nTotalBindCoin + nValue;
				nLeft = nLeft - nValue;
			end
		end
	end
	if nTotalBindCoin > 0 then
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_PROMOTION, "VIP返还获得".. nTotalBindCoin .."绑定金币");
	end
end

function VipPlayer:ShowMsg(pPlayer, nLeftPoint, nCutPoint)
	if (nLeftPoint == 0) then
		pPlayer.Msg("您的返还卷已用完而消失了。");
	else
		pPlayer.Msg("您的返还卷数额减少"..nCutPoint);
	end
end

function VipPlayer:OnNotifyVolTimeOut()
	if (self:CheckPlayerIsVip(me.szAccount, me.szName) ~= 1) then
		return 0;
	end
	-- 遍历背包 快过期提示
	local tbVipRetuntVol = me.FindClassItemInBags("fanhuanjuan");
	for _, tbItem in pairs(tbVipRetuntVol) do
		local pItem = tbItem.pItem;
		local nType , nTimeOut = pItem.GetTimeOut();
		local nLeftDays = math.ceil((nTimeOut - GetTime()) / (24 * 60 * 60));
		if (nLeftDays == 7 or (nLeftDays <= 3 and nLeftDays > 0)) then
			local szDate = os.date("%Y年%m月%d日", nTimeOut);
			me.CallClientScript({"Player:NotifyItemTimeOutClient", 46, szDate});
		end
		
		if (nLeftDays <= 0) then
			local nTaskSubId = pItem.nLevel + 2;
			me.SetTask(TASK_VIPPLAYER_TASKID, nTaskSubId, 0);
		end
	end
end

PlayerEvent:RegisterGlobal("OnLogin",  VipPlayer.OnNotifyVolTimeOut,  VipPlayer);
