
-- ====================== 文件信息 ======================

-- 剑侠世界门派任务奖励处理文件
-- Edited by peres
-- 2007/05/14 PM 08:33

-- 在人群里
-- 一对对年轻的情侣，彼此紧紧地纠缠在一起，旁若无人地接吻
-- 爱情如此美丽，似乎可以拥抱取暖到天明
-- 我们原可以就这样过下去，闭起眼睛，抱住对方，不松手亦不需要分辨。

-- ======================================================

-- 初始化奖励数据
function LinkTask:InitAward()
	
	print ("Start InitAward!");
	
	self.tbFile_AwardGroupRate	= Lib:NewClass(Lib.readTabFile, "\\setting\\task\\linktask\\award_grouprate.txt");
	self.tbFile_AwardItemRate	= Lib:NewClass(Lib.readTabFile, "\\setting\\task\\linktask\\award_itemrate.txt");

	-- 从表格里读出物品概率构造的 table
	self.tbAwardItemRate = {};
	
	self:_AssignItemRate(self.tbFile_AwardItemRate);
	
end;


-- 选择三个类型的奖励中，返回为一个有三个元素的 table
function LinkTask:SelectAwardType()
	local tbResult = {0,0,0};
	local tbNowRate = {};
	local nSelect = 0;
	
	-- 经验、金钱、物品、取消机会
	tbNowRate = {[1]=30,[2]=30,[3]=29,[4]=10}
	
	-- 选三个类型的奖励
	for i=1, 3 do
		nSelect = self:_CountAwardRate(tbNowRate, i);
		tbNowRate[nSelect] = 0;
		tbResult[i] = nSelect;
	end;
	
	return tbResult;
end;


function LinkTask:_CountAwardRate(tbRate, nBit)
	local nRow = #tbRate;
	local nRandom = 0;
	local nAdd = 0;
	local i=0;
	
	for i=1, nRow do
		nAdd = nAdd + tbRate[i];
	end;
	
	nRandom = self:GetRandomSeed(nBit);
	if nRandom <= 0 then
		nRandom = MathRandom(1, nAdd);
		self:SaveRandomSeed(nRandom, nBit);
	end
	
	nAdd = 0;
	
	for i=1, nRow do
		nAdd = nAdd + tbRate[i];
		if nAdd>=nRandom then
			return i;
		end;
	end;
	
	self:_Debug("CountAwardRate: error!");
	return 0;
end;


-- 获取当前等级的生产率
function LinkTask:_CountLevelProductivity()
	local nPyValue = 0;
	local nLevelGroup = self:SelectLevelGroup();
	local nLevelGroupRow = self.tbfile_TaskLevelGroup:GetDateRow("LevelGroup", nLevelGroup);
	
		nPyValue = self.tbfile_TaskLevelGroup:GetCellInt("LevelPy", nLevelGroupRow);
		if nPyValue == 0 or nPyValue == nil then
			self:_Debug("CountLevelProductivity: Get data error!");
			return 0;
		end;
		return nPyValue;
end;


-- 获取当前等级的基准经验
function LinkTask:_CountBasicExp()
	local nBasicExp = 0;
	local nLevelGroup = self:SelectLevelGroup();
	local nLevelGroupRow = self.tbfile_TaskLevelGroup:GetDateRow("LevelGroup", nLevelGroup);

		nBasicExp = self.tbfile_TaskLevelGroup:GetCellInt("BasicExp", nLevelGroupRow);
		if nBasicExp == 0 or nBasicExp == nil then
			self:_Debug("CountBasicExp: Get data error!");
			return 0;
		end;
		return nBasicExp;		
end;



function LinkTask:_AssignItemRate(tbFile)
	local nRow = tbFile:GetRow();
	local nGroupId = 0;
	
	local nGenre, nDetail, nParticular, nLevel, nFive, nValue, nRate, nBind = 0,0,0,0,0,0,0,0;
	local szName = "";
	
	for i=1, nRow do
		nGroupId = tbFile:GetCellInt("Group", i);
		
		if self.tbAwardItemRate[nGroupId] == nil then
			self.tbAwardItemRate[nGroupId] = {};
		end;
		
		nGenre         = tbFile:GetCellInt("Genre", i);
		nDetail        = tbFile:GetCellInt("Detail", i);
		nParticular    = tbFile:GetCellInt("Particular", i);
		nLevel         = tbFile:GetCellInt("Level", i);
		nValue         = tbFile:GetCellInt("Value", i);
		nRate          = tbFile:GetCellInt("Rate", i);
		szName         = tbFile:GetCell("Name", i);
		nBind			= tbFile:GetCellInt("Bind", i);
					
		table.insert(self.tbAwardItemRate[nGroupId], 
			 {nRate,  nGenre, nDetail, nParticular, nLevel, nValue, szName, nBind});
	end;
end;


