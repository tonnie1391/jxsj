-- 文件名　：kinrepository_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-06-10 14:44:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

function KinRepository:SetRoomAuthority_GS(dwKinId, nRoom, nAuthority)
	if self.IS_OPEN ~= 1 then
		return 0, "仓库未开放";
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	if nRoom < 0 or nRoom > self.ROOMTASK_END - self.ROOMTASK_BEGIN then
		print("room 参数有误");
		return 0;
	end
	if nAuthority < self.AUTHORITY_EVERYONE or nAuthority > self.AUTHORITY_FIGURE_CAPTAIN then
		print("room 权限参数有误");
		return 0;
	end
	GCExcute{"KinRepository:SetRoomAuthority_GC", dwKinId, nRoom, nAuthority};
	return 1;
end

function KinRepository:SetRoomExp_GS(dwKinId, nRoom, nExp)
	if self.IS_OPEN ~= 1 then
		return 0, "仓库未开放";
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	if nRoom < 0 or nRoom > self.ROOMTASK_END - self.ROOMTASK_BEGIN then
		print("room 参数有误");
		return 0;
	end
	if nExp < 0 or nExp > 4190000 then
		print("仓库经验数值超过上限(4190000)或者小于");
		return 0;
	end
	GCExcute{"KinRepository:SetRoomExp_GC", dwKinId, nRoom, nExp};
	return 1;
end

function KinRepository:SetRoomSize_GS(dwKinId, nRoom, nSize)
	if self.IS_OPEN ~= 1 then
		return 0, "仓库未开放";
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	local nRoomSize, nPermit, nExp = self:GetRoomInfo(dwKinId, nRoom);
	if not nRoomSize then
		return 0;
	end
	if nRoomSize >= nSize then
		return 0, "每页空间不能缩小";
	end
	if nSize > self.MAX_ROOM_SIZE then
		return 0, "每页最多设置" .. self.MAX_ROOM_SIZE .. "格";
	end
	GCExcute{"KinRepository:SetRoomSize_GC", dwKinId, nRoom, nSize};
	return 1;
end

function KinRepository:SetRoomInfo_GS2(dwKinId, nRoom, uInfo)
	if nRoom < 0 or nRoom > self.ROOMTASK_END - self.ROOMTASK_BEGIN then
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	cKin.SetTask(self.ROOMTASK_BEGIN + nRoom, uInfo);
end

-- 打开仓库检查返回3中权限，0：无法查看，1：只能看不能操作
function KinRepository:CheckOpen(pPlayer, dwKinId, nRoom, bCanOperate)
	if self.IS_OPEN ~= 1 then
		self:ErrorPrompt(pPlayer, "仓库功能暂未开放");
		return 0;
	end
	local nKinId = pPlayer.GetKinMember();
	if nKinId ~= dwKinId then -- 不是自己家族肯定不允许查看操作
		return 0;
	end
	-- 该页仓库是否开放了
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		self:ErrorPrompt(pPlayer, "你还没有家族！");
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		pPlayer.Msg("家族仓库未开启，威望排名前200的家族可以到家族领地的仓库管理员开启仓库功能。");
		return 0;
	end
	local nRoomSize, nPermit, nExp = self:GetRoomInfo(dwKinId, nRoom);
	if not nRoomSize or nRoomSize <= 0 then
		self:ErrorPrompt(pPlayer, "本页仓库还未开放");
		return 0;
	end
	return 1;
end

function KinRepository:CheckTakeAuthority(pPlayer)
	local nTime = pPlayer.GetTask(2063, 23);
	if nTime + self.TAKE_REPOSITOR_AUTHORITY_LAST > GetTime() then
		return 1;
	end
	return 0;
end

