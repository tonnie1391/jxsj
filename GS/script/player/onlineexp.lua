-- 文件名　：onlineexp.lua
-- 创建者　：zhouchenfei
-- 创建时间：2009-05-11 10:01:14
-- 文件说明：在线托管相关

local tbOnlineExp		= Player.tbOnlineExp or {};	-- 支持重载
Player.tbOnlineExp		= tbOnlineExp;

tbOnlineExp.TIME_GIVEEXP				= 5;			-- 在线托管给予经验的时间间隔，和给予经验的时间
tbOnlineExp.TIME_AUTOOPENONLINE			= 60 * 30;		-- 在线不操作自动进入在线托管的时间
tbOnlineExp.TIME_CHECKONLINESTATE		= 30;			-- 客户端进入游戏后判断玩家行动状态的时间，2秒
tbOnlineExp.ONLINESTATE_ID				= 1296;
tbOnlineExp.ONLINESTATE_TIME			= 60 * 60 * 24 * 100; -- 故意设的很大 
tbOnlineExp.HEAD_STATE_SKILLID			= 349;
tbOnlineExp.IS_OPEN						= EventManager.IVER_bOpenOnLineExp;

tbOnlineExp.tbAllowOnlineMap			= {				-- 能够在线托管的地图
		1, 2, 3, 4, 5, 6, 7, 8, 23, 24, 25, 26, 27, 28, 29, 
		1401, 1402, 1403, 1404, 1405, 1406, 1407, 1408, 1409, 1410, 1411, 1412,
		1437, 1438, 1439, 1440, 1441, 1442, 1443, 1444, 1445, 1446, 1447, 1448,
	};

function tbOnlineExp:GetTempOnlineExp(pPlayer)
	local tbTemp = Player:GetPlayerTempTable(pPlayer).tbOnlineExp;
	if (not tbTemp) then
		tbTemp = {};
		tbTemp.nOnlineX							= -1;
		tbTemp.nOnlineY							= -1;
		tbTemp.nOnlineMapId						= -1;
		tbTemp.nLastStandTime					= 0;
		tbTemp.nTimerId_CheckOnlineState		= 0;
		tbTemp.nOnlineExpState					= 0;
		tbTemp.nLogExp							= 0;
		Player:GetPlayerTempTable(pPlayer).tbOnlineExp 	= tbTemp;
	end
	return tbTemp;
end

function tbOnlineExp:SetOnlineState(nState, pPlayer)
	if self.IS_OPEN ~= 1 then 
		return 0;
	end
	if (not pPlayer) then
		pPlayer = me;
	end
	local tbTemp = self:GetTempOnlineExp(pPlayer);
	tbTemp.nOnlineExpState = nState;
	if (MODULE_GAMESERVER) then
		pPlayer.CallClientScript({"Player.tbOnlineExp:SetOnlineState", nState});
	end
end

function tbOnlineExp:GetOnlineState(pPlayer)
	if (not pPlayer) then
		pPlayer = me;
	end
	local tbTemp = self:GetTempOnlineExp(pPlayer);
	return tbTemp.nOnlineExpState;
end

function tbOnlineExp:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Player", "OnlineExp", unpack(arg));
	end
	if (MODULE_GAMECLIENT) then
		Dbg:Output("Player", "OnlineExp", unpack(arg));
	end
end

if (MODULE_GAMECLIENT) then

function tbOnlineExp:UpdateState(nFlag)
	if (nFlag) then
		if (1 == nFlag) then
			me.AddSkillEffect(self.HEAD_STATE_SKILLID);
		elseif (2 == nFlag) then
			me.RemoveSkillEffect(self.HEAD_STATE_SKILLID);
		end
	end
	local tbTemp 			= self:GetTempOnlineExp(me);
	local nMapId, nX, nY	= me.GetWorldPos();
	tbTemp.nOnlineMapId		= nMapId;
	tbTemp.nOnlineX			= nX;
	tbTemp.nOnlineY			= nY;
	CoreEventNotify(UiNotify.emCOREEVENT_UPDATEONLINEEXPSTATE);
end

