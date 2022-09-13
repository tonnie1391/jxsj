
Require("\\script\\player\\define.lua");
Require("\\script\\player\\playerevent.lua");
Require("\\script\\player\\playerschemeevent.lua");
Require("\\script\\player\\globalfriends.lua");

-- 玩家等级效率
Player.tbLevelEffect =
{-- [等级/10] 效率(比值)
	[1]		= 0.2,
	[2]		= 0.3,
	[3]		= 0.4,
	[4]		= 0.5,
	[5]		= 0.6,
	[6]		= 0.7,
	[7]		= 0.8,
	[8]		= 0.85,
	[9]		= 0.9,
	[10]	= 0.95,
	[11]	= 1.0,
	[12]	= 1.05,
	[13]	= 1.1,
	[14]	= 1.2,
	[15]	= 1.2,	
};
Player.bCanApplyJiesuo = 0;
Player.bApplyingJiesuo = 0;
Player.dwApplyJiesuoTime = 0;
Player.nAccountSafeLevel = 60;
Player.nAccountSafeHonour = 20000;
Player.nAccountSafeMode = 0;
Player.bForbid_GblSever_SpeRepair = 1;

Player.COMEBACK_DOUBT_OLD	= 1;	-- 怀疑外挂老玩家
Player.COMEBACK_DOUBT_NEW	= 2;	-- 怀疑外挂新玩家
Player.COMEBACK_YES_OLD	  	= 3;	-- 正常老玩家
Player.COMEBACK_YES_NEW		= 4;	-- 正常新玩家
Player.COMEBACK_TSKGROUPID	= 2082;
Player.COMEBACK_TSKID_FLAG	= 6;
Player.COMEBACK_TSKID_LASTTIME	= 7;
Player.COMEBACK_TSKID_NOWTIME	= 8;

Player.COMSUME_CLEAR_PROMPT_DAY	  = 1225;
Player.COMSUME_CLEAR_PROMPT_POINT =	500; 

Player.nOpenIpHandle	= EventManager.IVER_bOpenIpHandle;		-- 开启玩家登陆是否显示ip

Player.c2sFun = {};	--回调服务器的函数table

-- 客户端收到有人企图使自己复活
function Player:OnGetCure(nLifeP, nManaP, nStaminaP)
	CoreEventNotify(UiNotify.emCOREEVENT_GET_CURE, nLifeP, nManaP, nStaminaP);
end

function Player:OnFreezeCoin(pPlayer, nFlag, nCoin, nReason)
	if (nFlag == 1) then
--		pPlayer.Msg(string.format("Freeze:%d %d %d", nFlag, nCoin, nReason));
	elseif nFlag == 2 then
--		pPlayer.Msg(string.format("UnFreeze:%d %d %d", nFlag, nCoin, nReason));	
	end
	return 1;
end

-------------------------------------------------------------------------
-- 检查潜能加点是否合法
function Player:CheckAssignPotential(nStrength, nDexterity, nVitality, nEnergy)

	-- 计算加点后的潜能点
	nStrength	= math.max(me.nBaseStrength  + nStrength,	0);
	nDexterity	= math.max(me.nBaseDexterity + nDexterity,	0);
	nVitality	= math.max(me.nBaseVitality  + nVitality,	0);
	nEnergy		= math.max(me.nBaseEnergy    + nEnergy,		0);

	local nBaseTotal = me.nBaseStrength + me.nBaseDexterity + me.nBaseVitality + me.nBaseEnergy;
	local nTotal = nBaseTotal + me.nRemainPotential;

	-- 理论上任何一项潜能最终结果都不能超过总数的60%
	-- 但要考虑这样一种情况，假设加点前原有潜能值比例已经失调（比如通过GM指令修改），那么也必须保证能够正常加点。
	-- 此时比例最高的项在比例恢复正常前不能再增加（加点后比例可能仍然高于60%），比例低的项要保证加点后比例不会高于60%

	if (nStrength / 0.6) > nTotal then		-- 加点后力量比例不正确
		-- 如果加点前力量是正确的，那么加点失败，如果力量在比例不正常之前又有增加，也认为不正确
		if ((me.nBaseStrength / 0.6) > nTotal) and (me.nBaseStrength == nStrength) then
			return 1;
		end
	elseif (nDexterity / 0.6) > nTotal then	-- 加点后身法比例不正确
		if ((me.nBaseDexterity / 0.6) > nTotal) and (me.nBaseDexterity == nDexterity) then
			return 1;
		end
	elseif (nVitality / 0.6) > nTotal then	-- 加点后外功比例不正确
		if ((me.nBaseVitality / 0.6) > nTotal) and (me.nBaseVitality == nVitality) then
			return 1;
		end
	elseif (nEnergy / 0.6) > nTotal then		-- 加点后内功比例不正确
		if ((me.nBaseEnergy / 0.6) > nTotal) and (me.nBaseEnergy == nEnergy) then
			return 1;
		end
	else												-- 加点后潜能比例正常
		return 1;
	end

	return 0;

end

-------------------------------------------------------------------------
-- 玩家战斗状态下线调用此函数延迟
function Player:DelayShutdown(bForce)
	if (not bForce) then
		bForce = 0;
	end
	local nShutdownTime = me.GetDelayShutdownTime();
	if (nShutdownTime ~= 0) then
		return;
	end

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
	}
	GeneralProcess:StartProcess("Chuẩn bị rời mạng... Di chuyển sẽ hủy", 10 * Env.GAME_FPS, {me.FinishDelayLogout, bForce}, {me.SetDelayShutdownTime, 0}, tbEvent);
	me.SetDelayShutdownTime(GetFrame());
end


-------------------------------------------------------------------------
-- 玩家重生
function Player:PreLocalRevive(szFun, nId)
	if (me.IsDead()~= 1) then
		return;
	end
	local nReviveTime = 30;
	if szFun == "SkillRevive" then
		nReviveTime = 5;
	end
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
		Player.ProcessBreakEvent.emEVENT_BUYITEM,
		Player.ProcessBreakEvent.emEVENT_SELLITEM,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
	}

	GeneralProcess:StartProcess("Chuẩn bị hồi sinh", nReviveTime * Env.GAME_FPS, {Player[szFun], Player, nId}, nil, tbEvent);
end

function Player:CanBeRevived(pPlayer, nMapId, nReviveType)
	local bRet, szMsg = Map:CanBeRevived(nMapId, nReviveType)
	if bRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	return 1;
end

--是否可以进行回城复活
function Player:CanRemoteRevive()
	local bRet,szMsg = Map:CanBeRemoteRevive(me.nMapId);
	if bRet ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	return 1;
end


--使用物品复活
function Player:OnLocalRevive()
	if self:CanBeRevived(me, me.nMapId, 1) ~= 1 then
		return;
	end

	if (me.nLevel >= 30) then
		if (me.GetItemCountInBags(18,1,24,1) > 0 or me.GetItemCountInBags(18,1,268,1) > 0) then
			self:ItemRevive(me.nId);
		else
			me.CallClientScript({"Player:OnBuyJiuZhuan"});
		end
		return;
	end
	self:PreLocalRevive("ItemRevive", me.nId)
end