-- 检查是否能够存取
function KinRepository:CheckOperate(pPlayer, nOperateType)
	if pPlayer.IsAccountLock() == 1 then -- 没解锁能看但是不能操作
		self:ErrorPrompt(pPlayer, "账号未解锁，无法使用");
		return 0;
	end 
	if pPlayer.IsInPrison() == 1 then
		self:ErrorPrompt(pPlayer, "坐牢期间，无法使用");
		return 0;
	end
	local nNowTime = tonumber(GetLocalDate("%H%M%S"));
	if nNowTime >= KinRepository.FORBID_TIME_BEG and nNowTime <= KinRepository.FORBID_TIME_END then
		self:ErrorPrompt(pPlayer, "凌晨5:00~5:45家族仓库维护中暂时关闭");
		return 0;
	end
	local szMapType = GetMapType(pPlayer.nMapId);
	if not self.ALLOW_MAPTYPE_LIST[szMapType] then
		self:ErrorPrompt(pPlayer, "该地图无法操作家族仓库");
		return 0;
	end
	if nOperateType then -- 地图存取权限判断
		if self.ALLOW_MAPTYPE_LIST[szMapType] ~= self.OPERATE_TYPE_ALL and self.ALLOW_MAPTYPE_LIST[szMapType] ~= nOperateType then
			self:ErrorPrompt(pPlayer, string.format("家族仓库在该地图不能%s道具", KinRepository.TYPEDESC[nOperateType]));
			return 0;
		end
	end
	return 1;
end

-- 存东西检查接口，由程序调用
function KinRepository:CheckStore(pPlayer, dwKinId, nRoom, nRoomIndex)
	if self.IS_OPEN ~= 1 then
		self:ErrorPrompt(pPlayer, "仓库功能暂未开放");
		return 0;
	end
	if nRoomIndex > self.MAX_ROOM_SIZE then
		return 0;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId ~= dwKinId then -- 不是自己家族肯定不允许查看操作
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		self:ErrorPrompt(pPlayer, "你还没有家族！");
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		pPlayer.Msg("家族仓库未开启，威望排名前200的家族可以到家族领地的仓库管理员开启仓库功能。");
		return 0;
	end
	-- 家族威望跌出200名则不让存入东西,与家族领地保持一致
	if not HomeLand.tbLastWeekKinId2Index[dwKinId] or HomeLand.tbLastWeekKinId2Index[nKinId] > HomeLand.MAX_LADDER_RNAK then
		self:ErrorPrompt(pPlayer, "家族威望排名不够200名，无法存入只能取出");
		return 0;
	end
	local nRoomSize, nPermit, nExp = self:GetRoomInfo(dwKinId, nRoom);
	if not nRoomSize or nRoomSize <= 0 then
		self:ErrorPrompt(pPlayer, "本页仓库还未开放");
		return 0;
	end
	if nRoomIndex >= nRoomSize then
		self:ErrorPrompt(pPlayer, "该空间还未开放，您可以通过升级仓库经验来开放仓库空间");
		return 0;
	end
	if self:CheckOperate(pPlayer, self.OPERATE_TYPE_STORE) ~= 1 then
		return 0;
	end
	if self:CheckRepAuthority(nKinId, nMemberId, 0) ~= 1 then
		self:ErrorPrompt(pPlayer, "你没有权限操作仓库");
		return 0;
	end
	return 1;
end

-- 取东西检查接口，由程序调用
function KinRepository:CheckTake(pPlayer, dwKinId, nRoom, nRoomIndex)
	if self.IS_OPEN ~= 1 then
		self:ErrorPrompt(pPlayer, "仓库功能暂未开放");
		return 0;
	end
	if nRoomIndex > self.MAX_ROOM_SIZE then
		return 0;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId ~= dwKinId then -- 不是自己家族肯定不允许查看操作
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		self:ErrorPrompt(pPlayer, "你还没有家族！");
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		pPlayer.Msg("家族仓库未开启，威望排名前200的家族可以到家族领地的仓库管理员开启仓库功能。");
		return 0;
	end
	local nRoomSize, nPermit, nExp = self:GetRoomInfo(dwKinId, nRoom);
	if not nRoomSize or nRoomSize <= 0 then
		self:ErrorPrompt(pPlayer, "本页仓库还未开放");
		return 0;
	end
	if nRoomIndex >= nRoomSize then
		self:ErrorPrompt("该空间还未开放，您可以通过升级仓库经验来开放仓库空间");
		return 0;
	end
	if self:CheckOperate(pPlayer, self.OPERATE_TYPE_TAKE) ~= 1 then
		return 0;
	end
	if self:CheckRepAuthority(nKinId, nMemberId, nPermit) ~= 1 then
		self:ErrorPrompt(pPlayer, "你没有权限操作仓库");
		return 0;
	end
	if nPermit >= self.AUTHORITY_ASSISTANT then -- 仓库权限在管理员级别以上需要申请
		if self:CheckTakeAuthority(pPlayer) ~= 1 then
			self:ErrorPrompt(pPlayer, "请先点击“权限申请”按钮申请取出权限");
			return 0;
		end
	end
	return 1;