-- 五分钟进入状态的判断，开启这个timer
function tbOnlineExp:OnStartCheckOnlineExpState()
	if self.IS_OPEN ~= 1 then 
		return 0;
	end	
	local tbTemp = self:GetTempOnlineExp(me);
	tbTemp.nOnlineMapId, tbTemp.nOnlineX, tbTemp.nOnlineY	= me.GetWorldPos();
	tbTemp.nLastStandTime									= GetTime();
	tbTemp.nTimerId_CheckOnlineState						= Ui.tbLogic.tbTimer:Register(self.TIME_CHECKONLINESTATE * Env.GAME_FPS, self.OnTimer_CheckOnlineExpState, self);
end

-- 五分钟进入状态的判断，开启这个timer
function tbOnlineExp:OnEndCheckOnlineExpState()
	local tbTemp = self:GetTempOnlineExp(me);
	tbTemp.nOnlineMapId, tbTemp.nOnlineX, tbTemp.nOnlineY	= 0, 0, 0;	
	tbTemp.nLastStandTime	= 0;
	if (tbTemp.nTimerId_CheckOnlineState and tbTemp.nTimerId_CheckOnlineState > 0) then
		Ui.tbLogic.tbTimer:Close(tbTemp.nTimerId_CheckOnlineState);
	end
	tbTemp.nTimerId_CheckOnlineState	= 0;
end

-- 判断玩家是否能自动进入在线托管状态，条件是五分钟没有移动
function tbOnlineExp:OnTimer_CheckOnlineExpState()
	local tbTemp 			= self:GetTempOnlineExp(me);
	local nMapId, nX, nY	= me.GetWorldPos();
	local nNowTime			= GetTime();
	local nFlag				= self:GetOnlineState(me);

	if (me.nLevel < 20) then
		tbTemp.nLastStandTime = nNowTime;
		return;
	end

	if (nMapId ~= tbTemp.nOnlineMapId or nX ~= tbTemp.nOnlineX or nY ~= tbTemp.nOnlineY) then
		tbTemp.nLastStandTime = nNowTime;
		tbTemp.nOnlineMapId	= nMapId;
		tbTemp.nOnlineX		= nX;
		tbTemp.nOnlineY		= nY;
		if (1 == nFlag) then
			me.CallServerScript({"ApplyUpdateOnlineState", 0});
			me.Msg("Bạn rời khỏi nơi ủy thác ban đầu, thoát ủy thác trên mạng");
		end
		return;
	end

	if (1 == nFlag) then
		return;
	end
	
	if (tbTemp.nLastStandTime == 0) then
		tbTemp.nLastStandTime = nNowTime;
	end
	
	-- 还没有5分钟
	if (nNowTime - tbTemp.nLastStandTime < self.TIME_AUTOOPENONLINE) then
		return;
	end
	--战斗状态不自动托管
	if (1 == me.nFightState) then
		return;
	end
	
	-- 五分钟没动就直接进入在线托管
	AutoAi.Sit();
	me.CallServerScript({"ApplyUpdateOnlineState", 1});
	tbTemp.nLastStandTime = nNowTime;
	return;
end


end

if (MODULE_GAMESERVER) then

function tbOnlineExp:OnApplyUpdateState(nChangerState)
	local nState	= self:GetOnlineState(me);
	if (nChangerState == nState) then
		return;
	end
	
	local nFlag = 0;
	
	if (1 == nChangerState) then
		if self.IS_OPEN ~= 1 then 
			return 0;
		end
		self:OpenOnlineExp();
	else
		self:CloseOnlineExp();
		me.Msg("Thoát ủy thác trên mạng");
	end
end

