------------------------------------------------------
-- 文件名　：partner_gs.lua
-- 创建者　：dengyong
-- 创建时间：2009-12-09 20:28:42
-- 描  述  ：服务端可以被客户端调用的相关接口
------------------------------------------------------
--  注意：在服务器端（GS），在全局表Partner上挂了一个变量bClosePartnerTimer，该变量默认是没有定义的，
--        即该值为NIL，该值的作用是用来全局控制同伴动画效果TIMER的开关，只要该变量被赋值之后，所有的
--        同伴动画效果TIMER都将失效，所以该变量要慎用！！

if not MODULE_GAMESERVER then
	return;
end

if not Partner then
	Partner = {};
end

Partner.c2sFun = {};
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	Partner.c2sFun[szName] = fun;
end

-- 提升等级，一次只能升一级，剩余的经验继续放到累计经验中
function Partner:Upgrade(nPartnerIndex)
	-- 锁定状态，不能升级
	if me.IsAccountLock() == 1 then
		me.Msg("Tài khoản đang khóa, không thể thao tác");
		Partner:SendClientMsg("Tài khoản đang khóa, không thể thao tác");
		Account:OpenLockWindow(me);
		return 0;
	end
	if Account:Account2CheckIsUse(me, 6) == 0 then
		Dialog:Say("Bạn đang sử dụng mật khẩu phụ để đăng nhập trò chơi, thiết lập sự kiểm soát quyền truy cập, hoạt động không thể được thực hiện!");
		return 0;
	end	
	local pPartner = me.GetPartner(nPartnerIndex);
	if not pPartner then
		me.Msg("Hãy chọn bạn đồng hành muốn thăng cấp!");
		return 0;
	end
		
	local nRes, varMsg = self:PreUpgrade(pPartner);
	if nRes ~= 1 then
		me.Msg(varMsg);
		Partner:SendClientMsg(varMsg);
		return 0;
	end
	
	local nNewLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL) + 1;
	local nTalent = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TALENT);
	local nTalentLevel = nTalent % 1000;	
	--如果等级是5的倍数，触发提升技能相关接口
	if nNewLevel % self.LEVELTOUPSKILL == 0 then
		if nTalentLevel < self.TALENT_MAX and self:CanUpgradeSkill(pPartner) == 1 then
			local szMsg = string.format("Mức lĩnh ngộ của đồng hành là <color=yellow>%d<color>, nếu thăng cấp sẽ có xác suất <color=yellow>%d%%<color> thăng cấp 1 kỹ năng ngẫu nhiên, ngươi quyết định thế nào?", nTalentLevel, nTalentLevel);
			local tbOpt = 
			{
				{"Tăng", self.SetLevelUp, self, me.nId, nPartnerIndex, 1},	-- 要升技能等级
				{"Không"},
			}
			Dialog:Say(szMsg, tbOpt);
		else
			self:SetLevelUp(me.nId, nPartnerIndex, 1);		-- 要升技能等级
		end
	else
		self:SetLevelUp(me.nId, nPartnerIndex, 0);		-- 不升技能等级
	end	

	return 1;
end
RegC2SFun("UpgradeLevel", Partner.Upgrade);

-- 第三个参数为0(默认为0)时表示只升等级，第三个参数为1时表示要升一下技能等级
function Partner:SetLevelUp(nPlayerId, nPartnerIndex, bUpSkill)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local pPartner = pPlayer.GetPartner(nPartnerIndex);
	if not pPartner then
		return;
	end
	
	bUpSkill = bUpSkill or 0;
	if bUpSkill == 1 then
		self:UpgradeSkill(pPartner);
	end
	
	local nCurLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);	-- 当前等级
	local nBalanceExp = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_EXP) - self.tbLevelSetting[nCurLevel].nExp;
	local nNewLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL) + 1;
	
	--同伴满级Log
	if nNewLevel == 120 then
		local nCreateTime = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_CREATETIME);
		local nCurrentTime = GetTime();
		local nTimeSpan = nCurrentTime - nCreateTime;
		local nHours = math.floor(nTimeSpan / 3600);
		local nMinutes = math.floor((nTimeSpan - nHours * 3600) / 60);
		local nSeconds = nTimeSpan % 60;
		local nDays = math.floor(nHours / 24);
		nHours = nHours % 24;
		local szLog = string.format("Đồng Hành Log:Đồng Hành %s của  %s Tăng đến 120 cấp, Cần %d Ngày %d Giờ %d Phút %dGiây", pPartner.szName,me.szName, nDays, nHours, nMinutes, nSeconds);
		Dbg:WriteLog(szLog);
	end
	
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_EXP, nBalanceExp);		-- 设置剩余经验
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_LEVEL, nNewLevel);		-- 设置新等级
	if nNewLevel == self.FRIENDSHIP_DECLEVEL then
		-- 玩家升到30级时，需要把上次衰减时间重置到升到30级的这一时刻
		self:ResetDecrTime(pPartner); -- 重置同伴亲密度衰减变量
	end
	self:CaclulatePotential(nPartnerIndex);
	
	pPlayer.Msg(string.format("Đồng hành %s đã thăng lên cấp %d", pPartner.szName, nNewLevel));
	
	-- 如果玩家有同伴教育任务-结伴上路，则记录任务变量。
	local tbPlayerTasks	= Task:GetPlayerTask(pPlayer).tbTasks;
	local tbTask = tbPlayerTasks[tonumber(self.TASK_LEVELUP_MAIN, 16)];	-- 主任务ID
	if tbTask and tbTask.nReferId == tonumber(self.TASK_LEVELUP_SUB, 16) then
		pPlayer.SetTask(self.TASKID_MAIN, self.TASKID_LEVELUP, 1);
	end
	
	PlayerHonor:UpdatePartnerValue(pPlayer, 0);
	--Player.tbFightPower:RefreshFightPower(pPlayer);
	PlayerHonor:UpdateFightPower(pPlayer);
	return 1;
