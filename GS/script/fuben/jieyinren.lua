-- 文件名　：jieyinren.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-7
-- 描  述  ：
local tbNpc = Npc:GetClass("dataosha_city1");

function tbNpc:OnDialog()
	local tbOpt = {};
	local szMsg = "Đến đây và giải đố! Rất nhiều thứ hay ho!";	
	tbOpt = {
				{"Đăng ký tham gia", self.Apply, self},
				{"Theo đội trưởng", self.OnEnter, self, me.nId},
				--{"申请家族探险",self.ApplyKinTong, self, 2, me.nId},
				--{"进入家族探险", self.OnEnterKinTong, self, 2, me.nId},
				--{"申请帮会探险",self.ApplyKinTong, self, 3, me.nId},
				--{"进入帮会探险", self.OnEnterKinTong, self, 3, me.nId},
				--{"开启征程", self.Open, self},
				{"Ta chỉ đến xem thôi"},
			};
	Dialog:Say(szMsg, tbOpt);
	return;
end
function tbNpc:Open()
	local szMsg = "";
	local tbOpt ={{"取消"},};
	if not CFuben.FubenData[me.nId] then
		szMsg = "\n\n先看看你能去什么地方选一个吧！";
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	local nTempMapId = CFuben.FubenData[me.nId][1];
	local nDyMapId = CFuben.FubenData[me.nId][2];
	if CFuben.tbMapList[nTempMapId][nDyMapId].IsOpen == 0 then
		CFuben.tbMapList[nTempMapId][nDyMapId].IsOpen = 1;
		CFuben:GameStart(me.nId, CFuben.FubenData[me.nId][2]);
		szMsg = "成功开启！";
	else
		szMsg = "\n\n您已经开启过了！";		
	end
	Dialog:Say(szMsg, tbOpt);
	return;
end
function tbNpc:OnEnter(nPlayerId)	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then	
		if pPlayer.nTeamId ~= 0 then
			local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
			if CFuben:IsSatisfy(pPlayer.nId, tbPlayerList[1]) == 0 then
				return;
			end
			CFuben:JoinGame(pPlayer.nId, tbPlayerList[1]);
		else
			pPlayer.Msg("您没有队伍！");
			return;
		end
	end
end

function tbNpc:Apply()	
	local tbOpt = {
					{"取消"},
				};
	local szMsg = "\n\n这些神秘的地方有您想去的吗？";
	if me.nTeamId ~= 0 then
		for nType, tbFuBen in pairs (CFuben.FUBEN) do
			local nTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
			local nNowTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d"))*10000);
			if tbFuBen.nFlag == 1 and nNowTime - nTime >= tbFuBen.nTime * 24 * 3600 then			
				table.insert(tbOpt,1,{tbFuBen.szName,self.ApplyEx,self, tbFuBen, nType});
			end
		end
	else
		szMsg = "您不是队长不能带队去的！";
	end	
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbNpc:ApplyEx(tbFuBen, nType)	
	local tbOpt = {
					{"取消"},
				};
	local szMsg = "\n\n看看具体想去那里：";	
	local nTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nNowTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d"))*10000);	
	for nId, tbFuBenEx in pairs (tbFuBen) do
		if type(tbFuBenEx) == "table" then
			if nNowTime - nTime >= tbFuBenEx.nTime * 24 * 3600 then
				table.insert(tbOpt,1,{tbFuBenEx.szName,self.Apply_Ex,self, nId, nType});
			end
		end
	end	
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbNpc:Apply_Ex(nId, nType)
	CFuben:ApplyFuBenEx(nType, nId, me.nId);	--申请副本
	return;
end

function tbNpc:ApplyKinTong(nFlag, nPlayerId)
	local tbOpt = {
					{"取消"},
				};
	local szMsg = "\n\n看看你们能去什么地方，选一个：";	
	local nTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nNowTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d"))*10000);	
	for nType, tbFuBen in pairs (CFuben.FUBEN) do
		for nId, tbFuBenEx in pairs (tbFuBen) do
			if type(tbFuBenEx) == "table" then
				if nNowTime - nTime >= tbFuBenEx.nTime * 24 * 3600 and tbFuBenEx.nGroupModel == nFlag then
					table.insert(tbOpt,1,{tbFuBenEx.szName,self.ApplyKinTongEx,self, nType, nId, nFlag, nPlayerId});
				end
			end
		end
	end
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbNpc:ApplyKinTongEx(nType, nId, nFlag, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then		
		local nKinId, nExcutorId = pPlayer.GetKinMember();
		if nKinId == 0 or nExcutorId == 0 then
			pPlayer.Msg("您没有家族！");
			return 0;
		end
		local cKin = KKin.GetKin(nKinId)
		if not cKin then 
			return 0
		end
		local cMember = cKin.GetMember(nExcutorId);
		if not cMember then
			return 0;
		end
		if nFlag == 2 then
			local nFigure = cMember.GetFigure();
			if nFigure ~= 1 then
				pPlayer.Msg("您不是族长，没有这个权限！");
				return 0;
			end
			print(nType,nId,nPlayerId)
			CFuben:ApplyFuBenEx(nType, nId, nPlayerId);
		else
			local nTongId = pPlayer.dwTongId;
			if pTong == 0 then
				Dialog:Say("您没有帮会");
				return 0;
			end
			local nSelfKinId, nSelfMemberId = pPlayer.GetKinMember();
			if Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, 32) ~= 1 then
				pPlayer.Msg("你不是帮主，没有这个权限！");
				return 0;
			end
			CFuben:ApplyFuBenEx(nType, nId, nPlayerId);
		end
	end
end

function tbNpc:OnEnterKinTong(nFlag, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then		
		if nFlag == 2 then
			local nKinId = pPlayer.dwKinId;
			if nKinId == 0 then
				pPlayer.Msg("您没有家族！");
				return;
			end
			local nFlagEx , nPlayerIdEx =  CFuben:FindFunben(nFlag,nKinId);
			if nFlagEx== 0 then
				pPlayer.Msg("您的家族没有申请副本！");
				return;
			else
				if CFuben:IsSatisfy(me.nId, nPlayerIdEx) == 0 then
					return;
				end
				CFuben:JoinGame(me.nId, nPlayerIdEx);
			end
		else
			local nTongId = pPlayer.dwTongId;
			if nTongId == 0 then
				pPlayer.Msg("您没有帮会！");
				return;
			end
			local nFlagEx , nPlayerIdEx =  CFuben:FindFunben(nFlag,nTongId);
			if nFlagEx== 0 then
				pPlayer.Msg("您的帮会没有申请副本！");
				return;
			else
				if CFuben:IsSatisfy(me.nId, nPlayerIdEx) == 0 then
					return;
				end
				CFuben:JoinGame(me.nId, nPlayerIdEx);
			end
		end
	end
end
