local RELATIONTYPE_TRAINING 	= 5		-- 当前师徒关系
local RELATIONTYPE_TRAINED		= 6		-- 出师师徒关系
local RELATIONTYPE_INTRODUCE	= 8		-- 介绍人关系
local RELATIONTYPE_BUDDY		= 9		-- 指定密友关系
local COST_DELTEACHER			= 10000	-- 解除和师父关系的费用
local COST_DELSTUDENT			= 10000	-- 解除和弟子关系的费用

local tbNpc	= Npc:GetClass("renji");

-- 对话
function tbNpc:OnDialog()

	local szMsg = "Ta có thể giúp ngươi giải quyết vấn đề về các mối quan hệ, ngươi cần giúp gì?";
	local tbOpt = {};
	
	table.insert(tbOpt, {  "Quan hệ sư đồ", tbNpc.Training, self });
	table.insert(tbOpt, {  "Quan hệ người giới thiệu",	tbNpc.Introduce, self });
	table.insert(tbOpt, {  "Chỉ định mật hữu", tbNpc.Buddy, self });
	table.insert(tbOpt, {  "Nhận thưởng mật hữu",	tbNpc.GainBindCoin, self });
	table.insert(tbOpt, {  "Hệ thống thành tựu", tbNpc.AchievementDlg, self });
	table.insert(tbOpt, {  "Ta chỉ tiện đường ghé qua" });
	
	
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nCurDate >= 20100920 and nCurDate <= 20301004) then
		local tbTemp = {"<color=yellow>Sự kiện thành tựu mới<color>", SpecialEvent.Achive_Zhaneyuan.OnDialog,
			SpecialEvent.Achive_Zhaneyuan};
		table.insert(tbOpt, 1, tbTemp);
	end
	
	
	Dialog:Say(szMsg, tbOpt);
end