-- 计算奖励的经验，返回 Int
function LinkTask:CountAwardExp()
	self:_Debug("Start count exp award...");
	local nTaskValue1, nTaskValue2	= unpack(self:GetTaskValue());
	
	local nBasicExp = self:_CountBasicExp() * self:CountDouble();
	
	self:_Debug("Get award exp final: "..(nBasicExp * nTaskValue2 / 15000));
	return math.floor(nBasicExp * nTaskValue2 / 15000);
	
end;


-- 计算奖励的金钱，返回 Int
function LinkTask:CountAwardMoney()
	self:_Debug("Start count money award...");
	local nTaskValue1, nTaskValue2	= unpack(self:GetTaskValue());
	
	local nPyValue = self:_CountLevelProductivity() * self:CountDouble();
	
	self:_Debug("Get award money final: "..(nTaskValue2 * nPyValue)  + nTaskValue1);
	
	return math.floor(nTaskValue2 * nPyValue) + nTaskValue1;
end;


-- 选取奖励的物品，返回物品的名称和物品的Id table
function LinkTask:CountAwardItem(nBit)
	self:_Debug("Start count item award...");
	
	local tbTaskValue = self:GetTaskValue();
	local nValue = tbTaskValue[2];                             -- 只取第二个价值量
	local nPyValue = self:_CountLevelProductivity();           -- 得到当前等级的生产率
	
	-- 计算出最后的价值量
	nValue = nValue * nPyValue;
	
	self:_Debug("Get the task value: (pyValue / Value)"..nPyValue.." / "..nValue);
	
	-- 首先获取物品组的行数
	local nGroupRow = self.tbFile_AwardGroupRate:GetDateRow("TaskValue", nValue);
	if nGroupRow == 0 then
		self:_Debug("CountAwardItem: Get GroupRow error!");
		return
	end;
	
	local tbGroupRate = {};
	local nRateNum = 0;
	
	-- 取出该价值量下 10 个组的概率
	for i=1, 10 do
		nRateNum = self.tbFile_AwardGroupRate:GetCellInt("Rate"..i, nGroupRow);
		table.insert(tbGroupRate, nRateNum);
	end;
	
	-- 最后得出属于哪个组
	local nGroup = self:_CountAwardRate(tbGroupRate, nBit);
	
	local tbGroupItem = self.tbAwardItemRate[nGroup];
	
	local nRow = self:GetRandomSeed(nBit+3);
	if nRow <= 0 then
		nRow = Lib:CountRateTable(tbGroupItem, 1);
		self:SaveRandomSeed(nRow, nBit+3);
	end
	
	self:_Debug("Get award item final: "..tbGroupItem[nRow][7], tbGroupItem[nRow][2], tbGroupItem[nRow][3], tbGroupItem[nRow][4]);
		
		-- 返回：名字, tbItem, 是否绑定
		return tbGroupItem[nRow][7],
			   {tbGroupItem[nRow][2],
			    tbGroupItem[nRow][3],
			    tbGroupItem[nRow][4],
				tbGroupItem[nRow][5],0,0,0,nil,0,0, tbGroupItem[nRow][8]};
end;


-- 计算双倍或者其它数值加乘
function LinkTask:CountDouble()
	return 3;
end;