end

-- 玩家申请召唤/召回 同伴
function Partner:CallPartner(nPartnerIndex)
	if me.nActivePartner == nPartnerIndex then
		--召回同伴，同时计算并扣除相应的亲密度
		self:DoPartnerCallBack(me, 1);
	
		return 1;
	else
		local pPartner = me.GetPartner(nPartnerIndex);
		if not pPartner then
			return;
		end
		
		-- 亲密度不足，不能召唤
		if pPartner.GetValue(self.emKPARTNERATTRIBTYPE_FRIENDSHIP) < self.FRIENDSHIP_SHUYUAN then
			local szMsg = string.format("Độ thân mật giảm xuống %s, đồng hành không còn muốn xuất chiến.", pPartner.szName);
			me.Msg(szMsg);
			self:SendClientMsg(szMsg);
			return 0;
		end
		
		-- 战斗状态下要读条，非战斗状态下不读条
		if (me.nFightState == 1 ) then
		
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
				Player.ProcessBreakEvent.emEVENT_LOGOUT,
				Player.ProcessBreakEvent.emEVENT_DEATH,
				Player.ProcessBreakEvent.emEVENT_ATTACKED,
			}
			
			GeneralProcess:StartProcess("Đang xuất chiến...", self.CALLPROCESSTIME * Env.GAME_FPS, {self.CallSucc, self, me.nId, nPartnerIndex}, nil, tbEvent);
		
		else
			
			self:CallSucc(me.nId, nPartnerIndex);
		end
			
		return 0;
	end
end
RegC2SFun("CallPartner", Partner.CallPartner);

function Partner:CallSucc(nPlayerId, nPartnerIndex)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local pPartner = pPlayer.GetPartner(nPartnerIndex);
	if not pPartner then
		return;
	end
	
	-- 唤回之前激活的同伴，同时计算扣除相应的亲密度
	self:DoPartnerCallBack(pPlayer, 1);	
	
	-- 激活新同伴
	pPlayer.SetActivePartner(nPartnerIndex);	
	-- 被召出来之后，要重新设置一下亲密度的扣除时间
	Partner:ResetDecrTime(pPartner); -- 重置同伴亲密度衰减变量
	
	if pPlayer.nFightState == 1 then
		self:OnCallPartner(nPlayerId, nPartnerIndex);
		-- 开启为同伴召出效果而加的定时器，总开关没有关闭的情况才开启
		self:RegisterPartnerTimer(pPlayer);
	end
	pPlayer.AddSkillState(self.CHUSHOUXIANGZHUID, 1, 1, 400000000, 1);	
	
	-- 弹出popo提示满经验
	local nCurLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);	-- 当前等级
	local nStoreMax = self:GetMaxStoreExp(pPartner);		-- 计算当前能累积的最大经验值
	local nCurExp = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_EXP);
	-- 可以升级给提示
	if nCurExp >= nStoreMax and nCurLevel < self.MAXLEVEL - 9 then
		pPlayer.CallClientScript({"PopoTip:ShowPopo", 23});
	elseif nCurLevel < self.MAXLEVEL and Partner.tbLevelSetting[nCurLevel] and
		nCurExp >= Partner.tbLevelSetting[nCurLevel].nExp then
		pPlayer.CallClientScript({"PopoTip:ShowPopo", 21});
	end
	
	--Player.tbFightPower:RefreshFightPower(pPlayer);
	PlayerHonor:UpdateFightPower(pPlayer);
	-- 因为现在所有同伴都加财富，召出召回已经不会改变同伴价值量了
	--PlayerHonor:UpdatePartnerValue(pPlayer, 0)
end

-- 当激活同伴被唤回时，做相关处理
function Partner:DoPartnerCallBack(pPlayer, bDecFS)
	-- 如果没有激活同伴，不做处理
	if pPlayer.nActivePartner == -1 then
		return;
	end
		
	-- 关闭TIMER
	self:UnRegisterPartnerTimer(pPlayer);
	
	bDecFS = bDecFS or 0;
	-- 如果在战斗状态中，召回当前同伴时需要扣除亲密度
	if bDecFS == 1 and pPlayer.nFightState == 1 then
		self:DecreaseFriendship(pPlayer.nId);
	end
	
	-- 先扣亲密度再召回
	pPlayer.SetActivePartner(-1);	-- 取消激活同伴
	
	pPlayer.RemoveSkillState(self.CHUSHOUXIANGZHUID);