function tbOnlineExp:OpenOnlineExp()
	if self.IS_OPEN ~= 1 then 
		return 0;
	end	
	local pPlayer	= me;
	local nState	= self:GetOnlineState(pPlayer);
	if (1 == nState) then
		return 0;
	end
	local nFlag, szMsg = self:CheckCanOnline(pPlayer);
	if ( 0 ~= nFlag  ) then
		pPlayer.Msg(szMsg);
		return 0;
	end

	-- 玩家的timerid存在临时table中
	local tbTemp = self:GetTempOnlineExp(pPlayer);
	if (tbTemp.nOnlineExpOpenStateTimer and tbTemp.nOnlineExpOpenStateTimer > 0) then
		Player:CloseTimer(tbTemp.nOnlineExpOpenStateTimer);
	end
	Dialog:SetBattleTimer(me); -- 关闭可能的计时器
	tbTemp.nOnlineExpOpenStateTimer = Player:RegisterTimer(Env.GAME_FPS * self.TIME_GIVEEXP, self.OnTimer_GiveExp, self);

	self:SetOnlineState(1, pPlayer);
	tbTemp.nOnlineMapId, tbTemp.nOnlineX, tbTemp.nOnlineY = pPlayer.GetWorldPos();
	pPlayer.AddSkillState(self.ONLINESTATE_ID, 1, 0, self.ONLINESTATE_TIME * Env.GAME_FPS);

	pPlayer.Msg("Bắt đầu ủy thác trên mạng, nhân vật không thể di chuyển");
	pPlayer.CallClientScript({"Player.tbOnlineExp:UpdateState", 1});
	self:WriteOpenLog(pPlayer);
	return 1;
end

function tbOnlineExp:CloseOnlineExp()
	local pPlayer = me;
	
	local nState	= self:GetOnlineState(pPlayer);
	if (0 == nState) then
		return 0;
	end	
	
	self:SetOnlineState(0, pPlayer);
	Dialog:ShowBattleMsg(pPlayer, 0, 0);

	local tbTemp = self:GetTempOnlineExp(pPlayer);
	if (tbTemp.nOnlineExpOpenStateTimer and tbTemp.nOnlineExpOpenStateTimer > 0) then
		Player:CloseTimer(tbTemp.nOnlineExpOpenStateTimer);
	end

	tbTemp.nOnlineExpOpenStateTimer = 0;
	pPlayer.RemoveSkillState(self.ONLINESTATE_ID);
	pPlayer.CallClientScript({"Player.tbOnlineExp:UpdateState", 2});
	self:WriteCloseLog(pPlayer);
	return 1;
end

function tbOnlineExp:WriteOpenLog(pPlayer)
	local tbTemp = self:GetTempOnlineExp(pPlayer);
	tbTemp.nLogExp = 0;

	local nOfflineTime	= Player.tbOffline:GetTodayRestOfflineTime();
	local szMsg			= "OpenOnlineExp " .. pPlayer.szName .. "restlasttuoguan：" .. nOfflineTime .. ", ";

	for key, tbBaiju in ipairs(Player.tbOffline.BAIJU_DEFINE) do
		local nRestTime = me.GetTask(5, tbBaiju.nTaskId);
		szMsg	= szMsg .. nRestTime .. ",";
	end
	self:WriteLog(pPlayer.szName, szMsg);
end

function tbOnlineExp:WriteCloseLog(pPlayer)
	local tbTemp = self:GetTempOnlineExp(pPlayer);
	local nOfflineTime	= Player.tbOffline:GetTodayRestOfflineTime();
	local szMsg			= "CloseOnlineExp " .. pPlayer.szName .. "restlasttuoguan：" .. nOfflineTime .. ", ";

	szMsg = szMsg .. "addexp: " .. tbTemp.nLogExp .. ", resttime：";

	for key, tbBaiju in ipairs(Player.tbOffline.BAIJU_DEFINE) do
		local nRestTime = me.GetTask(5, tbBaiju.nTaskId);
		szMsg	= szMsg .. nRestTime .. ",";
	end
	
	self:WriteLog(pPlayer.szName, szMsg);	
end

function tbOnlineExp:GiveExpInfo(pPlayer, nExp)
	local tbTemp = self:GetTempOnlineExp(pPlayer);
	tbTemp.nLogExp = tbTemp.nLogExp + nExp;
end

