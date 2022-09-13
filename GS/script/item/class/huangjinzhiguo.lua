-- 文件名　：huangjinzhiguo.lua
-- 创建者　：zhongchaolong
-- 创建时间：2007-10-11 14:53:44
--黄金之果的食用效果 等级50-89级玩家每7天最多吃1个,每个经验1000w
local tbItemHuangJinZhiGuo = Item:GetClass("huangjinzhiguo");

tbItemHuangJinZhiGuo.DAY_LIMIT			= 7*3600*24;
tbItemHuangJinZhiGuo.nExp				= 10000000;--1000w 
--tbItemHuangJinZhiGuo.nUseCountLimit		= 30;--最多吃30个 废除

function tbItemHuangJinZhiGuo:OnUse()
	--黄金辉煌之果的使用
	local nGetPlayerRank	= HuiHuangZhiGuo.GetPlayerRank();
	local nItemLevel		= it.nLevel;
	local nUseTime			= me.GetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuangJinGuo_UseTime);
	local nNowTime			= GetTime();
	--local nCount			= me.GetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuangJinGuo_UseCount);废除
	local nExp				= self.nExp;
	local nLevelExp			= me.GetUpLevelExp()-me.GetExp();
	
	if ((nNowTime - nUseTime) < self.DAY_LIMIT) then --不够7天
		me.Msg("您的历练还不足以消化这枚果实。");
		return 0;
	end
-- 废除
--	if (nCount >= self.nUseCountLimit) then --吃了超过30个
--		me.Msg(string.format("每位大侠最多只能服用%d枚，若超过上限则可能走火入魔。",self.nUseCountLimit));
--		return 0;
--	end
	if (nGetPlayerRank ~= nItemLevel) then -- 如果级别不对,不能使用
		--这里告诉玩家级别不对,不能使用
		if (1 == nItemLevel) then
			me.Msg("这果实只有70级到99级之间玩家方能使用!");
		end
		return 0;
	end
	
	if (nLevelExp < nExp) then
		nExp = nLevelExp;
	end
	me.AddExp(nExp);
	
	me.SetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuangJinGuo_UseTime,GetTime());
	--me.SetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuangJinGuo_UseCount,nCount+1);废除
	return 1;
end