end

-- 玩家申请解除同伴
-- 第二个参数为1时表示要检查同伴的星级，否则不需要检查，默认为1要检查
function Partner:DissolvePartner(nPartnerIndex)
	-- 账号处于锁定状态，不能解散同伴
	if me.IsAccountLock() == 1 then
		me.Msg("Tài khoản của bạn bị khóa, không thể giải tán đồng hành");
		Partner:SendClientMsg("Tài khoản của bạn bị khóa, không thể giải tán đồng hành");
		Account:OpenLockWindow(me);
		return 0;
	end
	if Account:Account2CheckIsUse(me, 6) == 0 then
		Dialog:Say("Bạn đang sử dụng mật khẩu phụ để đăng nhập trò chơi, thiết lập sự kiểm soát quyền truy cập, hoạt động không thể được thực hiện!");
		return 0;
	end		 
	local pPartner = me.GetPartner(nPartnerIndex);
	if not pPartner then
		return 0;
	end
	
	local nRes, szRet = self:CanDissolvePartner(pPartner);
	if nRes == 0 then	-- 如果要解散的同伴星级大于5.5，提示玩家到龙五太爷那儿去申请
		me.Msg(szRet);
		Partner:SendClientMsg(szRet);
		return 0;
	end

	local szMsg = string.format("Khi giải tán đồng hành, điểm tiềm năng, tài phú, kỹ năng hỗ trợ sẽ biến mất và không thể khôi phục. Bạn có muốn xóa Đồng Hành <color=red>%s<color>?", pPartner.szName);
	local tbOpt = 
	{
		{"Đồng ý", self.DissolveConfirm, self, me.nId, nPartnerIndex},
		{"Để ta suy nghĩ thêm"},
	}
	Dialog:Say(szMsg, tbOpt);
	
	return 1;
end
RegC2SFun("DissolvePartner", Partner.DissolvePartner);

function Partner:CanDissolvePartner(pPartner) 
	local nStarLevel = self:GetSelfStartCount(pPartner);
	
	local szMsg = "";
	if nStarLevel >= self.DELLIMITSTARLEVEL * 2 or pPartner.nSkillCount >= self.DELLIMITSKILLCOUNT then
		local nApplyTime = me.GetTask(self.TASK_DEL_PARTNER_GROUPID, self.TASK_DEL_PARTNER_SUBID);
		if nApplyTime == 0 then
			szMsg = string.format("Đồng hành trên %0.1f sao hoặc có hơn 7 kỹ năng phải gặp <color=yellow>Long Ngũ Thái Gia<color> mới có thể giải tán",self.DELLIMITSTARLEVEL, self.DELLIMITSKILLCOUNT);

			return 0, szMsg;
		end
		
		local nDiff = GetTime() - nApplyTime;
		if nDiff <= Partner.DEL_USABLE_MINTIME then	
			szMsg = string.format("Muốn xóa Đồng hành trên %0.1f sao, cần vài giờ chuẩn bị trước khi xóa toàn bộ", 
				(Partner.DEL_USABLE_MINTIME - nDiff)/3600, self.DELLIMITSTARLEVEL, self.DELLIMITSKILLCOUNT);
		elseif nDiff >= Partner.DEL_USABLE_MAXTIME then
			szMsg = "Yêu cầu giải tán đồng hành của bạn đã hết hạn, vui lòng thao tác lại";
		end	
	end	
	
	if szMsg == ""  then
		return 1;
	end
	
	return 0, szMsg;
end

function Partner:ApplyDelPartner(nPlayerId)
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	if pPlayer.IsAccountLock() == 1 then
		pPlayer.Msg("Tài khoản của bạn đang bị khóa, không thể xóa Đồng Hành. Vui lòng mở khóa");
		Partner:SendClientMsg("Tài khoản của bạn đang bị khóa, không thể xóa Đồng Hành");
		Account:OpenLockWindow(pPlayer);
		return 0;
	end
	if Account:Account2CheckIsUse(pPlayer, 6) == 0 then
		pPlayer.Msg("Bạn đang sử dụng mật khẩu phụ để đăng nhập trò chơi, thiết lập sự kiểm soát quyền truy cập, hoạt động không thể được thực hiện!");
		return 0;
	end		
	pPlayer.SetTask(self.TASK_DEL_PARTNER_GROUPID, self.TASK_DEL_PARTNER_SUBID, GetTime());
	pPlayer.AddSkillState(self.DELDEBUFF_SKILLID, 1, 1, self.DEL_USABLE_MAXTIME * Env.GAME_FPS, 1, 0, 1);
	
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "Yêu cầu loại bỏ đồng");
	pPlayer.Msg("Bạn đã Hủy quan hệ đồng hành thành công");
end

function Partner:CancelDelPartner(nPlayerId)
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	pPlayer.SetTask(self.TASK_DEL_PARTNER_GROUPID, self.TASK_DEL_PARTNER_SUBID, 0);
	pPlayer.RemoveSkillState(self.DELDEBUFF_SKILLID);
	
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "Bị thu hồi đồng hành xóa các ứng dụng");
	pPlayer.Msg("Bạn đã hủy yêu cầu");
