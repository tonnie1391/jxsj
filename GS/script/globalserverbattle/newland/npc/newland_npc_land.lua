-------------------------------------------------------
-- 文件名　：newland_npc_land.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-06 17:04:23
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbNpc = Npc:GetClass("newland_npc_land");

-------------------------------------------------------
-- 1. 进入铁浮城
-- 2. 领取庆祝烟花
-------------------------------------------------------
function tbNpc:OnDialog()
	
	if Newland:CheckIsOpen() ~= 1 or Newland:CheckIsGlobal() ~= 1 then
		Dialog:Say("当日龙蛇归草莽，此时琴剑付高楼。");
		return 0;
	end
	
	local szMsg = "Thành trì sụp đổ đang chờ đợi chủ nhân mới. Ngươi có phải anh hùng thực sự không?<color=green>(Quay về Trương Tuyệt Chi ở Phượng Tường để nhận thưởng sau khi kết thúc trận chiến.)<color>";
	local tbOpt = 
	{
		{"<color=yellow>Tham chiến<color>", self.JoinWar, self},
		{"Thu thập pháo hoa", self.GetYanhua, self},
		{"Ta hiểu rồi"},
	};

	Dialog:Say(szMsg, tbOpt);
end

-- 进入比赛场
function tbNpc:JoinWar(nSure)
	
	-- 判断开战与否
	if Newland:GetWarState() == Newland.WAR_END then
		Dialog:Say("Trận chiến vẫn chưa bắt đầu.");
		return 0;
	end
	
	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, đẳng cấp còn quá thấp.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, ngươi chưa gia nhập môn phái.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 判断披风(雏凤)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < Newland.MANTLE_LEVEL then
		Dialog:Say(string.format("<color=yellow>Nguy hiểm, hãy trang bị phi phong thích hợp đã, ngươi vội quá rồi!<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;	
	end
	
	-- 帮会名字
	local szTongName = me.GetTaskStr(Newland.TASK_GID, Newland.TASK_TONGNAME);
	if not szTongName then
		Dialog:Say(string.format("<color=yellow>Nguy hiểm, ngươi vẫn chưa có Bang hội, ngươi vội quá rồi!<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;	
	end
	
	-- 检查帮会是否报名
	local nGroupIndex = Newland:GetGroupIndexByTongName(szTongName);
	if nGroupIndex <= 0 then
		Dialog:Say("Bang hội của ngươi không đủ tư cách để tham chiến.");
		return 0;
	end
	
	-- 设置军团编号
	if Newland:GetPlayerGroupIndex(me) ~= nGroupIndex then
		me.SetTask(Newland.TASK_GID, Newland.TASK_GROUP_INDEX, nGroupIndex);
	end
	
	-- 传送进复活点
	local nMapId = Newland:GetLevelMapIdByIndex(nGroupIndex, 1);
	local tbTree = Newland:GetMapTreeByIndex(nGroupIndex);
	if nMapId and tbTree then
		local nOk, szError = Map:CheckTagServerPlayerCount(nMapId);
		if nOk ~= 1 then
			Dialog:Say(szError);
			return 0;
		end
		local nMapX, nMapY = unpack(Newland.REVIVAL_LIST[tbTree[0]]);
		me.SetTask(Newland.TASK_GID, Newland.TASK_LAND_ENTER, 1);
		-- balance
		if Newland:CheckIsBalance() == 1 then
			Newland:AddBalance(me);
		end
		me.NewWorld(nMapId, nMapX, nMapY);
	end
end

-- 领取烟花
function tbNpc:GetYanhua()
	
	if Newland:GetDailyPeriod() ~= Newland.PERIOD_WAR_OPEN or Newland:GetPeriod() ~= Newland.PERIOD_WAR_REST then
		Dialog:Say("Pháo hoa chỉ có thể thu thập vào đêm kết thúc trận chiến.");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end
	
	me.AddItem(unpack(Newland.YANHUA_ID));
end