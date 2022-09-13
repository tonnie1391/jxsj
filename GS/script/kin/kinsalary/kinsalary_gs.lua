-------------------------------------------------------
-- 文件名　：kinsalary_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-07-02 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\kin\\kinsalary\\kinsalary_def.lua");

-- 消息封装
function Kinsalary:SendMessage(pPlayer, nType, szMsg)
	if nType == self.MSG_CHANNEL then
		pPlayer.Msg(szMsg);
	elseif nType == self.MSG_BOTTOM then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	elseif nType == self.MSG_MIDDLE then
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
end

-- 增加工资判定
function Kinsalary:CheckAddSalary(pPlayer, nType)
	
	-- 活动类型
	local tbInfo = self.EVENT_TYPE[nType];
	if not tbInfo then
		return 0;
	end
	
	-- 存在家族
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	-- 存在成员
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	
	-- 正式成员
	if Kin:CheckSelfRight(nKinId, nMemberId, 3) ~= 1 then
		return 0;
	end

	-- 周目标
	local nRate = 1;
	local nKinTask = pKin.GetSalaryCurTask();
	if nKinTask > 0 and nKinTask == nType then
		nRate = self.WEEKTASK_MULTI;
	end
	
	-- 改为比较次数
	local szTimes = pMember["Get"..tbInfo.szTimes]();
	if szTimes >= tbInfo.nMaxTimes  then
		return 0;
	end
	
	return 1;
end

-- 增加工资申请
function Kinsalary:AddSalary_GS(pPlayer, nType)
	
	if self:CheckAddSalary(pPlayer, nType) ~= 1 then 
		return 0;
	end
	
	local nKinId, nMemberId = pPlayer.GetKinMember();
	GCExcute{"Kinsalary:AddSalary_GC", nKinId, nMemberId, nType};
end

-- 增加工资执行
function Kinsalary:DoAddSalary_GS(nKinId, nMemberId, nType, nSalary)
	
	local tbInfo = self.EVENT_TYPE[nType];
	local pKin = KKin.GetKin(nKinId);
	local pMember = pKin.GetMember(nMemberId);
			
	-- 更新数据
	pKin.AddSalaryCurWeek(nSalary);
	pMember.AddSalaryCurWeek(nSalary);
	pMember["Add"..tbInfo.szKey](nSalary);
	pMember["Add"..tbInfo.szTimes](1);
	
	-- 更新家族等级
	local nKinSalary = pKin.GetSalaryCurWeek();
	local nCurSalaryLevel = pKin.GetSalaryCurLevel();
	local nLevel = self:GetKinSalaryLevel(nKinSalary);
	if nLevel > nCurSalaryLevel then
		pKin.SetSalaryCurLevel(nLevel);
		KKin.Msg2Kin(nKinId, string.format("Mức độ hoạt động của Gia tộc đạt cấp %s. Thỏi bạc hoạt động sẽ tăng %s lần cho các thành viên.", nLevel, self.MEMBER_AWARD[nLevel]));
	end
	
	-- 找玩家
	local nPlayerId = pMember.GetPlayerId();
	if not nPlayerId or nPlayerId <= 0 then
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	-- 频道公告
	self:SendMessage(pPlayer, self.MSG_CHANNEL, string.format("Thông qua %s, bạn nhận được %s lương gia tộc.", tbInfo.szName, nSalary));
end