function Player:ItemRevive(nId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	assert(pPlayer);
	if (pPlayer.IsDead() ~= 1) then
		return;
	end
	
	if (pPlayer.nLevel < 30) then
		pPlayer.OnLocalRevive();
		return;
	end
	
	local bRet = pPlayer.ConsumeItemInBags(1,18,1,268,1);
	if (bRet ~= 0) then
		bRet = pPlayer.ConsumeItemInBags(1,18,1,24,1);
	end

	if (bRet == 0) then
		pPlayer.Msg(pPlayer.szName.." dùng 1 Cửu Chuyển Tục Mệnh Hoàn, hồi phục ngay.");
		local nLostExp = me.GetDeathPunishExp();
		if nLostExp > 0 then	--补回失去的经验
			me.AddExp(nLostExp);
			me.ClearDeathPunishExp();
		end
		pPlayer.OnLocalRevive();
		if KinBattle:CheckUseJiuZhuan(pPlayer) == 1 then
			KinBattle:OnUseJiuZhuan(pPlayer); --家族战使用九转接口
		end
	end
end

--使用技能复活
function Player:PreSkillRevive(nSkillPlayerId)
	if (me.IsDead() ~= 1 or nSkillPlayerId <= 0) then
		return;
	end
	if self:CanBeRevived(me, me.nMapId, 2) ~= 1 then
		return;
	end
	self:PreLocalRevive("SkillRevive", nSkillPlayerId)
end

function Player:SkillRevive(nSkillPlayerId)
	if (me.IsDead() ~= 1) then
		return;
	end
	local pSkillPlayer = KPlayer.GetPlayerObjById(nSkillPlayerId);
	if self:CanBeRevived(me, me.nMapId, 2) ~= 1 then
		return;
	end
	me.Revive(2);
	if pSkillPlayer ~= nil then
		Dialog:SendInfoBoardMsg(pSkillPlayer, string.format("Chữa trị hồi phục %s bị trọng thương", me.szName));
		Dialog:SendInfoBoardMsg(me, string.format("Bạn được %s trị thương hồi phục rồi", pSkillPlayer.szName));
	end
end

function Player:TryOffline()
	return self.tbOffline:TryOffline();
end

-------------------------------------------------------------------------

-- 注册PlayerTimer
--	参数：nWaitTime（从现在开始的桢数）, fnCallBack, varParam1, varParam2, ...
--	返回：nRegisterId
function Player:RegisterTimer(nWaitTime, ...)
	-- 调用公用Timer控件，注册Timer
	local tbEvent	= {
		nWaitTime	= nWaitTime,
		tbCallBack	= arg,
		szRegInfo	= debug.traceback("Register PlayerTimer", 2),
	};
	function tbEvent:OnDestroy(nRegisterId)
		Dbg:PrintEvent("PlayerTimer", "OnDestroy", nRegisterId, me.szName);	-- 通知调试模块，PlayerTimer被销毁
		local tbPlayerTimer	= me.GetTempTable("Player").tbTimer or {};
		--assert(tbPlayerTimer[nRegisterId]); -- 注释掉先 zounan
		tbPlayerTimer[nRegisterId]	= nil;
	end
	local nRegisterId	= Timer:RegisterEx(tbEvent);

	-- 将注册情况记录在玩家临时table中
	local tbPlayerData	= me.GetTempTable("Player");
	local tbPlayerTimer	= tbPlayerData.tbTimer;
	if (not tbPlayerTimer) then
		tbPlayerTimer	= {};
		tbPlayerData.tbTimer	= tbPlayerTimer;
	end
	tbPlayerTimer[nRegisterId]	= tbEvent;

	-- 通知调试模块，注册新PlayerTimer
	Dbg:PrintEvent("PlayerTimer", "Register", nRegisterId, nWaitTime, me.szName);

	return nRegisterId;
end

-- 关闭PlayerTimer
function Player:CloseTimer(nRegisterId)
	Dbg:PrintEvent("PlayerTimer", "Close", nRegisterId, me.szName);	-- 通知调试模块，关闭PlayerTimer

	local tbPlayerTimer	= me.GetTempTable("Player").tbTimer or {};
	assert(tbPlayerTimer[nRegisterId]);
	Timer:Close(nRegisterId);
end

-- 通知客户端上次登陆IP和所在地
function Player:LoginIpHandle(nIp)
	if not nIp then
		return;
	end

	if (self.nOpenIpHandle == 0) then
		return 0;
	end
	
	local szLastIp = "Chưa biết";
	local szLastArea = "Chưa biết";
	local bFirstLogin = 1;
	local nLastIp = me.GetTask(2063, 1);
	if (nLastIp ~= 0) then		
	  bFirstLogin = 0;
		szLastIp = Lib:IntIpToStrIp(nLastIp);
		szLastArea = GetIpAreaAddr(nLastIp);
	end

	local szCurIp = "Chưa biết";
	local szCurArea = "Chưa biết";
	me.SetTask(2063, 1, nIp);		
	
	szCurIp = Lib:IntIpToStrIp(nIp);
	szCurArea = GetIpAreaAddr(nIp);
	
	local szWarning = "";
	if szCurArea ~= szLastArea and bFirstLogin ~= 1 then
		szWarning = "<color=red>Cảnh cáo!<color>";
	end
	local nLimiLevel, nSpeLevel, nMonthLimit = jbreturn:GetRetLevel(me);
	if nLimiLevel > 0 then
		szWarning 	= "";
		szLastArea 	= "Việt Nam";
	end
	local szTip = "IP trước：<color=yellow>"..szLastIp.. " "..szWarning.." <color>\nNước：<color=yellow>"..szLastArea.."<color>\nIP hiện tại：<color=yellow>"..szCurIp.." <color>\nNước：<color=yellow>"..szCurArea.."<color>";
	
	if bFirstLogin ~= 1 then  
	  --me.CallClientScript({"PopoTip:ShowPopo", 19, szTip});
	  me.CallClientScript({"PopoTip:ShowLoginPopo", szTip}); -- 登录提示泡泡,GroupId=19
	end	
	
	
	local pTabFile = KIo.OpenTabFile("\\setting\\BanPlayer.txt");
	if (not pTabFile) then
		print("Khong tim thay pTabFile");
		return	0;
	end
	
	local tbContent = pTabFile.AsTable();
	local nCheck = 1
	for i = 2, #tbContent do
		local szAccount = tbContent[i][1];
		if szAccount == me.szAccount then
			me.AddSkillState(Newland.THRONE_BUFFER, 1, 1, 24 * 3600 * Env.GAME_FPS, 1, 1);
			-- me.Msg("Allow for Login!!!")
			nCheck = 0;
			break;
		end
	end
	
	if nCheck == 1 then
		me.RemoveSkillState(Newland.THRONE_BUFFER)
	end
	
	KIo.CloseTabFile(pTabFile);
end

-- 上次登陆时间，秒数，跨服不算登陆
-- 注：在OnLogin事件中此函数返回值可能不正常
function Player:GetLastLoginTime(pPlayer)
	return pPlayer.GetTask(2063, 2);
end

-------------------------------------------------------------------------
-- 通用上线事件
function Player:_OnLogin(bExchangeServerComing)
	if GetTime() - Player:GetLastLoginTime(me) >= 3600 * 24 * 20 then
		for i = 1, 20 do 
			me.SetTask(2204, i, 0);
		end
	end
	-- 日志
	local szLoginIp		= me.GetPlayerIpAddress() or "???";
	
	if (me.GetTask(2181,3) <= 0) then
		me.SetTask(2181, 3, me.GetRoleCreateDate());
	end

	if (bExchangeServerComing ~= 1) then
		if not GLOBAL_AGENT then
			local nNotice = Player:RegisterTimer(Env.GAME_FPS * 3, self.AskCheckRealTime, self);
			me.SetTask(2205, 2, nNotice)
		end
		local szLogMsg		= string.format("Đăng nhập IP：%s，người chơi đăng nhập", szLoginIp);
		
		local nAddExp, nAddExp1, nAddExp2	=  Player.tbOffline:GetAddExp(me);
		if (nAddExp > 0) then
			local szMsg = string.format("Nhận kinh nghiệm ủy thác rời mạng lần trước %d", nAddExp);
			szLogMsg = szLogMsg .. ", " .. szMsg;
		end
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_LOGIN, szLogMsg);
	
		me.CheckXuanJingTimeOut(7);
		me.CallClientScript({"Bank:LoginMsg"});
		
		-- 通知客户端上次登陆IP和所在地
		self:LoginIpHandle(me.dwIp);	
		
		--上线记录相关时间以及累积值
		self:RecordTimeAbort();		
		
		--提醒开通锁定保护的类型
	    if me.IsAccountLock() == 1 then
		     if me.IsAccountLockOpen() == 1 and me.GetPasspodMode() == Account.PASSPODMODE_ZPTOKEN  then
				me.Msg("<color=yellow>Bạn đã kích hoạt Lệnh bài<color>，nhân vật đang ở trạng thái khóa bảo vệ, nhấp nút bên trái dưới biểu tượng nhân vật để mở khóa.");
		     elseif me.IsAccountLockOpen() == 1 and me.GetPasspodMode() == Account.PASSPODMODE_ZPMATRIX then
				me.Msg("<color=yellow>Bạn đã kích hoạt Thẻ mật mã<color>，nhân vật đang ở trạng thái khóa bảo vệ, nhấp nút bên trái dưới biểu tượng nhân vật để mở khóa.");
		     elseif me.IsAccountLockOpen() == 1 and me.GetPasspodMode() == 0 then
				me.Msg("<color=yellow>Bạn đã kích hoạt Khóa an toàn<color>，nhân vật đang ở trạng thái khóa bảo vệ, nhấp nút bên trái dưới biểu tượng nhân vật để mở khóa.");
	   	   end
	   	end
	   	
	   	-- 年底积分清空提示
	   	self:ConsumeClearPrompt();
	   	-- 上线记录家族最近登录时间
	   	local nKinId = me.GetKinMember();
	   	if nKinId > 0 then
	   		Kin:UpdateLastLoginTime(nKinId);
	   	end
	   	--local szCurIp = "Vô";
	   	--local nIp = me.dwIp;
	   	--if (nIp and nIp ~= 0) then
	   	--	szCurIp = Lib:IntIpToStrIp(me.dwIp);
	   	--end
	   	--szLogMsg = string.format("%s\t%s\t%s\t%s\t%s", me.szAccount, me.szName, szCurIp, me.nLevel, me.GetHonorLevel());
	   	--Dbg:WriteLogEx(Dbg.LOG_INFO, "login", szLogMsg);
	end
	
	me.UpdateEquipInvalid();

	if (bExchangeServerComing == 1) then
		self.CheckRealTime();
		Player:RegisterTimer(Env.GAME_FPS * 10, Player.CheckRealTime, Player);
		me.CallClientScript({"GM:DoCommand", [[me.UpdateEquipInvalid();]]});
	end
	
	if GLOBAL_AGENT then
		--如果是中心服务器，直接返回；
		if (self.bForbid_GblSever_SpeRepair == 1) then
			-- 全局服务器禁止特修
			me.CallClientScript({"Ui:ServerCall", "UI_SHOP", "OnSetForbidSpeRepair" , 1});
		end
		local nActiveAureId = me.GetTask(2062, 4);
		Dialog:SetActiveAuraId(me, nActiveAureId);
		return 0;
	end
	
	if (KPlayer.GetPlayerCount() >= KPlayer.GetMaxPlayerCount()) then
		me.Msg("Server hiện tại quá nhiều người, nếu rời mạng khó có thể đăng nhập lại.");
	end
	
	-- 恢复等级上限错误
	local nMaxLevel = KPlayer.GetMaxLevel();
	if (me.nLevel > nMaxLevel) then
		self:WriteLog(Dbg.LOG_ATTENTION, "PlayerLevel Too High!!", me.szName, me.nLevel, nMaxLevel);
		me.ResetFightSkillPoint();	-- 重置技能点
		me.SetTask(2,1,1);			-- 停止自动加点
		me.UnAssignPotential();		-- 重置潜能点
		me.AddLevel(nMaxLevel - me.nLevel);	-- 传入负数，降级
		me.AddExp(me.GetUpLevelExp());		-- 经验变成100%
		me.SetTask(2027,9, 2);		--给予2次宋金家族积分双倍奖励;
		local nAddFlag = me.Earn(100000, Player.emKEARN_ERROR_REAWARD) --补偿10W银两
		if nAddFlag == 1 then
			self:WriteLog(Dbg.LOG_ATTENTION, "Player Earn 100000 Menoy Success!!", me.szName, me.nLevel, nMaxLevel);
		else
			self:WriteLog(Dbg.LOG_ATTENTION, "Player Earn 100000 Menoy Fail!!", me.szName, me.nLevel, nMaxLevel);
		end	
		me.AddBindMoney(100000, self.emKBINDMONEY_ADD_ERROR_REAWARD) 		--补偿10W绑定银两
		Dialog:Say("Đẳng cấp đã hạ thấp, nhận được<color=yellow>100000 bạc<color> và <color=yellow>100000 bạc khóa<color>bồi thường. Mời đăng nhập lại.", {"Ngắt kết nối", me.KickOut});
	end
	
	Task:_OnLogin(); -- 临时的

	-- 载入玩家任务
	Task:OnLogin();

	-- 注册随机任务的事件
--	RandomTask:Register();

	-- 新人直接得到新手任务任务
	-- Task:OnAskBeginnerTask();
	me.SetTask(1000, 528, 747); -- Hoàn thành nhiệm vụ tân thủ

	-- 玩家注册计时器
	PlayerSchemeEvent:OnDailyEvent();

	if (self:IsFresh() == 1) then
		me.CallClientScript({"me.AddSkillState", 390, 1, 1, 400000000, 1});
	end
	
	-- TODO:liuchang 临时添加
	if (me.GetSkillLevel(10) > 20) then
		me.AddFightSkill(10, 20);
	end
	
	
--[[	-- 上线重置技能点
	if (me.GetTask(2029,2) == 0) then
		me.ResetFightSkillPoint();
		me.SetTask(2,1,1);
		me.UnAssignPotential();
		KPlayer.SendMail(me.szName, "战斗技能调整", 
			"    您好，由于新版本战斗技能做出了较大调整，所以在您登陆时重置了潜能点和技能点。请注意及时重新分配，以正常进行游戏。同时开放洗髓岛无限制免费洗点。");
		me.SetTask(2029, 2, 1, 1);
	end
--]]	
	SpecialEvent.RecommendServer:OnLoginRegister();	--推荐服务器自动登记。
	self:UpdateFudaiLimit();
	
	--如果是新手,pk模式为0;
	if me.IsFreshPlayer() == 1 then
		me.nPkModel = 0;
	end
	Wlls:OnLogin(); --武林联赛,上线,奖励自动补给.
	EPlatForm:OnLogin();
	Mission:LogOutRV();	--防止宕机状态解锁功能；
	
	if (bExchangeServerComing ~= 1) then
		self:ProcessAllReputeTitle(me);
	end

	self.tbBuyJingHuo:OnLogin(bExchangeServerComing);
	
	--大逃杀刷快捷键
	DaTaoSha:ReFreshShotCutalias();
	
	local nActiveAureId = me.GetTask(2062, 4);
	Dialog:SetActiveAuraId(me, nActiveAureId);
	SpecialEvent.ActiveGift:AddCounts(me, 1);		--登录活跃度
	
	if (bExchangeServerComing ~= 1) then
		if (SpecialEvent.tbTequan:CheckFreeTeQuan() == 1) then
			me.CallClientScript({"Tutorial:Login_OpenTimerProcessPlayerTutorial"});
		end
	end
	
	self:ResetDragonBallSate(me);
	--跟宠上线事件
	if not GLOBAL_AGENT then
		Npc.tbFollowPartner:FollowPartnerLogin();
	end
end