-- 根据选取出来的奖励表构成奖励面版
function LinkTask:ShowAwardDialog(tbAward)
	local tbGeneralAward = {};  -- 最后传到奖励面版脚本的数据结构
	local nRepute = 0;
	local tbSelect = {{}, {}, {}};  -- 三个可选奖励
	local nValue = 0;
	local tbItem, szItemName = {};
	
	local szAwardTalk	= "Tốt lắm! Ngươi thích món nào dưới đây?";	-- 奖励时说的话
		
	-- 每天的前 10 个任务奖励一个物品
	local nDailyTaskNum		= self:GetTaskNum_PerDay();
	local nDailyAward		= self:GetTask(self.TSK_LINKAWARDDATE);		-- 判断今天是否已经领过
	
	tbGeneralAward.tbFix	= {};
		
	if nDailyTaskNum == 9 and nDailyAward ~= tonumber(GetLocalDate("%Y%m%d")) then

		local nFixExp		= self:_CountBasicExp() * 0.5;				-- 10 次的额外经验
		local nFixMoney		= math.floor(30000 * self:_CountLevelProductivity() / 2) * Task.IVER_nLinkTaskAward;	-- 10 次的额外金钱
		
		table.insert(tbGeneralAward.tbFix,
				{szStatLogName="Bao Vạn Đồng", szType="exp",varValue=nFixExp,nSprIdx=0,szDesc="Kinh nghiệm"}
			);
		
		-- 将老包所有的固定银两都改为绑银 by peres 2009/02/16
		table.insert(tbGeneralAward.tbFix,
				{szStatLogName="Bao Vạn Đồng",szType="bindmoney",varValue=nFixMoney * 1.5,nSprIdx=1,szDesc="Bạc khóa"}
			);
			
		local nTreaMapItemLevel		= 1;
		if me.nLevel >= 50 and me.nLevel <= 79 then
			nTreaMapItemLevel = 2;
		elseif me.nLevel >= 80 then
			nTreaMapItemLevel = 3;
		end;
		table.insert(tbGeneralAward.tbFix,
				{szStatLogName="Bao Vạn Đồng", szType="item",varValue={18,1,9,nTreaMapItemLevel,0,0,0,nil,0,0},nSprIdx=0,szDesc="Tàng Bảo Đồ"}
			);
			
		table.insert(tbGeneralAward.tbFix,
				{szStatLogName="Bao Vạn Đồng", szType="item",varValue={18,1,1019,nTreaMapItemLevel,0,0,0,nil,0,0},nSprIdx=0,szDesc="Lệnh bài Tàng Bảo Đồ thông dụng"}
			);			
			
		szAwardTalk = szAwardTalk.."\n\nVì ngươi đã hoàn thành liên tục <color=green>10 nhiệm vụ trong hôm nay<color>, hãy nhận các phần thưởng dưới đây:";
		
		local nAward = me.GetTask(SpecialEvent.BuyOver.TASK_GROUP_ID, SpecialEvent.BuyOver.TASK_BAOVANDONG);
		local nDate = tonumber(os.date("%d", GetTime()));
		nAward = Lib:SetBits(nAward, 1, nDate, nDate);
		me.SetTask(SpecialEvent.BuyOver.TASK_GROUP_ID, SpecialEvent.BuyOver.TASK_BAOVANDONG, nAward);
		
	elseif nDailyTaskNum > 10 and math.fmod(nDailyTaskNum + 1, 10) == 0 then
		
		if self:GetTask(self.tbExMoneyAward[nDailyTaskNum + 1]) == 0 then
		
			local nFixMoney		= math.floor(5000 * self:_CountLevelProductivity() / 2) * Task.IVER_nLinkTaskAward;	-- 额外金钱	
			
			table.insert(tbGeneralAward.tbFix,
					{szStatLogName="Bao Vạn Đồng", szType ="bindmoney",varValue=nFixMoney * 1.5,nSprIdx=1,szDesc="Bạc khóa"}
				);
				
			-- 去除额外给的精活 by peres 2009/06/11
			local nMakePoint, nGatherPoint = self:AwardJingHuo();			-- 10 次的额外精力, 10 次的额外活力
			table.insert(tbGeneralAward.tbFix,
					{szType="makepoint",varValue=nMakePoint,nSprIdx=0,szDesc="Tinh lực"}
				);
			table.insert(tbGeneralAward.tbFix,
					{szType="gatherpoint",varValue=nGatherPoint,nSprIdx=0,szDesc="Hoạt lực"}
				);
		end;
		
	end;
	
	local nTskTotalNum = self:GetTaskTotalNum_PerDay();
	
	-- 固定奖励，义军声望	
	if (9 >= nTskTotalNum) then
		nRepute = 10;
	else
		nRepute = 3;
	end
	
	table.insert(tbGeneralAward.tbFix, {szType="linktask_repute",varValue={1,1,nRepute},nSprIdx=0,szDesc="Danh vọng Nghĩa quân "..nRepute.." điểm"});		
	
	for i = 1, 3 do
		if tbAward[i]==1 then        -- 经验
			
			nValue = self:CountAwardExp();
			tbSelect[i] = {szStatLogName="Bao Vạn Đồng", szType="exp",varValue=nValue,nSprIdx=0,szDesc= nValue.." kinh nghiệm"};
			
		elseif tbAward[i]==2 then    -- 银两
			
			nValue = self:CountAwardMoney();			
			tbSelect[i] = {szStatLogName="Bao Vạn Đồng", szType="bindmoney",varValue=nValue,nSprIdx=0,szDesc= nValue.." bạc khóa"};
			
		elseif tbAward[i]==3 then    -- 物品
			
			szItemName, tbItem = self:CountAwardItem(i+3);
			tbSelect[i] = {szStatLogName="Bao Vạn Đồng", szType="item",varValue=tbItem,nSprIdx=0,szDesc=szItemName};
			
		elseif tbAward[i]==4 then    -- 取消机会
			
			tbSelect[i] = {szStatLogName="Bao Vạn Đồng", szType="linktask_cancel",varValue=10,nSprIdx=0,szDesc="1 Cơ hội hủy bỏ nhiệm vụ"};
			
		end;
	end;
	
	tbGeneralAward.tbOpt = tbSelect;
	
	-- 暂时无随机奖励
	tbGeneralAward.tbRandom = {};
	
	GeneralAward:SendAskAward(szAwardTalk, 
							  tbGeneralAward, {"LinkTask:AwardFinish", LinkTask.AwardFinish} );

end;
