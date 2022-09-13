-------------------------------------------------------
-- 文件名　：xkland_map.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-04-22 11:39:09
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

-- map
local tbMap = Xkland.Map or {};
Xkland.Map = tbMap;

function tbMap:OnEnter(szParam)
	if Xkland:GM_EnterMap() == 1 then
		if Xkland.tbMissionGame and Xkland.tbMissionGame:IsOpen()~= 0 then
			local nRemainTime = Xkland.tbMissionGame:GetRemainTime();
			Xkland.tbMissionGame:OpenRightUI(me, Xkland.tbMissionGame.szRightTitle, nRemainTime);
		end
		return 0;
	end
	local nIndex = Xkland:GetGroupIndex(me);
	if nIndex <= 0 then
		Transfer:NewWorld2GlobalMap(me);
		me.SetLogoutRV(1);
		return 0;
	end
	if Xkland.tbMissionGame and Xkland.tbMissionGame:IsOpen()~= 0 then
		Xkland.tbMissionGame:JoinPlayer(me, nIndex);
		Xkland:AddMapPlayerCount_GA(me.nMapId, 1);
		me.SetLogoutRV(1);
	else
		Transfer:NewWorld2GlobalMap(me);
	end
end

function tbMap:OnLeave(szParam)
	if Xkland:GM_LeaveMap() == 1 then
		Dialog:ShowBattleMsg(me, 0, 0);
		return 0;
	end
	local nIndex = Xkland:GetGroupIndex(me);
	if Xkland.tbMissionGame and Xkland.tbMissionGame:IsOpen()~= 0 then
		Xkland.tbMissionGame:KickPlayer(me, nIndex);
		Xkland:AddMapPlayerCount_GA(me.nMapId, -1);
		me.SetLogoutRV(0);
	end
end

function Xkland:LinkMap(nMapId)
	local tbMap = Map:GetClass(nMapId);
	for szFunMap, _ in pairs(self.Map) do
		tbMap[szFunMap] = self.Map[szFunMap];
	end
end
-- end

-- map npc
local tbMapNpc = Xkland.MapNpc or {};
Xkland.MapNpc = tbMapNpc;

function Xkland:LinkNpc(nMapId)
	for szNpcClass, tbInfo in pairs(Xkland.NPC_CLASS) do
		if tbInfo.TransPos[nMapId] then
			local tbNpc = Npc:GetClass(szNpcClass);
			tbNpc.szNpcClass = szNpcClass;
			tbNpc.nProccess = tbInfo.Proccess;
			tbNpc.nFightState = tbInfo.FightState
			tbNpc.nSuperTime = tbInfo.SuperTime
			tbNpc.FnCheck = function(tbBase)
				return self.MapNpc[tbInfo.Check](self.MapNpc, szNpcClass, tbBase);
			end
			for szFunNpc, _ in pairs(self.MapNpc) do
				tbNpc[szFunNpc] = self.MapNpc[szFunNpc];
			end
		end
	end
end

function tbMapNpc:OnDialog()
	
	if me.GetCamp() == 6 then
		local tbInfo = Xkland.NPC_CLASS[self.szNpcClass];
		if tbInfo then
			local tbPos = tbInfo.TransPos[me.nMapId];
			me.NewWorld(unpack(tbPos));
		end
		return 0;
	end
	
	-- 判断条件
	if self.FnCheck(self) ~= 1 then
		return 0;
	end
	
	-- 进度条与否
	if self.nProccess > 0 then
		local tbBreakEvent = 
		{
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_SIT,
			Player.ProcessBreakEvent.emEVENT_RIDE,
			Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
			Player.ProcessBreakEvent.emEVENT_ATTACKED,
			Player.ProcessBreakEvent.emEVENT_DEATH,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_REVIVE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		}
		GeneralProcess:StartProcess("Đang truyền tống", 3 * Env.GAME_FPS, {self.OnTransPos, self}, nil, tbBreakEvent);
	else
		self:OnTransPos();
	end
end

function tbMapNpc:OnTransPos()

	local tbInfo = Xkland.NPC_CLASS[self.szNpcClass];
	if tbInfo then
		local tbPos = tbInfo.TransPos[me.nMapId];
		if me.nMapId ~= tbPos[1] and Xkland:GetMapPlayerCount(tbPos[1]) > Xkland.MAX_MAP_PLAYER then
			Dialog:Say("对不起，前往地图人数已满，请稍后再试。");
			return 0;
		end
		local nOk, szError = Map:CheckTagServerPlayerCount(tbPos[1]);
		if nOk ~= 1 then
			Dialog:Say(szError);
			return 0;
		end
		Player:AddProtectedState(me, Xkland.SUPER_TIME);
		me.SetFightState(self.nFightState);
		me.NewWorld(unpack(tbPos));
	end
end