function tbOnlineExp:OnTimer_GiveExp()
	local pPlayer			= me;
	local nMapId, nX, nY	= pPlayer.GetWorldPos();
	local nState			= self:GetOnlineState(pPlayer);
	local tbTemp			= self:GetTempOnlineExp(pPlayer);
	if (1 == nState and (nMapId ~= tbTemp.nOnlineMapId or nX ~= tbTemp.nOnlineX or nY ~= tbTemp.nOnlineY)) then
		pPlayer.Msg("Bạn rời khỏi nơi ủy thác ban đầu, kết thúc ủy thác trên mạng.");
		self:CloseOnlineExp();
		return 0;
	end

	local nFlag, szMsg = self:CheckCanOnline(pPlayer);
	if ( 0 ~= nFlag  ) then
		pPlayer.Msg(szMsg);
		pPlayer.Msg("Thoát ủy thác trên mạng");
		self:CloseOnlineExp();
		return 0;
	end

	nFlag = Player.tbOffline:AddSpecialExp(pPlayer, self.TIME_GIVEEXP, 1);
	if (3 == nFlag) then -- 没有托管补充时间了
		pPlayer.Msg("Thời gian ủy thác còn lại của bạn trong ngày là 0, thoát ủy thác trên mạng");
		self:CloseOnlineExp();
		return 0;
	elseif (2 == nFlag) then -- 没有白驹时间了
		pPlayer.Msg("Thời gian Bạch Câu Hoàn của bạn không đủ, kết thúc ủy thác trên mạng.");
		Dialog:Say("Thời gian Bạch Câu Hoàn của bạn không đủ, kết thúc ủy thác trên mạng. Hãy bổ sung thời gian Bạch Câu Hoàn.");
		self:CloseOnlineExp();
		return 0;		
	end
	
	if (1 ~= nFlag) then
		self:CloseOnlineExp();
		pPlayer.Msg("Thoát ủy thác trên mạng");
		return 0;			
	end	
			
	local szMsg = self:GetOnlineRightInfo();
	Dialog:SendBattleMsg(pPlayer, szMsg);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

function tbOnlineExp:GetOnlineRightInfo()
	local szMsg = "<color=gold>Ủy thác trên mạng<color>\n";
	
	local nOfflineTime = Player.tbOffline:GetTodayRestOfflineTime();
	szMsg	= szMsg .. "<color=green>Thời gian ủy thác trong ngày:<color>\n" .. "<color=yellow>" .. self:GetTimeDes(nOfflineTime) .. "<color>\n\n";

	for key, tbBaiju in ipairs(Player.tbOffline.BAIJU_DEFINE) do
		if (tbBaiju.nShowFlag == 1) then
			local nRestTime = me.GetTask(5, tbBaiju.nTaskId);
			szMsg	= szMsg .. "<color=green>Bạch Câu Hoàn <color=white>" .. Lib:StrTrim(tbBaiju.szName, " ") .. "<color> còn lại:<color>\n<color=yellow>" .. self:GetTimeDes(nRestTime) .. "<color>\n\n";
		end
	end
	szMsg = szMsg .. "Giao diện hệ thống có thể kết thúc ủy thác trên mạng";

	return szMsg;
end

function tbOnlineExp:GetTimeDes(nTime)
	local szOrg		= Lib:TimeFullDescEx(nTime);
	local nLen		= string.len(szOrg);
	local nSubLen	= 24 - nLen;
	for i=1, nSubLen do
		szOrg = " " .. szOrg;
	end	
	return szOrg;
end

function tbOnlineExp:CheckCanOnline(pPlayer)	
	if (pPlayer.nLevel < 20) then
		return 2, "Từ cấp 20 trở lên mới được mở ủy thác trên mạng.";
	end
	
	-- 满级满经验
	if (Player.tbOffline:CheckIsFullLevel(pPlayer) == 1) then
		return 3, "Kinh nghiệm đã đầy, không cần ủy thác.";
	end
	
	local nMapId	= pPlayer.nMapId;
	local nMapFlag	= 0;	
	for _, nId in pairs(self.tbAllowOnlineMap) do
		if (nMapId == nId) then
			nMapFlag = 1;
			break;
		end
	end
	if (0 == nMapFlag) then
		return 1, "Chỉ được mở ủy thác trên mạng tại thành thị, Tân Thủ Thôn hoặc nơi báo danh Liên Đấu.";
	end
	
	if (pPlayer.IsOfflineLive() == 1) then
		return 4, "";
	end
	return 0;
end

function tbOnlineExp:ClearOnlineExpState(pPlayer)
	self:SetOnlineState(0, pPlayer);
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
	pPlayer.RemoveSkillState(self.ONLINESTATE_ID);
	pPlayer.CallClientScript({"Player.tbOnlineExp:UpdateState", 2});
end

end
