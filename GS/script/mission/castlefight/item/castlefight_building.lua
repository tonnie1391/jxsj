-- 文件名  : castlefight_building.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-11 15:00:22
-- 描述    : 建筑道具

local tbItem = Item:GetClass("castlefight_building");

function tbItem:OnUse()
	self:OnUseEx(it.GetExtParam(1));
end

function tbItem:OnUseEx(nExtParam,nSure,nProcess)
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

	local nCamp  = CastleFight:GetPlayerTempTable(me).nCamp;	
	local tbCamp = tbMission:GetCampInfo(nCamp);
	
	local nPos  = tbCamp:CanBuildBuilding(me, nExtParam);
	if nPos == 0 then
		return;
	end
	
	if nSure == 0 then
	--	Dialog:OnOk("建造",{self.OnUseEx,self,nExtParam,1,nProcess});
		return;
	end
	
	if nProcess == 1 or CastleFight.NPC_TEMPLATE[nExtParam].nProductCD == 0 then
		tbCamp:BuildBuilding(me, nExtParam);
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
	GeneralProcess:StartProcess("Đang kiến tạo...", CastleFight.NPC_TEMPLATE[nExtParam].nProductCD * Env.GAME_FPS, {self.OnUseEx, self,nExtParam,1,1}, nil, tbBreakEvent);

	return;
end

function tbItem:InitGenInfo()
	it.SetTimeOut(0, GetTime() + CastleFight.ITEM_TIMEOUT);
	return { };
end