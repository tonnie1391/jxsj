-------------------------------------------------------------------
--File: 	
--Author: 	sunduoliang
--Date: 	2008-4-14 9:00
--Describe:	乾坤符
-------------------------------------------------------------------
Require("\\script\\item\\class\\tianyanfulogic.lua");

-- 乾坤符
local tbItem = Item:GetClass("tianyanfu");

function tbItem:OnUse()
	local nYear = it.GetGenInfo(2);
	local nTime = it.GetGenInfo(3);
	if nYear > 0 then
		local nDate = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
		local nCanDate = (nYear* 1000000 + nTime)
		local nSec1 = Lib:GetDate2Time(nDate);
		local nSec2 = Lib:GetDate2Time(nCanDate) + 10;
		if nSec1 < nSec2 then
			Dialog:Say(string.format("您刚使用过天眼符，请稍后再使用。"));
			return 0;
		end
	end
	
	self:ShowOnlineMember(it.dwId, 0);
	return 0;
end

function tbItem:ShowOnlineMember(nItemId, nNowPage)

	local szMsg = "请选择您想查询的在线仇人所在位置：";
	local tbOpt = {};
	local tbOnLineList = {};
	local tbTeamMemberList = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_ENEMEY, 1) ;
	if not tbTeamMemberList or #tbTeamMemberList <= 0 then
		Dialog:Say("您没有仇人！");
		return 0;
	end	
	for nP, szEnemyName in ipairs(tbTeamMemberList) do
		local nEnemyId = KGCPlayer.GetPlayerIdByName(szEnemyName);
		if nEnemyId then
			local nOnline = KGCPlayer.OptGetTask(nEnemyId, KGCPlayer.TSK_ONLINESERVER);
			if nOnline > 0 then
				table.insert(tbOnLineList, {nEnemyId, szEnemyName});
			end
		end
	end
	if #tbOnLineList <= 0 then
		Dialog:Say("您没有仇人在线！");
		return 0;
	end
	local nPage = 5;
	local nCount = nNowPage * nPage;
	local nSum = 0;
	for nP, tbEnemy in ipairs(tbOnLineList) do
		nSum = nSum + 1;
		if nSum > nCount then
			nCount = nCount + 1;
			if nCount > (nPage * (nNowPage + 1)) then
				table.insert(tbOpt, {"Trang sau", self.ShowOnlineMember, self, nItemId, nNowPage + 1});
				break;
			end
			local tbTemp = {string.format("%s", tbEnemy[2]), self.OnUseSure, self, nItemId, tbEnemy[1]};
			table.insert(tbOpt, tbTemp);
		end
	end
	table.insert(tbOpt, {"我先想想"});
	Dialog:Say(szMsg, tbOpt);
end


function tbItem:OnUseSure(nItemId, nEnemyId)
	local nOnline = KGCPlayer.OptGetTask(nEnemyId, KGCPlayer.TSK_ONLINESERVER);
	if nOnline <= 0 then
		Dialog:Say("该仇人现在不在线!");
		return 0;
	end
	GCExcute({"Item.tbTianYanFu:SelectEnemyPos", nEnemyId, me.nId, nItemId});
end

function tbItem:GetTip(nState)
	local nUseCount = it.GetGenInfo(1,0)
	local nLastCount = Item.tbTianYanFu.tbItemList[it.nParticular] - nUseCount;
	local szTip = "";
	szTip = szTip..string.format("<color=gold>右键点击使用<color>\n");
	szTip = szTip..string.format("<color=yellow>剩余使用次数: %s<color>",nLastCount);
	return szTip;
end