-- 领取工资
function Kinsalary:GetSalary_GS(pPlayer)
	
	-- 找家族
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	
	-- 解锁判定
	if pPlayer.IsAccountLock() ~= 0 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Tài khoản đang khóa, không thể thao tác.");
		return 0;
	end
	
	-- 等级限制
	if pPlayer.nLevel < self.MIN_LEVEL then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, string.format("Đẳng cấp chưa đạt %s, không thể thao tác", self.MIN_LEVEL));
		return 0;
	end
	
	-- 周一晚1900点
	local nDay = tonumber(os.date("%w", GetTime()));
	local nTime = tonumber(GetLocalDate("%H%M"));
	if nDay == 1 and nTime < self.TIME_GETSALARY then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Lương gia tộc chỉ có thể nhận sau 19 giờ.");
		return 0;
	end
	
	-- 没有工资
	local nSalary = pMember.GetSalaryLastWeek();
	if nSalary <= 0 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Không có phần thưởng để nhận.");
		return 0;
	end
	
	-- 是否维护完了
	local nCurSession = tonumber(os.date("%Y%W", GetTime()));
	local nSysSession = KGblTask.SCGetDbTaskInt(DBTASK_KINSALARY_SESSION);
	
	if nCurSession ~= nSysSession then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Hệ thống đang bảo trì, hãy đến nhận sau!");
		return 0;
	end
	
	-- 是否领取
	local nGetAward = pPlayer.GetTask(self.TASK_GID, self.TASK_GETAWARD);
	if nGetAward == 1 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Bạn đã nhận lương tuần rồi!");
		return 0;
	end
	
	-- 家族倍数
	local nKinSalaryLevel = pKin.GetSalaryLastLevel();
	local nMemberRate = self.MEMBER_AWARD[nKinSalaryLevel] or 1;
	local nCaptainRate = self.CAPTAIN_AWARD[nKinSalaryLevel] or 1;
	
	-- 族长只能领一次
	local nCaptain = Kin:CheckSelfRight(nKinId, nMemberId, 1);
	if nCaptain == 1 and pKin.GetSalaryCaptainGet() ~= 1 then
		nSalary = math.floor(nSalary * nCaptainRate);
	else
		nSalary = math.floor(nSalary * nMemberRate);
	end
	
	-- 加家族银锭
	local nYinding = pPlayer.GetTask(self.TASK_GID, self.TASK_YINDING);
	if nYinding +  nSalary > self.MAX_NUMBER then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Thỏi bạc gia tộc mang theo vượt quá giới hạn.");
		return 0;
	end
	
	-- 充值判定
	local nVipPlayer = pPlayer.GetTask(self.TASK_GID, self.TASK_VIPPLAYER);
	
	-- 计算数量
	local nCount = 0;
	if nVipPlayer >= tonumber(GetLocalDate("%Y%m")) then
		nCount = math.floor(nSalary / 1000);
	elseif IpStatistics:CheckStudioRole(pPlayer) ~= 1 and nSalary >= math.floor(self.MIN_SALARY * Lib:_GetXuanEnlarge(self:GetOpenDay())) then
		nCount = (MathRandom(1, 100) > 50) and 1 or 0;
	elseif nSalary >= math.floor(self.MIN_SALARY * Lib:_GetXuanEnlarge(self:GetOpenDay())) then
		nCount = (MathRandom(1, 100) > 95) and 1 or 0;
	end
	
	-- 背包空间
	local nNeed = 1;
	if pPlayer.CountFreeBagCell() < nNeed then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, (string.format("Hành trang không đủ %s ô trống.", nNeed)));
		return 0;
	end
	
	pPlayer.SetTask(self.TASK_GID, self.TASK_YINDING, nYinding + nSalary);
	self:SendMessage(pPlayer, self.MSG_CHANNEL, string.format("Nhận được %s Thỏi bạc gia tộc", nSalary));
	
	-- 加不绑定道具
	pPlayer.AddStackItem(self.ITEM_YUANBAO[1], self.ITEM_YUANBAO[2], self.ITEM_YUANBAO[3], self.ITEM_YUANBAO[4], nil, nCount);
	StatLog:WriteStatLog("stat_info", "family_salary", "get_salary", pPlayer.nId, nSalary, nCount, nVipPlayer);
	
	-- 频道公告
	pPlayer.SendMsgToFriend(string.format("Hảo hữu [%s] nhận được <color=green>%s Thỏi bạc gia tộc<color> và <color=green>%s Thỏi vàng gia tộc<color>", pPlayer.szName, nSalary, nCount));
	Player:SendMsgToKinOrTong(pPlayer, string.format(" nhận được %s Thỏi bạc gia tộc và %s Thỏi vàng gia tộc", nSalary, nCount));
	
	-- 家族技能
	local nPoint = math.floor(nSalary / 30 / Lib:_GetXuanEnlarge(self:GetOpenDay()));
	self:AddKinSkillExp(nKinId, nPoint);
	self:AddKinSkillOffer(pPlayer, nPoint);
	KinRepository:AddRepBuildValue(pPlayer.nId, math.floor(nSalary / Lib:_GetXuanEnlarge(self:GetOpenDay())));
	
	-- 记任务变量
	pPlayer.SetTask(self.TASK_GID, self.TASK_GETAWARD, 1);

	-- 增加股份		
	Tong:AddStockBaseCount_GS1(pPlayer.nId, math.floor(nSalary / 10 / Lib:_GetXuanEnlarge(self:GetOpenDay())), 0.8, 0.1, 0.1, 0, 0);
		
	-- 增加族长和副族长的领袖荣誉
	if nCaptain == 1 and pKin.GetSalaryCaptainGet() ~= 1 then
		local tbHonor = {100, 200, 300};  -- 1到3级的领袖荣誉表
		local nCaptainId = Kin:GetPlayerIdByMemberId(nKinId, pKin.GetCaptain());	-- 族长ID
		local nAssistantId = Kin:GetPlayerIdByMemberId(nKinId, pKin.GetAssistant()); -- 副族长ID
		if tbHonor[nKinSalaryLevel] then
			PlayerHonor:AddPlayerHonorById_GS(nCaptainId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[nKinSalaryLevel]);
			PlayerHonor:AddPlayerHonorById_GS(nAssistantId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[nKinSalaryLevel]/2);
		end
	end
	
	-- 增加江湖威望;
	pPlayer.AddKinReputeEntry(nCount);
	
	-- 完成任务
	if pPlayer.GetTask(1022, 224) == 1 and nSalary >= 1000 then
		pPlayer.SetTask(1022, 224, 2);
	end
	
	-- 调用gc执行
	GCExcute{"Kinsalary:GetSalary_GC", nKinId, nMemberId};