end

-- 检查存取，即交换操作
function KinRepository:CheckTakeAndStore(pPlayer, dwKinId, nRoom, nRoomIndex)
	local nRet = self:CheckStore(pPlayer, dwKinId, nRoom, nRoomIndex);
	if nRet ~= 1 then
		return 0;
	end
	nRet = self:CheckTake(pPlayer, dwKinId, nRoom, nRoomIndex);
	return nRet;
end

-- 检查交换仓库内道具接口
function KinRepository:CheckSwitchRep(pPlayer, dwKinId, nRoom, nPickIndex, nDropIndex)
	if self.IS_OPEN ~= 1 then
		self:ErrorPrompt(pPlayer, "仓库功能暂未开放");
		return 0;
	end
	if nPickIndex > self.MAX_ROOM_SIZE or nDropIndex > self.MAX_ROOM_SIZE then
		return 0;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId ~= dwKinId then -- 不是自己家族肯定不允许查看操作
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		self:ErrorPrompt(pPlayer, "你还没有家族！");
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		pPlayer.Msg("家族仓库未开启，威望排名前200的家族可以到家族领地的仓库管理员开启仓库功能。");
		return 0;
	end
	local nRoomSize, nPermit, nExp = self:GetRoomInfo(dwKinId, nRoom);
	if not nRoomSize or nRoomSize <= 0 then
		self:ErrorPrompt(pPlayer, "本页仓库还未开放");
		return 0;
	end
	if nPickIndex >= nRoomSize or nDropIndex >= nRoomSize then
		self:ErrorPrompt(pPlayer, "该空间还未开放，您可以通过升级仓库经验来开放仓库空间");
		return 0;
	end
	if self:CheckOperate(pPlayer, self.OPERATE_TYPE_TAKE) ~= 1 then
		return 0;
	end
	if self:CheckRepAuthority(nKinId, nMemberId, nPermit) ~= 1 then
		self:ErrorPrompt(pPlayer, "你没有权限操作仓库");
		return 0;
	end
	if nPermit >= self.AUTHORITY_ASSISTANT then
		if self:CheckTakeAuthority(pPlayer) ~= 1 then
			self:ErrorPrompt(pPlayer, "请先点击“权限申请”按钮申请取出权限");
			return 0;
		end
	end
	return 1;
end

--申请操作仓库，由程序调
function KinRepository:ApplyOperate(pPlayer, dwKinId, nRoom)
	if self.IS_OPEN ~= 1 then
		self:ErrorPrompt(pPlayer, "仓库功能暂未开放");
		return 0;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId ~= dwKinId then -- 不是自己家族肯定不允许查看操作
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		self:ErrorPrompt(pPlayer, "你还没有家族！");
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		pPlayer.Msg("家族仓库未开启，威望排名前200的家族可以到家族领地的仓库管理员开启仓库功能。");
		return 0;
	end
	-- 能否操作检查
	if self:CheckOperate(pPlayer) ~= 1 then
		return 0;
	end
	-- 充值检查
	if pPlayer.GetExtMonthPay() < self.OPERATE_MONTH_PAY then
		local szMsg = string.format("您可以前往家族领地的家族仓库管理员处打开家族仓库进行物品存取。<enter><enter>远程存取家族仓库物品是本月充值100元及以上玩家特权，您本月已充值<color=yellow>%s元<color>。", pPlayer.GetExtMonthPay())
		local tbOpt = 
		{
			{"<color=yellow>我要充值<color>", self.OnOpenOnlinePay, self},
			{"Ta hiểu rồi"}	
		};
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say(szMsg ,tbOpt);
		Setting:RestoreGlobalObj()
		return 0;
	end
	if self:CheckRepAuthority(dwKinId, nMemberId, 0) ~= 1 then
		self:ErrorPrompt(pPlayer, "你的家族仓库权限被禁止，无法操作！");
		return 0;
	end
	-- 战斗状态需要读条之后才能打开
	if pPlayer.nFightState == 1 then
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
		};
		Setting:SetGlobalObj(pPlayer);
		GeneralProcess:StartProcess("申请家族仓库操作...", 10 * Env.GAME_FPS, {self.ApplyOperateCallBack, self, pPlayer.nId, dwKinId, nRoom}, nil, tbEvent);
		Setting:RestoreGlobalObj()
		return 0;
	end
	pPlayer.CallClientScript({"KinRepository:UpdateRepOpenState_C2", 1});
	pPlayer.Msg("当前仓库可以存取,关闭之后需要重新申请");
	Dialog:SendBlackBoardMsg(pPlayer, "右键点击背包或仓库内道具即可进行存取");
	return 1;
