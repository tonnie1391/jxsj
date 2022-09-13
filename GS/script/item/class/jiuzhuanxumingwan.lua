-------------------------------------------------------------------
--File: 	jiuzhuanxumingwan.lua
--Author: 	zouying
--Date: 	2008-10-11
--Describe:	九转续命丸，奇珍阁自动使用物品
--InterFace1: 
-------------------------------------------------------------------

local tbJiuZhuan = Item:GetClass("jiuzhuanxumingwan")
	
function tbJiuZhuan:OnUse()
	me.Msg(me.szName.." sử dụng Cửu Chuyển Tục Mệnh Hoàn, vết thương đã hồi phục!");
	
	--补回丢失的经验
	local nLostExp = me.GetDeathPunishExp();
	if nLostExp > 0 then
		me.AddExp(nLostExp);
		me.ClearDeathPunishExp();
	end
	
	me.OnLocalRevive();
	if KinBattle:CheckUseJiuZhuan(me) == 1 then
		KinBattle:OnUseJiuZhuan(me);
	end
	return 1
end

