-- 文件名　:weaklyevent.lua
-- 创建者　:jiazhenwei
-- 创建时间:2011-12-13 16:49:06
-- 功能    :周末家族活动

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\kin\\kinplant\\kinplant_def.lua");

--load家族周末活动表
function KinPlant:LoadWeeklyEvent()
	local szFileName = "\\setting\\kin\\kinplant\\weeklyevent.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("[家族种植]读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nLevel = tonumber(tbParam.nLevel) or 0;
			local nTime = tonumber(tbParam.nTime) or 0;
			local nCount = tonumber(tbParam.nCount) or 0;
			local nMinCount = tonumber(tbParam.nMinCount) or 0;
			local nMaxStep = tonumber(tbParam.nMaxStep) or 0;
			self.tbWeeklyEvent[nLevel] = self.tbWeeklyEvent[nLevel] or {};
			self.tbWeeklyEvent[nLevel] = {nTime = nTime, nCount = nCount, nMinCount = nMinCount, nMaxStep = nMaxStep};
		end
	end
end

--load家族周末活动表
function KinPlant:LoadWeeklyNpcPos()
	local szFileName = "\\setting\\kin\\kinplant\\weeklynpcpos.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("[家族种植]读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nMapId = tonumber(tbParam.nMapId) or 0;
			local nPosX = tonumber(tbParam.TRAPX) or 0;
			local nPosY = tonumber(tbParam.TRAPY) or 0;
			if nMapId > 0 and nPosX > 0 and nPosY > 0 then
				self.tbWeeklyNpcPoint[nMapId] = self.tbWeeklyNpcPoint[nMapId] or {};
				table.insert(self.tbWeeklyNpcPoint[nMapId] , {math.floor(nPosX / 32), math.floor(nPosY/ 32)});
			end
		end
	end
end

KinPlant:LoadWeeklyEvent();
KinPlant:LoadWeeklyNpcPos();

--族长领取周末富禄之种
function KinPlant:GetSeedWeekly()
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang khóa, không thể nhận");
		return 0;	
	end
	local nWeek = tonumber(GetLocalDate("%w"));
	if nWeek > 0 and nWeek < 6 then
		Dialog:Say("Bạn chỉ có thể nhận Giống cây Phúc lộc từ 0 giờ ngày thứ 7.");
		return 0 ;
	end
	if me.nKinFigure ~= 1 then
		Dialog:Say("Chỉ có Tộc trưởng mới có thể đến nhận.");
		return 0 ;
	end
	local cKin = KKin.GetKin(me.dwKinId)
	if not cKin then
		return 0;
	end
	local nFlag = math.fmod(cKin.GetHandInCount() , 10);
	local nWeek = math.floor(math.fmod(cKin.GetHandInCount(), 1000) / 10);
	local nCount = math.floor(cKin.GetHandInCount() / 1000);
	local nNowWeek = tonumber(GetLocalDate("%W"));
	if nNowWeek ~= nWeek then
		nCount = 0;
		nFlag = 0;
	end
	if nFlag >= 1 then
		Dialog:Say("Hạt giống đã được nhận tuần này rồi.");
		return 0 ;
	end
	if nCount < self.nKinMaxTreeWeekly then
		Dialog:Say(string.format("Rât tiếc tuần này Gia tộc chỉ trồng được %s cây, để nhận Giống cây Phúc lộc cần tối thiểu thu hoạch %s cây giống mỗi tuần.", nCount, self.nKinMaxTreeWeekly));
		return 0 ;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ 2 ô trống.");
		return 0 ;
	end
	for i = 1, 2 do
		local pItem  = me.AddItem(unpack(self.tbWeeklySeed));
		if pItem then
			me.SetItemTimeout(pItem, 2*24*60, 0);
		end
	end
	GCExcute{"KinPlant:SetKinFlag", me.dwKinId};
	StatLog:WriteStatLog("stat_info", "spe_tree", "get_tree", me.nId, 1);
	KKin.Msg2Kin(me.dwKinId, "Đã nhận Giống cây Phúc lộc từ Lữ Phong Niên.", 0);
end