end

function KinRepository:ApplyOperateCallBack(nPlayerId, dwKinId, nRoom)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId ~= dwKinId then 
		return;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	if self:CheckOperate(pPlayer) ~= 1 then
		return 0;
	end
	pPlayer.CallClientScript({"KinRepository:UpdateRepOpenState_C2", 1});
	pPlayer.Msg("当前仓库可以存取,关闭之后需要重新申请");
	Dialog:SendBlackBoardMsg(pPlayer, "右键点击背包或仓库内道具即可进行存取");
	pPlayer.OpenKinRepository(nRoom);
end

-- 充值引导
function KinRepository:OnOpenOnlinePay()
	if IVER_g_nSdoVersion == 1 then
		me.CallClientScript({"OpenSDOWidget"});
		return;
	end
	local szZoneName = GetZoneName();
	me.CallClientScript({"Ui:ServerCall", "UI_PAYONLINE", "OnRecvZoneOpen", szZoneName});	
end

-- 申请限制仓库取权限,需要是仓库管理员才能申请
function KinRepository:ApplyTakeAuthority(pPlayer, dwKinId)
	if KinRepository.IS_TEST_SERVER == 1 then
		return;
	end
	if pPlayer.IsAccountLock() == 1 then -- 没解锁能看但是不能操作
		self:ErrorPrompt(pPlayer, "账号未解锁，无法申请");
		return 0;
	end 
	if pPlayer.IsInPrison() == 1 then
		self:ErrorPrompt(pPlayer, "坐牢期间，无法申请");
		return 0;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId ~= dwKinId then -- 不是自己家族肯定不允许查看操作
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		self:ErrorPrompt(pPlayer, "你还没有家族！");
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		pPlayer.Msg("家族仓库还未开始，威望排名前两百的家族可以到家族领地的仓库管理员开启仓库功能。");
		return 0;
	end
	
	-- 查看玩家是否有取权限, 
	if self:CheckRepAuthority(dwKinId, nMemberId, self.AUTHORITY_ASSISTANT) ~= 1 then
		self:ErrorPrompt(pPlayer, "对不起，你没有权限申请取操作");
		return 0;
	end
	if self:CheckTakeAuthority(pPlayer) == 1 then
		pPlayer.Msg("你可以取道具，不用再申请");
		Dialog:SendBlackBoardMsg(pPlayer, "你可以取道具，不用再申请");
		return;
	end
	local tbData = Kin:GetExclusiveEvent(dwKinId, Kin.KIN_EVENT_TAKE_REPOSITORY);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(pPlayer, "已经有取道具的申请，请先处理申请！");
		pPlayer.Msg("已经有取道具的申请，请先处理申请！");
		return 0;
	end
	return GCExcute{"KinRepository:ApplyTakeAuthority_GC", pPlayer.nId, dwKinId, nMemberId};
end

