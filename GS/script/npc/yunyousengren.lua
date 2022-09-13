
-- 云游僧人

local tbYunyousengren = Npc:GetClass("yunyousengren");

tbYunyousengren.nDelayTime			= 5;			-- 进度条延时的时间为5(秒)
--tbYunyousengren.tbTaskIdUsedCount	= {2007, 1};	-- 一天里使用的Từ Bi Tâm Kinh的数量的任务变量的Id
tbYunyousengren.tbCibeiItem			= {				-- Từ Bi Tâm Kinh
	["nGenre"] 				= 18,
	["nDetailType"]			= 1,
	["nParticularType"] 	= 18,
	["nLevel"]				= 1,
};
--tbYunyousengren.tbProbability		= {				-- 每天使用地Từ Bi Tâm Kinh的数目对应的概率
--	100, 80, 70, 60, 50, 40, 30,
--};

function tbYunyousengren:OnDialog()
	local tbCibeixinjing = Item:GetClass("cibeixinjing");
	local tbOpt = 
	{
		{"Ta muốn ăn năn sám hối", self.Repent, self},
		{"Kết thúc đối thoại"}
	}
	Dialog:Say(him.szName..": A di đà phật, thiện tay thiện tay...", tbOpt);
end

-- 忏悔
function tbYunyousengren:Repent()
	-- 临时判断特殊地图限制
	local nCurMapId = me.GetMapId();
	if ((nCurMapId >= 167 and nCurMapId <= 180) or (nCurMapId >= 187 and nCurMapId <= 195)) then
		me.Msg("Không thể sử dụng ở đây!");
		return 0;
	end
	-- 恶名值为0,不需要忏悔
	if (0 >= me.nPKValue) then
		Dialog:Say("Ngươi không cần đến gặp ta!");
		return;
	end
	-- 经验达到或超过-50%,不允许忏悔
	local nExpPercent = math.floor(me.GetExp() * (-100) / me.GetUpLevelExp());
	if (nExpPercent	> 50) then
		Dialog:Say(him.szName..": Lượng kinh nghiệm lớn hơn 50%, hãy quay lại sau!");
		return;
	end
	-- 没有Từ Bi Tâm Kinh，不能忏悔
	if (me.GetItemCountInBags(self.tbCibeiItem.nGenre, self.tbCibeiItem.nDetailType, self.tbCibeiItem.nParticularType, self.tbCibeiItem.nLevel) <= 0) then
		Dialog:Say(him.szName..": Hành trang không có 《Từ Bi Tâm Kinh》.");
		return;
	end	
	
	Dialog:Say(him.szName..": Ngươi cần phải thành tâm niệm 《Từ Bi Tâm Kinh》, để rửa sạch tội lỗi mình đã gây ra, có chắc chứ?", 
		{
			{"Ta muốn đọc 《Từ Bi Tâm Kinh》", self.DelayTime, self},
			{"Để ta suy nghĩ thêm"}
		});
end

-- self.nDelayTime(秒)的延时
function tbYunyousengren:DelayTime()
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	GeneralProcess:StartProcess("Đang niệm Từ Bi Tâm Kinh...", self.nDelayTime * Env.GAME_FPS, {self.UseItem, self}, nil, tbEvent);		
end

function tbYunyousengren:UseItem()
	if (me.ConsumeItemInBags(1, self.tbCibeiItem.nGenre, self.tbCibeiItem.nDetailType, self.tbCibeiItem.nParticularType, self.tbCibeiItem.nLevel) ~= 0) then
		Dbg:WriteLogEx(Dbg.LOG_ERROR, "tbYunyousengren", "cibeixinjing not found！");
		return;
	end	
--	
--	local nReadedAmount	= me.GetTask(self.tbTaskIdUsedCount[1], self.tbTaskIdUsedCount[2]) + 1;		-- 获得任务变量的值
--	me.SetTask(self.tbTaskIdUsedCount[1], self.tbTaskIdUsedCount[2], nReadedAmount);				-- 每使用一个Từ Bi Tâm Kinh，记录每天使用次数的任务变量要加1
--	
--	local nProbability	= 0;		-- 概率（如果成功率是20%，nProbability的值为20）
--	if (nReadedAmount > #self.tbProbability) then
--		nProbability	= self.tbProbability[#self.tbProbability];
--	else
--		nProbability	= self.tbProbability[nReadedAmount];
--	end
--	 
--	if (MathRandom(100) <= nProbability) then
		me.AddPkValue(-1);
		me.Msg("Đã thuộc lòng 《Từ Bi Tâm Kinh》, giảm đi 1 PK.");
--	else
--		me.Msg("你诵读了1篇《Từ Bi Tâm Kinh》，心中杀意未减，毫无任何效果！");
--	end
end
