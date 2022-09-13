-- 文件名　：zhukeling.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-09 14:14:26
-- 功能描述：结婚道具（逐客令）

local tbItem = Item:GetClass("marry_zhukeling");

--=================================================


tbItem.MAX_RANGE = 20;
tbItem.NUM_PER_PAGE = 15;

--=================================================

-- 从客户端得到选择中的NPC对象，并把ID返回给服务器
-- 如果没有选择NPC对象，返回0
function tbItem:OnClientUse()
	local pSelectNpc = me.GetSelectNpc();
	if not pSelectNpc then
		return 0;
	end

	return pSelectNpc.dwId;
end

function tbItem:CanUse(pItem)
	local szErrMsg = "";
	
	if (0 == Marry:CheckWeddingMap(me.nMapId)) then
		szErrMsg = "你没有处在典礼场地当中，不能使用该物品。";
		return 0, szErrMsg;
	end
	
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId) or {};
	local bIsCurMapItem = 0;	-- 是否是当前地图可以使用的物品
	for _, szName in pairs(tbCoupleName) do
		if (szName == pItem.szCustomString) then
			bIsCurMapItem = 1;
			break;
		end
	end
	if (0 == bIsCurMapItem) then
		szErrMsg = "这个物品与当前举行典礼的二位侠侣不匹配，不能使用！";
		return 0, szErrMsg;
	end
	
	local nPrivilegeLevel = self:GetLevel(me.nMapId, me.szName);
	if (nPrivilegeLevel < 2) then
		szErrMsg = "逐客令需要二位侠侣或他们的结义兄弟、闺中密友才能使用，你不能使用。";
		return 0, szErrMsg;
	end
	
	return 1;
end

-- 参数应该为选中NPC的ID
function tbItem:OnUse(nParam)
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local nNpcId = nParam;
	local pNpc = KNpc.GetById(nNpcId);
	if (0 == nNpcId or not pNpc) then
		me.Msg("请选择一个玩家后再使用该道具。");
		return 0;
	end
	local pPlayer = pNpc.GetPlayer();
	if (not pPlayer) then
		me.Msg("请选择一个玩家后再使用该道具。");
		return 0;
	end
	
	local bCanUse, szErrMsg = self:CanUse(it);
	if (0 == bCanUse) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local tbEvent = 
	{
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
	}

	GeneralProcess:StartProcess("准备驱逐...", 5 * Env.GAME_FPS,
		{self.SelectPlayer, self, pPlayer.szName, me.szName, it.dwId}, nil, tbEvent);

end

function tbItem:SelectPlayer(szDstName, szAppName , nItemId)
	if (0 == self:CanBeBanished(szDstName)) then
		Dialog:Say("不能驱逐，该玩家是侠侣或他们的结义兄弟、闺中密友。");
		return;
	end
	local szMsg = string.format("你确定要把<color=yellow>%s<color>请出当前典礼场地吗？", szDstName);
	local tbOpt = {
		{"是的，我确定", self.SureSelectPlayer, self, szDstName, szAppName, nItemId},
		{"我还是再想想吧"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:SureSelectPlayer(szDstName, szAppName, nItemId)
	local pPlayer = KPlayer.GetPlayerByName(szDstName);
	local pItem = KItem.GetObjById(nItemId);
	if (pPlayer and pItem) then
		pItem.Delete(me);
		Setting:SetGlobalObj(pPlayer);
		Marry:KickPlayer(pPlayer.nMapId, pPlayer);
		Dialog:Say("很遗憾，您已经被请出典礼场地。");
		Setting:RestoreGlobalObj();
	end
	pPlayer = KPlayer.GetPlayerByName(szAppName);
	pPlayer.Msg(string.format("你已经将<color=yellow>%s<color>请出典礼场地。", szDstName));
end

-- 判断一个人是否可以被驱逐（可以驱逐比自己权限低的角色）
function tbItem:CanBeBanished(szName)
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return 0;
	end
	
	local nHisLevel = self:GetLevel(pPlayer.nMapId, szName);
	if (nHisLevel == 0) then
		return 0;
	end
	
	local nMyLevel = self:GetLevel(me.nMapId, me.szName);
	if (nMyLevel <= nHisLevel) then
		return 0;
	end
	
	return 1;
end

-- 获取权限等级
function tbItem:GetLevel(nMapId, szName)
	if (not nMapId or nMapId <= 0 or not szName) then
		return 0;
	end
	return Marry:GetWeddingPlayerLevel(nMapId, szName);
end