function KinRepository:ApplyTakeAuthority_GS2(nPlayerId, dwKinId, nMemberId, nRoom)
	local tbData = Kin:GetExclusiveEvent(dwKinId, Kin.KIN_EVENT_TAKE_REPOSITORY);
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nMemberId = nMemberId;
	tbData.tbApplyRecord.nPow = KinRepository.AUTHORITY_ASSISTANT;
	tbData.tbApplyRecord.nPlayerId = nPlayerId;
	tbData.tbAccept = {};
	tbData.nAgreeCount = self.TAKE_AUTHORITY_AGREE_COUNT;
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.TAKE_REPOSITORY_APPLY_LAST,
		Kin.CancelExclusiveEvent_GS,
		Kin,
		dwKinId,
		Kin.KIN_EVENT_TAKE_REPOSITORY,
		nPlayerId
		);
	local cApplyPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if cApplyPlayer then
		cApplyPlayer.Msg("你申请了家族权限仓库操作，在2分钟内需要另外2名仓库管理员同意才能生效");
		Dialog:SendBlackBoardMsg(cApplyPlayer, "你申请了家族权限仓库操作，在2分钟内需要另外2名仓库管理员同意才能生效");
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	KKinGs.KinClientExcute(dwKinId, {"Kin:SendTakeRepositoryApply_C2", szPlayerName});
	return KKinGs.KinClientExcute(dwKinId, {"Kin:TakeRepositoryRequestApply_C2",Kin.KIN_EVENT_TAKE_REPOSITORY, nMemberId, szPlayerName});
end

function KinRepository:AgreeTakeAuthority_GS2(nPlayerId, dwKinId)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	local tbData = Kin:GetExclusiveEvent(dwKinId, Kin.KIN_EVENT_TAKE_REPOSITORY);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		Kin:DelExclusiveEvent(dwKinId, Kin.KIN_EVENT_TAKE_REPOSITORY);
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	KKinGs.KinClientExcute(dwKinId, {"Kin:AgreeTakeAuthority_C2", szPlayerName})
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return;
	end
	cPlayer.Msg("您的申请已通过，已获得5分钟时间可对权限仓库进行自由存取。");
	Dialog:SendBlackBoardMsg(cPlayer, "您获得了5分钟时间能自由取出权限仓库物品，超时需要重新申请");
	cPlayer.SetTask(2063, 23, GetTime());
end

-- 错误提示
function KinRepository:ErrorPrompt(pPlayer, szMsg)
	if not pPlayer then
		return 0;
	end
	if szMsg and szMsg ~= "" then
		pPlayer.Msg(szMsg);
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_INFOBOARD", "OnOpen" , szMsg});	
	end
end

-- 增加记录
function KinRepository:AddRecord_GS2(dwKinId, nRoomType, nType, nTimes, szName, nGenre, nDetailType, nParticular, nLevel, nCount)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	cKin.AddRepRecord(nRoomType, nType, nTimes, szName, nGenre, nDetailType, nParticular, nLevel, nCount);
end

-- 查看记录
function KinRepository:ApplyViewRecord_GS(pPlayer, nRoomType, nPage)
	if nRoomType ~= self.REPTYPE_FREE and nRoomType ~= self.REPTYPE_LIMIT then
		return;
	end
	if nPage < 1 or nPage > 10 then
		return;
	end
	local nKinId, nExcutorId = pPlayer.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return;
	end
	local nRecordCount = cKin.GetRepRecordCount(nRoomType);
	if not nRecordCount then
		return;
	end
	local nPageTotal = math.ceil(nRecordCount/10);
	if nPageTotal == 0 then
		pPlayer.Msg("暂时还没有存取记录");
		Dialog:SendBlackBoardMsg(pPlayer, "暂时还没有存取记录");
		return;
	end
	if nPage > nPageTotal then
		return;
	end
	local tbRecord = cKin.GetRepRecord(nRoomType);
	if not tbRecord then
		return;
	end
	local nStarId = nRecordCount - ((nPage - 1) * 10);
	local tbResult = {};
	for i = 1, 10 do
		if not tbRecord[nStarId - i + 1] then
			break;
		end
		tbResult[i] = tbRecord[nStarId - i + 1];
	end
	pPlayer.CallClientScript({"KinRepository:UpdateRecord_C2", tbResult, nRoomType, nPage, nPageTotal});
end

