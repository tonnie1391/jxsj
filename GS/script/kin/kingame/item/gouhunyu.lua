----------------------------------------------------------------
-- 家族BOSS 召唤令牌(勾魂玉)
-- zhengyuhua
----------------------------------------------------------------

local tbLingPai = Item:GetClass("gouhunyu");

tbLingPai.USE_RANDE	 	= 30;		-- 使用范围
tbLingPai.TEXIAO_TIME	= 6;		-- 特效持续时间
tbLingPai.CALLTIME		= 5;		-- 召唤延迟
tbLingPai.CALL_BOSS_POS	= {2029,2769}
tbLingPai.CALL_BOSS_POS_NEW = {59008/32,103424/32}; --新家族关卡勾魂玉地点
tbLingPai.EFFECT_NPC	= 2976		-- 特效NPC模板
tbLingPai.BOSS_LIST 	= 
{
	[1] =				-- 初级BOSS列表 
	{
		{2969,	55,	2},
		{2970,	55,	5},
		{2971,	55,	4},
		{2972,	55,	5},
		{2973,	55,	1},
		{2974,	55,	3},
	},
	[2] = 				-- 中级BOSS列表
	{
		{2978,	75,	1},
		{2979,	75,	2},
		{2980,	75,	3},
		{2981,	75,	4},
		{2982,	75,	5},
	}
}

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

function tbLingPai:CanMapUse(nMapTemplateId)
	if nMapTemplateId == KinGame.MAP_TEMPLATE_ID or nMapTemplateId == KinGame2.MAP_TEMPLATE_ID then
		return 1;
	end
	return 0;
end

function tbLingPai:CanPosUse(x,y)
	if math.abs(x - self.CALL_BOSS_POS[1]) + math.abs(y - self.CALL_BOSS_POS[2]) <= self.USE_RANDE or 
		math.abs(x - self.CALL_BOSS_POS_NEW[1]) + math.abs(y - self.CALL_BOSS_POS_NEW[2]) <= self.USE_RANDE then
		return 1;
	end
	return 0;
end


function tbLingPai:OnUse()
	local nBindKinId = it.GetGenInfo(1, 0);
	nBindKinId = nBindKinId * 2 + it.GetGenInfo(2, 0);
	local nKinId = me.GetKinMember(1);
	if nBindKinId ~= nKinId then
		local pBindKin = KKin.GetKin(nBindKinId);
		if pBindKin then
			me.Msg(string.format("该物品已经和家族“%s”绑定，你的家族无法使用！", pBindKin.GetName()));
		else
			me.Msg("该物品已经和其他家族绑定，你的家族无法使用！")
		end
		return 0;
	end
	local nMapId, nX, nY 	= me.GetWorldPos()
	local nMapIndex 		= SubWorldID2Idx(nMapId);
	local nMapTemplateId	= SubWorldIdx2MapCopy(nMapIndex);
	if self:CanMapUse(nMapTemplateId) ~= 1 then
		me.Msg("只能在家族关卡内使用");
		return 0;
	end
	if self:CanPosUse(nX,nY) ~= 1 then
		me.Msg("离开召唤地点太远，无法进行召唤！");
		return 0;
	end
	GeneralProcess:StartProcess("召唤中...", 1 * Env.GAME_FPS, {self.EndProcess, self, it.dwId, nMapId,nX,nY}, nil, tbEvent);
	return 0;
end

-- 进度条读完
function tbLingPai:EndProcess(nItemId, nMapId,nPosX,nPosY)
	local nRoom, nX, nY = me.FindItemId(nItemId);
	if (not nRoom) or (not nX) or (not nY) then
		return 0;
	end
	local pItem = me.GetItem(nRoom, nX, nY);
	if not pItem then
		return 0;
	end
	local nItemLevel = pItem.nLevel;
	if me.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1 then
		return 0;
	end
	-- 特效NPC
	local pNpc = KNpc.Add2(self.EFFECT_NPC, 10, -1, nMapId, nPosX,nPosY);
	local nKinId = me.GetKinMember()
	Timer:Register(self.CALLTIME * Env.GAME_FPS, self.CallKinBoss, self, nKinId, nItemLevel, nMapId,0,nPosX,nPosY)
	Timer:Register(self.TEXIAO_TIME * Env.GAME_FPS, self.DelEffect, self, pNpc.dwId)
end

function tbLingPai:CallKinBoss(nKinId, nItemLevel, nMapId, nCallTime,nX,nY)
	local nCount = #self.BOSS_LIST[nItemLevel];
	local nRandom = Random(nCount) + 1;
	local tbBoss = self.BOSS_LIST[nItemLevel][nRandom];
	local cKin = KKin.GetKin(nKinId);
	
	if not tbBoss then
		-- 随机BOSS出问题了？
		print("Kin Boss is nil? Call again!", "nRandom ="..nRandom);
		if not nCallTime then
			nCallTime = 0;
		end
		nCallTime = nCallTime + 1;
		if nCallTime >= 5 then	-- 连Call 5次失败就不再重新CallBoss了
			print("Call Kin Boss Failed 5 times", cKin and cKin.GetName() or "无家族")
			return 0;
		end
		return self:CallKinBoss(nKinId, nItemLevel, nMapId, nCallTime,nX,nY);
	end
	
	-- 召唤BOSS
	local pNpc = KNpc.Add2(tbBoss[1], tbBoss[2], tbBoss[3], nMapId, nX, nY, 0, 1);
	if cKin and pNpc then
		KDialog.MsgToGlobal(string.format("<color=green>%s<color>家族在家族副本中召唤出了<color=white>%s<color>",cKin.GetName(), pNpc.szName));
		-- KStatLog.ModifyAdd("mixstat", "家族Boss\t召唤\t"..pNpc.szName, "总量", 1);
	end
	return 0;
end

function tbLingPai:DelEffect(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then		-- 删除召唤特效NPC
		pNpc.Delete();
	end
	return 0;
end


	