-- 复活点出去检测
function tbMapNpc:Check_RevivalOut(szNpcClass, tbBase, nSure)
	
	-- 判断披风
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < Xkland.MANTLE_LEVEL then
		Dialog:Say("只有佩戴雏凤或以上披风的侠士才能进入战场。");
		return 0;		
	end
	
	-- 等待期
	if Xkland:GetWarState() ~= 2 then
		Dialog:Say("铁浮城之战尚未打响，请在复活点准备。");
		return 0;
	end
	
	-- 出复活点许可证
	local nPassport = me.GetTask(Xkland.TASK_GID, Xkland.TASK_PASSPORT);
	if nPassport ~= 1 then
		
		-- 判断跨服绑银
		local nGroupIndex = Xkland:GetGroupIndex(me);
		local nCostMoney = Xkland.MONEY_COST[pItem.nLevel].nCost;
		local nRevival = GetPlayerSportTask(me.nId, Xkland.GA_TASK_GID, Xkland.GA_TASK_WAR_REVIVAL) or 0;
		
		local tbWar = Xkland.tbWarBuffer[nGroupIndex];
		if not tbWar then
			return 0;
		end
		
		if not nSure then
			local szMsg = "";
			if tbWar.tbFreeRevival and tbWar.tbFreeRevival[pItem.nLevel] then
				if nCostMoney <= tbWar.nRevivalMoney then
					local nTimes = tbWar.tbFreeRevival[pItem.nLevel] - nRevival;
					if nTimes > 0 then
						szMsg = string.format("铁浮城不可随便出入，你还有<color=yellow>%s次<color>免费征战次数，此次出战将消耗1次，你确定要出去战斗吗？", nTimes);
					else
						szMsg = string.format("铁浮城不可随便出入，你已没有免费征战次数。你必须缴纳<color=yellow>%s两<color>跨服绑银，你确定要出去战斗吗？", nCostMoney);
					end
				else
					szMsg = string.format("铁浮城不可随便出入，本军团的军需库绑银不足！你必须缴纳<color=yellow>%s两<color>跨服绑银，你确定要出去战斗吗？", nCostMoney);
				end
			else
				szMsg = string.format("铁浮城不可随便出入，你必须缴纳<color=gold>%s两<color>跨服绑银，你确定要出去战斗吗？", nCostMoney);
			end
				
			local tbOpt = 
			{
				{"我要进入", self.Check_RevivalOut, self, szNpcClass, tbBase, 1},
				{"Để ta suy nghĩ thêm"},
			};
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
		
		if tbWar.tbFreeRevival and tbWar.tbFreeRevival[pItem.nLevel] and nRevival < tbWar.tbFreeRevival[pItem.nLevel] and nCostMoney <= tbWar.nRevivalMoney then
			
			me.SetTask(Xkland.TASK_GID, Xkland.TASK_PASSPORT, 1);
			SetPlayerSportTask(me.nId, Xkland.GA_TASK_GID, Xkland.GA_TASK_WAR_REVIVAL, nRevival + 1);
			GCExcute({"Xkland:AddFreeRevival_GA", nGroupIndex, -nCostMoney});
			me.Msg(string.format("本军团的军需库被扣除了<color=gold>%s两<color>绑银。", nCostMoney));
			
			tbBase:OnDialog();
		else	
			if me.GetBindMoney() < nCostMoney then
				Dialog:Say("你身上的跨服绑银不足，无法进入战场。");
				return 0;
			end
			
			me.CostBindMoney(nCostMoney);		
			me.SetTask(Xkland.TASK_GID, Xkland.TASK_PASSPORT, 1);
			me.Msg(string.format("你被扣除了<color=gold>%s两<color>跨服绑银。", nCostMoney));
			
			-- log
			Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("扣除跨服绑银：%s", nCostMoney));
			
			tbBase:OnDialog();
		end
	end
	
	me.Msg("须知：城战凶险，此去需披风保护，各地点披风最低要求：<color=orange>外围-雏凤、内层-潜龙、王座-至尊。<color>");
	
	return 1;
end

-- 复活点进入检测
function tbMapNpc:Check_RevivalIn(szNpcClass)
	
	local nGroupIndex = Xkland:GetGroupIndex(me);
	local tbInfo = Xkland.NPC_CLASS[szNpcClass];
	local tbPos = tbInfo.TransPos[me.nMapId];
	
	if Xkland:GetSession() == 1 then
--		local tbTmpPos = Xkland.REVIVAL_POS_INDEX[nGroupIndex];
--		if Lib:Val2Str(tbTmpPos) == Lib:Val2Str(tbPos) then
			return 1;
--		end
	else
		for nIndex, tbTmpPos in pairs(Xkland.REVIVAL_POS_WAR[nGroupIndex]) do
			if Lib:Val2Str(tbTmpPos) == Lib:Val2Str(tbPos) then
				return 1;
			end
		end
	end
	
	return 0;
end

-- 默认检测
function tbMapNpc:Check_Default(szNpcClass)
	return 1;
end

-- 复活点进入检测
function tbMapNpc:Check_RevivalSpecIn(szNpcClass)
	
	if Xkland:GetSession() == 1 then
		return 0;
	end

	local nGroupIndex = Xkland:GetGroupIndex(me);
	local nRevivalOwner = Xkland:GetRevivalOwner(me.nMapId);
	
	if nRevivalOwner == 0 or nRevivalOwner ~= nGroupIndex then
		return 0;
	end
	
	return 1;
end

-- 进入2层检测
function tbMapNpc:Check_Floor_2(szNpcClass)
	
	-- 判断披风
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < 8 then
		Dialog:Say("只有佩戴潜龙或以上披风的玩家才能进入内城。");
		return 0;		
	end
	
	return 1;
end

-- 进入3层检测
function tbMapNpc:Check_Floor_3(szNpcClass)
	
	-- 判断披风
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < 9 then
		Dialog:Say("只有佩戴无双或至尊披风的玩家才能进入王座。");
		return 0;		
	end
	
	return 1;
end

--for _, nMapId in pairs(Xkland.MAP_LIST) do
--	Xkland:LinkNpc(nMapId);
--	Xkland:LinkMap(nMapId);
--end