end

function Kinsalary:DoGetSalary_GS(nKinId, nMemberId)
	
	-- 存在家族
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	-- 存在成员
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	
	-- 族长领取一次
	if Kin:CheckSelfRight(nKinId, nMemberId, 1) == 1 then
		pKin.SetSalaryCaptainGet(1);
	end

	-- 清空上周工资
--	pMember.SetSalaryLastWeek(0);
end

-- 更新周数据
function Kinsalary:UpdateKinWeeklyTask_GS(nKinId, nNewTask, nLastTask, nLastWeek, nLastLevel)
	
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	-- 更新数据
	pKin.SetSalaryLastTask(nLastTask);
	pKin.SetSalaryCurTask(nNewTask);
	pKin.SetSalaryLastWeek(nLastWeek);
	pKin.SetSalaryCurWeek(0);
	pKin.SetSalaryLastLevel(nLastLevel);
	pKin.SetSalaryCurLevel(0);
	pKin.SetSalaryCaptainGet(0);
	
	-- 更新成员数据
	self:UpdateKinMemberWeeklyTask(pKin);
end

-- 增加家族经验
function Kinsalary:AddKinSkillExp(nKinId, nCount)
	if Kin.tbKinSkill.Open ~= 1 then
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local nLevel = pKin.GetSkillLevel();
	local nMaxLevel = #Kin.tbKinSkill.tbLevelExp;
	if nLevel >= nMaxLevel - 1 then
		return 0;
	end
	GCExcute{"Kin:AddSkillExp_GC", nKinId, nCount};
end

-- 增加个人功勋
function Kinsalary:AddKinSkillOffer(pPlayer, nCount)
	if Kin.tbKinSkill.Open ~= 1 then
		return 0;
	end
	local nOffer = pPlayer.GetTask(Kin.TASK_GROUP, Kin.TASK_SKILLOFFER);
	if nOffer >= 2000000000 then
		self:SendMessage(pPlayer, self.MSG_CHANNEL, "你的功勋值已经达到上限了，无法再获取了。");
		return 0;
	end
	pPlayer.SetTask(Kin.TASK_GROUP, Kin.TASK_SKILLOFFER, nOffer + nCount);
	self:SendMessage(pPlayer, self.MSG_CHANNEL, string.format("你获得了%s点家族功勋", nCount));
