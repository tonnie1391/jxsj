-------------------------------------------------------------------
--File: 	
--Author: 	sunduoliang
--Date: 		2008-4-14
--Describe:	家族召唤令牌
-------------------------------------------------------------------
Require("\\script\\item\\class\\zhaohuanlingpailogic.lua");

-- 家族召唤令牌
local tbItem = Item:GetClass("jiazuzhaohuanlingpai");
tbItem.nTime = 10;							-- 延时的时间(秒)

--家族召唤令牌ID,对应使用次数.
tbItem.tbItemList = {
		[87] = 10,		--家族召唤令牌，10次；
	}
function tbItem:OnUse()
	local pPlayer = me;
	
	local nCanSendIn  = Item:IsCallInAtMap(pPlayer.nMapId, unpack(it.TbGDPL()));
	if (nCanSendIn ~= 1) then
		pPlayer.Msg("该道具禁止在本地图使用。")
		return 0;
	end
	local nKinId, nKinMemId = pPlayer.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		pPlayer.Msg("您还没有家族，不能使用家族召唤令牌。")
		return 0;
	end
	if pPlayer.nKinFigure <= 0 or pPlayer.nKinFigure >= 4 then
		pPlayer.Msg("只有家族正式成员才能使用家族召唤令牌。")
		return 0;		
	end
	local tbOpt = 
	{
		{"使用",self.SendAllMember, self, it.dwId},
		{"退出"},
	}
	Dialog:Say("您是否使用家族召唤令牌，把本家族所有在线成员召唤到身边来?",tbOpt);
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
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
	local nKinId, nKinMemId = pPlayer.GetKinMember();
	if pPlayer.nKinFigure <= 0 or pPlayer.nKinFigure >= 4 then
		pPlayer.Msg("只有家族正式成员才能使用家族召唤令牌。")
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if pItem == nil then
		pPlayer.Msg("您使用的家族召唤令牌已被删除，非法操作出现异常，请于GM联系。");
		return 0; 
	end	
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	local nUseCount = pItem.GetGenInfo(1,0);
	if self.tbItemList[pItem.nParticular] - nUseCount <= 1 then
		if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			pPlayer.Msg("删除家族召唤令牌令败！");
			return 0;
		end
	else
		pItem.SetGenInfo(1,nUseCount + 1);
		pItem.Sync();
	end
	local nFightState = pPlayer.nFightState;
	GCExcute({"Item.tbZhaoHuanLingPai:SelectPlayer", 1, nMapId, nPosX, nPosY, nPlayerId, nKinId, pPlayer.szName, nFightState});
	pPlayer.Msg("您成功使用了家族召唤令牌，所有在线的家族成员将会接收到召唤请求。");
end


function tbItem:GetTip(nState)
	local nUseCount = it.GetGenInfo(1,0)
	local nLastCount = self.tbItemList[it.nParticular] - nUseCount;
	local szTip = "";
	szTip = szTip..string.format("<color=0x8080ff>右键点击使用<color>\n");
	szTip = szTip..string.format("<color=yellow>剩余使用次数: %s<color>",nLastCount);
	return szTip;
end