function Player:AskCheckRealTime()
	-- me.Msg("AskCheckRealTime")
	local tbData = Lib:LoadTabFile("\\setting\\player\\setmaxlevel.txt");
	if (not tbData) then
		print("Khong tim thay "..szClassList.." tab file!");
		return	0;
	end
	local tbContent = {};
	for _, tbRow in ipairs(tbData) do
		local nGetOpenDay = tonumber(tbRow.DATE) or 0;
		local nGetMaxLevel = tonumber(tbRow.MAX_LEVEL) or 0;
		tbContent[nGetOpenDay]	= nGetMaxLevel;
	end
	local nTimeOpenServer = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nOpenDay = math.floor((GetTime() - nTimeOpenServer) / (3600 * 24));
	local nOffset = 0;
	for i = 1, #tbContent do
		if nOpenDay == 0 then
			nOffset = 55;
			break;
		elseif nOpenDay == i then
			nOffset = tbContent[i]
			break;
		elseif i == #tbContent then
			nOffset = tbContent[#tbContent];
			break;
		end
	end
	
	local nType 	= Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_LEVEL, 0);
	local tbInfo	= GetHonorLadderInfoByRank(nType, 1);
	local nDiff = 0;
	local tbOpt = {
		{"Bật ưu đãi", self.SetCheckRealTime, self, 1},
		{"Tắt ưu đãi", self.SetCheckRealTime, self},
	}
	if tbInfo then
		nDiff = math.floor(tbInfo.nHonor/100) - me.nLevel;
	end
	if nDiff > 50 then
		nDiff = 50;
	elseif nDiff == 0 then
		Dialog:Say("Số ngày mở máy chủ: <color=red>"..nOpenDay.."<color>\n\n"..
		"Máy chủ đang mở cấp: <color=red>"..nOffset.."<color>\n\n"..
		"Hiệu số cấp độ với Top 1: <color=red>Không đáng kể<color>\n\n"..
		"Ngươi không nhận được ưu đãi tăng kinh nghiệm luyện công.", tbOpt);
		return
	end
	Dialog:Say("Số ngày mở máy chủ: <color=red>"..nOpenDay.."<color>\n\n"..
	"Máy chủ đang mở cấp: <color=red>"..nOffset.."<color>\n\n"..
	"Hiệu số cấp độ với Top 1: <color=red>"..nDiff.."<color>\n\n"..
	"Ngươi nhận được ưu đãi tăng kinh nghiệm luyện công so với người đứng đầu.\nTương ứng: <color=green>+"..nDiff.."0%<color> Exp luyện công\n\n<color=red>Tối đa chỉ được +500%<color>", tbOpt);
end

function Player:SetCheckRealTime(nTurnOn)
	me.SetTask(2205, 1, nTurnOn or 0)
	local nNotice = me.GetTask(2205, 2)
	Player:CloseTimer(nNotice);
	self.CheckRealTime();
	Player:RegisterTimer(Env.GAME_FPS * 10, Player.CheckRealTime, Player);
end

function Player:CheckRealTime()
	if me.GetTask(2205, 1) == 1 then
		-- me.Msg("Check Real Time!!!")
		local nType 	= Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_LEVEL, 0);
		local tbInfo	= GetHonorLadderInfoByRank(nType, 1);
		local nDiff = 0;
		if tbInfo then
			nDiff = math.floor(tbInfo.nHonor/100) - me.nLevel;
		end 
		if nDiff > 50 then
			nDiff = 50;
		elseif nDiff == 0 then
			return
		end
		if me.GetSkillState(2482) > 0 then
			me.RemoveSkillState(2482);
		end
		me.AddSkillState(2482, nDiff, 1, Env.GAME_FPS * 10, 1, 1)
	else
		return
	end
end

function Player:RecordTimeAbort()
	--by jiazhenwei
	local nCurTime = GetTime();
	local nLastTime = me.GetTask(2063,17);			--记录上次登录时间（即时更新）
	local nCurExTime = me.GetTask(2063,2);		--记录这次登录时间（即使更新）
	local nJianGeTime = me.GetTask(2063,16);		--记录上次登录时间（24小时后更新）	
	--老玩家
	if ((nCurTime - nLastTime) > 24 * 3600) or ((nCurTime - nCurExTime) > 24 * 3600) then
		me.SetTask(2063,16,nCurExTime);
		me.SetTask(2063,17,nCurTime);
	end
	
	if (Lib:GetLocalDay(nCurTime) ~= Lib:GetLocalDay(nCurExTime)) then
		-- 是今天第一次登陆，记录身上装备着的真元信息
		local szLog = "";
		for i = Item.EQUIPPOS_ZHENYUAN_MAIN, Item.EQUIPPOS_ZHENYUAN_SUB2 do
			local pItem = me.GetItem(Item.ROOM_EQUIP, i);
			if pItem then
				if (szLog ~= "") then
					szLog = szLog..",";
				end
				szLog = szLog..string.format("%d,%s,%s,%d,%1.0f", i, pItem.szGUID, pItem.szName, Item.tbZhenYuan:GetLevel(pItem), Item.tbZhenYuan:GetZhenYuanValue(pItem));
			end
		end
		
		if (szLog ~= "") then
			StatLog:WriteStatLog("stat_info", "zhenyuan", "hutizhenyuan", me.nId, szLog);
		end
	end
	
	me.SetTask(2063, 2, nCurTime);
	--记录当月天数
	local nNowMonth = tonumber(GetLocalDate("%m"));
	local nMonth = me.GetTask(2063,18);
	if nMonth ~= nNowMonth then
		me.SetTask(2063,18,nNowMonth);
		me.SetTask(2063,20, 0);			--重置累积的天数
		me.SetTask(2122,8, 0);			--重置领取次数
	end
	local nDate = me.GetTask(2063,19);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < nNowDate then
		me.SetTask(2063,19,nNowDate);
		me.SetTask(2063,20,me.GetTask(2063,20) + 1);
	end
	--end
end

-- 跨区服普通GS登出数据同步
function Player:DataSync_GS2(szName, nCurrentMoney)
	if szName and nCurrentMoney then
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_CURRENCY_MONEY, nCurrentMoney);		
	end
end

-- 登录安全提示
function Player:OnLogin_AccountSafe(bExchangeServer)
	if (bExchangeServer == 1 or IVER_g_nTwVersion == 1) then
		return;
	end

	if (0 == IVER_g_nLockAccount) then
		return;
	end		

	Timer:Register(1, Player.AccountSafe, Player);
end

function Player:AccountSafe()	
	local nCurHonor = PlayerHonor:GetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	if (me.nLevel >= self.nAccountSafeLevel and me.GetPasspodMode() == self.nAccountSafeMode and nCurHonor >= self.nAccountSafeHonour) then	
		me.CallClientScript({"UiManager:OpenWindow", "UI_LOCKACCOUNT"});
	end
	return 0;
end

function Player:OnLogin_OnSetComeBackOldPlayer(bExchangeServerComing)
	if (1 == bExchangeServerComing) then
		return;
	end
	local nFlag	= self:GetComeBackFlag();
	if (nFlag > 0) then
		return;
	end
	
	local nLevel = me.nLevel;
	if (nLevel < 79 or nLevel < me.GetAccountMaxLevel()) then
		return;
	end
	
	local nZeroFlag = self:CheckComeBackZero();

	local nNowTime	= GetTime();
	local nLastTime	= me.nLastSaveTime;
	
	if (nLastTime <= 0) then
		return;
	end

	local tbTime = {
		year=2009,
		month=2,
		day=20,
		hour=0,
		min=0,
		sec=0,
	};
	local nLimitTime = os.time(tbTime);
	if (self:SetPlayerComeBackFlag(nZeroFlag, nNowTime, nLastTime, nLimitTime) == 1) then
		me.SetTask(self.COMEBACK_TSKGROUPID, self.COMEBACK_TSKID_LASTTIME, nLastTime);
		me.SetTask(self.COMEBACK_TSKGROUPID, self.COMEBACK_TSKID_NOWTIME, nNowTime);
	end
end

function Player:SetPlayerComeBackFlag(nFlag, nNowTime, nLastTime, nLimitTime)
	if (nLastTime > nLimitTime and 1 == nFlag) then
		self:SetComeBackFlag(self.COMEBACK_YES_NEW);
		self:WriteLog_ForPlayer("SetPlayerComeBackFlag", me.szName, " is right new player");
		return 0;
	end

	if (nLastTime > nLimitTime and 0 == nFlag) then
		self:SetComeBackFlag(self.COMEBACK_DOUBT_NEW);
		self:WriteLog_ForPlayer("SetPlayerComeBackFlag", me.szName, " is doubt new player");
		return 0;
	end

	if (nLastTime <= nLimitTime and 1 == nFlag) then
		self:SetComeBackFlag(self.COMEBACK_YES_OLD);
		self:WriteLog_ForPlayer("SetPlayerComeBackFlag", me.szName, " is right call back player");
		return 1;
	end

	if (nLastTime <= nLimitTime and 0 == nFlag) then
		self:SetComeBackFlag(self.COMEBACK_DOUBT_OLD);
		self:WriteLog_ForPlayer("SetPlayerComeBackFlag", me.szName, " is doubt call back player");
		return 1;
	end
end

function Player:WriteLog_ForPlayer(...)
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Player", unpack(arg));
end

function Player:GetComeBackFlag()
	return me.GetTask(self.COMEBACK_TSKGROUPID, self.COMEBACK_TSKID_FLAG);
end

function Player:SetComeBackFlag(nValue)
	me.SetTask(self.COMEBACK_TSKGROUPID, self.COMEBACK_TSKID_FLAG, nValue);
end

-- 金币 > 0, 钱庄金币 > 0, 月充值 > 0, 
function Player:CheckComeBackZero()
	if (me.nCoin > 0) then
		return 1;
	end
	
	if (me.nBankCoin > 0) then
		return 1;
	end
	
	if (me.GetExtMonthPay() > 0) then
		return 1;
	end
	
	if (me.GetReputeValue(1,2) > 0) then
		return 1;
	end
	
	--这个需要加上转修门派的声望
	if (me.nFaction > 0 and me.GetReputeValue(3, me.nFaction) > 0) then
		return 1;
	end
	
	if (me.GetReputeValue(4,1) > 0) then
		return 1;
	end
	
	if (me.GetReputeValue(5,2) > 0) then
		return 1;
	end

	if (me.GetReputeValue(5,3) > 0) then
		return 1;
	end
	
	for i=1, 5 do
		if (me.GetReputeValue(6,i) > 0) then
			return 1;
		end
	end
	return 0;
end

