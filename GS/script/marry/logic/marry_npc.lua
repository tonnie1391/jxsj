-------------------------------------------------------
-- 文件名　：marry_npc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 00:29:41
-- 文件描述：
-------------------------------------------------------

Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

local tbNpc = Marry.DialogNpc or {};
Marry.DialogNpc = tbNpc;

-- 判断求婚
function tbNpc:CheckQiuhun()
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end

	local szOptMsg = [[


<color=yellow>Điều kiện nạp cát:<color>
    1. Nhân vật nam/nữ đạt cấp <color=yellow>69<color>;
    2. Nhân vật nam/nữ <color=yellow>độc thân<color> và không có quan hệ hiệp lữ;
    3. Đạt <color=yellow>độ thân mật<color> tối thiểu <color=yellow>cấp 3<color>.
]]
	-- 我没有结婚
	if me.IsMarried() == 1 then
		Dialog:Say("Đã có hiệp lữ rồi!" .. szOptMsg);
		return 0;
	end

	-- 等级69级
	if me.nLevel < 69 then
		Dialog:Say("Đẳng cấp chưa đạt 69." .. szOptMsg);
		return 0;
	end
	
	-- 俩人组队
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		Dialog:Say("Hãy tổ đội cùng nhau." .. szOptMsg);
		return 0;
	end
	
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	if not pTeamMate then
		return 0;
	end

	-- 同性恋
	if me.nSex == pTeamMate.nSex then
		Dialog:Say("Giới tính không phù hợp." .. szOptMsg);
		return 0;
	end
	
	-- 对方没有结婚
	if pTeamMate.IsMarried() == 1 then
		Dialog:Say("Hoa đã có chủ rồi, ngươi tìm người khác đi." .. szOptMsg);
		return 0;
	end

	-- 等级69级
	if pTeamMate.nLevel < 69 then
		Dialog:Say("Đẳng cấp chưa đạt 69." .. szOptMsg);
		return 0;
	end
	
	-- 我已经订婚
	if me.GetTaskStr(Marry.TASK_GROUP_ID, Marry.TASK_QIUHUN_NAME) ~= "" then
		Dialog:Say("Ngươi đã nạp cát rồi." .. szOptMsg);
		return 0;
	end
	
	-- 对方已经订婚
	if pTeamMate.GetTaskStr(Marry.TASK_GROUP_ID, Marry.TASK_QIUHUN_NAME) ~= "" then
		Dialog:Say("Đối phương đã nạp cát rồi." .. szOptMsg);
		return 0;
	end
	
	-- 亲密度3级
	if me.GetFriendFavorLevel(pTeamMate.szName) < 3 then
		Dialog:Say("Độ thân mật dưới cấp 3." .. szOptMsg);
		return 0;
	end
	
	-- 在附近
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	if tbPlayerList then
		for _, pPlayer in ipairs(tbPlayerList) do
			if pPlayer.szName == pTeamMate.szName then
				nNearby = 1;
			end
		end
	end
	
	if nNearby ~= 1 then
		Dialog:Say("Đối phương ở quá xa..." .. szOptMsg);
		return 0;
	end
	
	return 1;
end