end

function Partner:GetDelState(pPlayer)
	local nApplyTime = pPlayer.GetTask(self.TASK_DEL_PARTNER_GROUPID, self.TASK_DEL_PARTNER_SUBID);
	
	if nApplyTime == 0 then
		return 1;
	else
		local nDiffTime = GetTime() - nApplyTime;
		
		if nDiffTime <= 0 or nDiffTime > self.DEL_USABLE_MAXTIME then
			return 1;
		else
			return 0;
		end 
	end
end

-- 第三个参数表示删除同伴操作的类型：为0（默认值）时，表示删除；为1时表示把同伴转成道具
-- 为2时表示把同伴转成真元
function Partner:DissolveConfirm(nPlayerId, nPartnerIndex, nWay)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	nWay = nWay or 0;	-- 默认是普通的删除操作
	
	-- 如果要解散的是当前激活同伴，把激活变量设回初始
	if nPartnerIndex == pPlayer.nActivePartner then
		pPlayer.SetActivePartner(-1);
		pPlayer.RemoveSkillState(self.CHUSHOUXIANGZHUID);
	end
	
	-- 由于解散一个同伴后，激活同伴的索引发生了改变，需要把原来的计时器关掉重新开启一个
	self:UnRegisterPartnerTimer(pPlayer);
	
	local pPartner = pPlayer.GetPartner(nPartnerIndex);
	if not pPartner then
		return 0;
	end
	
	local szName = pPartner.szName;
	local nNewActiveIndex = pPlayer.nActivePartner;
	-- 删除之前先记录下同伴的星级
	local nStarLevel = self:GetSelfStartCount(pPartner);
	local nSkillCount = pPartner.nSkillCount;
	
	if pPlayer.nActivePartner > nPartnerIndex then
		pPlayer.SetActivePartner(-1);
		self:DeletePartnerLog(nPlayerId, nPartnerIndex, nWay);
		pPlayer.DeletePartner(nPartnerIndex);
		pPlayer.SetActivePartner(nNewActiveIndex - 1);
	else
		self:DeletePartnerLog(nPlayerId, nPartnerIndex, nWay);
		pPlayer.DeletePartner(nPartnerIndex);	
	end
	
	-- 为激活同伴开启计时器
	if pPlayer.nActivePartner ~= -1 then
		self:RegisterPartnerTimer(pPlayer);
	end
	
	local szMsg = "";	-- 给玩家的提示信息
	if nWay == 0 then  	-- 普通的删除操作
		szMsg = string.format("Bạn đã không còn Đồng Hành %s", szName);
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("删除同伴：%s", szName));
	elseif nWay == 1 then	-- 把同伴转成道具操作
		szMsg = string.format("Đồng hành %s của bạn đã được đưa vào thư giới thiệu.", szName);
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("推荐同伴：%s", szName));
	elseif nWay == 2 then	-- 把同伴转成真元
		szMsg = string.format("Đồng hành %s đã trở thành chân nguyên.", szName);
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("将同伴：%s转成真元", szName));
	end
	
	pPlayer.Msg(szMsg);
	Partner:SendClientMsg(szMsg);
	
	-- 如果当前删除的同伴是5.5星以上的，重置申请变量
	if (nStarLevel >= self.DELLIMITSTARLEVEL * 2 or nSkillCount >= self.DELLIMITSKILLCOUNT) and nWay == 0 then		-- 5.5星以上的做任务变量重置
		pPlayer.SetTask(self.TASK_PEEL_PARTNER_GROUPID, self.TASK_DEL_PARTNER_SUBID, 0);
		pPlayer.RemoveSkillState(self.DELDEBUFF_SKILLID);
	end
	
	-- 删除一个同伴之后，要刷新一下战斗力
	--Player.tbFightPower:RefreshFightPower(pPlayer);
	PlayerHonor:UpdateFightPower(pPlayer);
	
	return 1;
end

-- 第三个参数跟Partner:DissolveConfirm()里的第三个参数一致
function Partner:DeletePartnerLog(nPlayerId, nPartnerIndex, nWay)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	nWay = nWay or 0;	-- 默认是普通删除操作
	
	local pPartner = pPlayer.GetPartner(nPartnerIndex);
	local nTempId = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_TEMPID);
	local nLevel = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL);
	local nPTempId = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialTemp);
	local nPPoint = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialPoint);

	local nPartnerValue = Partner:GetPartnerValue(pPartner);
	
	local szLog = "";
	if nWay == 0 then		-- 普通的删除操作
		szLog = "Xóa Đồng Hành.";
	elseif nWay == 1 then	-- 把同伴转成道具
		szLog = "Thay đổi Đồng Hành.";
	elseif nWay == 2 then	-- 把同伴转成真元
		szLog = "Ngưng tụ Đồng Hành，";
	end
	
	szLog = szLog..string.format(" %d,%d,%d,%d,%d,%d,%d,%d,%d;",
		nTempId, nLevel, nPTempId, nPPoint,
		pPartner.GetAttrib(0), pPartner.GetAttrib(1), pPartner.GetAttrib(2), pPartner.GetAttrib(3),
		nPartnerValue
	);
	for i = 0, pPartner.nSkillCount - 1 do
		local tbSkill = pPartner.GetSkill(i);
		szLog = szLog .. string.format("(%d,%d);", tbSkill.nId, tbSkill.nLevel);
	end
	-- 把同伴转成道具的时候，在使用推荐信那里已经做了详细的记录，这里就不再需要记到客服LOG了。
	-- 考虑到分析数据的时候可能会用到相关的数据，所以本地LOG暂时先保留
	if nWay ~= 1 then
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_REALTION, szLog);
	end
	Dbg:WriteLog("同伴Log:", pPlayer.szName, ",", szLog);
