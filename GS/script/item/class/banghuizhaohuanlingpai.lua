-------------------------------------------------------------------
--File: 	
--Author: 	sunduoliang
--Date: 		2008-4-14
--Describe:	帮会召唤令牌
-------------------------------------------------------------------
Require("\\script\\item\\class\\zhaohuanlingpailogic.lua");

-- 帮会召唤令牌
local tbItem = Item:GetClass("banghuizhaohuanlingpai");
tbItem.nTime = 10;							-- 延时的时间(秒)
function tbItem:OnUse()
	do return end --暂时不开放
	local pPlayer = me;
	local nTongId = pPlayer.dwTongId;
	if nTongId == nil or nTongId <= 0 then
		pPlayer.Msg("您还没有帮会，不能使用帮会召唤令牌。")
		return 0;
	end
	local nSelfKinId, nSelfMemberId = pPlayer.GetKinMember();
	if Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, 0) ~= 1 then
		pPlayer.Msg("你不是长老或长老权力被冻结，无权使用召唤令牌!");
		return 0;
	end
	local tbOpt = 
	{
		{"使用",self.SendAllMember, self, it.dwId},
		{"退出"},
	}
	Dialog:Say("您是否使用帮会召唤令牌，把本帮会所有在线成员召唤到身边来?",tbOpt);
	return 0;
end

function tbItem:SendAllMember(nItemId)
	local pPlayer = me;
	local tbEvent	= {						-- 会中断延时的事件
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	};
	if (0 == pPlayer.nFightState) then				-- 玩家在非战斗状态下传送无延时正常传送
		self:SendAllMemberSuccess(pPlayer.nId, nItemId)
		return 0;
	end
	GeneralProcess:StartProcess("正在发送召唤请求...", self.nTime * Env.GAME_FPS, {self.SendAllMemberSuccess, self, pPlayer.nId, nItemId}, nil, tbEvent);	-- 在战斗状态下需要nTime秒的延时
end


-- 功能:	召唤玩家
-- 参数:	nMapId 要传至的报名点的Id
function tbItem:SendAllMemberSuccess(nPlayerId, nItemId)

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	
	local nTongId = pPlayer.dwTongId;
	if nTongId == nil or nTongId <= 0 then
		pPlayer.Msg("您还没有帮会，不能使用帮会召唤令牌。")
		return 0;
	end
	
	local nSelfKinId, nSelfMemberId = pPlayer.GetKinMember();
	if Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, 0) ~= 1 then
		pPlayer.Msg("你不是长老或长老权力被冻结，无权使用召唤令牌!");
		return 0;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if pItem == nil then
		pPlayer.Msg("您使用的帮会召唤令牌已被删除，非法操作出现异常，请于GM联系。");
		return 0; 
	end	
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
		pPlayer.Msg("删除帮会召唤令牌令败！");
		return 0;
	end
	local nFightState = pPlayer.nFightState;
	--对所有帮会成员发送请求
	GCExcute({"Item.tbZhaoHuanLingPai:SelectPlayer", 2, nMapId, nPosX, nPosY, nPlayerId, nTongId, pPlayer.szName, nFightState});
	pPlayer.Msg("您成功使用了帮会召唤令牌，所有在线帮会成员将会接收到召唤请求。");
end