-- 求婚对话
function tbNpc:OnQiuhun(nItemId)
	
	if self:CheckQiuhun() ~= 1 then
		return 0;
	end

	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	local szMsg = string.format("Ngươi chắc chắn Nạp cát với <color=green>%s<color>?", pTeamMate.szName);
	local tbOpt = 
	{
		{"Xác nhận", self.OnConfirmQiuhun, self, me.nId, pTeamMate.nId, nItemId},
		{"Để ta suy nghĩ thêm"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 确认求婚
function tbNpc:OnConfirmQiuhun(nSuitorId, nTeamMateId, nItemId)

	local pSuitor = KPlayer.GetPlayerObjById(nSuitorId);
	local pTeamMate = KPlayer.GetPlayerObjById(nTeamMateId);
	
	if not pSuitor or not pTeamMate then
		return 0;
	end
	
	-- 只要使用了求婚卡片，不论对方是否同意都得删除
	local pItem = KItem.GetObjById(nItemId);
	if pItem then
		pItem.Delete(pSuitor);
	end
	
	local szMsg = string.format("<color=green>%s<color> gửi yêu cầu Nạp cát cùng bạn.", pSuitor.szName);
	local tbOpt = 
	{
		{"Ta đồng ý", self.OnAcceptQiuhun, self, nSuitorId, nTeamMateId},
		{"Ta từ chối", self.OnRefuseQiuhun, self, nSuitorId, nTeamMateId},
	};
	
	Setting:SetGlobalObj(pTeamMate);
	Dialog:Say(szMsg, tbOpt);
	Setting:RestoreGlobalObj();
end

-- 接受求婚
function tbNpc:OnAcceptQiuhun(nSuitorId, nTeamMateId)

	local pSuitor = KPlayer.GetPlayerObjById(nSuitorId);
	local pTeamMate = KPlayer.GetPlayerObjById(nTeamMateId);
	
	if not pSuitor or not pTeamMate then
		return 0;
	end
	
	-- 增加求婚关系
	if pSuitor.nSex == 0 then
		Marry:AddQiuhun(pSuitor, me);
		pSuitor.Msg(string.format("Chúc mừng, nạp cát thành công! Thiết lập mối quan hệ hiệp lữ cùng <color=yellow>%s<color> nhân vật nam đến Vạn Hữu Toàn mua Túi quà lễ và đặt lễ ở Nguyệt Lão tại Giang Tân Thôn.", pTeamMate.szName));
		pTeamMate.Msg(string.format("Chúc mừng, nạp cát thành công! Thiết lập mối quan hệ hiệp lữ cùng <color=yellow>%s<color> nhân vật nam đến Vạn Hữu Toàn mua Túi quà lễ và đặt lễ ở Nguyệt Lão tại Giang Tân Thôn.", pSuitor.szName));
	else
		Marry:AddQiuhun(me, pSuitor);
		pSuitor.Msg(string.format("Chúc mừng, nạp cát thành công! Thiết lập mối quan hệ hiệp lữ cùng <color=yellow>%s<color> nhân vật nam đến Vạn Hữu Toàn mua Túi quà lễ và đặt lễ ở Nguyệt Lão tại Giang Tân Thôn.", pTeamMate.szName));
		pTeamMate.Msg(string.format("Chúc mừng, nạp cát thành công! Thiết lập mối quan hệ hiệp lữ cùng <color=yellow>%s<color> nhân vật nam đến Vạn Hữu Toàn mua Túi quà lễ và đặt lễ ở Nguyệt Lão tại Giang Tân Thôn.", pSuitor.szName));
	end
	
	pSuitor.SendMsgToFriend(string.format("Hảo hữu <color=yellow>%s<color> nạp cát cùng <color=yellow>%s<color> thành công.", pSuitor.szName, pTeamMate.szName));
	Player:SendMsgToKinOrTong(pSuitor, string.format(" nạp cát cùng <color=yellow>%s<color> thành công.", pTeamMate.szName));
	pSuitor.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("与 %s 确定求婚关系", pTeamMate.szName));
	
	pTeamMate.SendMsgToFriend(string.format("Hảo hữu <color=yellow>%s<color> chấp nhận nạp cát từ <color=yellow>%s<color>", pTeamMate.szName, pSuitor.szName));
	Player:SendMsgToKinOrTong(me, string.format(" chấp nhận nạp cát từ <color=yellow>%s<color>", pSuitor.szName));
	pTeamMate.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("与 %s 确定求婚关系", pSuitor.szName));
	
	-- 频道公告
	Dialog:SendBlackBoardMsg(pSuitor, string.format("Chúc mừng, <color=yellow>%s<color> đã nạp cát cùng bạn.", pTeamMate.szName));
	KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("<color=green>[%s]<color> nạp cát cùng <color=green>[%s]<color>. Hãy chúc mừng cho cặp đôi này!", pTeamMate.szName, pSuitor.szName));

	Dbg:WriteLog("Marry", "结婚系统", pSuitor.szName, pSuitor.szAccount, pTeamMate.szName, pTeamMate.szAccount, "求婚成功");
end