end

-- 玩家对同伴赠送礼物添加领悟度，通过给予界面
function Partner:SendGift(nPartnerIndex)
	if me.IsAccountLock() == 1 then
		me.Msg("Tài khoản của bạn đang bị khóa,không thể tặng quà cho Đồng Hành. Vui lòng mở khóa");
		Partner:SendClientMsg("Tài khoản của bạn đã khóa, không thể tặng quà");
		Account:OpenLockWindow(me);
		return 0;
	end
	if Account:Account2CheckIsUse(me, 6) == 0 then
		me.Msg("Bạn đang sử dụng mật khẩu phụ để đăng nhập trò chơi, thiết lập sự kiểm soát quyền truy cập, hoạt động không thể được thực hiện!");
		return 0;
	end
	nPartnerIndex = nPartnerIndex or me.nActivePartner;
	local pPartner = me.GetPartner(nPartnerIndex);
	if not pPartner then
		-- print("同伴索引不合法！");
		return;
	end
	
	if self:CanUpgradeSkill(pPartner) == 0 then
		me.Msg(string.format("Đồng hành %s đã đầy các kỹ năng, không cần phải nâng cao lĩnh ngộ.", pPartner.szName));
		return;
	end
	
	local nTalent = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TALENT);
	local nTalentLevel = nTalent % 1000;
	if nTalentLevel >= self.TALENT_MAX then
		me.Msg(string.format("Đồng hành %s đã đầy các kỹ năng, không cần phải nâng cao lĩnh ngộ.", pPartner.szName));
		return;
	end
	
	local szMsg = self.szGiftContent;
	Dialog:OpenGift(szMsg, {"Partner:CheckGiftItem"}, {self.OnSendGiftOk, self, nPartnerIndex});
end
RegC2SFun("SendGift", Partner.SendGift);

function Partner:OnSendGiftOk(nPartnerIndex, tbItemObj)
	if nPartnerIndex ~= me.nActivePartner then
		return;
	end
	
	if Lib:CountTB(tbItemObj) <= 0 then
		return;
	end
	
	local nTalentAdded = 0;
	for _, tbItem in pairs(tbItemObj) do
		local szIndex = string.format("%d_%d_%d_%d", tbItem[1].nGenre, tbItem[1].nDetail, tbItem[1].nParticular, tbItem[1].nLevel)
		if self.tbItemTalentValue[szIndex] then
			local szBindValue = tbItem[1].nBindType == 1 and "nBindValue" or "nUnBindValue";
			nTalentAdded = nTalentAdded + self.tbItemTalentValue[szIndex][szBindValue] * tbItem[1].nCount;
		else
			me.Msg("Vật này không thể tặng cho Đồng hành");
			return 0;
		end
	end
	
	local pPartner = me.GetPartner(nPartnerIndex);
	local nCurTalent = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_TALENT);
	local nCurTalentLevel = nCurTalent % 1000;	-- nCurTalent = nTalentLevel + nTalentPoint*1000
	
	-- 这里传入的是领悟度价值量，第三个参数要为1
	local nNewLevel, nBalancePoint, bTooMuch = self:GetTalentLevelAdded(pPartner, nTalentAdded, 1);
	if nNewLevel > self.TALENT_MAX or bTooMuch == 1 then
		--me.Msg("您放入的物品过多，为了避免浪费，请整理后再来吧！");
		Dialog:Say(
			"<color=yellow>Nhiều quà tặng, sẽ bị lãng phí, để xác định tất cả những món quà?<color>", 
			{
				{"Vẫn tặng", self.DelGift, self, nPartnerIndex, pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID), tbItemObj, nTalentAdded},
				{"取消"},
			}
		)
		return 0;
	end
	
	local szMsg = string.format("Với quà tặng này,mức lãnh ngộ của đồng hành tăng lên <color=yellow>%d<color>, bạn có muốn tặng cho Đồng Hành？", nNewLevel);
	local tbOpt = 
	{
		{"Xác nhận", self.DelGift, self, nPartnerIndex, pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID), tbItemObj, nTalentAdded},
		{"Để ta suy nghĩ thêm"},
	}
	Dialog:Say(szMsg, tbOpt);
end