function Player:OnLogin_StatComeBack(bExchangeServerComing)
	if (1 == bExchangeServerComing) then
		return;
	end
	local nNowTime	= GetTime();
	local nLastTime	= me.nLastSaveTime;
	if ((nNowTime - nLastTime) < 30 * 3600 * 24) then -- 30天回来
		return;
	end
	if (nLastTime <= 0) then
		return;
	end
	local nMaxLevel		= me.GetAccountMaxLevel();
	local tbInfo		= GetPlayerInfoForLadderGC(me.szName);
	local szLastTime	= os.date("%Y-%m-%d %H:%M:%S", nLastTime);
	local szNowTime		= os.date("%Y-%m-%d %H:%M:%S", nNowTime);
	local tbReputeId	= {
			[1] = {1, 2, 3},
			[2] = {1, 2, 3},
			[3] = {me.nFaction},
			[4] = {1},
			[5] = {1, 2, 3, 4},
			[6] = {1, 2, 3, 4, 5},
			[7] = {1},
		};
	-- 区服名 账号 角色名 当前角色等级 当前账号下最大角色等级 上次登录时间 本次登录时间 时间差 累计在线时间 银两 绑定银两 金币 绑定金币 
	-- 钱庄金币 门派 路线 活力 精力 江湖威望 
	-- 义军 等级 军营 等级 机关学 等级 扬州 等级 凤翔 等级 襄阳 等级 当前门派 等级 家族 等级 白虎堂 等级 盛夏活动 等级 逍遥谷 等级 祈福 等级 挑战武林高手金 等级 挑战武林高手木 等级 挑战武林高手水 等级 挑战武林高手火 等级 挑战武林高手土 等级 武林联赛 等级
	local tb	= {
		GetGatewayName(),
		tbInfo.szAccount,
		me.szName,
		me.nLevel,
		nMaxLevel,
		szLastTime,
		szNowTime,
		(nNowTime - nLastTime),
		me.nOnlineTime,
		me.GetRoleCreateDate(),
		me.nTotalMoney,
		me.GetBindMoney(),
		me.nCoin,
		me.nBindCoin,
		me.nBankCoin,
		Player:GetFactionRouteName(me.nFaction), 
		Player:GetFactionRouteName(me.nFaction, me.nRouteId),
		me.dwCurGTP,
		me.dwCurMKP,
		me.nPrestige,
	};
	-- 声望
	for nCamp, tbCamp in ipairs(tbReputeId) do
		for nClass, tbClass in ipairs(tbCamp) do
			local nRepute	= 0;
			local nLevel	= 0;
			if (nClass > 0) then
				nRepute = me.GetReputeValue(nCamp, nClass);
				nLevel	= me.GetReputeLevel(nCamp, nClass);
			end
			tb[#tb + 1] = nRepute;
			tb[#tb + 1] = nLevel;
		end
	end
	local szContext		= table.concat(tb, "\t");
	-- tbInfo.szAccount .. "\t";
	GCExcute({"KFile.AppendFile", "\\..\\stat_playercomeback_" .. GetGatewayName() .. ".txt", szContext .. "\n"});
end

function Player:ClearCibeixinjingUsedAmount()
	local tbYunyousengren = Npc:GetClass("yunyousengren");
	me.SetTask(tbYunyousengren.tbTaskIdUsedCount[1], tbYunyousengren.tbTaskIdUsedCount[2], 0);
end

function Player:ClearInsightBookUsedCount()
	me.SetTask(2006, 1, 0, 1);
end

-------------------------------------------------------------------------
-- 通用下线事件
function Player:_OnLogout(szReason)
	if (MODULE_GAMESERVER) then
		self:CommitLevelUpInfo(me.nId);
		-- 日志
		if (szReason ~= "SwitchServer") then 
			local nBank_Coin = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_SUM);
			local nBank_Money = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_SUM);
			local szDeRobot = "未使用外挂";
			if DeRobot:IsUseWG(me) == 1 then
				szDeRobot = "使用外挂";
			end
			local szMsg = string.format("Người chơi rời mạng (Cấp: %d, %s: %d, hiện kim và tồn: %d, %s khóa: %d, Bạc khóa: %d,Đồng trong Tiền Trang: %d)", 
									me.nLevel,
									IVER_g_szCoinName, me.nCoin,
									me.nCashMoney + me.nSaveMoney,
									IVER_g_szCoinName, me.nBindCoin,
									me.GetBindMoney(),
									me.nPrestige,
									me.GetGlbBindMoney(),
									nBank_Money,
									nBank_Coin,
									me.dwCurMKP,
									me.dwCurGTP, 
									KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_TONGSTOCK),
									szDeRobot
									);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_LOGOUT, szMsg);
			--玩家下线的时候把玩家的江湖威望存放到任务变量中
			me.SetTask(0, 2389, me.nPrestige);	--0, 2389是江湖威望的任务变量
			local nKinId, nMemberId = me.GetKinMember();
			if nKinId > 0 then
				GCExecute({"Kin:SetLastLogOutTime_GC", nKinId, nMemberId, GetTime()});
			end
		end
		-- 更新经验百分比
		-- 全局服没有应用战斗力等级排行榜，全局服时也不用同步经验百分比
		if (IsGlobalServer() == false) then	
			GCExecute({"Player.tbFightPower:UpdatePlayerExp", me.nId, me.nLevel, me.GetExpPercent(0)});
		end
	end

	-- 清除PlayerTimer
	local tbPlayerTimer	= me.GetTempTable("Player").tbTimer;
	if (tbPlayerTimer) then
		for nRegisterId, tbEvent in pairs(tbPlayerTimer) do
			-- 通知调试模块，关闭PlayerTimer
			Dbg:PrintEvent("PlayerTimer", "LogoutClose", nRegisterId, me.szName);
			-- TODO: FanZai	还不能支持下线不消失的PlayerTimer
			Timer:Close(nRegisterId);
		end
	end
	if (szReason ~= "SwitchServer") then 
		--by jiazhenwei下线记录在线累积时间
		local nNowTime = GetTime();
		local nLastLogInTime = me.GetTask(2063, 2);
		local nTodayTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")));
		if nTodayTime <= nLastLogInTime  then
			me.SetTask(2063,21, me.GetTask(2063,21) + nNowTime - nLastLogInTime);
		else
			me.SetTask(2063,21, nNowTime - nTodayTime);
		end
		-- Player:PlayerLostChip(me.nId)
		--end
	end
	
	if (MODULE_GAMESERVER) then
		local tbXJRecord = me.GetXJRecordInfo();
		if tbXJRecord and tbXJRecord ~= {} then
			local szLog = "";
			local bHasValue = 0;
			for i, nCount in pairs(tbXJRecord) do
				if (i ~= 1) then
					szLog = szLog..",";
				end
				
				szLog = string.format("%s%d", szLog, nCount);
				
				if (nCount > 0 ) then
					bHasValue = 1;
				end
			end
			
			if (bHasValue == 1) then
				StatLog:WriteStatLog("stat_info", "roleobtain", "xuanjing", me.nId, szLog);
			end
		end
		
		MiniResource.tbDownloadInfo:OnLogout(szReason);
		
		--跟宠上线事件
		if not GLOBAL_AGENT then
			Npc.tbFollowPartner:FollowPartnerLogOut();
		end
	else
		ClientEvent:OnLogout(szReason);
	end
end


-------------------------------------------------------------------------
-- 通用升级事件
function Player:_OnLevelUp(nLevel)
	-- 生活技能升级
	LifeSkill:AddSkillWhenPlayerLevelUp(nLevel);

	if (MODULE_GAMESERVER) then
		if (self:IsFresh() ~= 1) then
			me.CallClientScript({"me.RemoveSkillState", 390});
			if (me.nLevel == 30) then
				me.Msg("Bạn có thể đổi hình thức chiến đấu mới!");
			end
		end
		
		
		----判断是否有新的世界任务可接
		local tbTaskListInfo =  Task:GetBranchTaskTable(me);
		if (tbTaskListInfo and #tbTaskListInfo > 0) then			
	   		for _,tbInfo in ipairs(tbTaskListInfo) do
		  		if (me.nLevel == tbInfo[1]) then
						me.CallClientScript({"Ui:ServerCall", "UI_TASKTIPS", "Begin", "Đã có nhiệm vụ Thế Giới mới, ấn <color=yellow>F4<color> trên <color=yellow>bàn phím<color> để kiểm tra!"});
	 		     		break;
	 		 	 end		  
		 	 end
		end

		
		--达到一定等级，自动设置师徒选项
		-- 20级了可以拜师了，
		if (me.nLevel == 20) then
			me.CallClientScript({"me.SetTrainingOption", 1, 1});
		elseif (me.nLevel == 49) then
			me.CallClientScript({"me.SetTrainingOption", 1, 0});
		elseif (me.nLevel == 80) then -- 80级了加一下军营的进入次数
			Task.tbArmyCampInstancingManager:UpdateEnterTimes();
		end
		self:SetActMaxLevel(nLevel);
		local tbActiveEvent = {[10] = 10, [20] = 12, [30] = 39, [40] = 40, [50] = 41};
		if tbActiveEvent[me.nLevel] then
			SpecialEvent.ActiveGift:AddCounts(me, tbActiveEvent[me.nLevel]);		--升级活跃度
		end
		SpecialEvent.tbGoldBar:AddTask(me, 11);		--金牌联赛升级	
	end
	if MODULE_GAMECLIENT then
		Tutorial:OnLevelUp();
	end
end

function Player:IsFresh()
	return me.IsFreshPlayer();
end


-------------------------------------------------------------------------
-- 通用死亡事件
function Player:_OnDeath(pKiller)
	BlackSky:GiveMeBright(me);
	if (not pKiller) then
		return;
	end
	if (pKiller.nKind == 1) then		
		local szMsg = "Bạn bị <color=yellow>"..pKiller.szName.."<color>đánh trọng thương!";
		if pKiller.GetTrickName() ~= "" then
			szMsg = "Bạn bị <color=yellow>"..pKiller.GetTrickName().."<color>đánh trọng thương!";
		end
		Dialog:SendInfoBoardMsg(me, szMsg);
		me.Msg(szMsg)
		local pPlayer = pKiller.GetPlayer();
		if (pPlayer) then
			local szMsg = "<color=yellow>"..me.szName.."<color> bị bạn đánh trọng thương.";
			if me.GetNpc().GetTrickName() ~= "" then
				szMsg = "<color=yellow>"..me.GetNpc().GetTrickName().."<color> bị bạn đánh trọng thương.";
			end
			Dialog:SendInfoBoardMsg(pPlayer, szMsg);
			pPlayer.Msg(szMsg);
			--击杀玩家时调用宠物奖励
			Npc.tbFollowPartner:AddAward(pPlayer, "killplayer");
			Player:PlayerLostChip(me.nId, pPlayer.nId);
		end
	end
end

-------------------------------------------------------------------------
function Player:_OnKillNpc()
	-- 如果是精英怪，首领怪，判断是否要给玩家的同伴添加经验
	if him.GetNpcType() ~= 0 then
		Partner:OnKillBoss(me, him);
	end
	
	local szMapType = GetMapType(me.nMapId);
	if szMapType == "fight" then
		local nRand = MathRandom(1000000)
		-- me.SetTask(2209, 1, me.GetTask(2209, 1) + 1); 
		-- me.Msg(""..me.GetTask(2209, 1))
		if nRand <= 500 then
			me.AddItem(18, 1, 1815, 5);
			local szItemName = KItem.GetNameById(18, 1, 1815, 5)
			local szMsg = "Người chơi <color=yellow>"..me.szName.."<color> nhặt được <color=yellow>"..szItemName.."<color> từ bản đồ luyện công."
			KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, "<color=green>"..szMsg.."<color>");
			KDialog.MsgToGlobal("<color=green>"..szMsg.."<color>");
		elseif nRand <= 5000 then
			me.AddItem(18, 1, 1815, 1);
		end
	end

	Task:OnKillNpc(me,him);
end

function Player:_OnCampChange()
	if (MODULE_GAMESERVER) then
		if (self:IsFresh() ~= 1) then
			me.CallClientScript({"me.RemoveSkillState", 390});
		end
	end
end

-- 活动数据同步
function Player:SyncCampaignDate(nType, tbDate, nUsefulTime)
	me.SetCampaignDate(nType, tbDate, nUsefulTime);
end

-- 获得玩家等级效率
function Player:GetLevelEffect(nLevel)
	local nLevel10 	= math.floor(nLevel / 10);
	return self.tbLevelEffect[nLevel10] or 0;
end