-- 拒接求婚
function tbNpc:OnRefuseQiuhun(nSuitorId, nTeamMateId)
	
	local pSuitor = KPlayer.GetPlayerObjById(nSuitorId);
	local pTeamMate = KPlayer.GetPlayerObjById(nTeamMateId);
	
	if not pSuitor or not pTeamMate then
		return 0;
	end
	
	Dialog:SendBlackBoardMsg(pSuitor, string.format("Thật buồn, <color=green>%s<color> đã từ chối nạp cát của bạn.", pTeamMate.szName));
end

-- 解除求婚关系
function tbNpc:OnRemoveQiuhun(nSure)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 俩人组队
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		Dialog:Say("Cần tổ đội 2 người đến để gỡ bỏ nạp cát.");
		return 0;
	end
	
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	if not pTeamMate then
		return 0;
	end
	
	if Marry:CheckQiuhun(me, pTeamMate) ~= 1 then
		Dialog:Say("Không có mỗi quan hệ nào giữa 2 người.");
		return 0;
	end
	
	if Marry:CheckPreWedding(me.szName) == 1 or Marry:CheckPreWedding(pTeamMate.szName) == 1 then
		Dialog:Say("Đã đặt lễ, không thể hủy bỏ nạp cát.");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("Ngươi có chắc muốn hủy bỏ nạp cát cùng <color=yellow>%s<color> không? Mỗi bên cần tiêu hao <color=yellow>10 vạn bạc<color> để thực hiện.", pTeamMate.szName);
		local tbOpt = 
		{
			{"Đồng ý", self.OnRemoveQiuhun, self, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if me.nCashMoney < Marry.CANCEL_QIUHUN_COST then
		Dialog:Say("Lượng bạc mang theo không đủ");
		return 0;
	end
	
	if pTeamMate.nCashMoney < Marry.CANCEL_QIUHUN_COST then
		Dialog:Say(string.format("%s không mang đủ bạc trên người.", pTeamMate.szName));
		return 0;
	end
	
	me.CostMoney(Marry.CANCEL_QIUHUN_COST, Player.emKPAY_EVENT);
	pTeamMate.CostMoney(Marry.CANCEL_QIUHUN_COST, Player.emKPAY_EVENT);
	
	me.Msg(string.format("Bạn và <color=yellow>%s<color> đã gỡ bỏ quan hệ nạp cát và trừ đi <color=yellow>%s<color> bạc thường.", pTeamMate.szName, Marry.CANCEL_QIUHUN_COST));
	pTeamMate.Msg(string.format("Bạn và <color=yellow>%s<color> đã gỡ bỏ quan hệ nạp cát và trừ đi <color=yellow>%s<color> bạc thường.", me.szName, Marry.CANCEL_QIUHUN_COST));
	
	me.RemoveSpeTitle(string.format("Tri kỷ của %s", pTeamMate.szName));
	pTeamMate.RemoveSpeTitle(string.format("Tri kỷ của %s", me.szName));
	
	Marry:RemoveQiuhun(me, pTeamMate);
	
	Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, pTeamMate.szName, pTeamMate.szAccount, "双方解除求婚");
end

-- 单方面解除求婚关系
function tbNpc:OnSingleRemoveQiuhun(nSure)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	local szQiuhunName = me.GetTaskStr(Marry.TASK_GROUP_ID, Marry.TASK_QIUHUN_NAME);
	if szQiuhunName == "" then
		Dialog:Say("Không cần hủy bỏ quan hệ.");
		return 0;
	end
	
	if Marry:CheckPreWedding(me.szName) == 1 then
		Dialog:Say("Đã đặt lễ cưới, không thể hủy bỏ nạp cát.");
		return 0;
	end
	
	-- 另一方自动触发解除求婚关系
	local szKeyName = Marry.tbProposalBuffer[me.szName];
	if szKeyName and szKeyName == szQiuhunName then
		me.SetTaskStr(Marry.TASK_GROUP_ID, Marry.TASK_QIUHUN_NAME, "");
		if me.nSex == 0 then
			me.RemoveSpeTitle(string.format("Tri kỷ của %s", szQiuhunName));
		else
			me.RemoveSpeTitle(string.format("Tri kỷ của %s", szQiuhunName));
		end
		me.Msg(string.format("Bạn và <color=yellow>%s<color> đã hủy bỏ quan hệ nạp cát.", szQiuhunName));
		Marry:RemoveProposal_GS(me.szName);
		return 0;
	end
	
	if not nSure then
		local szMsg = "Ngươi quyết tâm đơn phương hủy bỏ quan hệ nạp cát? Cần mang theo <color=yellow>20 vạn<color> bạc thường.";
		local tbOpt = 
		{
			{"Ta đồng ý", self.OnSingleRemoveQiuhun, self, 2},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if me.nCashMoney < Marry.SINGLE_QIUHUN_COST then
		Dialog:Say("Không mang theo đủ bạc thường.");
		return 0;
	end
	
	me.CostMoney(Marry.SINGLE_QIUHUN_COST, Player.emKPAY_EVENT);
	me.SetTaskStr(Marry.TASK_GROUP_ID, Marry.TASK_QIUHUN_NAME, "");
	me.Msg(string.format("Bạn và <color=yellow>%s<color> đã gỡ bỏ quan hệ nạp cát và khấu trừ <color=yellow>%s<color> bạc thường.", szQiuhunName, Marry.SINGLE_QIUHUN_COST));
	
	if me.nSex == 0 then
		me.RemoveSpeTitle(string.format("Tri kỷ của %s", szQiuhunName));
	else
		me.RemoveSpeTitle(string.format("Tri kỷ của %s", szQiuhunName));
	end

	KPlayer.SendMail(szQiuhunName, "Quan hệ nạp cát", 
		string.format("Thật đáng tiếc, <color=gold>%s<color> đã đơn phương hủy bỏ quan hệ nạp cát với bạn. Đừng buồn, hãy tìm lại cho mình một tri kỷ tốt hơn.", me.szName)
		);
		
	Marry:AddProposal_GS(szQiuhunName, me.szName);
	
	Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, "单方解除求婚");
end 

-- 解除婚姻关系
function tbNpc:OnDivorce(nSure)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 俩人组队
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		Dialog:Say("Cần cùng tổ đội mới có thể thao tác!");
		return 0;
	end
	
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	if not pTeamMate then
		return 0;
	end
	
	if me.IsAccountLock() ~= 0 or pTeamMate.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang khóa, không thể thao tác.");
		return 0;
	end
	
	if me.IsMarried() ~= 1 or pTeamMate.IsMarried() ~= 1 or me.GetCoupleName() ~= pTeamMate.szName then
		Dialog:Say("Bạn không có mối quan hệ hiệp lữ nào!");
		return 0;
	end
	
	if me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_INTERVAL) == 1 then
		Dialog:Say("Mỗi tháng chỉ có thể hủy bỏ quan hệ hiệp lữ 1 lần.");
		return 0;
	end
	
	local nTimes = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_TIMES);
	if nTimes > Marry.MAX_DIVORCE_TIMES then
		nTimes = Marry.MAX_DIVORCE_TIMES;
	end
	local nCostCount = 2 ^ nTimes; 
	if not nSure then
		local szMsg = string.format("Ngươi chắc chắn hủy bỏ quan hệ hiệp lữ cùng <color=yellow>%s<color> chứ? Đồng thời sẽ tiêu hao <color=yellow>%s<color>Phá Toái Chi Tâm.", pTeamMate.szName, nCostCount);
		local tbOpt = 
		{
			{"Đồng ý", self.OnDivorce, self, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nFindItem = 0;
	local tbFind = me.FindItemInBags(18, 1, 719, 1);
	for _, tbItem in pairs(tbFind or {}) do
		if tbItem.pItem then
			nFindItem = nFindItem + 1;
		end
	end
		
	if nFindItem < nCostCount then
		Dialog:Say("Không tìm thấy vật phẩm yêu cầu.");
		return 0;
	end
	
	local nCostItem = 0;
	for _, tbItem in pairs(tbFind or {}) do
		if tbItem.pItem then
			me.DelItem(tbItem.pItem);
			nCostItem = nCostItem + 1;
			if nCostItem >= nCostCount then
				break;
			end
		end
	end
	
	Marry:DoDivorce(me, pTeamMate.szName);
	Marry:DoDivorce(pTeamMate, me.szName);

	Relation:DelRelation_GS(me.szName, pTeamMate.szName, Player.emKPLAYERRELATION_TYPE_COUPLE, 1);
	Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, pTeamMate.szName, pTeamMate.szAccount, "双方解除婚姻关系");	
end

-- 单方面离婚
function tbNpc:OnSingleDivorce(nSure)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang khóa không thể thao tác.");
		return 0;
	end
	
	if me.IsMarried() ~= 1 then
		Dialog:Say("Chưa có quan hệ hiệp lữ, không thể thao tác.");
		return 0;
	end
	
	local szCoupleName = me.GetCoupleName();
	local szKeyName = Marry.tbDivorceBuffer[me.szName];
	if szKeyName then
		Marry:DoDivorce(me, szCoupleName);
		Marry:RemoveDivorce_GS(me.szName);
		return 0;
	end
	
	if me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_INTERVAL) == 1 then
		Dialog:Say("Mỗi tháng chỉ có thể hủy bỏ quan hệ hiệp lữ 1 lần.");
		return 0;
	end
	
	local nTimes = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_TIMES);
	if nTimes > Marry.MAX_DIVORCE_TIMES then
		nTimes = Marry.MAX_DIVORCE_TIMES;
	end
	
	local nCostCount = 2 ^ nTimes * 2; 
	if not nSure then
		local szMsg = string.format("Ngươi muốn đơn phương hủy bỏ quan hệ hiệp lữ? Đồng thời tiêu hao <color=yellow>%s<color> Phá Toái Chi Tâm.", nCostCount);
		local tbOpt = 
		{
			{"Đồng ý", self.OnSingleDivorce, self, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nFindItem = 0;
	local tbFind = me.FindItemInBags(18, 1, 719, 1);
	for _, tbItem in pairs(tbFind or {}) do
		if tbItem.pItem then
			nFindItem = nFindItem + 1;
		end
	end
		
	if nFindItem < nCostCount then
		Dialog:Say("Không tìm thấy vật phẩm yêu cầu.");
		return 0;
	end
	
	local nCostItem = 0;
	for _, tbItem in pairs(tbFind or {}) do
		if tbItem.pItem then
			me.DelItem(tbItem.pItem);
			nCostItem = nCostItem + 1;
			if nCostItem >= nCostCount then
				break;
			end
		end
	end
	
	local pCouple = KPlayer.GetPlayerByName(szCoupleName);
	if pCouple then
		Marry:DoDivorce(pCouple, me.szName);
	else
		Marry:AddDivorce_GS(szCoupleName, me.szName);
	end

	Marry:DoDivorce(me, szCoupleName);
	Relation:DelRelation_GS(me.szName, szCoupleName, Player.emKPLAYERRELATION_TYPE_COUPLE, 1);
	KPlayer.SendMail(szCoupleName, "Quan hệ Hiệp lữ", string.format("Thật đáng tiếc, <color=gold>%s<color>Đã đơn phương hủy bỏ quan hệ hiệp lữ.\nHãy tìm một tri kỷ khác tốt hơn.", me.szName));
	Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, "单方面解除婚姻关系");	
end

function Marry:DoDivorce(pPlayer, szCoupleName)
	
	if not pPlayer then
		return 0;
	end
	
	-- 清除婚期
	Marry:RemovePlayerWedding(pPlayer.szName);
	pPlayer.RemoveSpeTitle(string.format("Hiệp lữ của %s", szCoupleName));
	pPlayer.Msg(string.format("Bạn và <color=yellow>%s<color> từ nay đường ai nấy đi!", szCoupleName));
	
	-- 任务变量门清
	for i = 1, 24 do	
		pPlayer.SetTask(Marry.TASK_GROUP_ID, i, 0);
	end
	
	local nTimes = pPlayer.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_TIMES);
	if nTimes < Marry.MAX_DIVORCE_TIMES then
		nTimes = nTimes + 1;
	end
	pPlayer.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_TIMES, nTimes);
	pPlayer.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_INTERVAL, 1);
end