-- 删除给予界面中的礼物物品，同时给同伴增加领悟度
function Partner:DelGift(nPartnerIndex, nPartnerTempId, tbItemObj, nTalentAdded)
	local pPartner = me.GetPartner(nPartnerIndex);
	if not pPartner or nPartnerTempId ~= pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID) then
		return;
	end
	
	local nTalentPointAdded = nTalentAdded;
	local szLog = "";
	local nTotleValue = 0;
	local nConsumeValue = 0;	-- 消耗价值量
	
	-- 没有成功删除的物品，不加亲密度
	for _, tbItem in pairs(tbItemObj) do
		local szIndex = string.format("%s_%s_%s_%s", tbItem[1].nGenre, tbItem[1].nDetail, tbItem[1].nParticular, tbItem[1].nLevel);
		nTotleValue = tbItem[1].nValue * tbItem[1].nCount;
		local nItemConsumeValue = self:CalItemConsumValue(tbItem[1]);
		szLog = "同伴Log:" .. me.szName .. "使用" .. tbItem[1].nCount .. "个" .. tbItem[1].szName .. ",用来增加同伴领悟度";
		if me.DelItem(tbItem[1], Player.emKLOSEITEM_PARTNER_TALENT) ~= 1 then
			local szBindValue = tbItem[1].nBindType == 1 and "nBindValue" or "nUnBindValue";
			nTalentPointAdded = nTalentPointAdded - self.tbItemTalentValue[szIndex][szBindValue];
		else
			if nTotleValue > 50000 then
				Dbg:WriteLog(szLog);
			end
			nConsumeValue = nConsumeValue + nItemConsumeValue;
		end
	end
	
	-- 给玩家添加消耗价值
	Spreader:AddConsume(nConsumeValue, 1, "[喂养同伴]杂物");
	Dbg:WriteLog("Spreader:OnItemConsumed",
		"推广员消耗记录：",
		Spreader:ExtractZoneGroup(),
		me.szAccount,
		string.format("[%s]赠送礼物给同伴%s，添加消耗记录[%s]", me.szName,
			pPartner.szName, tostring(nConsumeValue))
	);
		
	Dbg:WriteLog("同伴Log:", me.szName, "通过给予界面，增加同伴领悟度（总价值量）:", nTalentPointAdded);

	if nTalentPointAdded <= 0 then
		me.Msg("Món quà này không có giá trị,hãy thử dùng quà khác");
		return 0;
	end	
	
	local nCurTalent = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TALENT);
	local nCurTalentLevel = nCurTalent % 1000;
	local nCurTalentPoint = math.floor(nCurTalent / 1000);
	-- 传入的是领悟度价值量，第三个参数要设为1
	local nNewLevel, nBalancePoint = self:GetTalentLevelAdded(pPartner, nTalentPointAdded, 1);

	local nRes, szMsg = self:AddTalent(pPartner, nNewLevel, nBalancePoint);
	if szMsg ~= "" then
		me.Msg(szMsg);
	end
	
	-- 如果玩家有同伴教育任务-更加强大，则记录任务变量。
	if nRes ~= 1 then
		return;
	end
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	local tbTask = tbPlayerTasks[tonumber(self.TASK_SKILLUP_MAIN, 16)];	-- 主任务ID
	if tbTask and tbTask.nReferId == tonumber(self.TASK_SKILLUP_SUB, 16) then
		me.SetTask(self.TASKID_MAIN, self.TASKID_TALENTUP, 1);
	end
end

-- 计算某个物品的消耗价值，只能是IB物品且CONSUME列为0时才算消耗价值
function Partner:CalItemConsumValue(pItem)
	local nValue = 0;	-- 这是消耗价值！
	local nIndex = Spreader:CalBitByGDPL(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	
	if pItem.IsIbItem() == 1 and Spreader.tbIbItem[nIndex] == 0 then	-- IB物品
		nValue = pItem.nBuyPrice * pItem.nCount;
	end

	return nValue;
end

-- 申请绑定同伴装备
function Partner:BindPartnerEquip(nPlayerId)
	Item:SwitchBindGift_Trigger(nPlayerId, Item.SWITCHBIND_BIND, Item.SWITCHBIND_PARTNEREQUIP);
end
RegC2SFun("BindEquip", Partner.BindPartnerEquip);
--[[
function Partner:OnSureBind(tbItemObj)
	if Lib:CountTB(tbItemObj) <= 0 then
		return;
	end
	
	for i, tbItem in pairs(tbItemObj) do
		if (tbItem[1].IsPartnerEquip() == 1) then
			tbItem[1].Bind(1);		-- 强制绑定同伴装备
		else
			self:SendClientMsg("只能放入同伴装备！");
		end
	end
end
]]--

-- 月影商店点击确定后回调
function Partner:MoonStoneOkFun(tbParams, tbBoxItem)
	local nDropCount = 0;
	local bBind = 0;
	for _k, _v in pairs(tbBoxItem) do
		local pItem = _v[1];
		nDropCount = nDropCount + pItem.nCount;
		if pItem.IsBind() == 1 then
			bBind = 1;
		end
	end
	local nTargetCount = math.floor(nDropCount / tbParams.nCount);
	
	if (me.CanAddItemIntoBag( { nGenre=tbParams.nGenre, nDetail=tbParams.nDetail, nParticular=tbParams.nParticular, nLevel=tbParams.nLevel, nSeries=-1, bBind=bBind, nCount=nTargetCount } ) ~= 1) then
		me.Msg("Hành trang không đủ");		
		return;
	end
	
	nDropCount = math.floor(nDropCount / tbParams.nCount) * tbParams.nCount;
	local nRemainToDel = nDropCount;
	for _k, _v in pairs(tbBoxItem) do
		local pItem = _v[1];
		if nRemainToDel <= 0 then
			break;
		elseif pItem.nCount <= nRemainToDel then
			local nItemCount = pItem.nCount;
			if me.DelItem(pItem) == 1 then
				nRemainToDel = nRemainToDel - nItemCount;
			end
		else
			pItem.SetCount(pItem.nCount - nRemainToDel);
			nRemainToDel = 0;
			break;
		end
	end
	local nCount = math.floor((nDropCount - nRemainToDel) / tbParams.nCount);
	if nRemainToDel > 0 then
		Dbg:WriteLog("同伴Log:", me.szName, "moonstoneshop.lua", nDropCount, nRemainToDel);
	end
	me.AddStackItem(tbParams.nGenre, tbParams.nDetail, tbParams.nParticular, tbParams.nLevel,{bForceBind = bBind}, nCount)
	local szMsg = string.format("%s用%d个月影之石兑换%d个%s",
		me.szName, 
		nDropCount - nRemainToDel, 
		nCount,
		KItem.GetNameById(tbParams.nGenre, 
			tbParams.nDetail, 
			tbParams.nParticular, 
			tbParams.nLevel)
		);
	Dbg:WriteLog("同伴Log:", szMsg);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_MOONSTONE, "同伴Log:" .. szMsg)