--种周末的树
function KinPlant:PlantWeekly(nLevel, nItemLevel)
	if not nLevel or not self.tbWeeklyEvent[nLevel] then
		Dialog:Say("Mức chọn không đúng");
		return 0;
	end
	if me.dwKinId <= 0 then
		Dialog:Say("Ngươi chưa có Gia tộc, không thể gieo hạt.");
		return 0 ;
	end
	--time
	if nItemLevel <= 1 then	--特殊树种这里不做周末限制
		local nDate = tonumber(GetLocalDate("%w"));
		if not self.tbWeeklyDate[nDate] then
			Dialog:Say("Giống cây này chỉ có thể trồng vào cuối tuần.");
			return 0 ;
		end
	end
	--map
	local nMapId, x, y = me.GetWorldPos();
	if not self.tbWeaklyMap[nMapId] then
		Dialog:Say("Hạt giống chỉ có thể gieo ở Phượng Tường Phủ và Thành Đô Phủ.");
		return 0;
	end
	--npc
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			Dialog:Say("Trồng tại đây sẽ che khuất <color=green>".. pNpc.szName.."<color>. Hãy lựa chọn nơi khác.");
			return 0;
		end
	end
	local pNpc = KNpc.Add2(self.nWeeklyTempNpcId, 1, -1, nMapId, x, y);
	if not pNpc then
		return 0;
	end
	pNpc.SetLiveTime(30*60*18);	--树只存在30分钟
	local nAddTime = 0;
	if self.nTimer_ReFreshNpc then
		nAddTime = math.max(math.floor(Timer:GetRestTime(self.nTimer_ReFreshNpc) / Env.GAME_FPS), 0);
	end
	local nTimerId = Timer:Register((self.tbWeeklyEvent[nLevel].nTime + nAddTime) * Env.GAME_FPS, self.Rand, self, pNpc.dwId, nLevel);
	local tbTemp = pNpc.GetTempTable("Npc");
	tbTemp.tbWeekly = {
		["nLevel"] 	= nLevel,
		["dwKinId"]  	= me.dwKinId,
		["nTimerId"]  	= nTimerId,
		["nFinish"]  	= 0,
		["nStep"]  	= 0,
		["nCount1"]  	= 0,
		["nCount2"]  	= 0,
		["nCount3"]  	= 0,
		["tbPlayer"] 	= {},
		["tbAward"] 	= {},
		["tbStepCount"] 	= {},
		};
	local szKinName = "";
	local cKin = KKin.GetKin(me.dwKinId)
	if cKin then
		szKinName = cKin.GetName();
	end
	if szKinName ~= "" then
		pNpc.szName = pNpc.szName .. " của " .. szKinName;	
	end
	return 1;
end

