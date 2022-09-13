-- 文件名　：huihuangzhizhong.lua
-- 创建者　：zhongchaolong
-- 创建时间：2007-10-10 17:53:23
-- npc辉煌之种，玩家点击，提示需要等待种子成熟才能摘取

local tbNpcHuiHuangZhiZhong = Npc:GetClass("huihuangzhizhong");

tbNpcHuiHuangZhiZhong.nGrowTime			= 5; --成熟的时间

function tbNpcHuiHuangZhiZhong:OnDialog()
	
--	local nGetPlayerRank = HuiHuangZhiGuo.GetPlayerRank();
--	
--	if (nGetPlayerRank ~= him.nLevel) then -- 如果级别不对,不能进行拾取
--		--这里告诉玩家级别不对,不能拾取
--		if (1 == him.nLevel) then
--			me.Msg("这里的种子只有级50到89级之间玩家方能拾取!");
--		end
--		return 0;
--	end;
	local tbNpcInfo	= him.GetTempTable("HuiHuangZhiGuo");
	local nFiveMinute = 300 --单位(秒)
	local nTime = nFiveMinute - GetTime() + tbNpcInfo.nPlantTime
	local nHour, nMinute, nSecond = Lib:TransferSecond2NormalTime(nTime)
	local szTime = ""
	if (nHour ~= 0) then
		szTime = string.format("%s%d小时",szTime,nHour)
	end
	if (nMinute ~= 0) then
		szTime = string.format("%s%d分",szTime,nMinute)
	end
	szTime = string.format("%s%d秒",szTime,nSecond)
	me.Msg(string.format("目前种子还未成熟，种子要<color=yellow>%s<color>方能成熟。", szTime));
end;