end

-- 弹泡泡提示&初始化携带同伴数量
function Partner:OnLogin(bIsChangeServer)
	-- 初始化携带同伴数量
	if me.nPartnerLimit < Partner.PARTNERLIMIT_MIN then
		me.SetPartnerLimit(Partner.PARTNERLIMIT_MIN);
	end
	
	-- 同伴满经验没升级技能提示
	if me.nActivePartner ~= -1 then
		local pPartner = me.GetPartner(me.nActivePartner);
		if not pPartner then
			return;
		end
		local nStoreMax = self:GetMaxStoreExp(pPartner);		-- 计算当前能累积的最大经验值
		local nCurExp = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_EXP);
		local nCurLevel = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL);
		if nCurExp >= nStoreMax and nCurLevel < self.MAXLEVEL - 9 then
			me.CallClientScript({"PopoTip:ShowPopo", 23});
		end
	end
	
	if (1 == bIsChangeServer) then
		return;
	end
	
	-- 还没有同伴提示
	if me.nPartnerCount <= 0 and me.nLevel >= 100 then
		me.CallClientScript({"PopoTip:ShowPopo", 20});
	end

end

-- 注册下线时扣除激活同伴的亲密度的回调
function Partner:OnLogout_PartnerActive(szReason)
	-- 注销为同伴召出效果而加的定时器
	Partner:UnRegisterPartnerTimer(me);
		
	-- 同伴亲密度衰减判定
	local pPartner = me.GetPartner(me.nActivePartner);
	if me.nFightState == 1 and pPartner then
		Partner:DecreaseFriendship(me.nId);
	end
end

-- 注册上线时重设亲密度相关变量的回调
function Partner:OnLogin_PartnerActive()	
	for nPartnerIndex = 1, me.nPartnerCount do
		local pPartner = me.GetPartner(nPartnerIndex - 1);
		self:ResetDecrTime(pPartner);	-- 重置同伴亲密度衰减变量
		if nPartnerIndex == me.nActivePartner then
			me.AddSkillState(self.CHUSHOUXIANGZHUID, 1, 1, 400000000, 1);	-- 给个特别长的时间
		end
	end
end

-- 把同伴转成真元
function Partner:ConvertToZhenYuan(nPartnerIndex)
	if not Item.tbZhenYuan.bOpen or Item.tbZhenYuan.bOpen ~= 1 then
		return 0;
	end
	
	if self:CheckConverCondition(me) ~= 1 then
		return 0;
	end	
	
	local pPartner = me.GetPartner(nPartnerIndex);
	if not pPartner then
		return;
	end	
	
	if self:CanConvertToZhenYuan(pPartner) ~= 1 or pPartner.GetValue(self.emKPARTNERATTRIBTYPE_LEVEL) ~= 1 then
		me.Msg("<color=yellow>Đồng hành phải là cấp 1 và có dấu ấn màu xanh lam mới có thể ngưng tụ.<color> (Kiểm tra trong giao diện F9, sau đó bấm Ngưng tụ)");
		--me.Msg("只有通过以下途径获得的1级同伴才可转化为真元：抓捕同伴时头像框是蓝色的目标。");
		return;
	end
	
	local nCost = Item.tbZhenYuan:GetConvertCost(pPartner);
	if nCost > me.nCashMoney then
		Dialog:Say(string.format("Để ngưng tụ Đồng hành cần <color=yellow>%s lượng bạc<color>, hãy chuẩn bị thêm ngân lượng!", Item:FormatMoney(nCost)));
		return
	end
	
	local szMsg = string.format("Sau khi ngưng tụ, đồng hành sẽ biến mất, và sẽ tiêu tốn <color=yellow>%s lượng bạc<color>, ngươi chắc chắn muốn ngưng tụ đồng hành thành Chân nguyên?", Item:FormatMoney(nCost));
	local tbOpt = 
	{
		{"Đồng ý", Partner.OnSureConvert, Partner, me.nId, nPartnerIndex, 0},	
		{"Để ta suy nghĩ thêm"},
	}
	
	Dialog:Say(szMsg, tbOpt);