-- 同步仓库信息
function KinRepository:SyncRepositoryInfo(pPlayer)
	local dwKinId, nExcutorId = pPlayer.GetKinMember();
	if dwKinId == 0 then
		return;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	local cMember = cKin.GetMember(nExcutorId);
	if not cMember then
		return;
	end
	local tbRoomInfo = {};
	for i = 1, self.MAX_ROOM_PAGE do
		tbRoomInfo[i] = {};
		tbRoomInfo[i].nRoomSize, tbRoomInfo[i].nPermit, tbRoomInfo[i].nExp = self:GetRoomInfo(dwKinId, i - 1);
	end
	local nAuthority = cMember.GetRepAuthority();
	-- 没有设置权限的有默认权限
	if nAuthority >= 0 and nAuthority < KinRepository.AUTHORITY_ASSISTANT then
		local nFigure = cMember.GetFigure();
		if nFigure <= Kin.FIGURE_REGULAR or nFigure == Kin.FIGURE_RETIRE then
			nAuthority = KinRepository.AUTHORITY_RETIRE;
		end
	end
	local nOpenState = pPlayer.CheckKinRepIsOpen();
	pPlayer.CallClientScript({"KinRepository:UpdateRepInfo_C2", tbRoomInfo, nAuthority, nOpenState});
end

