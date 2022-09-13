-- 文件名  : castlefight_delete.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-11 16:29:10
-- 描述    : 

local tbItem = Item:GetClass("castlefight_delete");
function tbItem:OnUse(nNpcId)
	self:OnUseEx(nNpcId);
end

function tbItem:OnUseEx(nNpcId, nSure, nProcess)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		me.Msg("Không có mục tiêu, không thể sử dụng!")
		return 0;
	end	
	
	nSure = nSure or 1;
	nProcess = nProcess or 0;
	local tbMission =  CastleFight:GetPlayerTempTable(me).tbMission;
	if not tbMission then
		return;
	end	

	if tbMission:IsPlaying() == 0 then
		me.Msg("Chưa thể sử dụng!")
		return 0;
	end

	--分阶段嘛？
	--if tbMission.nStateJour > 3 then
	--	me.Msg("时机不对，现在不能使用这个！");
	--	return 0;
	--end


	local nCamp  = CastleFight:GetPlayerTempTable(me).nCamp;	
	local tbCamp = tbMission:GetCampInfo(nCamp);
	
	local nRes  = tbCamp:CanDelBuilding(me, pNpc);
	if nRes == 0 then
		return;
	end

	local nMapId, nX, nY = pNpc.GetWorldPos();
	local _, nX2, nY2 = me.GetWorldPos();
	local nDistance = (nX2 - nX) * (nX2 - nX) + (nY2 - nY) * (nY2 - nY);
	if nDistance > 30 then
		CastleFight:SendMsgAndBroadMsg(me, "Đứng gần để sử dụng.");
		return;
	end

	
	if nSure == 0 then
	--	Dialog:OnOk("升级",{self.OnUseEx,self,nNpcId,1,nProcess});
		return;
	end
	
	if nProcess == 1 then
		tbCamp:DelBuilding(pNpc, 1);
		return;
	end
	
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
	GeneralProcess:StartProcess("Đang phá hủy...", 1 * Env.GAME_FPS, {self.OnUseEx, self,nNpcId,1,1}, nil, tbBreakEvent);
	return;
end

function tbItem:OnClientUse()
	local pNpc = me.GetSelectNpc();
	if not pNpc then
		return 0;
	end
	return pNpc.dwId;
end