--增加步骤
function KinPlant:AddStep(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		return;
	end
	tbTemp.tbWeekly.nStep = tbTemp.tbWeekly.nStep + 1;
	local nLevel = tbTemp.tbWeekly.nLevel;
	--已经最后一波了
	if self.tbWeeklyEvent[nLevel].nMaxStep + 1  <= tbTemp.tbWeekly.nStep then
		return 1;
	end
	--已经达标
	if self.tbWeeklyEvent[nLevel].nMinCount  <= tbTemp.tbWeekly.nFinish then
		return 2;
	end
	return;
end

--随即刷道具，需求物品
function KinPlant:Rand(dwNpcId, nLevel)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		return 0;
	end
	local cKin = KKin.GetKin(tbTemp.tbWeekly.dwKinId)
	local nStep = self:AddStep(dwNpcId);
	if nStep then
		local szMsg = "";
		if nStep == 1 then
			szMsg = "Hoạt động Trồng cây Phúc Lộc đã kết thúc. Thử thách thất bại";			
			if cKin then
				--StatLog:WriteStatLog("stat_info", "spe_tree", "tree_end", me.nId, string.format("0,%s", tbTemp.tbWeekly.nLevel));
				WriteStatLog("stat_info", "spe_tree", "tree_end", string.format("NONE\tNONE\t%s,0,%s", cKin.GetName(), tbTemp.tbWeekly.nLevel));
			end
		else
			szMsg = "Hoạt động Trồng cây Phúc lộc thành công. Mời thành viên đến nhận thưởng";
			if cKin then
				local tbName = {"Xuất Trần","Kinh Thế","Sồ Phượng","Tiềm Long","Chí Tôn","<color=yellow>Vô Song<color>"};
				local szWorldMsg = string.format("Gia tộc [%s] vượt qua thử thách [%s] trong hoạt động Trồng cây Phúc lộc.", cKin.GetName(), tbName[tbTemp.tbWeekly.nLevel])
				KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szWorldMsg);
				Dialog:GlobalMsg2SubWorld_GS(szWorldMsg);
				--StatLog:WriteStatLog("stat_info", "spe_tree", "tree_end", me.nId, string.format("1,%s", tbTemp.tbWeekly.nLevel));
				WriteStatLog("stat_info", "spe_tree", "tree_end", string.format("NONE\tNONE\t%s,1,%s", cKin.GetName(), tbTemp.tbWeekly.nLevel));
			end
		end
		KKin.Msg2Kin(tbTemp.tbWeekly.dwKinId, szMsg, 0);
		self:CloseAddNpc();
		return 0;
	end
	self:RandItem(dwNpcId);
	if tbTemp.tbWeekly.nStep == 1 then
		self:AddNpc(pNpc.nMapId);
		KKin.Msg2Kin(tbTemp.tbWeekly.dwKinId, string.format("Các vị đại hiệp có thể đến giao nguyên liệu cho Cây Phúc lộc.", tbTemp.tbWeekly.nStep), 0);
	else
		KKin.Msg2Kin(tbTemp.tbWeekly.dwKinId, string.format("Đợt %s đã bắt đầu, hãy nhanh chân thu thập nguyên liệu càng sớm càng tốt.", tbTemp.tbWeekly.nStep), 0);
	end
	return self.tbWeeklyEvent[nLevel].nTime * Env.GAME_FPS;
end

