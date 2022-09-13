-- 文件名　：taoyuanrukou.lua
-- 创建者　：xiewen
-- 创建时间：2008-12-10 19:27:37


-------------- 定义特定地图回调 ---------------
local tbMap = Map:GetClass(1497); -- 地图Id
local tbDeathEventId = {};
local tbPrisonMap = {1497, 1498, 1499, 1500, 1501, 1502, 1503}
local nCurrentPrisonId = nil;

-- 定义玩家进入事件
function tbMap:OnEnter(szParam)
	me.Msg("欢迎来到桃源入口。");	
	self:RegisterDeathHandler();	
	--BlackSky:SimpleTalk(me, "欢迎来到剑侠世界的隐藏关卡入口，只要打败这里的桃源守卫，你就可以开启通向桃源的入口，获得无穷的宝藏。");
end;

-- 定义玩家离开事件
function tbMap:OnLeave(szParam)
	self:UnRegisterDeathHandler();
	if Player:CanLeaveTaoyuan(me) == 0 then
		me.Msg("你离开了桃源入口！");
	end
	--BlackSky:GiveMeBright(me)
end

function tbMap:RegisterDeathHandler()
	if not tbDeathEventId[me.nId] then
		tbDeathEventId[me.nId] = PlayerEvent:Register("OnDeath", self.OnDeathRevive, self);
	end
end

function tbMap:UnRegisterDeathHandler()
	if tbDeathEventId[me.nId] then
		PlayerEvent:UnRegister("OnDeath", tbDeathEventId[me.nId]);
		tbDeathEventId[me.nId] = nil;
	end
end

function tbMap:OnDeathRevive()
	if me.nMapId == nCurrentPrisonId then
		-- 马上原地复活
		me.ReviveImmediately(1);
		me.NewWorld(nCurrentPrisonId, 1628, 3200);
	end
end

function tbMap:Init()
	for i, nMapId in pairs(tbPrisonMap) do
		if IsMapLoaded(nMapId) == 1 then
			nCurrentPrisonId = nMapId;
			break;
		end
	end
	--14台服务器的时候，（8-14台）不能封进桃园
	if not nCurrentPrisonId then
		nCurrentPrisonId = tbPrisonMap[MathRandom(#tbPrisonMap)];
	end
end

function tbMap:OnPlayerLogin(bExchangeServer)
	if bExchangeServer == 1 then
		return
	end
	if me.GetArrestTime() == 0 then
		if me.nMapId == nCurrentPrisonId then
			Timer:Register(Env.GAME_FPS * 2, self.OnReleasePlayer, self, me.nId) -- 保证传送进度条出现
		end
		return
	end
	me.NewWorld(nCurrentPrisonId, 1628, 3200)
	if me.nMapId ~= nCurrentPrisonId then
		print("[taoyuanrukou]	抓入天牢失败，踢出玩家["..me.szName.."]。")
		me.KickOut()
		return
	end
	local nJailTerm = me.GetJailTerm()
	if nJailTerm > 0 then
		local nTimeRemain = nJailTerm + me.GetArrestTime() - GetTime()
		if nTimeRemain <= 0 then
			nTimeRemain = 2; -- 保证传送进度条出现
		end
		Timer:Register(Env.GAME_FPS * nTimeRemain, self.OnReleasePlayer, self, me.nId)
	end
end

-- 定时释放玩家
function tbMap:OnReleasePlayer(nId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if not pPlayer or pPlayer.nMapId ~= nCurrentPrisonId then
		return 0;
	end
	if Player:CanLeaveTaoyuan(pPlayer) == 1 then
		Player:SetFree(pPlayer);
	else
		pPlayer.Msg("谁批准你出来的，乖乖回去坐好。");
		return;
	end
	
	return 0;
end

for _, nMapId in pairs(tbPrisonMap) do
	local tbDestMap = Map:GetClass(nMapId);
	for szFnc in pairs(tbMap) do			-- 复制函数
		tbDestMap[szFnc] = tbMap[szFnc];
	end
end

ServerEvent:RegisterServerStartFunc(tbMap.Init, tbMap);
PlayerEvent:RegisterGlobal("OnLogin", tbMap.OnPlayerLogin, tbMap);
