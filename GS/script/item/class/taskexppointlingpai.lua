-------------------------------------------------------------------
--File: 	taskexppointlingpai.lua
--Author: 	zhouchenfei
--Date: 	2010-12-15 17:11:51
--Describe:	经验任务点数获取道具
-------------------------------------------------------------------

local tbLingPai = Item:GetClass("taskexppointlingpai");
tbLingPai.ADD_SHENGWANG = {5, 10, 100}	-- 令牌等级对应增加的门派声望

function tbLingPai:OnUse()
	local nLevel = it.nLevel;
	if (nLevel < 1 or nLevel > 3) then
		return 0;
	end
	
	local nPoint = tbLingPai.ADD_SHENGWANG[nLevel];
	local nAddPoint = nPoint + me.GetTask(2130, 4);

	me.Msg(string.format("您获得了经验任务点数%s点，请到经验任务平台查询剩余发布点数。", nAddPoint));
	me.SetTask(2130, 4, nAddPoint);
	Dbg:WriteLog(string.format("[使用物品][TaskExpPointLingPai]增加经验任务点数%s点",nPoint), me.szName);
	return 1;
end