--随即需求的道具
function KinPlant:RandItem(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		return;
	end
	local nLevel = tbTemp.tbWeekly.nLevel;
	local nCount1 = 0;
	local nCount2 = 0;
	local nCount3 = 0;
	--需求的总数
	local nCount  = self.tbWeeklyEvent[nLevel].nCount;	
	nCount1 = MathRandom(nCount);	--随即第1种
	nCount = nCount - nCount1;
	if nCount > 0 then 
		nCount2 = MathRandom(nCount);	--随即第2种
		nCount3 = nCount - nCount2;			--剩余的为第3种
	end	
	
	local tbCount = {nCount1, nCount2, nCount3};
	Lib:SmashTable(tbCount)	--打乱随即的物品
	tbTemp.tbWeekly.nCount1 = tbCount[1];
	tbTemp.tbWeekly.nCount2 = tbCount[2];
	tbTemp.tbWeekly.nCount3 = tbCount[3];
	return;
end

--每个家族第一阶段掉进来
function KinPlant:AddNpc(nMapId)
	if self.nNum_KinPlant <= 0 then
		self.nTimer_ReFreshNpc = Timer:Register(1, self.AddNpcTime, self, nMapId);
	end
	self.nNum_KinPlant = self.nNum_KinPlant  + 1;
end

--每个家族完成或者失败掉进来
function KinPlant:CloseAddNpc()
	self.nNum_KinPlant = math.max(self.nNum_KinPlant - 1, 0);		-- 保证不会出现负值
end

--补充npc数量，保持每种4个
function KinPlant:AddNpcTime(nMapId)
	--如果发现已经没有家族在进行任务了关掉刷npc的timer
	if self.nNum_KinPlant <= 0 then
		return 0;
	end
	for i = 1, 8 do
		local nIndex = self:RandomPos(nMapId);	--随即一个不重复的点
		local x, y = unpack(self.tbWeeklyNpcPoint[nMapId][nIndex]);
		local pNpc = KNpc.Add2(self.tbWeeklyNpcId[math.fmod(i,2) + 1], 1, -1, nMapId, x, y);
		if pNpc then
			pNpc.SetLiveTime(3*60*18);	--只存在2分钟
			self.tbManagerNpc[i] = nIndex;
		end
	end
	--没有加过，或者上次出现的时间不满足现在情况
	for j = 9, 12 do		
		local nIndex = self:RandomPos(nMapId);	--随即一个不重复的点
		local nX, nY = unpack(self.tbWeeklyNpcPoint[nMapId][nIndex]);
		Npc:OnSetFreeAI(nMapId, nX*32, nY*32, 9873, 0, 0, 180, 0, 9890, 10, {});
		self.tbManagerNpc[j] = nIndex;
	end
	return 3*60*Env.GAME_FPS;
end

--随即点
function KinPlant:RandomPos(nMapId)
	local nRand = MathRandom(#self.tbWeeklyNpcPoint[nMapId])
	for i = 1, 5 do
		if self.tbManagerNpc[i] and self.tbManagerNpc[i] == nRand then
			nRand = nRand + 1;
			nRand = math.fmod(nRand, #self.tbWeeklyNpcPoint[nMapId]) + 1;	--防止出现超过最大值的点
		end
	end
	return nRand;
end

--检查身上是不是有有材料
function KinPlant:CheckItemInBag()
	if #GM:GMFindAllRoom({18,1,1587,1}) > 0 then
		return 1;
	end
	if #GM:GMFindAllRoom({18,1,1588,1}) > 0 then
		return 1;
	end
	if #GM:GMFindAllRoom({18,1,1589,1}) > 0 then
		return 1;
	end
	return 0;
end

----------------------------------------------------------------------
--npc
local tbNpc = Npc:GetClass("weeklyplant");

function tbNpc:OnDialog()
	local tbName = {"Xuất Trần","Kinh Thế","Sồ Phượng","Tiềm Long","Chí Tôn","<color=yellow>Vô Song<color>"};
	local tbItemName = {"Nước", "Phân bón", "Thuốc trừ sâu"}
	local tbTemp = him.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		Dialog:Say("Cây đang bệnh.");
		return;
	end
	if tbTemp.tbWeekly.dwKinId ~= me.dwKinId then
		Dialog:Say("Cây này không thuộc Gia tộc của bạn.");
		return 0;
	end
	local nLevel = tbTemp.tbWeekly.nLevel;
	local szMsg = "";
	local nMaxStep  = KinPlant.tbWeeklyEvent[nLevel].nMaxStep;	
	local nMinCount  = KinPlant.tbWeeklyEvent[nLevel].nMinCount;
	local nFlag = 0;
	if tbTemp.tbWeekly.nStep <= 0 then
		szMsg = "Cây Phúc Lộc (Độ khó "..tbName[nLevel]..") sẽ bắt đầu sau: "..string.format("%s giờ %s phút %s giây", Lib:TransferSecond2NormalTime(math.floor(Timer:GetRestTime(tbTemp.tbWeekly.nTimerId) / 18)));
	elseif tbTemp.tbWeekly.nStep <= nMaxStep and tbTemp.tbWeekly.nFinish < nMinCount then
		szMsg = string.format("Thử thách Cây Phúc Lộc đã bắt đầu: \nMỗi giai đoạn phát triển của Cây Phúc Lộc đều cần một lượng <color=green>Nước, Phân bón, Thuốc trừ sâu<color>. Nộp đủ nguyên liệu đúng thời gian quy định ở mỗi giai đoạn sẽ nhận được <color=yellow>1 điểm tăng trưởng<color>. Gia tộc sẽ được thưởng khi đạt yêu cầu về điểm tăng trưởng.\n<color=red>Mỗi thành viên chỉ có thể mang theo tối đa 1 nguyên liệu và chỉ giao tối đa 2 nguyên liệu mỗi vòng.<color>\n<color=yellow>[Nước và Phân bón]<color>: Có thể thu thập trong thành\n<color=yellow>[Thuốc trừ sâu]<color>: Đối thoại với Cung Phong Niên đang đi bộ trong thành\nĐộ khó: <color=yellow>%s<color>, Điểm tăng trưởng tối thiểu %s\nGiai đoạn: <color=yellow>%s/%s<color>, Giá trị tăng trưởng <color=yellow>%s<color>\nNước: :<color=yellow>%s<color>\nPhân bón:<color=yellow>%s<color>包\nThuốc trừ sâu:<color=yellow>%s<color>包\nThời gian còn lại: %s giờ %s phút %s giây", 
			tbName[nLevel], nMinCount, tbTemp.tbWeekly.nStep, nMaxStep, tbTemp.tbWeekly.nFinish, tbTemp.tbWeekly.nCount1, tbTemp.tbWeekly.nCount2, tbTemp.tbWeekly.nCount3, Lib:TransferSecond2NormalTime(math.floor(Timer:GetRestTime(tbTemp.tbWeekly.nTimerId) / 18)));
		if tbTemp.tbWeekly.nCount1 == 0 and tbTemp.tbWeekly.nCount2 == 0 and tbTemp.tbWeekly.nCount3 == 0 then
			szMsg = string.format("Thử thách Cây Phúc Lộc đã bắt đầu: \nMỗi giai đoạn phát triển của Cây Phúc Lộc đều cần một lượng <color=green>Nước, Phân bón, Thuốc trừ sâu<color>. Nộp đủ nguyên liệu đúng thời gian quy định ở mỗi giai đoạn sẽ nhận được <color=yellow>1 điểm tăng trưởng<color>. Gia tộc sẽ được thưởng khi đạt yêu cầu về điểm tăng trưởng.\n<color=red>Mỗi thành viên chỉ có thể mang theo tối đa 1 nguyên liệu và chỉ giao tối đa 2 nguyên liệu mỗi vòng.<color>\n<color=yellow>[Nước và Phân bón]<color>: Có thể thu thập trong thành\n<color=yellow>[Thuốc trừ sâu]<color>: Đối thoại với Cung Phong Niên đang đi bộ trong thành\nĐộ khó: <color=yellow>%s<color>, Điểm tăng trưởng tối thiểu %s\nGiai đoạn: <color=yellow>%s/%s<color>, Giá trị tăng trưởng <color=yellow>%s<color>\n<color=green>Lượt này đã hoàn thành<color>\nThời gian còn lại: %s giờ %s phút %s giây", 
			tbName[nLevel], nMinCount, tbTemp.tbWeekly.nStep, nMaxStep, tbTemp.tbWeekly.nFinish, Lib:TransferSecond2NormalTime(math.floor(Timer:GetRestTime(tbTemp.tbWeekly.nTimerId) / 18)));
		end
		nFlag = 1;
	else
		if tbTemp.tbWeekly.nFinish >= nMinCount then
			szMsg = "Sự chăm chỉ của bạn đã được ghi nhận. Đây chính là phần thưởng cho sự cố gắng không ngừng nghỉ.";
			nFlag = 3;
		else
			szMsg = "Rất tiếc bạn cần cố gắng hơn. Đừng nản lòng, hãy tiếp tục cố gắng hơn ở lần sau.";
			nFlag = 2;
		end
	end
	
	local tbOpt = {};
	if nFlag > 0 then
		table.insert(tbOpt, {"Xem số người đã nộp nguyên liệu", self.Quely, self, him.dwId});
	end
	if nFlag == 1 then
		table.insert(tbOpt, 1,  {"Nộp nguyên liệu", self.HandInItem, self, him.dwId});
	elseif nFlag >= 2 then
		table.insert(tbOpt, {"Nhận thưởng", self.GetAward, self, him.dwId, nFlag});
	end
	table.insert(tbOpt, {"Quy tắc hoạt động", self.QuelyRule, self});
	table.insert(tbOpt, {"Ta hiểu rồi"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:QuelyRule()
	Dialog:Say("Mỗi giai đoạn Cây Phúc Lộc cần 1 lượng Nước, Phân bón, Thuốc trừ sâu. <color=green>Nước và Phân bón<color> thu thập trong thành thị， <color=green>Thuốc trừ sâu<color> cần đối thoại với <color=green>Cung Phong Niên<color>.\n  Nếu hoàn thành trong thời gian quy định, Cây Phúc Lộc sẽ nhận được <color=yellow>1 điểm tăng trưởng<color>. Mỗi khi bắt đầu vòng mới, địa điểm Nước, Phân bón sẽ thay đổi địa điểm thu thập.")
end

function tbNpc:Quely(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		Dialog:Say("Cây đang bệnh");
		return;
	end
	local szMsg = "Người chơi đã nộp nguyên liệu:\n"
	local tb = {};
	for szName, nCount in pairs(tbTemp.tbWeekly.tbPlayer) do
		table.insert(tb, {szName, nCount});
	end
	if #tb > 1 then
		table.sort(tb, function(a, b) return a[2] > b[2] end);
	end
	for i, tbInfo in pairs(tb) do
		szMsg = szMsg.."Vị trí "..i..":  "..tbInfo[1].."x"..tbInfo[2].."\n";
	end
	Dialog:Say(szMsg);
	return;
end

function tbNpc:HandInItem(dwNpcId)
	Dialog:OpenGift("Hãy đặt nguyên liệu vào", nil ,{self.OnOpenGiftOk, self, dwNpcId});
end

function tbNpc:OnOpenGiftOk(dwNpcId, tbItemObj)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		return 0;
	end
	if tbTemp.tbWeekly.dwKinId ~= me.dwKinId then
		Dialog:Say("Cây này không thuộc Gia tộc của ngươi. Nhầm hàng rồi!");
		return 0;
	end
	if me.nKinFigure == 0 or me.nKinFigure == Kin.FIGURE_SIGNED then
		Dialog:Say("Chỉ có thành viên Chính thức và thành viên Danh dự được tham gia.");
		return 0;
	end
	if Lib:CountTB(tbItemObj) ~= 1 then
		Dialog:Say("Mỗi lần chỉ có thể đưa 1 nguyên liệu");
		return 0;
	end
	local nStep = tbTemp.tbWeekly.nStep;
	if tbTemp.tbWeekly.tbStepCount[me.szName] then
		if nStep == tbTemp.tbWeekly.tbStepCount[me.szName][1] and tbTemp.tbWeekly.tbStepCount[me.szName][2] >= KinPlant.nMaxStepCount then
			Dialog:Say(string.format("Chỉ có thể giao %s mỗi giai đoạn", KinPlant.nMaxStepCount));
			return 0;
		end
	end
	local nParticular = 0;
	for _, pItem in pairs(tbItemObj) do
		local szItem = string.format("%s,%s,%s,%s", pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if szItem ~= "18,1,1587,1" and szItem ~= "18,1,1588,1" and szItem ~= "18,1,1589,1" then
			Dialog:Say("Không đúng nguyên liệu rồi");
			return 0;
		end
		nParticular = pItem[1].nParticular;
	end
	for _, pItem in pairs(tbItemObj) do
		pItem[1].Delete(me);
	end
	
	for i = 1, 3 do
		if nParticular == 1586 + i and tbTemp.tbWeekly["nCount"..i] > 0 then
			tbTemp.tbWeekly["nCount"..i] = tbTemp.tbWeekly["nCount"..i] - 1;
			tbTemp.tbWeekly.tbPlayer[me.szName] = tbTemp.tbWeekly.tbPlayer[me.szName] or 0;
			tbTemp.tbWeekly.tbPlayer[me.szName] = tbTemp.tbWeekly.tbPlayer[me.szName] + 1;
			--每次步骤只能交两次
			tbTemp.tbWeekly.tbStepCount[me.szName] = tbTemp.tbWeekly.tbStepCount[me.szName] or {nStep, 0};
			if nStep ~= tbTemp.tbWeekly.tbStepCount[me.szName][1] then
				tbTemp.tbWeekly.tbStepCount[me.szName] = {nStep, 0};
			end
			tbTemp.tbWeekly.tbStepCount[me.szName][2] = tbTemp.tbWeekly.tbStepCount[me.szName][2] + 1;
			--因为每次最多上交1个，所以在这里做判断不会出问题
			self:CheckIsFinish(dwNpcId);
			local tbItemName = {"Nước", "Phân bón", "Thuốc trừ sâu"}
			Dialog:SendBlackBoardMsg(me, string.format("Bạn vừa giao 1 %s", tbItemName[i]));
			StatLog:WriteStatLog("stat_info", "spe_tree", "tree_join", me.nId, i);
		end
	end
end

--每次交种子都判断本次是不是成功
function tbNpc:CheckIsFinish(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		return 0;
	end
	local nFlag = 0;
	for i = 1, 3 do
		if tbTemp.tbWeekly["nCount"..i] ~= 0 then
			nFlag = 1;
			break;
		end
	end
	if nFlag == 0 then
		 tbTemp.tbWeekly.nFinish =  tbTemp.tbWeekly.nFinish + 1;
		 KKin.Msg2Kin(me.dwKinId, "Đã thu thập đủ tài nguyên cho Cây Phúc Lộc", 0);
	end
end

function tbNpc:GetAward(dwNpcId, nFlag)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbWeekly then
		return;
	end
	if  not KinPlant.tbWeeklyAward[tbTemp.tbWeekly.nLevel] then
		return;
	end
	local tbAward = KinPlant.tbWeeklyAward[tbTemp.tbWeekly.nLevel];
	if tbTemp.tbWeekly.tbAward[me.szName] then
		Dialog:Say("Ngươi đã nhận phần thưởng rồi");
		return;
	end
	if me.CountFreeBagCell() < 3 + nFlag then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", 3 + nFlag));
		return;
	end
	if not tbTemp.tbWeekly.tbPlayer[me.szName] then
		Dialog:Say("Chỉ có thể nhận phần thưởng sau khi hoàn tất thử thách!");
		return;
	end
	if nFlag == 3 then
		me.AddStackItem(tbAward[2][1], tbAward[2][2], tbAward[2][3], tbAward[2][4], nil, tbAward[1]);
		me.AddKinReputeEntry(10);
		Achievement:FinishAchievement(me, 472);	--缘起缘落
		Achievement:FinishAchievement(me, 473);	--福泽广被
		Achievement:FinishAchievement(me, 473 + tbTemp.tbWeekly.nLevel);	--泽被苍生1-5,苦尽甘来
	end
	me.AddStackItem(18,1,80,1, nil, 5);
	tbTemp.tbWeekly.tbAward[me.szName] = 1;
	me.Msg("Chúc mừng vượt qua thử thách.");
end

--清水
local tbWarter = Npc:GetClass("weeklywarter");

function tbWarter:OnDialog(_, nFlag)
	if KinPlant:CheckItemInBag() == 1 then
		Dialog:Say("Mỗi người chỉ mang tối đa 1 nguyên liệu");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống");
		return;
	end
	if not nFlag then
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
			};
		GeneralProcess:StartProcess("Đang thu thập...", 3 * Env.GAME_FPS, {self.OnDialog, self, _, 1}, nil, tbEvent);
		return;
	end
	local pItem  = me.AddItem(18,1,1587,1);
	if pItem then
		me.SetItemTimeout(pItem, 3, 0);
		Dialog:SendBlackBoardMsg(me, string.format("Đã thu thập được 1 %s", pItem.szName));
	end
	
end

--肥料
local tbFertilizer = Npc:GetClass("weeklyfertilizer");

function tbFertilizer:OnDialog(_, nFlag)
	if KinPlant:CheckItemInBag() == 1 then
		Dialog:Say("Mỗi người chỉ mang tối đa 1 nguyên liệu");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống");
		return;
	end
	if not nFlag then
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
			};
		GeneralProcess:StartProcess("Đang thu thập...", 3 * Env.GAME_FPS, {self.OnDialog, self, _, 1}, nil, tbEvent);
		return;
	end
	local pItem  = me.AddItem(18,1,1588,1);
	if pItem then
		me.SetItemTimeout(pItem, 3, 0);
		Dialog:SendBlackBoardMsg(me, string.format("Đã thu thập được 1 %s", pItem.szName));
	end
end

--药粉
local tbPower = Npc:GetClass("weeklypower");

function tbPower:OnDialog(_, nFlag)
	if not nFlag then
		Dialog:Say("Ngươi đến tìm <color=yellow>Thuốc trừ sâu<color> đúng không? Cái này quý giá lắm, ta cho ngươi 1 cái mang về. Cầu mong ngươi sẽ hoàn thành thử thách", {{"Cảm ơn ngài!", self.OnDialog, self, nil, 1},{"Ta không cần nữa"}});
		return 0;
	end
	if KinPlant:CheckItemInBag() == 1 then
		Dialog:Say("Mỗi người chỉ mang tối đa 1 nguyên liệu");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống");
		return;
	end
	local pItem  = me.AddItem(18,1,1589,1);
	if pItem then
		me.SetItemTimeout(pItem, 3, 0);
		Dialog:SendBlackBoardMsg(me, string.format("Đã thu thập được 1 %s", pItem.szName));
	end
end
----------------------------------------------------------------------
--item

local tbSeed = Item:GetClass("WeeklySeed");

function tbSeed:OnUse(nLevel, dwItemId)
	local tbName = {"Xuất Trần","Kinh Thế","Sồ Phượng","Tiềm Long","Chí Tôn","<color=yellow>Vô Song<color>"};
	local szMsg = "Hạt giống thú vị và đầy thử thách. Có thể trồng ở Phượng Tường Phủ hoặc Thành Đô Phủ vào cuối tuần, <color=yellow>hãy chọn độ khó cho thử thách<color>\n\n<color=yellow>[Qui tắc]<color>: Quá trình trồng cây kéo dài 30 phút và được chia thành 10 giai đoạn. Đối với mỗi giai đoạn, cây Phúc Lộc sẽ yêu cầu một lượng nhất định <color=green>Nước, Phân bón, Thuốc trừ sâu<color>\n<color=yellow>Nước và Phân bón<color>: Thu thập trong thành\n<color=yellow>Thuốc trừ sâu<color>: Nhận từ Cung Phong Niên đi dạo trong thành\n  Nếu hoàn thành thử thách trong thời gian quy định sẽ nhận được <color=yellow>1 điểm tăng trưởng<color>\n<color=red>Chỉ có thể mang theo 1 nguyên liệu trong túi<color>";
	local tbOpt = {};
	if not dwItemId then
		for i = 1, 6 do
		 	table.insert(tbOpt, {tbName[i], self.OnUse, self, i, it.dwId})
		end
		table.insert(tbOpt, {"Để ta suy nghĩ lại"});
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	if not dwItemId then
		return;
	end
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return;
	end
	if KinPlant:PlantWeekly(nLevel, pItem.nLevel) == 1 then
		pItem.Delete(me);
		local cKin = KKin.GetKin(me.dwKinId)
		if cKin then
			local tbMap = {[24] = "Phượng Tường Phủ", [27] = "Thành Đô Phủ"};
			local szWorldMsg = string.format("Gia tộc [%s] tại [%s] trồng Cây Phúc Lộc, các thành viên gia tộc đang cùng nhau vượt thử thách", cKin.GetName(), tbMap[me.nMapId]);
			KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szWorldMsg);
			Dialog:GlobalMsg2SubWorld_GS(szWorldMsg);
		end
		StatLog:WriteStatLog("stat_info", "spe_tree", "seed_use", me.nId, 1);
		KKin.Msg2Kin(me.dwKinId, "Cây Phúc Lộc đã được trồng, mau nhanh chân đến hoàn thành thử thách", 0);
	end
end

local tbSource = Item:GetClass("WeeklySource");

function tbSource:OnUse()
	Dialog:Say(" Bạn muốn phá hủy nguyên liệu này", {{"Đồng ý", self.Destroy, self, it.dwId},{"Ta suy nghĩ đã"}})
	return 0;
end

function tbSource:Destroy(dwId)
	local pItem = KItem.GetObjById(dwId);
	if pItem then
		local szName = pItem.szName;
		pItem.Delete(me);
		me.Msg("Đã phá hủy "..szName);
	end
end
