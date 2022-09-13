-- 文件名　：huihuangzhiguo.lua
-- 创建者　：zhongchaolong
-- 创建时间：2007-10-10 18:56:24
--辉煌之果的食用效果 等级50-89级玩家每天最多吃5个,每个经验100w
local tbItemHuiHuangZhiGuo= Item:GetClass("huihuangzhiguo");
tbItemHuiHuangZhiGuo.nExp				= 1000000;--100w

function tbItemHuiHuangZhiGuo:OnUse()	--辉煌之果的使用

	local nGetPlayerRank	= HuiHuangZhiGuo.GetPlayerRank();
	local nItemLevel		= it.nLevel;
	local nDate				= me.GetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuiHuangGuo_UseDate);
	local nNowDate			= tonumber(GetLocalDate("%y%m%d"));
	local nExp				= self.nExp;
	local nLevelExp			= me.GetUpLevelExp()-me.GetExp();
	
	if (nDate ~= nNowDate) then
		me.SetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuiHuangGuo_UseDate,nNowDate);
		me.SetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuiHuangGuo_UseCount,0);--设置为0次
	end
	
	local nCount = me.GetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuiHuangGuo_UseCount);
	
	if (nCount >= HuiHuangZhiGuo.MaxHuiHuangGuoUseCount) then
		me.Msg(string.format("今天已经食用了%d个。",nCount));
		return 0;
	end
	if (nGetPlayerRank ~= nItemLevel) then -- 如果级别不对,不能使用
		--这里告诉玩家级别不对,不能使用
		if (1 == nItemLevel) then
			me.Msg("这个果子只有70级到99级之间玩家方能使用!");
		end
		return 0;
	end
	if (nLevelExp < nExp) then
		nExp = nLevelExp;
	end
	me.AddExp(nExp);
	me.SetTask(HuiHuangZhiGuo.TSKG_HuiHuangZhiGuo_ACT,HuiHuangZhiGuo.TSK_HuiHuangGuo_UseCount,nCount+1);
	return 1;
end
