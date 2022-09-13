-- 文件名　：xiakestone.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-15 12:10:10
-- 描  述  ：

Require("\\script\\task\\xiakedaily\\xiakedaily_def.lua")

local tbClass = Npc:GetClass("xiakestone");

function tbClass:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local tbNpcData = him.GetTempTable("Task");
	if not tbNpcData.nType then
		return;
	end
	local pOwer = KPlayer.GetPlayerObjById(tbNpcData.nRefreshPlayerId);
	if (not pOwer) then
		return;
	end
	
	if XiakeDaily:CheckHasTask(me, 1, tbNpcData.nType) ~= 1 then
		Dialog:SendInfoBoardMsg(me, "你身上没有未完成的侠客军营任务，无法开启");
		return;
	end
	
	local nTeamId = pOwer.nTeamId;
	
	if (me.nTeamId == 0) then
		local szMsg = "只有组队才能开启！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	
	if (me.nTeamId ~= nTeamId) then
		local szMsg = "只有<color=yellow>"..pOwer.szName.."<color>所在的队伍才能开启！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	
	--打断开启事件
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	--开启宝箱
	GeneralProcess:StartProcess("开启任务", 5 * 18, {self.OnCheckOpen, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);
end

function tbClass:OnCheckOpen(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc or pNpc.nIndex == 0) then
		return;
	end
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	local tbNpcData = pNpc.GetTempTable("Task"); 
	assert(tbNpcData);
	
	local pOwer = KPlayer.GetPlayerObjById(tbNpcData.nRefreshPlayerId);
	if (not pOwer) then
		return;
	end
	
	if pPlayer.nTeamId == 0 or pPlayer.nTeamId ~= pOwer.nTeamId then
		return;
	end
	
	if XiakeDaily:CheckHasTask(me, 1, tbNpcData.nType) ~= 1 then
		Dialog:SendInfoBoardMsg(me, "Mở thất bại");
		return;
	end
	self:AddBoss(pNpc.dwId);
end

function tbClass:AddBoss(nNpcId, tbInstancing)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end;
	
	local tbNpcData = pNpc.GetTempTable("Task"); 
	local nMapId = tbNpcData.nRefreshMapId;
	local nPosX = tbNpcData.nRefreshNpcPosX;
	local nPosY = tbNpcData.nRefreshNpcPosY;
	local nType = tbNpcData.nType;
	pNpc.Delete();
	if nType == 4 then -- 鄂伦河源是基于躺尸的，以前的机制不好用了，单独处理
		Npc:GetClass("xiake_bailu_dlg"):StarChallenge(nMapId, nPosX, nPosY);
		return;
	end
	local pTempNpc = KNpc.Add2(2976, 10, -1, nMapId, nPosX, nPosY);
	if pTempNpc then
		Timer:Register(5 * Env.GAME_FPS, self.CallBoss, self, nType, pTempNpc.dwId);
		local tbPlayList, _ = KPlayer.GetMapPlayer(nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Setting:SetGlobalObj(teammate);
			if nType == 1 then
				TaskAct:Talk("<npc=7312>：“你以为结束了吗？不，这只是刚刚开始。”");
			elseif nType == 2 then
				TaskAct:Talk("<npc=7315>：“你们终于来了，我喜欢你们，你们将是我最好的试验品。”");
			elseif nType == 3 then
				TaskAct:Talk("<npc=7317>：“你们来的比我想象的早很多，不过你们也只能走到这里了。”");
			end
			Setting:RestoreGlobalObj();
		end
	end
end

function tbClass:CallBoss(nType, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end;
	local nMapId, nPosX, nPosY	= pNpc.GetWorldPos();
	pNpc.Delete();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nMapId);
	if not tbInstancing then
		return 0;
	end
	if nType == 1 then
		local pNpcBaiWuWei = KNpc.Add2(7312, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
		if pNpcBaiWuWei then
			Task.ArmyCamp:StartTrigger(pNpcBaiWuWei.dwId, 4);
			Task.ArmyCamp:StartTrigger(pNpcBaiWuWei.dwId, 5);
			Task.ArmyCamp:StartTrigger(pNpcBaiWuWei.dwId, 6);
		end
	elseif nType == 2 then
		local pNpcOuYangZiYan = KNpc.Add2(7315, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	elseif nType == 3 then
		local nNpcDaLiShen = KNpc.Add2(7317, tbInstancing.nNpcLevel, -1, nMapId, nPosX, nPosY);
	end
	return 0;
end
