-- 文件名　：chongzhi_box.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-11-16 14:23:56
-- 功能    ：

local tbItem = Item:GetClass("chongzhi_box");

tbItem.tbAwardItem = {	
				{18,1,118,1},
				{18,1,1526,1},
				{18,1,1527,1},
				{18,1,1528,1},
			   };

function tbItem:OnUse()
	local szInfo = "请选择你想要的物品，只能选择一项呦~~ （根据您的服务器开启时间，有些选项可能无法出现在您的选择范围中。）";
	local tbOpt ={					
			{"Đóng lại"},
		};
	local nServerStarTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local szColor = "white";
	local nFlag = 0;
	if GetTime() - nServerStarTime < 365 *24*3600 then
		szColor = "gray";
		nFlag = 1;
	end
	table.insert(tbOpt, 1, {string.format("<color=%s>祈福声望加速令符<color>", szColor),self.AddItem, self, 4, it.dwId, nFlag});
	table.insert(tbOpt, 1, {string.format("<color=%s>武林联赛声望加速令符<color>", szColor),self.AddItem, self, 3, it.dwId, nFlag});
	table.insert(tbOpt, 1, {string.format("<color=%s>领土声望加速令符<color>", szColor),self.AddItem, self, 2, it.dwId, nFlag});
	table.insert(tbOpt, 1, {string.format("金条", szColor),self.AddItem, self, 1, it.dwId});
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:AddItem(nType, nItemId, nFlag)
	if nType > 1 and nFlag and nFlag == 1 then
		me.Msg("你还不能领取这个物品，请选择其他东西。");
		return;
	end
	local pItem =  KItem.GetObjById(nItemId);
	if pItem then
		local nRet = pItem.Delete(me);
		if nRet ~= 1 then
			return;
		end
		local pItemEx = me.AddItem(unpack(self.tbAwardItem[nType]));
		if pItemEx then
			if nType == 1 then
				pItemEx.Bind(1);
			end
			Dbg:WriteLog("玩家："..me.szName.."开启充值礼盒获得:"..pItemEx.szName);
		end
	end
end
	