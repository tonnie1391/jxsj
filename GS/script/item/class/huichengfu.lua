
-- 回城符

local tbHuichengfu = Item:GetClass("huichengfu");

tbHuichengfu.nTime = 10;					-- 延时的时间(秒)

-- UNDONE: zbl	临时写法,以后改为判断配置表格参数
tbHuichengfu.nWuxianhuichengfuId =	{[23] = 1, [234] = 1}; 	-- 无限回城符的Id

function tbHuichengfu:OnUse()
	Log:Ui_LogSetValue("是否使用过回城卷", 1)	
	self:DelayTime(it, me);
	return	0;
end

-- 功能:	点击回城符后,玩家在战斗状态下将延时tbHuichengfu.nTime(秒),否则不延时
-- 参数:	pItem		回程符这个对象
function tbHuichengfu:DelayTime(pItem, pPlayer)
	if (me.nFightState == 0) then
		self:TransPlayer(pItem.dwId, pPlayer.nId);
		return;
	end
	local tbEvent = {
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
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
	GeneralProcess:StartProcess("正在回城...", self.nTime * Env.GAME_FPS, {self.TransPlayer, self, pItem.dwId, pPlayer.nId}, nil, tbEvent);
end

-- 功能:	延时之后处理的问题
-- 参数:	pItem		回程符这个对象
function tbHuichengfu:TransPlayer(nItemId, nPlayerId)
	local pItem = KItem.GetObjById(nItemId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	if (not pItem) then
		pPlayer.Msg("回城符不存在！");
		return;
	end
	local nMapId, nReliveId		= pPlayer.GetRevivePos();
	local nReliveX, nReliveY = RevID2WXY(nMapId, nReliveId);	-- 得到trip点的地图Id(nMapId),以及它的坐标(nReliveX, nReliveY)

	local nCanUse = KItem.CheckLimitUse(pPlayer.nMapId, "chuansong");
	if (not nCanUse or nCanUse == 0) then
		pPlayer.Msg("该道具禁止在本地图使用")
		return;
	end
	
	local nRet, szMsg = Map:CheckTagServerPlayerCount(nMapId)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return;
	end
	-- 不是无限回城符,删除
	if (not self.nWuxianhuichengfuId[pItem.nParticular]) then
		if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			pPlayer.Msg("删除回程符失败！");
			return;
		end
	end
	-- DO ZouYing
	--if (me.GetMapId() == nMapId) then		-- UNDONE: zbl	临时处理,除以32
	--	SetPos(nReliveX / 32, nReliveY / 32);
	--else
	pPlayer.NewWorld(nMapId, nReliveX / 32, nReliveY / 32);
end