-- 功能: 计算防御栏里受到同等级敌人的伤害减少了xx%(返回的是xx,不是xx%)
function Player:CountReduceDefence(nDefense)
	local nMaxPercent = KFightSkill.GetSetting().nDefenceMaxPercent;				--旧的抗性减免百分比上限
	local nExcessRisPer = KFightSkill.GetSetting().nExcessRisPer/100;				--溢出抗性将会放大的百分比
	local pReduceDefance = 2 * nMaxPercent * nDefense / (nDefense + 10 * me.nLevel + 200);
	local klv = me.nLevel*10+200;
	if nDefense>klv then
		pReduceDefance = 100*1/(1+1/(nExcessRisPer * nDefense / klv + nMaxPercent /(100 - nMaxPercent) - nExcessRisPer));
	end
	if (nDefense < 0) then
		pReduceDefance = 0;
	end
	return pReduceDefance;
end

function Player:AddProtectedState(pPlayer, nTime)
	if (nTime > 0) then
		pPlayer.AddSkillState(self.nBeProtectedStateSkillId, 1, 1, nTime * Env.GAME_FPS);
	else
		pPlayer.RemoveSkillState(self.nBeProtectedStateSkillId);
	end
end

function Player:UpdateFudaiLimit()
	local tbItem	= Item:GetClass("fudai");
	local nMaxUse	= tbItem.ITEM_USE_COUNT_MAX.nCommon;
	if (me.GetExtMonthPay() >= tbItem.VIP) then
		nMaxUse = tbItem.ITEM_USE_COUNT_MAX.nVip;
	end
	
	-- *******合服优惠，合服7天后过期*******
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 and me.nLevel >= 50 then
		nMaxUse = nMaxUse + 5;
	end
	-- *************************************
	
	me.SetTask(tbItem.TASK_GROUP_ID, tbItem.TASK_COUNT_LIMIT, nMaxUse);
end

-- 当获得的升级经验到达一定条件时会触发这个加心得的脚本
function Player:AddXinDe(nXinDeTimes)
	local nXinDe = 10000 * nXinDeTimes;
	Task:AddInsight(nXinDe);
end

if MODULE_GAMESERVER then
-- 摘马牌失败（在马上，并且上下马CD中）
function Player:OnSwitchHorseFailed(nPlayerId)
	if type(nPlayerId) ~= "number" then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return
	end

	pPlayer.Msg("Không thể lên xuống ngựa.")
end

function Player:Buy_GS1(nCurrencyType, nCost, nEnergyCost, nBuy, nBuyIndex, nCount)
	if nCount < 0 then
		return 0;
	end
	if nEnergyCost < 0 then
		nEnergyCost = 0;
	end
	if nCost < 0 then
		return 0;
	end
	if nCurrencyType == 9 then -- 货币类型是帮会建设资金
		local cTong = KTong.GetTong(me.dwTongId);
		if not cTong then
			me.Msg("Chưa vào bang, không được mua!");
			return 0;
		end
		local nTongId = me.dwTongId;
		local nSelfKinId, nSelfMemberId = me.GetKinMember();
		if Tong:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, Tong.POW_FUN) ~= 1 then
			me.Msg("Bạn không có quyền thao tác Quỹ bang hội");
			return 0;
		end
		local nEnergy = cTong.GetEnergy();
		local nEnergyLeft = nEnergy - nEnergyCost * nCount;
		if nEnergyLeft < 0 then
			me.Msg("Không đủ sức lãnh đạo bang hội!");
			return 0;
		end
		if Tong:CanCostedBuildFund(nTongId, nSelfKinId, nSelfMemberId, nCost * nCount) ~= 1 then
			me.Msg("Mức quỹ không đủ! Mời <color=yellow>Thủ Lĩnh<color> thiết lập hạn sử dụng cao nhất!");
			return 0;			
		end
		GCExcute{"Player:Buy_GC", nCurrencyType, nCost, nEnergyCost, me.dwTongId, nSelfKinId, nSelfMemberId, me.nId, nBuy, nBuyIndex, nCount};
	end
end

function Player:Buy_GS2(nCurrencyType, dwTongId, nPlayerId, nBuy, nBuyIndex, nCost, nEnergyLeft, nCount)
	local cTong = KTong.GetTong(dwTongId);
	if not cTong then
		return 0;
	end
	cTong.SetEnergy(nEnergyLeft);
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end	
	
	if nCurrencyType == 9 then
		pPlayer.Buy_Sync(nCurrencyType, nBuy, nBuyIndex, nCost, nCount);
	end
end

function Player:SendMsgToKinOrTong(pPlayer, szMsg, bIsTong)
	if (not pPlayer) then
		return;
	end
	if (bIsTong == 1) then
		local nTongId = pPlayer.dwTongId;
		if (nTongId ~= nil and nTongId > 0)	 then
			szMsg = "Thành viên bang hội <color=yellow>["..pPlayer.szName .. "]<color>" ..szMsg;
			pPlayer.SendMsgToKinOrTong(1, szMsg);
			return;
		end
	end
	
	local nKinId = pPlayer.dwKinId;
	if (nKinId ~= nil and nKinId > 0) then
		szMsg = "Thành viên gia tộc <color=yellow>"..pPlayer.szName .."<color>".. szMsg;
		pPlayer.SendMsgToKinOrTong(0, szMsg);
	end
end

function Player:ApplyBuyAndUseJiuZhuan()
	if (me.IsAccountLock() ~= 0)then
		me.Msg("Tài khoản đang khóa, không thực hiện thao tác này được!");
		Account:OpenLockWindow(me);
		return;
	end
	me.ApplyAutoBuyAndUse(53, 1);
	Dbg:WriteLog("Player", me.szName, "ApplyBuyAndUseJiuZhuan", 53);
end

function Player:NotifyItemTimeOut(nLeftTime)
	if (nLeftTime > 0) then
		me.CallClientScript({"Player:NotifyItemTimeOutClient", 45});
	else
		me.Msg("Mất Huyền Tinh trong Thương Khố hoặc túi vì hết hạn sử dụng.");
	end
end

-- 抓进桃源天牢。szORpPlayer:玩家名字或对象，nJailTerm:刑期(真实世界秒数,0为无期(默认))
function Player:Arrest(szORpPlayer, nJailTerm)
	local pPlayer = nil;	
	if type(szORpPlayer) == "string" then
		pPlayer = KPlayer.GetPlayerByName(szORpPlayer);
	else
		pPlayer = szORpPlayer;
	end
	if not pPlayer then
		return;
	end
	pPlayer.SetJailTerm(nJailTerm or 0);
	pPlayer.SetArrestTime(GetTime());
	pPlayer.KickOut();
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_COMPENSATE, "关桃源，刑期(真实世界秒数,0为无期)："..(nJailTerm or 0));
	return 1;
end

-- 从桃源天牢放出来.szORpPlayer:玩家名字或对象
function Player:SetFree(szORpPlayer)
	local pPlayer = nil;	
	local szPlayerName = "";
	if type(szORpPlayer) == "string" then
		pPlayer = KPlayer.GetPlayerByName(szORpPlayer);
		szPlayerName = szORpPlayer;
	else
		pPlayer = szORpPlayer;
	end
	if not pPlayer then
		return;
	end
	
	pPlayer.SetJailTerm(0);
	pPlayer.SetArrestTime(0);
	pPlayer.ForbitSet(0, 1);
	
	local nMapId, nReliveId  = pPlayer.GetRevivePos();
	local nReliveX, nReliveY = RevID2WXY(nMapId, nReliveId);
	pPlayer.NewWorld(nMapId, nReliveX / 32, nReliveY / 32); -- 回到存档点
	
	-- 顺便清除反外挂系统标志(houxuan)
	if self.tbAntiBot:IsKilledByAntiBot(pPlayer) == 1 then
		self.tbAntiBot:SetPlayerInnocent(pPlayer.szName)
	end	

	--将存放原因的任务变量清除
	pPlayer.SetTask(SpecialEvent.HoleSolution.TASK_COMPENSATE_GROUPID, SpecialEvent.HoleSolution.TASK_SUBID_REASON, 0);	

	pPlayer.KickOut();
	return 1;
end



-- 是否可以离开桃源天牢
function Player:CanLeaveTaoyuan(pPlayer)
	if pPlayer.GetArrestTime() == 0 then -- 没有被抓进桃源天牢
		return 1;
	else
		if pPlayer.GetJailTerm() == 0 or pPlayer.GetJailTerm() + pPlayer.GetArrestTime() > GetTime() then
			return 0;
		end
	end
	return 1;
end


-- 增加声望值 返回0表示声望异常 1表示到达等级上限 2表示声望增加成功
function Player:AddRepute(pPlayer, nClass, nCampId, nShengWang)
	local nLevel		= pPlayer.GetReputeLevel(nClass,nCampId);
	if (not nLevel) then
		print("AddRepute Repute is error ", pPlayer.szName, nClass, nCampId);
		return 0;
	else
		if (1 == pPlayer.CheckLevelLimit(nClass, nCampId)) then
			return 1;
		end
	end
	pPlayer.AddRepute(nClass, nCampId, nShengWang);
	return 2;
end

-- 增加声望，如果有累积声望会消耗累积声望
function Player:AddReputeWithAccelerate(pPlayer, nClass, nCampId, nShengWang)
	local nLevel		= pPlayer.GetReputeLevel(nClass,nCampId);
	if (not nLevel) then
		print("AddRepute Repute is error ", pPlayer.szName, nClass, nCampId);
		return 0;
	else
		if (1 == pPlayer.CheckLevelLimit(nClass, nCampId)) then
			return 1;
		end
	end
	local nShengWangExt = Item:GetClass("reputeaccelerate"):GetAndUseExtRepute(pPlayer, nClass, nCampId, nShengWang, 1);
	pPlayer.AddRepute(nClass, nCampId, nShengWang + nShengWangExt);
	return 2, nShengWangExt;
end

function Player:OnMoneyErr(szReason, nCheckMoney, nNowMoney)
	if (me.nLastSaveTime <= 1238457600) then	-- 早期错误数据
		return;
	end
	local szMsg	= string.format("%s\t%s\t%s\t[%d]\t%s\t%d=>%d\t%s", GetLocalDate("%Y-%m-%d %H:%M:%S"),
		me.szAccount, me.szName, me.nId, szReason, nCheckMoney, nNowMoney, me.GetPlayerIpAddress());
	print("MoneyErr1", szMsg);
	GCExcute({"KFile.AppendFile", "\\log\\moneyerr1_" .. GetGatewayName() .. ".txt", szMsg .. "\n"});
	if (nNowMoney > nCheckMoney) then
		--me.SetLogType(1+4);
	end
end

function Player:OnChangeFightState()
	if me.nFightState == 0 then		-- 从1变为0
		-- 从战斗状态转成非战斗状态，
		if me.nActivePartner ~= -1 then
			Partner:DecreaseFriendship(me.nId);
		end
		
		-- 关闭TIMER
		Partner:UnRegisterPartnerTimer(me);
	else							-- 从0变为1	
		local pPartner = me.GetPartner(me.nActivePartner);
		if pPartner then			
			-- 如果该玩家有激活的同伴，开启为同伴召出效果而加的定时器
			-- 总开关没有限制关闭才能开启TIMER
			Partner:RegisterPartnerTimer(me);
			
			-- 从非战斗状态转到战斗状态，记录亲密度衰减开始时间
			Partner:ResetDecrTime(pPartner); -- 重置同伴亲密度衰减变量
		end
	end
end

-- by zhangjinpin@kingsoft
-- 账号冻结
function Player:Freeze(szPlayer)
	local pPlayer = nil;	
	if type(szPlayer) == "string" then
		pPlayer = KPlayer.GetPlayerByName(szPlayer);
	else
		pPlayer = szPlayer;
	end
	if not pPlayer then
		return;
	end
	pPlayer.SetTask(2063, 4, 1);
	pPlayer.Msg("Tài khoản của bạn đã bị khóa.");
	pPlayer.KickOut();
	return 1;