function KinRepository:SetRepositoryFlag_GS2(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetIsOpenRepository(1);
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0;
	end
	cMember.SetRepAuthority(KinRepository.AUTHORITY_FIGURE_CAPTAIN);
	KKin.Msg2Kin(nKinId, "恭喜本家族开启了家族仓库，可以在F6家族面板或家族领地中的仓库管理员处打开家族仓库。详情参见F12-家族仓库。")
end

-- 扩张仓库
function  KinRepository:ExtendRep(nType)
	if nType ~= KinRepository.REPTYPE_FREE and nType ~= KinRepository.REPTYPE_LIMIT then
		return;
	end
	local dwKinId, nExcutorId = me.GetKinMember();
	if dwKinId == 0 then
		return;
	end
	local nRet, cKin = Kin:CheckSelfRight(dwKinId, nExcutorId, 1)
	if nRet ~= 1 then
		Dialog:Say("只有家族族长才能操作");
		return;
	end
	if cKin.GetIsOpenRepository() == 0 then
		return;
	end
	local nLevel = 0;
	if nType == KinRepository.REPTYPE_FREE then -- 自由仓库
		nLevel = cKin.GetFreeRepBuildLevel();
	elseif nType == KinRepository.REPTYPE_LIMIT then	-- 限制仓库
		nLevel = cKin.GetLimitRepBuildLevel();
	end
	if nLevel >= #KinRepository.BUILD_VALUE[nType] then
		Dialog:Say("仓库已经升到最高级了");
		return;
	end
	local nBuildValue = cKin.GetRepBuildValue();
	if nBuildValue < KinRepository.BUILD_VALUE[nType][nLevel+1][1] then
		local szMsg = string.format("升级需要消耗<color=yellow>%s点<color>建设度，当前家族建设度不够", KinRepository.BUILD_VALUE[nType][nLevel+1][1]);
		Dialog:Say(szMsg);
		return;
	end
	local nMoney = cKin.GetMoneyFund();
	local nExtendMoney = self:GetExtendMoney(nType, nLevel + 1);
	-- 如果有家族资金申请则不让扩展
	local nCheckResult = Kin:CheckHaveEnoughMoney(dwKinId, nExtendMoney);
	if nCheckResult ~= 1 then
		if nCheckResult == -1 then
			Dialog:Say(string.format("家族资金正在使用中，请先处理所有家族资金请求。"));
		elseif nCheckResult == -2 then
			Dialog:Say(string.format("家族资金不足，扩展仓库需要消耗<color=yellow>%s<color>家族资金", nExtendMoney));
		end
		return;
	end
	GCExcute{"KinRepository:ExtendRep_GC", nType, dwKinId, nExcutorId, me.nId};
end

function KinRepository:ExtendRep_GS2(nType, dwKinId, nLevel, nBuildValue, nMoney, nDataVer, nPlayerId)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	cKin.SetKinDataVer(nDataVer);
	cKin.SetRepBuildValue(nBuildValue);
	cKin.SetMoneyFund(nMoney);
	if nType == KinRepository.REPTYPE_FREE then -- 自由仓库
		cKin.SetFreeRepBuildLevel(nLevel + 1);
		KKin.Msg2Kin(dwKinId, "家族族长成功将公共仓库扩充了。")
	elseif nType == KinRepository.REPTYPE_LIMIT then	-- 限制仓库
		cKin.SetLimitRepBuildLevel(nLevel + 1);
		KKin.Msg2Kin(dwKinId, "家族族长成功将权限仓库扩充了。")
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	self:SyncRepositoryInfo(pPlayer);
end

-- 增加建设度
function KinRepository:AddRepBuildValue(nPlayerId, nValue)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local dwKinId, nMemberId = pPlayer.GetKinMember();
	if dwKinId == 0 then
		return;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	local nBuildValue = cKin.GetRepBuildValue();
	if nBuildValue >= 2000000000 then -- 保护一下别超了
		return;
	end
	local nFreeLevel = cKin.GetFreeRepBuildLevel();
	local nLimitLevel = cKin.GetLimitRepBuildLevel();
	-- 都满级了不加了
	if nFreeLevel >= #self.BUILD_VALUE[self.REPTYPE_FREE] and nLimitLevel >= #self.BUILD_VALUE[self.REPTYPE_LIMIT] then
		return;
	end
	GCExcute{"KinRepository:AddRepBuildValue_GC", dwKinId, nValue};
end

function KinRepository:AddRepBuildValue_GS2(dwKinId, nBuildValue, nDataVer)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	cKin.SetKinDataVer(nDataVer);
	cKin.SetRepBuildValue(nBuildValue);
end

function KinRepository:SetMemberRepAuthority(nMemberId, nCurRepAuthority, nSetRepAuthority)
	if nCurRepAuthority == nSetRepAuthority then
		return;
	end
	local dwKinId, nExcutorId = me.GetKinMember();
	if nMemberId == nExcutorId then
		return;
	end
	local nRet, cKin = Kin:CheckSelfRight(dwKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return;
	end
	if cKin.GetIsOpenRepository() == 0 then
		return;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return;
	end
	local nRepAuthority = cMember.GetRepAuthority();
	if nRepAuthority ~= nCurRepAuthority then
		return;
	end
	if nSetRepAuthority == self.AUTHORITY_ASSISTANT then
		if cMember.GetFigure() > Kin.FIGURE_REGULAR then
			Dialog:Say("记名成员和荣誉成员不能设置成仓库管理员。");
			return;
		end

		local nManagerCount = 0;
		local itor = cKin.GetMemberItor()
		local cTemp = itor.GetCurMember()
		while cTemp do
			if cTemp.GetRepAuthority() == self.AUTHORITY_ASSISTANT then
				nManagerCount = nManagerCount + 1;
			end
			cTemp = itor.NextMember();
		end
		if nManagerCount >= self.MAX_MANAGER_COUNT then
			Dialog:Say("最多可以设置4个管理员。");
			return;
		end		
	end
	GCExcute{"KinRepository:SetMemberRepAuthority_GC", dwKinId, nExcutorId, nMemberId,nCurRepAuthority, nSetRepAuthority};
end

function KinRepository:SetMemberRepAuthority_GS2(dwKinId, nMemberId,nCurRepAuthority, nSetRepAuthority, nDataVer)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	cKin.SetKinDataVer(nDataVer);
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return;
	end
	cMember.SetRepAuthority(nSetRepAuthority);
	local nPlayerId = cMember.GetPlayerId();
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	local szMsg = "";
	if nSetRepAuthority == -1 then
		szMsg = string.format("家族成员[%s]的家族仓库存取权限已被禁止。", szName);
	elseif nSetRepAuthority == 0 then
		if nCurRepAuthority == -1 then
			szMsg = string.format("家族成员[%s]的家族仓库权限已被恢复。", szName);
		elseif nCurRepAuthority == self.AUTHORITY_ASSISTANT then
			szMsg = string.format("家族成员[%s]的家族仓库管理员身份已被取消。", szName);
		end
	else
		szMsg = string.format("家族成员[%s]被任命为家族仓库管理员。", szName);
	end
	KKin.Msg2Kin(dwKinId, szMsg);
	KKinGs.KinClientExcute(dwKinId, {"Kin:SetMemberRepAuthority_C2", nMemberId, nSetRepAuthority});
end