end
RegC2SFun("Convert", Partner.ConvertToZhenYuan);

function Partner:GetPartnerEquipParam(pItem)
	if (not pItem or pItem.IsPartnerEquip() ~= 1) then
		return 0;
	end
	
	local nValue = pItem.GetGenInfo(1);
	nValue = Lib:LoadBits(nValue, 0, 1);
	
	return nValue;
end

function Partner:SetPartnerEquipParam(pItem)
	if (not pItem or pItem.IsPartnerEquip() ~= 1) then
		return;
	end
	
	local nValue = pItem.GetGenInfo(1);
	nValue = Lib:SetBits(nValue, 1, 0, 1);
	pItem.SetGenInfo(1, nValue);
end

-- 分两步：第一步（0），启动进度条，进度条成功进入第二步
-- 第二步（1），添加真元道具，删除同伴
function Partner:OnSureConvert(nPlayerId, nPartnerIndex, nStep)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
		
	
	nStep = nStep or 0;		-- 默认是第一步
	if nStep == 0 then		-- 启动进度条
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
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_DEATH,
			Player.ProcessBreakEvent.emEVENT_ATTACKED,
		}
		
		GeneralProcess:StartProcess("Đang ngưng tụ...", self.CONVERTPROCESSTIME * Env.GAME_FPS, {self.OnSureConvert, self, nPlayerId, nPartnerIndex, 1}, 
			{pPlayer.CallClientScript, {"Partner:PlayerConvertAnimate", 0}}, tbEvent);
		pPlayer.CallClientScript({"Partner:PlayerConvertAnimate", 1});	-- 1表示播放
	elseif nStep == 1 then	-- 转化真元：添加道具，删除同伴
		pPlayer.CallClientScript({"Partner:PlayerConvertAnimate", 0});	-- 0表示停止
		local pPartner = pPlayer.GetPartner(nPartnerIndex);
		if not pPartner then
			return;
		end
		
		-- 经历了一次异步，要重新判断一下条件
		if self:CheckConverCondition(pPlayer) ~= 1 then
			return;
		end
		
		-- 银两扣除成功了才添加真元
		local nCost = Item.tbZhenYuan:GetConvertCost(pPartner);
		if pPlayer.CostMoney(nCost, Player.emKPAY_CONVERT_PARTNER) ~= 1 then
			pPlayer.Msg("Không đủ ngân lượng!");
			return;
		end
		
		local 	nPartTempId = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_TEMPID);
		local 	nSkillCount = pPartner.nSkillCount;
		-- 先删除同伴, 2表示删除途径是转成真元
		if (self:DissolveConfirm(nPlayerId, nPartnerIndex, 2) ~= 1) then
			local szLog = string.format("%s凝聚真元失败[银两扣除成功，同伴删除失败，真元未添加]！扣除银两%d两。", pPlayer.szName, nCost);
			Dbg:WriteLog("[partnerconvert]", szLog);
			return;
		end			
		
		local pItem = Item.tbZhenYuan:Generate({nPartTempId, nSkillCount});
		if not pItem then
			local szLog = string.format("%s凝聚真元失败[银两扣除成功，同伴删除成功，真元添加失败]！扣除银两%d两，删除同伴（%d,%d）。",
				 pPlayer.szName, nCost, nPartTempId, nSkillCount);
			Dbg:WriteLog("[partnerconvert]", szLog);
			return;
		end
		
		
	end
end

-- 检查背包、账号锁
function Partner:CheckConverCondition(pPlayer)
	if (pPlayer.IsAccountLock() == 1) then
		pPlayer.Msg("Tài khoản đang khóa, không thể thao tác!");
		return 0;
	end
	if Account:Account2CheckIsUse(pPlayer, 6) == 0 then
		pPlayer.Msg("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end	

	-- 先检查背包
	if pPlayer.CountFreeBagCell() <= 0 then
		pPlayer.Msg("Hành trang không đủ chỗ trống");
		return 0;
	end
	
	return 1;
end


PlayerEvent:RegisterGlobal("OnLogin", Partner.OnLogin, Partner);

-- 注册下线时扣除激活同伴的亲密度的回调
PlayerEvent:RegisterGlobal("OnLogout", Partner.OnLogout_PartnerActive, Partner);
-- 注册上线时重设亲密度相关变量的回调
PlayerEvent:RegisterGlobal("OnLogin", Partner.OnLogin_PartnerActive, Partner);