end

-- 打开商店
function Kinsalary:OpenShop(pPlayer, nType)
	if GLOBAL_AGENT then
		return 0;
	end
	if not self.SHOP_TYPE[nType] then
		return 0;
	end
	if pPlayer.nFightState > 0 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "战斗状态无法打开商店。");
		return 0;
	end
	if pPlayer.IsAccountLock() ~= 0 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "你的账号处于锁定状态，无法打开商店。");
		return 0;
	end
	pPlayer.OpenShop(nType, 10);
end

-- 判定奖励最大银两
function Kinsalary:GetMaxMoney(tbAward)
	local nMaxValue = 0;
	for _, tbInfo in ipairs(tbAward) do
		if tbInfo[1] == "绑银" and nMaxValue < tbInfo[2] then
			nMaxValue = tbInfo[2];
		end
	end
	return nMaxValue;
end

-- 随机奖励
function Kinsalary:RandomAward(pPlayer, tbAward, nType)
	local nRate = MathRandom(1000000);
	local nAdd = 0;
	local nFind = 0;
	for i, tbInfo in ipairs(tbAward) do
		nAdd = nAdd + tbInfo[3];
		if nRate <= nAdd then
			nFind = i;
			break;
		end
	end
	if nFind > 0 then
		local tbFind = tbAward[nFind];
		if tbFind[1] == "玄晶" then
			if nType == 1 then
				pPlayer.AddItemEx(18, 1, 114, tbFind[2]);
				StatLog:WriteStatLog("stat_info", "family_salary", "open_box", pPlayer.nId, nType, string.format("%s_%s_%s_%s", 18, 1, 114, tbFind[2]), 1);
			else
				pPlayer.AddItemEx(18, 1, 1, tbFind[2]);
				StatLog:WriteStatLog("stat_info", "family_salary", "open_box", pPlayer.nId, nType, string.format("%s_%s_%s_%s", 18, 1, 1, tbFind[2]), 1);
			end
		elseif tbFind[1] == "绑金" then
			pPlayer.AddBindCoin(tbFind[2]);
			StatLog:WriteStatLog("stat_info", "family_salary", "open_box", pPlayer.nId, nType, tbFind[1], tbFind[2]);
		elseif tbFind[1] == "绑银" then
			pPlayer.AddBindMoney(tbFind[2]);
			StatLog:WriteStatLog("stat_info", "family_salary", "open_box", pPlayer.nId, nType, tbFind[1], tbFind[2]);
		end
	end
end

-- 获取家族信息
function Kinsalary:GetKinSalaryInfo(pPlayer)
	
	-- 存在家族
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	-- 存在成员
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end

	-- 工资数据
	local tbInfo = 
	{
		nSalaryCurWeek  = pKin.GetSalaryCurWeek(),
		nSalaryLastWeek	= pKin.GetSalaryLastWeek(),
		nSalaryCurTask	= pKin.GetSalaryCurTask(),
		nSalaryLastTask	= pKin.GetSalaryLastTask(),
		nSalaryCurLevel	= pKin.GetSalaryCurLevel(),
		nSalaryLastLevel	= pKin.GetSalaryLastLevel(),
		nSalaryCaptainGet	= pKin.GetSalaryCaptainGet(),
	};
	
	return tbInfo;
end