end

-- 登陆事件判断冻结
function Player:OnLogin_CheckFreeze()
	if me.GetTask(2063, 4, 1) == 1 then
	pPlayer.Msg("Tài khoản của bạn đã bị khóa.");
		me.KickOut();
	end
end
-- end

-- 客户端发送非法协议处理 目前只记个LOG zounan
function Player:ProcessIllegalProtocol(szFunc,szParam, nValue)
	szFunc = szFunc or "";
	szParam = szParam or "";
	nValue = nValue or 0;	
	Dbg:WriteLog("Player:ProcessIllegalProtocol", me.szAccount, me.szName,szFunc,szParam,nValue);
end

--存储玩家快捷键(传入一个table用来记录到这个里面去)
function Player:SaveShotCut(tbSave)
	tbSave[me.nId] = {};
	for nPos = 1 , Item.TSKID_SHORTCUTBAR_FLAG do
		tbSave[me.nId][nPos] = me.GetTask(Item.TSKGID_SHORTCUTBAR, nPos);		
	end
	local nLeftSkill, nRightSkill = FightSkill:LoadSkillTask(me);
	tbSave[me.nId][Item.TSKID_SHORTCUTBAR_FLAG + 1] = nLeftSkill;
	tbSave[me.nId][Item.TSKID_SHORTCUTBAR_FLAG + 2] = nRightSkill;
end