function  tbNpc:Training()
	local tbOpt = 	{
		{ "Xin bái sư", 		tbNpc.AppTrain,					self },
		{ "Tiến hành nghi thức",   tbNpc.Graduation, 				self },
		{ "Hủy quan hệ sư đồ chưa xuất sư",	tbNpc.DelTrainingRelation,		self },
		-- { "Hủy quan hệ sư đồ",	tbNpc.DelTrainedRelation,	self },
		{ "Hủy quan hệ sư đồ đã xuất sư",	tbNpc.GetShiTuChuanSongFu, 		self },
		{ "Nhận sư đồ đồng tâm phù", tbNpc.RetrieveAchievement, 	self},
	};
	if (me.GetTrainingStudentList()) then
		table.insert(tbOpt, #tbOpt, {"Nhận danh hiệu sư đồ", tbNpc.ChangeShituTitle, self});
	end
	
	if (me.GetTrainingTeacher()) then
		table.insert(tbOpt, #tbOpt, {"Nhận danh hiệu sư phụ", tbNpc.GetStudentTitle, self});
	end
	if Esport.Mentor.bVisible then
		if self:GetTeamMission() then
			table.insert(tbOpt, {"Vào phó bản sư đồ", tbNpc.PreStartMentor, self });
		else
			table.insert(tbOpt, {"Mở phó bản sư đồ", tbNpc.PreStartMentor, self });
		end
	end
	
	table.insert(tbOpt, {"Ta chỉ tiện đường ghé qua"});
	
	Dialog:Say("Quan hệ sư đồ", tbOpt);
end

--=====================================

function tbNpc:DelTrainedRelation()
	local szTeacher = me.GetTrainingTeacher(RELATIONTYPE_TRAINED);
	local tbStudent = me.GetRelationList(RELATIONTYPE_TRAINED, 1);
	if (not szTeacher and (not tbStudent or Lib:CountTB(tbStudent) <= 0)) then
		Dialog:Say("你现在没有已出师的师徒关系。");
		return 0;
	end
	
	Dialog:Say("解除已出师师徒关系",
		{
			{"和师傅解除关系", self.DelTrainedTeacher, self, 0, szTeacher},
			{"和弟子解除关系", self.DelTrainedStudent, self, 0, 1},	
			{"Ta chỉ tiện đường ghé qua"},
		});
end

function tbNpc:DelTrainedTeacher(bConfirm, szTeacher)
	bConfirm = bConfirm or 0;
	szTeacher = szTeacher or "";
	if ("" == szTeacher) then
		Dialog:Say("你还没有出师，不能进行此操作。");
		return 0;
	end
	if (me.nCashMoney < COST_DELTEACHER) then
		Dialog:Say(string.format("弟子主动删除师傅需要缴纳%s两的手续费，你还是准备好了再来吧。", COST_DELTEACHER));
		return 0;
	end
	
	if (me.IsHaveRelation(szTeacher, RELATIONTYPE_TRAINED, 0) ~= 1) then
		return 0;
	end
	
	if (0 == bConfirm) then
		
		Dialog:Say(string.format("你确定要和<color=yellow>%s<color>解除师徒关系吗？", szTeacher),
			{
				{"是的，我确定", self.DelTrainedTeacher, self, 1, szTeacher},
				{"我还是再考虑一下吧"},
			})
			
	else
		
		if (me.CostMoney(COST_DELTEACHER, Player.emKPAY_DEL_TEACHER) ~= 1) then
			Dialog:Say("解除师徒关系需要<color=red>10000<color>两银子，你身上银子不够，带够了再来吧。")
			return 0;
		end
		Relation:DelRelation_GS(me.szName, szTeacher, RELATIONTYPE_TRAINED, 0);
		KPlayer.SendMail(szTeacher, "师徒关系解除通知",
			"您好，您的弟子<color=yellow>" .. me.szName .. "<color>已经单方面和你解除了师徒关系。节哀啊节哀。");
		Dialog:Say("你和<color=yellow>" .. szTeacher .. "<color>的师徒关系已经成功解除了，以后你们就天各一方，互不相干了。")
	end
end

function tbNpc:DelTrainedStudent(bConfirm, nPageNum, szStudentName)
	bConfirm = bConfirm or 0;
	nPageNum = nPageNum or 1;
	szStudentName = szStudentName or "";
	
	if (0 == bConfirm) then
		
		local tbStudent = me.GetRelationList(RELATIONTYPE_TRAINED, 1);
		if (not tbStudent or Lib:CountTB(tbStudent) <= 0) then
			Dialog:Say("你还没有已经出师的弟子，不能进行此操作。");
			return;
		end
		local szMsg = "请选择你要和谁解除师徒关系";
		local tbOpt = {};
		
		-- 每页显示10个供选择弟子
		local nBeginIndex = (nPageNum - 1) * 10 + 1;
		local nEndIndex = nBeginIndex + 10;
		local nTotalPage = math.ceil(#tbStudent / 10);
		for nIndex, szStudent in ipairs(tbStudent) do
			if (nIndex >= nBeginIndex and nIndex < nEndIndex) then
				local tbOneOpt = {szStudent, self.DelTrainedStudent, self, 1, nPageNum, szStudent};
				table.insert(tbOpt, tbOneOpt);
			end
		end
		
		if (nPageNum > 1) then
			table.insert(tbOpt, {"Trang trước", self.DelTrainedStudent, self, 0, nPageNum - 1});
		end
		if (nPageNum < nTotalPage) then
			table.insert(tbOpt, {"Trang sau", self.DelTrainedStudent, self, 0, nPageNum + 1});
		end
		Dialog:Say(szMsg, tbOpt);
		
	else
		
		if (me.IsHaveRelation(szStudentName, RELATIONTYPE_TRAINED, 1) ~= 1) then
			Dialog:Say("你们之间不存在已出师的师徒关系。");
			return;
		end
		Relation:DelRelation_GS(me.szName, szStudentName, RELATIONTYPE_TRAINED, 1);
		KPlayer.SendMail(szStudentName, "师徒关系解除通知",
			"您好，您的师傅<color=yellow>" .. me.szName .. "<color>已经单方面和你解除了师徒关系。节哀啊节哀。");
		Dialog:Say("你和<color=yellow>" .. szStudentName .. "<color>的师徒关系已经成功解除了，以后你们就天各一方，互不相干了。")
		
	end
end

--=====================================

function tbNpc:DelTrainingRelation()
	local pszTeacher = me.GetTrainingTeacher();
	local tbStudent = me.GetTrainingStudentList();
	if (self:CanDoRelationOpt(me.szName) == 0) then
		return;
	end
	if (not pszTeacher and not tbStudent) then
		Dialog:Say("Hiện tại bạn không có quan hệ sư đồ chưa xuất sư.");
		return 0;
	else
		Dialog:Say("Hủy quan hệ.",
		{
			{ "Hủy quan hệ đồ đệ", tbNpc.DelTrainingTeacherDialog, self },
			{ "Hủy quan hệ sư phụ", tbNpc.DelTrainingStudentDialog, self },
			{ "Ta chỉ tiện đường đến xem" }
		})
	end
end

function tbNpc:Introduce()
	if (self:CanDoRelationOpt(me.szName) == 0) then
		return;
	end
	Dialog:Say("Sau khi thiết lập, mỗi lần tiêu phí tại Kỳ Trân Các, người giới thiệu sẽ nhận được phần thưởng 5% tiêu phí. <color=yellow>Quan hệ người giới thiệu duy trì 1 năm, đến hạn sẽ tự động huy. Khi độ thân mật cả 2 người đạt cấp 6, có thể đến chỗ ta xin chuyển thành mật hữu chỉ định.<color>\n\nXác định thiết lập quan hệ người giới thiệu?",
	{
		{ "Xác nhận người giới thiệu", tbNpc.IntroduceDialog, 			self },
		{ "Muốn trở thành mật hữu", tbNpc.BuddyDialog, 				self },	
		{ "Ta chỉ tiện đường ghé qua" }
	})
end

function tbNpc:Buddy()
	if (self:CanDoRelationOpt(me.szName) == 0) then
		return;
	end
	Dialog:Say("Sau khi thành mật hữu, 1 người tiêu phí tại Kỳ Trân Các, người kia sẽ nhận được phần thưởng hoàn trả. <color=yellow>Quan hệ mật hữu duy trì 1 năm, đến hạn sẽ tự động hủy. Cần đến chỗ ta chỉ định lại mật hữu lần nữa.<color>\n\nXác định trở thành mật hữu? Hủy quan hệ mật hữu sẽ mất 1 khoản chi phí, hãy suy nghĩ kỹ.",
	{
		{ "Muốn trở thành mật hữu", tbNpc.BuddyDialog, 				self },	
		{ "Muốn xóa mật hữu", 	tbNpc.DelBuddyDialog, 			self },
		{ "Ta chỉ tiện đường ghé qua" }
	})
end

function tbNpc:GainBindCoin()
	if 1 ~= jbreturn:GainBindCoin() then
											
		local tbOption = {
			{ string.format("Ta muốn nhận %s", IVER_g_szCoinName), tbNpc.GetIbBindCoin,			self },
			{ "Ta chỉ tiện đường ghé qua" }
		};
		-- 美术同学特别通道
		-- local nWeek = Lib:GetLocalWeek();
		-- if me.GetTask(2056, 16) >= nWeek then
			-- table.insert(tbOption, 1, {"工资优惠", jbreturn.GetFreeReward, jbreturn});
		-- end
		Dialog:Say("Nhận thưởng mật hữu",tbOption);
	end
end

-- 更换师徒称号
function tbNpc:ChangeShituTitle()
	local tbItem = Item:GetClass("teacher2student");
	tbItem:ChangeShituTitle();
end

-- 获取弟子称号
function tbNpc:GetStudentTitle()
	local tbItem = Item:GetClass("teacher2student");
	tbItem:FetchStudentTitle();
end

-- 检查拜师的条件
function tbNpc:CheckAppTrainCond()
	if (0 == self:CanDoRelationOpt(me.szName)) then
		return 0;
	end

	if (me.GetTrainingTeacher()) then
		Dialog:Say("Bạn đã có sư phụ, không thể nhận đệ tử.");
		return 0;
	end
	
	if (me.nLevel < Relation.STUDENT_MINILEVEL) then
		Dialog:Say(string.format("Chưa đạt cấp <color=yellow>%s<color>, không thể bái sư", Relation.STUDENT_MINILEVEL));
		return 0;
	end
	
	if (me.nLevel >= Relation.STUDENT_MAXLEVEL) then
		Dialog:Say(string.format("Đã quá cấp <color=yellow>%s<color>, không thể bái sư.", Relation.STUDENT_MAXLEVEL));
		return 0;
	end
	
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nLastAppDate = me.GetTask(Relation.TASK_GROUP, Relation.TASKID_LASTAPPTRAIN_DATE);
	local nAppCount = me.GetTask(Relation.TASK_GROUP, Relation.TASKID_APPTRAIN_COUNT);
	if (nAppCount > Relation.MAX_APPTRAIN_COUNT) then
		Dialog:Say(string.format("Bạn đã có <color=yellow>%s<color> đệ tử, không thể nhận thêm", Relation.MAX_APPTRAIN_COUNT));
		return 0;
	end
	
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (2 ~= nMemberCount) then
		Dialog:Say("Tổ đội 2 người cùng đến mới có thể bái sư");
		return 0;
	end
	
	local cTeamMate	= tblMemberList[1];
	for i = 1, #tblMemberList do
		if (tblMemberList[i].szName ~= me.szName) then
			cTeamMate = tblMemberList[i];
		end
	end
	
	-- 在拜师前，如果不是好友关系，先自动加为好友
	if (me.IsFriendRelation(cTeamMate.szName) ~= 1) then
		Dialog:Say("Bạn phải kết bạn mới nhận được đệ tử.");
		return 0;
	end
	
	if (cTeamMate.nLevel < Relation.TEACHER_NIMIEVEL) then
		Dialog:Say(string.format("Cấp nhỏ hơn %s, không thể nhận đệ tử, hãy tu luyện thêm đi.", Relation.TEACHER_NIMIEVEL));
		return 0;
	end
	
	if (cTeamMate.nLevel - me.nLevel < Relation.GAPMINILEVEL) then
		Dialog:Say(string.format("Bạn chưa đủ <color=yellow>%s<color> cấp, không thể nhận sư phụ,  hãy tu luyện thêm đi.",
			Relation.GAPMINILEVEL));
		return 0;
	end
	
	local tbStudentList	= me.GetTrainingStudentList();
	if (tbStudentList and Lib:CountTB(tbStudentList) > Relation.MAX_STUDENCOUNT) then
		Dialog:Say(string.format("Đã có %s đệ tử, không thể nhận thêm, hãy nghỉ ngơi đi.", Relation.MAX_STUDENCOUNT));
		return 0;
	end
	
	if (cTeamMate.GetTrainingTeacher()) then
		Dialog:Say("Chưa thể tạo quan hệ sư đồ, hãy nghỉ ngơi đi.");
		return 0;
	end
	
	return 1;
end

-- 申请拜师
function tbNpc:AppTrain()
	local bCanAppTrain = self:CheckAppTrainCond();
	if (1 == bCanAppTrain) then
		local tblMemberList, nMemberCount = me.GetTeamMemberList()
		local cTeamMate	= tblMemberList[1];
		for i = 1, #tblMemberList do
			if (tblMemberList[i].szName ~= me.szName) then
				cTeamMate = tblMemberList[i];
				break;
			end
		end
		local szTeacherName = cTeamMate.szName;
		-- me.CallClientScript({"Relation:CmdApplyTeacher", cTeamMate.szName});
		cTeamMate.CallClientScript({"Relation:ApplyTeacher_S2C", me.szName});
	end
end

-- 密友：建立指定密友对话
function tbNpc:BuddyDialog()
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	-- 玩家必须处于组队状态，且队伍中只有两个人
	if (nMemberCount ~= 2) then
		Dialog:Say("Tổ đội 2 người đến để thành mật hữu")
		return
	end
	Dialog:Say("2 ngươi đến đây để trở thành mật hữu.",
		{
			{"Đúng, ta muốn trở thành mật hữu", tbNpc.MakeBuddy, self},
			{"Để ta suy nghĩ lại"}
		});
end

-- 密友：建立指定密友
function tbNpc:MakeBuddy()
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	-- 玩家必须处于组队状态，且队伍中只有两个人
	if (nMemberCount ~= 2) then
		Dialog:Say("Tổ đội 2 người đến để thành mật hữu")
		return
	end
	for i = 1, #tblMemberList do
		local cTeamMate = tblMemberList[i]
		if (cTeamMate.szName ~= me.szName) then
			-- 检查级别
			if (me.nLevel < 61 or cTeamMate.nLevel < 61) then
				Dialog:Say("Rất tiếc, bạn chưa đủ cấp <color=red>60<color>, hãy quay trở lại sau.")
				return
			end
			-- 两人必须互相是好友，且亲密度不低于 等级6级。即秦密度3600
			local nFavor = me.GetFriendFavor(cTeamMate.szName)
		
			if (nFavor <= 2500) then
				Dialog:Say("Độ thân mật của 2 ngươi chưa đạt cấp <color=red>6<color>, hãy quay trở lại sau.")
				return
			end
			-- 检查是否已经是指定密友
			if (KPlayer.CheckRelation(me.szName, cTeamMate.szName, RELATIONTYPE_BUDDY) ~= 0) then
				Dialog:Say("Đã là mật hữu rồi.")
				return
			end
			-- 两人之间必须没有师徒关系
			if (KPlayer.CheckRelation(me.szName, cTeamMate.szName, RELATIONTYPE_TRAINING, 1) ~= 0 or
				KPlayer.CheckRelation(me.szName, cTeamMate.szName, RELATIONTYPE_TRAINED, 1) ~= 0) then
				Dialog:Say("Quan hệ sư đồ không thể trở thành mật hữu.")
				return
			end
			-- 检查指定密友数量 暂时设定为4个
			if (me.GetRelationCount(RELATIONTYPE_BUDDY) >= 4 or
				cTeamMate.GetRelationCount(RELATIONTYPE_BUDDY) >= 4) then
				Dialog:Say("Bạn đã có đủ 4 mật hữu.")
				return
			end
			-- 两人之间必须没有介绍人关系
			if (KPlayer.CheckRelation(me.szName, cTeamMate.szName, RELATIONTYPE_INTRODUCE, 1) ~= 0) then
				Relation:DelRelation_GS(me.szName, cTeamMate.szName, RELATIONTYPE_INTRODUCE);
			end
			-- 建立指定密友关系
			Relation:AddRelation_GS(me.szName, cTeamMate.szName, RELATIONTYPE_BUDDY);
		end
	end
end

-- 确认介绍人对话
function tbNpc:IntroduceDialog()
	-- 检查级别
	if (me.nLevel > 11) then
		Dialog:Say("Ngươi đã quá cấp 11, không thể xác nhận người giới thiệu.")
		return
	end
	-- 玩家必须处于组队状态，且队伍中只有两个人
	

	local tblMemberList, nMemberCount = KTeam.GetTeamMemberList(me.nTeamId);
	local pszTeamHint = "1 trong 2 ngươi phải lớn hơn <color=red>30 cấp<color>, ta có thể giúp ngươi trở thành mật hữu." 
	if (nMemberCount ~= 2) then
		Dialog:Say(pszTeamHint)
		return
	end
	for i = 1, #tblMemberList do
		local npMemId = tblMemberList[i]
		if (npMemId ~= me.nId) then
			-- 检查级别
			local nOnline = KGCPlayer.OptGetTask(npMemId, KGCPlayer.TSK_ONLINESERVER);
			if nOnline <= 0 then
				Dialog:Say("Hảo hữu đang ngoại tuyến.");
				return;
			end
			local szMemName = KGCPlayer.GetPlayerName(npMemId);
			local tbInfo = GetPlayerInfoForLadderGC(szMemName);
			if not tbInfo then
				return;
			end
			if (tbInfo.nLevel - me.nLevel < 30) then
				Dialog:Say(pszTeamHint)
				return
			end
			-- 检查是否已有介绍人
			if (me.GetRelationCount(RELATIONTYPE_INTRODUCE) ~= 0) then 
				Dialog:Say("Bạn đã có người giới thiệu")
				return
			end
			-- 加介绍人之前需要已经是好友关系
			if (me.IsFriendRelation(szMemName) ~= 1) then
				Dialog:Say("Hãy trở thành hảo hữu trước.");
				return;
			end
			-- 建立介绍人关系
			Relation:AddRelation_GS(me.szName, szMemName, RELATIONTYPE_INTRODUCE, 0);
			Dialog:Say("Ngươi và " .. szMemName .. " thiết lập mật hữu.")
		end
	end
end

-- 删除密友对话
function tbNpc:DelBuddyDialog()
	Dialog:Say("Chỉ có thể xóa chỉ định mật hữu của bản thân. Đưa ta <color=red>20 vạn bạc<color>, ta sẽ hủy quan hệ mật hữu. Xác nhận chứ?",
		{
			{"Vâng, ta muốn giải trừ", tbNpc.DeleteBuddy, self},
			{"Ta phải suy nghĩ lại"}
		})
end

-- 删除密友
function tbNpc:DeleteBuddy()
	local tblRelation = me.GetRelationList(RELATIONTYPE_BUDDY)
	if (#tblRelation == 0) then
		Dialog:Say("Không phải là mật hữu")
		return
	end
	local tblOptions = {}
	for i = 1, #tblRelation do
		tblOptions[i] = {tblRelation[i], tbNpc.DeleteTheBuddyDialog, self, tblRelation[i]}
	end
	tblOptions[#tblRelation + 1] = {"Ta đang nghĩ về nó"}
	Dialog:Say("Ngươi muốn xóa mật hữu?", tblOptions)
end

-- 删除某个指定密友对话
function tbNpc:DeleteTheBuddyDialog(pszBuddy)
	Dialog:Say("Có phải ngươi và <color=yellow>" .. pszBuddy .. "<color> hủy bỏ quan hệ mật hữu?",
		{
			{"Vâng, ta muốn hủy bỏ quan hệ mật hữu với " .. pszBuddy .. "", tbNpc.DeleteTheBuddy, self, pszBuddy},
			{"Để ta suy nghĩ lại"}
		})
end

-- 删除某个指定密友
function tbNpc:DeleteTheBuddy(pszBuddyName)
	-- 扣除20W银两
	if (me.CostMoney(200000, Player.emKPAY_DEL_BUDDY) ~= 1) then
		Dialog:Say("Phải trả <color=red>200000<color> bạc mới có thể hủy bỏ, có đủ tiền hãy quay lại.")
		return
	end
	Relation:DelRelation_GS(me.szName, pszBuddyName, RELATIONTYPE_BUDDY);
	me.Msg("Ngươi đã cho 20 vạn bạc để "..pszBuddyName.." hủy bỏ quan hệ mật hữu.");
	KPlayer.SendMail(pszBuddyName,
		"Thông báo hủy mật hữu",
		"Xin chào, mật hữu của bạn " .. me.szName .. " đã hủy bỏ quan hệ mật hữu với bạn. Rất tiếc.")
end

-- 和师父解除关系对话
function tbNpc:DelTrainingTeacherDialog()
	local pszTeacher = me.GetTrainingTeacher()
	if (pszTeacher == nil) then
		Dialog:Say("Ngươi không thể hủy quan hệ sư đồ")
		return
	end
	Dialog:Say("Ngươi có muốn hủy quan hệ sư đồ với <color=yellow>" .. pszTeacher .. "<color>, nếu có quan hệ sẽ được hủy, ngươi không thể nhận thưởng quan hệ, hãy xem xét. Cần có <color=red>10000<color> bạc để hủy.",
		{
			{"Vâng, ta biết, ta muốn hủy quan hệ sư đồ", tbNpc.DelTrainingTeacher, self, pszTeacher},
			{"Ta phải suy nghĩ lại"}
		})
end

-- 和师父解除关系
function tbNpc:DelTrainingTeacher(pszTeacher)
	if (me.CostMoney(COST_DELTEACHER, Player.emKPAY_DEL_TEACHER) ~= 1) then
		Dialog:Say("Hủy quan hệ sư đồ cần <color=red>10000<color> bạc, ngươi không đủ tiền, khi nào đủ tiền hãy quay lại.")
		return
	end
	Relation:DelRelation_GS(me.szName, pszTeacher, RELATIONTYPE_TRAINING, 0);
	
	-- 去掉师徒称号
	local szStudentTitle = pszTeacher .. EventManager.IVER_szTudiTitle;
	me.RemoveSpeTitle(szStudentTitle);
	EventManager:WriteLog("去除自定义称号"..szStudentTitle, me);
	
	
	KPlayer.SendMail(pszTeacher, "Thông báo hủy quan hệ sư đồ",
		"Xin chào, đệ tử của ngươi " .. me.szName .. " đã đơn phương hủy bỏ quan hệ sư đồ. Rất tiếc.");
	Dialog:Say("Ngươi và <color=yellow>" .. pszTeacher .. "<color> đã hủy quan hệ sư đồ thành công, ngươi sẽ không còn gặp nhau.")
end

-- 和弟子解除关系对话
function tbNpc:DelTrainingStudentDialog()
	local tbStudent = me.GetTrainingStudentList()
	if (tbStudent == nil) then
		Dialog:Say("Ngươi không có sư đồ")
		return
	end
	local tbOption = {}
	for i = 1, #tbStudent do
		tbOption[i] = {tbStudent[i], tbNpc.DelTrainingStudent1, self, tbStudent[i]}
	end
	tbOption[#tbStudent + 1] = {"Vâng, ta đang nghĩ về nó"}
	Dialog:Say("Ngươi muốn hủy quan hệ sư đồ?", tbOption)
end

-- 和弟子解除关系
function tbNpc:DelTrainingStudent1(pszStudent)
	Dialog:Say("Ngươi có muốn hủy quan hệ sư đồ với <color=yellow>" .. pszStudent .. "<color>, nếu có quan hệ sẽ được hủy, ngươi không thể nhận thưởng quan hệ, hãy xem xét.",
		{
			{"Vâng, ta biết, ta muốn hủy quan hệ sư đồ", tbNpc.DelTrainingStudent2, self, pszStudent},
			{"Để ta suy nghĩ lại"}
		})
end

-- 和弟子解除关系
function tbNpc:DelTrainingStudent2(pszStudent)
	Relation:DelRelation_GS(me.szName, pszStudent, RELATIONTYPE_TRAINING, 1);
	
	local szTeacherTitle = pszStudent .. EventManager.IVER_szTeacherTitle;
	me.RemoveSpeTitle(szTeacherTitle);
	EventManager:WriteLog("Tước bỏ danh hiệu sư đồ"..szTeacherTitle, me);
	
	KPlayer.SendMail(pszStudent, "Thông báo hủy quan hệ sư đồ",
		"Xin chào, sư phụ của ngươi " .. me.szName .. " đã đơn phương hủy bỏ quan hệ sư đồ. Rất tiếc.");
	Dialog:Say("Ngươi và " .. pszStudent .. " đã hủy quan hệ sư đồ thành công, ngươi sẽ không còn gặp nhau.")
end

--开启师徒副本
function tbNpc:PreStartMentor()

	local tbMiss = self:GetTeamMission();
	
	--如果副本已经开启了，显示进入副本
	if tbMiss then		
			
		--将玩家再次传入到FB中的起始点
		tbMiss:ReEnterMission(me.nId);
	else	--否则开启副本	
		if Esport.Mentor:CheckEnterCondition(me.nId) ~= 1 then
			return;
		end
			
		if Esport.Mentor:PreStartMission() == 0 then
			Dialog:Say("Số lượng đã hết")
		end
	end

end

--根据当前队伍来取得MISSION，即始终根据队伍中的徒弟来取MISSION
function tbNpc:GetTeamMission()
	--必须是师徒二人组成的队伍才能进，这时候已经不需要做其它判定了，因为该玩家只会被送到他之前开启了的副本里面
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(me.nTeamId);
	if not anPlayerId or not nPlayerNum or nPlayerNum ~= 2 then 
		Dialog:Say("Sư phụ và đệ tử phải vào cùng tổ đội.");
		return;
	end
			
	--如果是徒弟要进，直接进入自己的副本就好了；
	--如果是师傅要进，进入到队伍中的徒弟的副本。
	local tbMiss;		
	if Esport.Mentor:CheckApprentice(me.nId) == 1 then
		tbMiss = Esport.Mentor:GetMission(me);
	else
		local pStudent = Esport.Mentor:GetApprentice(me.nId); 
		tbMiss = Esport.Mentor:GetMission(pStudent);		--如果当前队伍不是由满足关系的师徒二人组成的，得到的MISSION为NIL
	end
	
	return tbMiss;
end

-- 修复弟子已完成的固定成就
function tbNpc:RetrieveAchievement()
	-- 只有当前有师傅的时候才可以修复成就
	if (not me.GetTrainingTeacher()) then
		Dialog:Say("Hiện tại ngươi chưa có sư phụ");
		return;
	end
	
	local szMsg = "Thành công trong hệ thống sư đồ, nếu ngươi đã hoàn thành tất cả những thành tựu cố đinh, có thể không thành công nhưng có thể được sửa chữa. Các kết quả có thể được phục hồi trong giao diện bảng giao diện sư đồ.";
	Dialog:Say(szMsg,
		{"Ta đã biết, sửa chữa thành tựu", Achievement.CheckPreviousAchievement, Achievement, 1},
		{"Trở lại sau"});
end

function tbNpc:GetShiTuChuanSongFu(bAutoGet)

	local tbChuanSongFu = { Item.SCRIPTITEM, 1, 65, 1 };
	local tbBaseProp = KItem.GetItemBaseProp(unpack(tbChuanSongFu));
	if not tbBaseProp then
		return;
	end

	local nCount = me.GetItemCountInBags(unpack(tbChuanSongFu));
	if (nCount >= 1 and (not bAutoGet)) then
		me.Msg("Ngươi đã có Sư đồ đồng tâm phù");
		return;
	elseif (nCount >= 1 and bAutoGet and bAutoGet == 1) then
		return;
	end

	-- 现在领取师徒传送符的条件只要达到拜师条件即可
	local nLevel = me.nLevel;
	if (nLevel < 20 and (not bAutoGet)) then
		me.Msg("Phải đạt cấp 20 mới được nhận Sư đồ đồng tâm phù");
		return 0;
	elseif (nLevel < 20 and bAutoGet and bAutoGet == 1) then
		return 0;
	end
		
	local tbItem =
	{
		nGenre		= tbChuanSongFu[1],
		nDetail		= tbChuanSongFu[2],
		nParticular	= tbChuanSongFu[3],
		nLevel		= tbChuanSongFu[4],
		nSeries		= (tbBaseProp.nSeries > 0) and tbBaseProp.nSeries or 0,
		bBind		= KItem.IsItemBindByBindType(tbBaseProp.nBindType),
		nCount		= 1,
	};

	if (me.CanAddItemIntoBag(tbItem) == 0 and (not bAutoGet)) then
		me.Msg("Hành trang đã đầy");
		return;
	elseif (me.CanAddItemIntoBag(tbItem) == 0 and bAutoGet and bAutoGet == 1) then
		return;
	end

	tbChuanSongFu[5] = tbItem.nSeries;
	me.AddItem(unpack(tbChuanSongFu));
end


function tbNpc:GetIbBindCoin()
	me.ApplyGainIbCoin();
end

-- 出师仪式
function tbNpc.Graduation()
	if (tbNpc:CanDoRelationOpt(me.szName) == 0) then
		return;
	end
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	if (nMemberCount ~= 2) then
		Dialog:Say("Tổ đội 2 người đến đây")
		return
	end
	local cTeamMate	= tblMemberList[1];
	for i = 1, #tblMemberList do
		if (tblMemberList[i].szName ~= me.szName) then
			cTeamMate	= tblMemberList[i];		
		end	
	end
	local TeacherList	= me.GetTrainingTeacher();
	local StudentList	= me.GetTrainingStudentList();
	
	if (StudentList == nil) then
		if (TeacherList ~= nil) then
			Dialog:Say("Yêu cầu sư phụ phải có mặt",
				{
					{"Ta hiểu"};
				});
				return;
		end

		Dialog:Say("Hai ngươi không có mối quan hệ nào!");
		return;
		
	end
	local bFind	= 0;
	for _,szStudentName in ipairs(StudentList) do
		if (szStudentName == cTeamMate.szName) then
			bFind	= 1;
			break;
		end
	end
	if (0 == bFind)then
			Dialog:Say("Không có quan hệ sư đồ");
			return;
	end
	
	if (cTeamMate.nFaction == 0) then
		Dialog:Say("Chưa gia nhập môn phái");
		return;
	end
	
	-- 获取所有固定成就
	local tbGudingAchievement = Achievement_ST:GetSpeTypeAchievementInfo(cTeamMate.nId, "Thành tựu cố định");
	local bAchieve = 1;
	for _, tbInfo in pairs(tbGudingAchievement) do
		if (tbInfo.bAchieve == 0) then
			bAchieve = 0;
			break;
		end
	end
	if (0 == bAchieve) then
		Dialog:Say("Cần hoàn tất thành tựu cố định");
		return;
	end
	
	Dialog:Say("Sư phụ và đệ tử cần tổ độ, sau khi đạt cấp 90 và hoàn thành thành tựu cố định có thể xuất sư.",
		{
			{"Cho phép xuất sư", tbNpc.DoGraduation, self, cTeamMate},
			{"Ta chỉ xem qua"}
		});

end

function tbNpc:DoGraduation(cTeamMate)
	local szStudent	= "";
	-- 检查级别
	if (cTeamMate.nLevel < 90) then
		Dialog:Say("Chưa đạt cấp 90, hãy quay lại sau.");
		return
	end
	szStudent	= cTeamMate.szName;

	local pPlayer	= KPlayer.GetPlayerByName(szStudent);
	if (pPlayer ~= nil ) then
	
		me.TrainedStudent(szStudent);
		local szAccount = KGCPlayer.GetPlayerAccount(pPlayer.nId);
		StatLog:WriteStatLog("stat_info", "relationship", "remove", me.nId, szAccount, szStudent, 5, 0);
		StatLog:WriteStatLog("stat_info", "relationship", "create", me.nId, szAccount, szStudent, 6, 0);
		Dialog:Say("Đệ tử " .. szStudent.." đã xuất sư. Từ nay, " .. szStudent.." sẽ trở thành mật hữu và bạn sẽ nhận được 5% đồng khóa khi mật hữu tiêu phí tại Kỳ Trân Các. <color=yellow>Quan hệ sẽ tự động hủy bỏ sau 1 năm.<color>");	
		
		pPlayer.Msg("Xuất sư thành công, từ nay có thể tự mình bôn tẩu giang hồ.");
	end
	
	-- 去取自定义称号，只把师傅的称号去掉，弟子的保留
	local szTeacherTitle = cTeamMate.szName .. EventManager.IVER_szTeacherTitle;
	me.RemoveSpeTitle(szTeacherTitle);
	EventManager:WriteLog("去除自定义称号"..szTeacherTitle, me);
end

function tbNpc:CanDoRelationOpt(szAppName)
	local pAppPlayer = KPlayer.GetPlayerByName(szAppName);
	if (not pAppPlayer) then
		return 0;
	end
	local bCanOpt, szErrMsg = Relation:CanDoRelationOpt(szAppName);
	if (bCanOpt == 0) then
		if ("" ~= szErrMsg) then
			pAppPlayer.Msg(szErrMsg);
		end
		return 0;
	end
	return 1;
end

function tbNpc:AchievementDlg()
	if (not Achievement.FLAG_OPEN or Achievement.FLAG_OPEN == 0) then
		Dialog:Say("Hệ thống thành tựu chưa mở.");
		return;
	end
	
	local szMsg = "Ta có thể giúp gì cho ngươi?";
	local tbOpt = {
		{"Nhận lại thành tưu", self.RepairAchievementDlg, self},
		{"Mở cửa hàng thành tựu", self.OpenAchievementShop, self},
		{"Ta chỉ ghé xem thôi"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OpenAchievementShop()
	me.OpenShop(181, 10);
end

function tbNpc:RepairAchievementDlg()
	local szMsg = "Ngươi chắc chứ?";
	local tbOpt = {
		{"Đồng ý", self.RepairAchievement, self},
		{"Ta suy nghĩ lại đã"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:RepairAchievement()
	Achievement:RepairAchievement();
end

function Relation:SyncIbBinCoinInfo(tbInfoList, bFirst)
	if (not tbInfoList or #tbInfoList == 0)then
		local szMsg	= "";

		if (bFirst == 1) then
			szMsg = string.format("Hiện tại không có phần thưởng %s khóa", IVER_g_szCoinName);
		else
			szMsg = "Đã nhận tất cả.";
		end
		Dialog:Say(szMsg, 
		{
			{"Thoát"}
		});
		return;
	end
	if (bFirst ~= 1) then
		Dialog:Say(string.format("Tiếp tục nhận %s từ người khác.", IVER_g_szCoinName),
		{
			{"Đồng ý", Relation.ShowGetIbCoin, self, tbInfoList},
			{"Quay lại", Relation.CancelGainCoin, self},
		});
	else
		self:ShowGetIbCoin(tbInfoList);
	end
end

function Relation:ShowGetIbCoin(tbInfoList)
	for nIndex, tbInfo in ipairs(tbInfoList) do
		Dialog:Say("Mật hữu "..tbInfo.szName..string.format(" tiêu tốn trên Kỳ Trân Các, ngươi sẽ được nhận %s<color=red>", IVER_g_szCoinName)..tbInfo.nBindCoin.."<color> đồng khóa",
		{
			{"Đồng ý", Relation.GainIbCoin, self, tbInfo.szName, tbInfo.nBindCoin},
			{"Quay lại sau", Relation.CancelGainCoin, self},
		});
	end	
end

function Relation:GainIbCoin(szTarget, nBindCoin)
	if (me.nBindCoin + nBindCoin >= 2000000000) then
		me.Msg(string.format("Đã nhận đủ %s, không nhận thêm được.",IVER_g_szCoinName));
		return;
	end
	me.GainIbCoin(szTarget);
	
	-- 成就，获得密友返还金币
	Achievement:FinishAchievement(me, 14);
end

function Relation:CancelGainCoin()
	me.CancelGainIbCoin();
end

-- 找到当前师徒称号以及对应玩家的名字
function Relation:FindTitleAndName(szSuffix, pPlayer)
	local szPlayerName = "";
	
	local tbAllTitle = pPlayer.GetAllTitle();
	local szCurShituTitle = "";
	local bFind = 0;
	for _, tbTitleInfo in pairs(tbAllTitle) do
		-- 自定义称号大类的id是250
		local nTitleLen = string.len(tbTitleInfo.szTitleName);
		local nSuffixLen = string.len(szSuffix);
		local nStart, nEnd = string.find(tbTitleInfo.szTitleName, szSuffix);
		if (tbTitleInfo.byTitleGenre == 250 and nTitleLen > nSuffixLen and
			nStart ~= nEnd and nEnd == nTitleLen) then
			szPlayerName = string.sub(tbTitleInfo.szTitleName, 1, nTitleLen - nSuffixLen);
			return tbTitleInfo.szTitleName, szPlayerName;
		end
	end
end

function Relation:CheckTeacherTitle()
	-- 玩家的身份是师傅的话，检查无效的师徒称号并删除
	local szCurTitle, szPlayerName = self:FindTitleAndName(EventManager.IVER_szTeacherTitle, me);
	if (szCurTitle and szPlayerName and me.IsTeacherRelation(szPlayerName, 1) ~= 1) then
		me.RemoveSpeTitle(szCurTitle);
	end
end

function Relation:CheckStudentTitle()
	-- 玩家的身份是弟子的话，检查无效的师徒称号并删除
	local szCurTitle, szPlayerName = self:FindTitleAndName(EventManager.IVER_szTudiTitle, me);
	if (szCurTitle and szPlayerName and me.IsTeacherRelation(szPlayerName, 0) ~= 1) then
		me.RemoveSpeTitle(szCurTitle);
	end
end

-- 在玩家上线的时候，检查师徒称号是否有效
function Relation:CheckShituTitle()
	self:CheckTeacherTitle();
	self:CheckStudentTitle();
end

-- 注册通用上线事件
PlayerEvent:RegisterGlobal("OnLogin", Relation.CheckShituTitle, Relation);