-- 获取成员信息
function Kinsalary:GetPlayerSalaryInfo(pPlayer)
	
	-- 存在家族
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	-- 存在成员
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	
	-- 工资数据
	local tbInfo = 
	{
		nSalaryVipPlayer = pPlayer.GetTask(self.TASK_GID, self.TASK_VIPPLAYER),
		nSalaryGetAward = pPlayer.GetTask(self.TASK_GID, self.TASK_GETAWARD),
		nSalaryJinDing = pPlayer.GetTask(self.TASK_GID, self.TASK_JINDING),
		nSalaryYinDing = pPlayer.GetTask(self.TASK_GID, self.TASK_YINDING),
	};
	
	for i, tbT in ipairs(self.EVENT_TYPE) do
		tbInfo["n"..tbT.szKey] = pMember["Get"..tbT.szKey]();
		tbInfo["n"..tbT.szTimes] = pMember["Get"..tbT.szTimes]();
	end
	
	return tbInfo;
end

-- 设置家族数据
function Kinsalary:SetKinSalaryInfo(pPlayer, szType, nValue)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	GCExcute({"Kinsalary:SetKinSalaryInfo_GC", nKinId, szType, nValue});
end

function Kinsalary:DoSetKinSalaryInfo(nKinId, szType, nValue)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	pKin["Set"..szType](nValue);
end

-- 设置成员数据
function Kinsalary:SetMemberSalaryInfo(pPlayer, szType, nValue)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	GCExcute({"Kinsalary:SetMemberSalaryInfo_GC", nKinId, nMemberId, szType, nValue});
end

function Kinsalary:DoSetMemberSalaryInfo(nKinId, nMemberId, szType, nValue)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	pMember["Set"..szType](nValue);
end

-- 打开家族商店
function c2s:ApplyKinSalaryOpenShop(nType)
	if GLOBAL_AGENT then
		return 0;
	end
	Kinsalary:OpenShop(me, nType);
end

-- 打开工资界面
function c2s:ApplyKinOpenSalary()
	
	local nKinId, nMemberId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end

	local nKinSalaryLevel = pKin.GetSalaryLastLevel();
	local nMemberRate = Kinsalary.MEMBER_AWARD[nKinSalaryLevel] or 1;
	local nCaptainRate = Kinsalary.CAPTAIN_AWARD[nKinSalaryLevel] or 1;

	local nExtra = 1;
	if Kin:CheckSelfRight(nKinId, nMemberId, 1) == 1 and pKin.GetSalaryCaptainGet() ~= 1 then
		nExtra = nCaptainRate;
	else
		nExtra = nMemberRate;
	end
	
	local tbInfo = 
	{
		nGetAward = me.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_GETAWARD),
		nVipPlayer = me.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_VIPPLAYER),
		nSalary = pMember.GetSalaryLastWeek(),
		nTotal = math.floor(pMember.GetSalaryLastWeek() * nExtra),  
	};
	
	me.CallClientScript({"UiManager:OpenWindow", "UI_KIN_GET_SALARY"});
	me.CallClientScript({"Ui:ServerCall", "UI_KIN_GET_SALARY", "OnRecvData", tbInfo});
end

-- 获取工资
function c2s:ApplyKinGetSalary()
	
	-- 激活特权的角色直接领取
	local nVipPlayer = me.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_VIPPLAYER);
	if nVipPlayer >= tonumber(GetLocalDate("%Y%m")) then
		Kinsalary:GetSalary_GS(me);
		
	-- 提示充值和激活
	else
		local szMsg = "    Ngươi muốn nhận lương gia tộc tuần trước đúng chứ?";
		local tbOpt = 
		{
			-- {"<color=yellow>立即充值<color>", c2s.ApplyOpenOnlinePay, c2s},
			-- {"<color=yellow>激活特权<color>", Player.ActionKinWage, Player},
			{"Nhận lương gia tộc", Kinsalary.GetSalary_GS, Kinsalary, me},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
	end	
end

-- 测试指令
function Kinsalary:_T1(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	GCExcute({"Kinsalary:_T1_GC", nKinId});
end

-- 每周事件
function Kinsalary:PlayerWeeklyEvent()
	me.SetTask(self.TASK_GID, self.TASK_GETAWARD, 0);
end

-- 注册玩家事件
PlayerSchemeEvent:RegisterGlobalWeekEvent({Kinsalary.PlayerWeeklyEvent, Kinsalary});
