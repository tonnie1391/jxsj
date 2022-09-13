-------------------------------------------------------
-- 文件名　：wldh_qualification_item.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-08 11:52:25
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\qualification\\wldh_qualification_def.lua");

local tbItem = Item:GetClass("yingxiongtie");

function tbItem:OnUse()
	
	-- 判断能否使用
	if self:CheckUse(me) ~= 1 then
		return 0;
	end
	
	local nCount = me.GetTask(Wldh.Qualification.TASK_GROUP_ID, Wldh.Qualification.TASK_YINXIONGTIE);
	local nCurCount = nCount + 1;
	
	-- 使用后，更新英雄贴排行榜
	PlayerHonor:SetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0, nCurCount);
	me.SetTask(Wldh.Qualification.TASK_GROUP_ID, Wldh.Qualification.TASK_YINXIONGTIE, nCurCount);
	
	me.Msg(string.format("英雄帖使用成功，你已经用了<color=yellow>%d<color>个英雄贴。", nCurCount));
	
	-- 道具消失
	return 1;
end

function tbItem:CheckUse(pPlayer)
	
	if Wldh.Qualification:CheckServer() ~= 1 then
		Dialog:Say("对不起，你所在的服务器不能参加武林大会，无法使用英雄帖。");
		return 0;
	end
	
	-- 判断资格
	if Wldh.Qualification:CheckMember(pPlayer) ~= 0 then
		Dialog:Say("对不起，你已经获得参加武林大会的资格，不需要再使用英雄帖了。");
		return 0;
	end
	
	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < Wldh.Qualification.MEMBER_STATE[1] then
		Dialog:Say("对不起，还未到活动时间，不能使用英雄帖。");
		return 0;
	end
	
	-- 特殊处理
	if nNowDate > 200909272158 then
		Dialog:Say("对不起，已经过了最后一次排名的时间，无法再使用英雄贴了。");
		return 0;
	end
	
	-- 是否产生名单
	local nProssession = KGblTask.SCGetDbTaskInt(DBTASK_WLDH_PROSSESSION);
	if nProssession == 0 then
		Dialog:Say("对不起，尚未产生武林大会资格最初名单，请稍后再使用英雄贴。");
		return 0;
	end
	
	return 1;
end

