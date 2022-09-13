-- 文件名  : castlefight_update.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-11 15:00:46
-- 描述    : 升级道具

local tbItem = Item:GetClass("castlefight_skill");
function tbItem:OnUse()
	local tbMission =  CastleFight:GetPlayerTempTable(me).tbMission;
	if not tbMission then
		me.Msg("Không thể sử dụng ngoài hoạt động!");
		return;
	end	

	if tbMission:IsPlaying() == 0 then
		me.Msg("Chưa thể sử dụng!")
		return 0;
	end	
	
	if me.nFightState ~= 1 then
		me.Msg("Chỉ có thể sử dụng ở doanh trại.");
		return;
	end
	
	local nCurTimes = CastleFight:GetFinalSkillTimes(me);
	if nCurTimes <= 0 then
		me.Msg("Đã sử dụng hết chiêu thức!");
		return;
	end
	
	local _, nX, nY = me.GetWorldPos();
	me.CastSkill(CastleFight.FINAL_SKILL_ID, 1, nX, nY);
	
	tbMission:BroadcastSystemMsg(string.format("<color=yellow>%s<color> đã sử dụng Khuynh Thành Tất Sát",me.szName));
	tbMission:BroadcastBlackBoardMsg(string.format("<color=yellow>%s<color> đã sử dụng Khuynh Thành Tất Sát",me.szName));
	tbMission:ConsumSkillCount(me.nId,1);
	CastleFight:SetFinalSkillTimes(me, nCurTimes - 1);
end

function tbItem:InitGenInfo()
	it.SetTimeOut(0, GetTime() + CastleFight.ITEM_TIMEOUT);
	return { };
end