--根据已知tb设置快捷键
function Player:RestoryShotCut(tbSave)
	if not tbSave[me.nId] then
		return;
	end
	for nPos = 1 , #tbSave[me.nId] - 2 do
		me.SetTask(Item.TSKGID_SHORTCUTBAR, nPos, tbSave[me.nId][nPos]);
	end
	FightSkill:SaveLeftSkillEx(me, tbSave[me.nId][#tbSave[me.nId] - 1]);
	FightSkill:SaveRightSkillEx(me, tbSave[me.nId][#tbSave[me.nId]]);
	FightSkill:RefreshShortcutWindow(me);
	tbSave[me.nId] = nil;
end

--检查每天任务变量，过期重置
function Player:CheckTask(nGroupId, nGDate, szDateRule, nGCount, nCount)	
	if not nGroupId or not nGDate or not szDateRule or not nGCount or not nCount then
		return 0;
	end
	local nNowDate = tonumber(GetLocalDate(szDateRule));
	local nDate = me.GetTask(nGroupId, nGDate);	
	if nDate ~= nNowDate then
		me.SetTask(nGroupId, nGDate, nNowDate);
		me.SetTask(nGroupId, nGCount, 0);
		return 1;
	end
	local nNowCount = me.GetTask(nGroupId, nGCount);
	if nNowCount >= nCount then
		return 0;	
	end
	return 1;
end

--设扩展变量
function Player:SetActMaxLevel(nNewLevel)
	if self:CheckIsXp() == 1 then
		return;
	end
	local nExt7OrgValue = me.GetExtPoint(7);
	local nExt7 = math.floor(nExt7OrgValue / 1000);
	local nOldLevel = (nExt7OrgValue % 1000);
	local nDisLevel = 0;
	if (nOldLevel >= 0) then
		nDisLevel = (nNewLevel - nOldLevel);
	else
		nDisLevel = (nNewLevel + nOldLevel);
	end
	if (nDisLevel > 0) then
		local tbTemp = me.GetTempTable("Player");
		tbTemp.nAccumulateLevel = tbTemp.nAccumulateLevel or 0;
		if (nExt7 < 0) then
			tbTemp.nAccumulateLevel = -nDisLevel;
		else
			tbTemp.nAccumulateLevel = nDisLevel;
		end
		if (not tbTemp.nAccumulateLevelTimerId) then
			tbTemp.nAccumulateLevelTimerId = Player:RegisterTimer(Env.GAME_FPS, Player.CommitLevelUpInfo, Player, me.nId);
			assert(tbTemp.nAccumulateLevelTimerId > 0);
		end
	end
end

function Player:CommitLevelUpInfo(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	local tbTemp = pPlayer.GetTempTable("Player");
	assert(tbTemp);
	local nAccumulateLevel = tbTemp.nAccumulateLevel;
	if (nAccumulateLevel) then
		tbTemp.nAccumulateLevel = 0;
		if (nAccumulateLevel > 0) then
			pPlayer.AddExtPoint(7, nAccumulateLevel);
		elseif (nAccumulateLevel < 0) then
			pPlayer.PayExtPoint(7, -nAccumulateLevel);
		end
	end
	if (tbTemp.nAccumulateLevelTimerId) then
		Setting:SetGlobalObj(pPlayer);
		Player:CloseTimer(tbTemp.nAccumulateLevelTimerId);
		Setting:RestoreGlobalObj();
		tbTemp.nAccumulateLevelTimerId = nil;
	end

	return 0;
end

--检查体服标志
function Player:CheckIsXp()
	if EventManager.IVER_bOpenTiFu == 0 then
		return 0;
	end
	return 1;
end

function Player:ApplyJoinFaction(nFaction, nRoute)
	if (me.nFaction > 0) then
		Dialog:Say("少侠您已经加入过门派了！");
		return;
	end
	
	local tbMenPai = Npc.tbMenPaiNpc;
	tbMenPai:JoinZhuXiuFaction(nFaction, nRoute);
end

function Player:GetViewInfo_GS(szName)
	if (not szName) then
		return;
	end
	local nID = KGCPlayer.GetPlayerIdByName(szName);
	if (not nID) then
		return;
	end
	local nFaction = KGCPlayer.GCPlayerGetInfo(nID).nFaction;
	local nLevel = KGCPlayer.OptGetTask(nID,11); -- emKGC_OPT_PLAYER_LEVEL = 11,获取玩家等级

	me.CallClientScript({"Player:GetViewInfo_C", nFaction,nLevel,szName});
end

Player.c2sFun["GetViewInfo_GS"] = Player.GetViewInfo_GS;

function Player:LogUiVersion(nUiVersion)
	if nUiVersion == 1 or nUiVersion == 2 then
		if me.GetTask(2063, 22) ~= nUiVersion then
			me.SetTask(2063, 22, nUiVersion);
			StatLog:WriteStatLog("stat_info", "Interface", "type", me.nId, nUiVersion);
		end
	end
end

Player.c2sFun["WriteUiVersionLog"] = Player.LogUiVersion;

function Player:OnReceiveClientGatesInfo(...)
	local tbArg = arg;
	if (tbArg.n < 2) then
		return;
	end
	
	local szCorrectGate = tbArg[1];
	if szCorrectGate ~= GetGatewayName() then
		print("Invalide gate info from client!", szCorrectGate, GetGatewayName());
		return;
	end
	
	self.tbGatesInfo = self.tbGatesInfo or {};
	self.tbGatesInfo[szCorrectGate] = self.tbGatesInfo[szCorrectGate] or {};
	
	for i = 2, tbArg.n do
		if not self.tbGatesInfo[szCorrectGate][tbArg[i]] then
			self.tbGatesInfo[szCorrectGate][tbArg[i]] = 1;
		end
	end	
	
	if not self.nGatesInfoSyncTimer then
		self.nGatesInfoSyncTimer = Timer:Register(Env.GAME_FPS * 60, self.SyncGatesInfoToGC, self);
	end
end

function Player:SyncGatesInfoToGC()
	if not self.tbGatesInfo or Lib:CountTB(self.tbGatesInfo) == 0 then
		return;
	end
	
	GCExcute{"Player:CollectGatesInfo_GC", self.tbGatesInfo};
	self.tbGatesInfo = nil;		-- 清空
end

function Player:OnResetAllPlayerDragonBallState()
	for _, pPlayer in ipairs(KPlayer.GetAllPlayer()) do
		self:ResetDragonBallSate(pPlayer);
	end
end

function Player:ResetDragonBallSate(pPlayer)
	local nLastDay = pPlayer.GetTask(self.TASK_MAIN_GROUP, self.TASK_SUB_GROUP_RESET_DAY);	-- 直接存放的是天数
	local nToday = Lib:GetLocalDay(GetTime());
	local nLocalDayTime = Lib:GetLocalDayTime(GetTime());	-- 今天已经过去的时间
	
	if nLocalDayTime < 3 * 3600 then -- 跨天了但在3点之前，认为是前一天
		nToday = nToday - 1;
	end
	
	if nLastDay ~= nToday then		
		-- 否则认为要刷新任务变量
		Item:SetDragonBallState(pPlayer, nil, 0, 1);
	end
end

function Player:ViewConsume()
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản chưa mở khóa, không thể tra xem tiêu hao Kỳ Trân Các.");
		Account:OpenLockWindow(me);
		return 0;
	end
	if Account:Account2CheckIsUse(me, 4) == 0 then
		Dialog:Say("Bạn đang đăng nhập trò chơi bằng mật mã phụ, không thể thực hiện thao tác này!");
		return 0;
	end		
	if IsLoginUseVicePassword(me.nPlayerIndex) == 1 then
		Dialog:Say("Dùng mật khẩu phụ đăng nhập vào game, không thể tiến hành thao tác này.");
		return 0;
	end
	local nNowYear = tonumber(GetLocalDate("%Y")) - 2011;
	local nYear = me.GetTask(2070, 8);
	local nYearGrade = me.GetTask(2070, 5) + me.GetTask(2070,2);
	local nLastYearGrade = me.GetTask(2070, 10);
	local nConsumeMonth = Spreader:IbShopGetConsume();
	local nConsumeLastM = me.GetTask(2070, 4);	
	local nMoney = me.GetTask(2070, 6);
	if nNowYear >= 0 and nYear ~= nNowYear then
		nMoney = 0;
		nLastYearGrade = nYearGrade;
		nYearGrade = 0;
	end
	local szTip = string.format("奇珍阁消耗情况如下：\n\n<color=yellow>上月消耗：%s<color>\n<color=yellow>本月消耗：%s<color>\n\n<color=yellow>去年累计消耗：%s<color>\n<color=yellow>今年累计消耗：%s<color>\n",nConsumeLastM, nConsumeMonth, nLastYearGrade, nYearGrade);
	Dialog:Say(szTip);
end

-- 特权福利界面
function Player:OpenFuliTequan(nFlag)
	if (GLOBAL_AGENT) then
		return;
	end
	if not nFlag or type(nFlag) ~= "number" then
		return;
	end
	Player.tbBuyJingHuo:OpenBuJingHuo(me, 3);
	local nMonthPay = me.GetExtMonthPay();
	local nMonthConsume = Spreader:IbShopGetConsume();
	local nPrestigeActive = SpecialEvent.ChongZhiRepute:CheckISCanGetRepute();
	if nPrestigeActive ~= 1 then
		if SpecialEvent.ChongZhiRepute:CheckIsSetExt() == 1 then
			nPrestigeActive = -1;
		end
	end
	local nKinWageActive = me.GetAccTask("tequan.kinWage");
	local nRank = GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_WEIWANG, 0);
	local nWeek = KGblTask.SCGetDbTaskInt(DBTASK_WEIWANG_WEEK);
	if nFlag == 1 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_FULITEQUAN", 1, nMonthPay, nMonthConsume, nPrestigeActive, nRank, nWeek, nKinWageActive});
	else
		me.CallClientScript({"Ui:ServerCall", "UI_FULITEQUAN", "Update", 1, nMonthPay, nMonthConsume, nPrestigeActive, nRank, nWeek, nKinWageActive});
	end
end

Player.c2sFun["OpenFuliTequan"] = Player.OpenFuliTequan;

-- 打开PVP，PVE界面
function Player:OpenFubenInfo(nFlag)
	if (GLOBAL_AGENT) then
		return;
	end
	local nLadderType = 0;
	nLadderType = KLib.SetByte(nLadderType, 3, 2);
	nLadderType = KLib.SetByte(nLadderType, 2, 2);
	nLadderType = KLib.SetByte(nLadderType, 1, 2);
	local nXoyoRank	= GetTotalLadderRankByName(nLadderType, me.szName);
	if nXoyoRank < 0 then
		nXoyoRank = 0;
	end
	local nSportMemGrade = 0;
	local nSportRemainTimes = 0;
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if cKin then
		local cMember = cKin.GetMember(nMemberId);
		if cMember then
			local nMonthNow = tonumber(GetLocalDate("%m"));
			local nMonth = cMember.GetKinGameMonth();
			if nMonthNow == nMonth then
				nSportMemGrade = cMember.GetKinGameGrade();
			end
		end
	end
	me.CallClientScript({"UiManager:OpenWindow", "UI_FUBEN_INFO", nXoyoRank, nSportMemGrade});
	SuperBattle:SelectState_GS(me, 1);
end

Player.c2sFun["OpenFubenInfo"] = Player.OpenFubenInfo;

-- 领取藏宝图次数
function Player:GetTreasureTimes(nType)
	if (GLOBAL_AGENT) then
		return;
	end
	if me.nLevel < 25 then
		me.Msg("Chỉ có hiệp sĩ đạt cấp 25 mới được nhận.");
		return;
	end
	if nType == 1 then -- 周次数
		local nAddCount, szMsg = TreasureMap2:AddWeekCommonCount(me);
		if szMsg then
			me.Msg(szMsg);
		end
	elseif nType == 2 then -- 天次数
		local nAddCount, szMsg = TreasureMap2:AddDayRandCount(me);
		if szMsg then
			me.Msg(szMsg);
		end
	elseif nType == 3 then -- 领取高级藏宝图令牌
		local szMapType = GetMapType(me.nMapId);
		if szMapType ~= "village" and szMapType ~= "city" then
			me.Msg("Nhận tại Thành hoặc Tân Thủ Thôn.");
			return;
		end
		local tbjunxuguan = Npc:GetClass("yijunjunxuguan");
		tbjunxuguan:OnGetMissionItem();
	end
end

Player.c2sFun["GetTreasureTimes"] = Player.GetTreasureTimes;

-- 前往PVE，PVP各报名点
function Player:GoFubenEnter(nUseChuangSongFu, nType)
	if nUseChuangSongFu == 1 then
		local tbChuangsongfu = Item:GetClass("chuansongfu");
		local tbFind = me.FindClassItemInBags("chuansongfu");
		local pItem = nil;
		for _, tbItem in ipairs(tbFind) do
			local nParticular = tbItem.pItem.nParticular;
			for nKey, _ in pairs(tbChuangsongfu.tbNewTransItem) do
				if nParticular == nKey then
					pItem = tbItem.pItem;
					break;
				end
			end
		end
		if not pItem then
			me.Msg("Không có Vô Hạn Truyền Tống Phù, không thể đưa đến điểm chỉ định");
			return;
		end
		local szForbitMap = KItem.GetOtherForbidType(unpack(pItem.TbGDPL()))
		local nCanUse = 1;
		if szForbitMap then
			nCanUse = KItem.CheckLimitUse(me.nMapId, szForbitMap);
		end
		if (not nCanUse or nCanUse == 0) then
			me.Msg("Đạo cụ này không được dùng ở đây!");
			return;
		end
		if nType == 1 then -- 逍遥谷
			tbChuangsongfu:OnTransItem(pItem, tbChuangsongfu.tbXiaoyaogu, tbChuangsongfu.tbNewTransItem[pItem.nParticular]);
		elseif nType == 2 then -- 军营副本
			tbChuangsongfu:OnTransArmyCamp(pItem.dwId);
		elseif nType == 3 then -- 本服宋金
			tbChuangsongfu:OnTransBattle(pItem.dwId);
		elseif nType == 4 then -- 白虎堂
			tbChuangsongfu:OnTransItem(pItem, tbChuangsongfu.tbBaihutang, tbChuangsongfu.tbNewTransItem[pItem.nParticular])
		end
	else
		if nType == 1 then -- 藏宝图
			local tbPathInfo = {
				[1] = {szName = "Quan Quân Nhu (Nghĩa quân)-Giang Tân Thôn", tbPos = {5, 1639, 3103}}, 
				[2] = {szName = "Quan Quân Nhu (Nghĩa quân)-Vân Trung Trấn", tbPos = {1, 1407, 3150}}, 
				[3] = {szName = "Quan Quân Nhu (Nghĩa quân)-Vĩnh Lạc Trấn", tbPos = {3, 1634, 3172}}
			};
			local tbOpt = {};
			for _, tbInfo in ipairs(tbPathInfo) do
				table.insert(tbOpt, {tbInfo.szName, Player.GoFubenEnterByAutoPath, Player, unpack(tbInfo.tbPos)});
			end
			table.insert(tbOpt, {"Để ta suy nghĩ đã"});
			Dialog:Say("Hãy chọn 1 điểm báo danh Tàng Bảo Đồ", tbOpt);
		elseif nType == 2 then -- 高级藏宝图
			local tbPathInfo = {
				[1] = {szName = "Thần Trùng Trấn", tbPos = {2150, 1648, 3924}}, 
				[2] = {szName = "Thời Quang Điện", tbPos = {132, 1900, 3806}}, 
			};
			local tbOpt = {};
			for _, tbInfo in ipairs(tbPathInfo) do
				table.insert(tbOpt, {tbInfo.szName, Player.GoFubenEnterByAutoPath, Player, unpack(tbInfo.tbPos)});
			end
			table.insert(tbOpt, {"Để ta suy nghĩ đã"});
			Dialog:Say("Hãy chọn 1 điểm báo danh thi đấu", tbOpt);
		elseif nType == 3 then -- 家族竞技
			local tbPathInfo = {
				[1] = {szName = "Án Nhược Tuyết--Giang Tân Thôn", tbPos = {5, 1660, 3042}}, 
				[2] = {szName = "Án Nhược Tuyết--Vân Trung Trấn", tbPos = {1, 1535, 3119}}, 
				[3] = {szName = "Án Nhược Tuyết--Vĩnh Lạc Trấn", tbPos = {3, 1636, 3207}}
			};
			local tbOpt = {};
			for _, tbInfo in ipairs(tbPathInfo) do
				table.insert(tbOpt, {tbInfo.szName, Player.GoFubenEnterByAutoPath, Player, unpack(tbInfo.tbPos)});
			end
			table.insert(tbOpt, {"Để ta suy nghĩ đã"});
			Dialog:Say("Hãy chọn 1 điểm báo danh thi đấu", tbOpt);
		end
	end
end

Player.c2sFun["GoFubenEnter"] = Player.GoFubenEnter;

function Player:GoFubenEnterByAutoPath(nTargetMapId, nTargetX, nTargetY)
	me.CallClientScript({"Ui.tbLogic.tbAutoPath:ProcessClick", {nMapId=nTargetMapId, nX=nTargetX, nY=nTargetY}});
end

-- 特权家族工资
function Player:ActionKinWage()
	if (GLOBAL_AGENT) then
		return;
	end
	local nAction = me.GetTask(2196,1);
	local nDate	  = tonumber(GetLocalDate("%Y%m"));
	--已经激活
	if nAction >= nDate then
		return;
	end
	if me.GetExtMonthPay() < EventManager.IVER_nPlayerFuli_KinWage then
		me.Msg("需要充值达到50元才能激活该功能。")
		return;
	end
	--账号已经激活过
	if me.GetAccTask("tequan.kinWage") >= nDate then
		me.Msg("Mỗi tài khoản chỉ có thể kích hoạt 1 nhân vật.");
		return;
	end
	
	me.SetAccTask("tequan.kinWage", nDate);
	me.SetTask(2196, 1, nDate);
	me.Msg("Đã kích hoạt thành công tư cách tiền lương gia tộc.");
	Dbg:WriteLog("TeQuanFuli", "激活家族工资特权资格", me.szName);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "激活家族工资特权资格");
end
Player.c2sFun["ActionKinWage"] = Player.ActionKinWage;

function Player:OpenConsumeUrl()
	me.CallClientScript({"OpenWebSite", "http://zt.xoyo.com/jxsj/mall/"});
end

-- 年底积分清空提醒
function Player:ConsumeClearPrompt()
	local nDate = tonumber(GetLocalDate("%m%d"));
	if nDate < self.COMSUME_CLEAR_PROMPT_DAY then
		return;
	end
	local nMoney = me.GetTask(2070, 6);
	if nMoney < self.COMSUME_CLEAR_PROMPT_POINT then
		return;
	end
	local nYear = GetLocalDate("%Y");
	me.Msg(string.format("Gợi ý: 0 giờ 31/12/%s, điểm tích lũy tiêu hao Kỳ Trân Các sẽ bị hủy, hãy mau sử dụng điểm tích lũy tiêu hao.<color=yellow>CTRL+G hoặc Kỳ Trân Các để mở cửa hàng điểm tích lũy<color>", nYear));
end

function Player:OnPlayerLeaveTeam()
	local pCarrier = me.GetCarrierNpc();
	if not pCarrier then
		return;
	end 
	
	Npc.tbCarrier:OnPlayerLeaveTeam(pCarrier, me);
end

end

if MODULE_GAMECLIENT then

-- 获得客户端玩家的名字
function Player:GetPlayerName()
	if not me or not me.szName then
		return ""
	end
	return me.szName
end
function Player:GetViewInfo_C(nFaction,nLevel,szName)
	local szNameShow = "Tên: " .. "<color=yellow>".. szName .. "<color>";
	local szFaction = "Cấp: " .. "<color=yellow>" .. nLevel .. "<color>";
	local szLevel = "Môn phái: " .. "<color=yellow>" .. Player:GetFactionRouteName(nFaction).. "<color>";
	local szMsg = string.format("%s\n\n%s\n\n%s\n",szNameShow,szLevel, szFaction);
	ShowEquipLink("", szMsg, "");
end

--查看玩家信息
function Player:GetViewInfo(szName)
	me.CallServerScript({ "PlayerCmd", "GetViewInfo_GS", szName});
end


function Player:OnSelectNpc(pNpc)
	local tbTemp = me.GetTempTable("Npc");
	tbTemp.pSelectNpc = pNpc;
	CoreEventNotify(UiNotify.emCOREEVENT_SYNC_SELECT_NPC);
end

function Player:OnChangeState(nState)
	CoreEventNotify(UiNotify.emCOREEVENT_CHANGEWAITGETITEMSTATE, nState);
	if (nState == 2) then
		CoreEventNotify(UiNotify.emCOREEVENT_UPDATEBANKINFO);
	end
end

function Player:NotifyItemTimeOutClient(nType, szDate)
	
	if (szDate and nType == 46) then -- 返还券
		me.Msg("Phản Hoàn Quyển trong ".. szDate .." sẽ hết hạn, mau dùng hết, tránh lãng phí.");
	elseif (nType == 45) then
		me.Msg("Trong túi hoặc thương khố có huyền tinh sắp quá hạn.");
	end
	CoreEventNotify(UiNotify.emCOREEVENT_SET_POPTIP, nType);
end

function Player:OnBuyJiuZhuan()
	local tbMsg = {};
	tbMsg.szMsg = string.format("Bạn không có <color=yellow>Cửu Chuyển Tục Mệnh Hoàn<color>. Bạn muốn tốn <color=red>50 %s<color> trị thương?", IVER_g_szCoinName);
	tbMsg.nOptCount = 2;
	function tbMsg:Callback(nOptIndex)
		if (nOptIndex == 2) then
				if (me.IsAccountLock() ~= 0) then
					UiNotify:OnNotify(UiNotify.emCOREEVENT_SET_POPTIP, 44);
					me.Msg("Tài khoản đang khóa, không thực hiện thao tác này được!");
					Account:OpenLockWindow(me);
					return;
				end
				if IVER_g_nSdoVersion == 0 then
					if (me.nCoin >= 50) then
						me.CallServerScript({"ApplyBuyJiuZhuan"});
					else
						me.Msg("Bạn không đủ đồng.");
					end
				else
					me.CallServerScript({"ApplyBuyJiuZhuan"});
				end
		end
	end
	UiManager:OpenWindow(Ui.UI_MSGBOX, tbMsg);
end

function Player:UpdateDrawMantle()
	Ui(Ui.UI_PLAYERPANEL):UpdateDrawMantle();	
end

function Player:GetPluginUseState()
	local tbNameList = KInterface.GetPluginNameList() or {};
	local nState = KInterface.GetPluginManagerLoadState()
	if (1 == nState) then
		local nPluginNum = 0;
		for _, szName in pairs(tbNameList) do
			local tbInfo = KInterface.GetPluginInfo(szName);
			if (tbInfo.nLoadState == 1) then
				nPluginNum = nPluginNum + 1;
			end
		end
		if (nPluginNum > 0) then
			me.CallServerScript({"RecordPluginUseState", me.szName, nPluginNum});
		end
	end
end

function Player:JiesuoNotify()	
	local tbMsg = {};
	tbMsg.szMsg = "Tài khoản khóa đã bị hủy";
	tbMsg.nOptCount = 1;
	UiManager:OpenWindow(Ui.UI_MSGBOX, tbMsg);
end

-- 提醒用户正在申请取消帐号锁
function Player:ApplyJiesuoNotify(dwApplyTime)
	local tbMsg = {};
	tbMsg.szMsg = "Tài khoản đang <color=red>xin trợ giúp mở khóa<color>, nhấp \"Xác nhận\" kiểm tra chi tiết.";
	tbMsg.nOptCount = 2;
	function tbMsg:Callback(nOptIndex)
		if (nOptIndex == 2) then			
			local szSay = "Một nhân vật khác trong tài khoản đã xin đóng bảo vệ tài khoản. Nếu bạn không làm thao tác này, xin lập tức hủy bỏ, dùng phần mềm diệt virus mới nhất quét virus Trojan và đổi mật mã để đảm bảo an toàn cho tài khoản."..
			"\nNhắc nhở: Xin đóng bảo vệ tài khoản sẽ có hiệu lực khi đăng nhập lại sau <color=yellow>5<color> ngày kể từ ngày xin phép.";
			if dwApplyTime ~= nil then
				szSay = "Vào <color=white><bclr=blue>"..os.date("%Y - %m - %d  %H giờ %M phút %S giây", dwApplyTime)..
				"<bclr><color> xin đóng bảo vệ tài khoản. Nếu bạn không làm thao tác này, xin lập tức hủy bỏ, dùng phần mềm diệt virus mới nhất quét virus Trojan và đổi mật mã để đảm bảo an toàn cho tài khoản."..
				"\nNhắc nhở: Xin đóng bảo vệ tài khoản sẽ có hiệu lực sau <color=white><bclr=blue>"..os.date("%Y - %m - %d  %H giờ %M phút %S giây", dwApplyTime + 5 * 24 * 60 * 60).."<bclr><color> sau đăng nhập lại mới có hiệu lực";
			end
			if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then -- 有 白驹经验等 对话框打开时
				me.Msg(szSay);
			else
				Dialog:Say(szSay);
			end		
		end
	end
 
	UiManager:OpenWindow(Ui.UI_MSGBOX, tbMsg);

	Player.bApplyingJiesuo = 1;
end

function Player:SyncJiesuoState_C(bCanApplyJiesuo, bApplyingJiesuo, dwApplyTime)
	self.bCanApplyJiesuo = bCanApplyJiesuo;
	self.bApplyingJiesuo = bApplyingJiesuo;
	self.dwApplyJiesuoTime = dwApplyTime;	
end

function Player:SetActiveAura(nActiveAura)
	me.SetAuraSkill(nActiveAura);
end

function Player:BindInfoSync(nBind1, nBind2)
	if (UiManager:WindowVisible(Ui.UI_REPOSITORY) == 1) then
		Ui(Ui.UI_REPOSITORY):UpdateBindInfo(nBind1, nBind2);
	end
end

end

-- 客户端 当生命低于25%时候 
------------------------------------------------------------------------
function Player:LifeIsPoor_C()
	if (me.nLevel > 20) then
		return;
	end;
	
	local bHave = false;
	local tbBuffList = me.GetBuffList();
	for i = 1, #tbBuffList do
		local tbInfo = me.GetBuffInfo(tbBuffList[i].uId);
		if (tbInfo.nSkillId == 476) then
			bHave = true;
		end;
	end;
	
	local pNpc = me.GetNpc();
	if (not bHave and pNpc) then
		pNpc.Chat("Điềm Tửu Thúc nhắc ta nên ăn khi chiến đấu ngoài rừng!");
	end;
end;

function Player:LogPluginUseState(bExchangeServerComing)
	if (bExchangeServerComing ~= 1) then
		me.CallClientScript({"Player:GetPluginUseState"});
	end
end

function Player:CallGlobalFriends(szFunc, ...)
	return Player.tbGlobalFriends[szFunc](Player.tbGlobalFriends, ...);
end

function Player:TellNewServerRule(nServerOpenDays, nLimit)
	local szMsg = string.format(
		"Để nhiều người chơi có thể tham gia trò chơi, tối đa đăng nhập được %d client đến server đã mở <color=green>%d ngày<color>.",
		nLimit,
		nServerOpenDays
		);
		
	local tbMsg = {};
    tbMsg.szMsg = szMsg;
	tbMsg.nOptCount = 1;
	tbMsg.tbOptTitle = { "Đồng ý" };
    UiManager:OpenWindow(Ui.UI_MSGBOX, tbMsg);
end

-- 清除月已消费充值点数
function Player:ResetMonthPayPoint()
	me.SetTask(2137,2,0);
	me.SetTask(2137,3,GetTime());
end

function Player:OnLogin_DrawMantle()
	local nValue = me.GetTask(self.TSK_GROUP_HIDE_MANTLE, self.TSK_SUB_HIDE_MANTLE);
	me.SetBeHideMantle(nValue);
	-- 通知UI设置按钮状态
	me.CallClientScript({"Player:UpdateDrawMantle"});
end

function Player:IsHideMantle()
	local nValue = me.GetTask(self.TSK_GROUP_HIDE_MANTLE, self.TSK_SUB_HIDE_MANTLE);
	return nValue;	
end

-- Player.c2sFun = {};
function Player:OnClientClickHideMantle(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local nTask = pPlayer.GetTask(self.TSK_GROUP_HIDE_MANTLE, self.TSK_SUB_HIDE_MANTLE);
	if nTask == 0 then	-- 申请隐藏披风
		pPlayer.SetTask(self.TSK_GROUP_HIDE_MANTLE, self.TSK_SUB_HIDE_MANTLE, 1);
	else  -- 申请取消披风隐藏
		pPlayer.SetTask(self.TSK_GROUP_HIDE_MANTLE, self.TSK_SUB_HIDE_MANTLE, 0);
	end
	
	pPlayer.SetBeHideMantle(pPlayer.GetTask(self.TSK_GROUP_HIDE_MANTLE, self.TSK_SUB_HIDE_MANTLE));
end
Player.c2sFun["OnClickHideMantle"] = Player.OnClientClickHideMantle;

function Player:ClientApplyRepositoryInfo(nPlayerId, nType)
	-- 不能没有TYPE
	if (not nType) then
		return;
	end

	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not Player then
		return;
	end
	
	me.ApplyRepItemInfo(nType);
end
Player.c2sFun["ApplyRepositoryInfo"] = Player.ClientApplyRepositoryInfo;
	

function Player:ViewEquipOnMe(pViewPlayer)
	if not pViewPlayer then
		return;
	end
	
	local nHonorLevel = me.GetHonorLevel();
	local szMsg = self.tbViewEquipMsg[nHonorLevel] or "";
	if szMsg and szMsg ~= "" then
		me.Msg(string.format("%s%s", pViewPlayer.szName, szMsg));
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", string.format("<color=yellow>%s%s<color>", pViewPlayer.szName, szMsg)});
		--pViewPlayer.Msg(self.szBeViewdEquipMsg);
		--pViewPlayer.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", string.format("<color=yellow>%s<color>", self.szBeViewdEquipMsg)});
	end
end

--为了减少客户端收包数量，对重复性的通知进行一次性通知处理
function Player:BuyGoodsMsg(nCount,szGoodsName)
	if not MODULE_GAMESERVER then
		return;
	end
	if not nCount or nCount == 0 then
		return;
	end
	if not szGoodsName or #szGoodsName == 0 then
		return;
	end
	me.Msg(string.format("Tổng cộng nhận được %d %s!",nCount,szGoodsName),"");
end

-- 发消息给指定名字的玩家
function Player:Msg2Player(szPlayerName, szMsg, szTitle)
	local pPlayer	= KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		return 0;
	end
	pPlayer.Msg(szMsg, szTitle);
end

function Player:GetCloseSyncTeamResultFlag()
	return tonumber(KGblTask.SCGetDbTaskInt(DBTASK_CLOASE_TEAMLINK)) or 0;
end

--设置新手状态，状态为1则50级判断失效
function Player:SetFreshState(pPlayer, nState)
	if nState <= 0 then
		nState = 0;
	elseif nState > 1 then
		nState = 1;
	end
	pPlayer.SetTask(2179,20,nState);
	pPlayer.SendSyncData();
end

-------------------------------------------------------------------------


-- 注册通用上线事件
PlayerEvent:RegisterGlobal("OnLogin", Player._OnLogin, Player);

-- 注册通用下线事件
PlayerEvent:RegisterGlobal("OnLogout", Player._OnLogout, Player);

-- 注册升级回掉
PlayerEvent:RegisterGlobal("OnLevelUp", Player._OnLevelUp, Player);

-- 注册玩家死亡事件
PlayerEvent:RegisterGlobal("OnDeath", Player._OnDeath, Player);

-- 注册通用杀怪事件
PlayerEvent:RegisterGlobal("OnKillNpc", Player._OnKillNpc, Player);

PlayerEvent:RegisterGlobal("OnCampChange", Player._OnCampChange, Player);

-- 注册定期清心得书使用事件
PlayerSchemeEvent:RegisterGlobalDailyEvent({Player.ClearInsightBookUsedCount, Player});

PlayerEvent:RegisterGlobal("OnLogin", Player.OnLogin_AccountSafe, Player);

PlayerEvent:RegisterGlobal("OnLogin", Player.OnLogin_StatComeBack, Player);

PlayerEvent:RegisterGlobal("OnLogin", Player.OnLogin_OnSetComeBackOldPlayer, Player);

PlayerEvent:RegisterGlobal("OnLogin", Player.LogPluginUseState, Player);

PlayerSchemeEvent:RegisterGlobalMonthEvent({Player.ResetMonthPayPoint, Player});

PlayerEvent:RegisterGlobal("OnLogin", Player.OnLogin_DrawMantle, Player);
---- 注册定期清xxxx
--PlayerSchemeEvent:RegisterGlobalDailyEvent({Player.ClearCibeixinjingUsedAmount, Player});
--
