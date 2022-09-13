-- 文件名  : christmas.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-11-17 11:26:31
-- 描述    :  vn 圣诞节

--VN--
if not MODULE_GAMESERVER then
	return;
end

SpecialEvent.tbVnChristmas = SpecialEvent.tbVnChristmas or {};
local tbVnChristmas = SpecialEvent.tbVnChristmas;
tbVnChristmas.TASKGID 					= 2147;	--任务组
tbVnChristmas.TASK_DURK_DATA			= 6;		--吃durk日期
tbVnChristmas.TASK_DURK_COUNT			= 7;		--吃durk每天次数
tbVnChristmas.TASK_DURK_ALLCOUNT		= 8;		--吃durk总次数
tbVnChristmas.TASK_GOOSE_DATA			= 9;		--吃goose日期
tbVnChristmas.TASK_GOOSE_COUNT			= 10;		--吃goose每天次数
tbVnChristmas.TASK_GOOSE_ALLCOUNT		= 11;		--吃goose总次数
tbVnChristmas.TASK_HONGNUAN_DATA		= 12;		--烘暖小妹日期
tbVnChristmas.TASK_HONGNUAN_COUNT		= 13;		--烘暖小妹每天次数
tbVnChristmas.TASK_HONGNUAN_ALLCOUNT	= 14;		--烘暖小妹总次数
tbVnChristmas.TASK_AWARD				= 19;		--烘暖小妹是否获奖
tbVnChristmas.TASK_QUALIFICARION			= 15;		--买马的资格
tbVnChristmas.nChristmasStartTime 	= 20101013;		--烘暖卖火柴的小妹
tbVnChristmas.nChristmasEndTime 	= 20100112;		--烘暖卖火柴的小妹
tbVnChristmas.tbHunShi				= {18, 1, 205, 1};	--魂石
tbVnChristmas.tbHorse				= {1, 12, 35, 4};		--奔宵马
tbVnChristmas.nNeedHunShi			= 3000;			--买马需要的魂石数目
tbVnChristmas.NRANGE 			= 1000;			--npc跑动随机范围	

--查询烤鸭烤鹅
function tbVnChristmas:OnDialog()
	local nDurkDate = me.GetTask(self.TASKGID, self.TASK_DURK_DATA);
	local nDurkCount = me.GetTask(self.TASKGID, self.TASK_DURK_COUNT);
	local nDurkAllCount = me.GetTask(self.TASKGID, self.TASK_DURK_ALLCOUNT);
	local nGooseAllCount = me.GetTask(self.TASKGID, self.TASK_GOOSE_ALLCOUNT);	
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDurkDate ~= nNowDate then
		nDurkCount = 0;
	end
	local szMsg = string.format("  你总共已经食用了<color=yellow>%s<color>只烤鸭，<color=yellow>%s<color>只烤鹅，今天你已经食用了<color=yellow>%s<color>只烤鸭和烤鹅。", nDurkAllCount, nGooseAllCount, nDurkCount);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

--查询烘暖小妹
function tbVnChristmas:OnDialogEx()
	local nHongNuan = me.GetTask(self.TASKGID, self.TASK_HONGNUAN_ALLCOUNT);
	local szMsg = string.format("  你总共烘暖了<color=yellow>%s<color>次卖火柴的小妹", nHongNuan);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

----------------------------------------------------------------------------------------------
--购买马
function tbVnChristmas:OnDialog_Buy(bBuy)
	local nFlag = me.GetTask(self.TASKGID, self.TASK_QUALIFICARION);
	if nFlag <= 0 then
		Dialog:Say("我想你还没有资格购买！", {{"Ta hiểu rồi"}});
		return 0;
	elseif nFlag >= 2 then
		Dialog:Say("你都买过了，还来找我干什么？", {{"Ta hiểu rồi"}});
		return 0;
	end
	if not bBuy then
		--Dialog:Say("你有购买奔宵马的资格，是不是要花费3000不绑定五行魂石购买呢？", {{"我要购买！", self.BuyHorse, self}});
		Dialog:OpenGift("需要花费3000不绑定五行魂石", nil ,{self.OnOpenGiftOk, self});
	end
end

function tbVnChristmas:OnOpenGiftOk(tbItemObj)
	local tbCrystalList = {};
	local nFlag, szMsg = self:ChechItem(tbItemObj);
	if (nFlag == 0) then
		me.Msg(szMsg or "存在不符合的物品或者数量超过限制!");		
		return 0;
	end;
	-- 扣除物品
	for _, pItem in pairs(tbItemObj) do
		if me.DelItem(pItem[1], Player.emKLOSEITEM_CYSTAL_COMPOSE) ~= 1 then
			return 0;
		end
	end	
	local pItem = me.AddItem(unpack(self.tbHorse));
	if pItem then
		pItem.SetTimeOut(0, GetTime() + 90 *24 *3600);
		pItem.Sync();
	end
	me.SetTask(self.TASKGID, self.TASK_QUALIFICARION, 2);
	return 1;
end

-- 检测物品及数量是否符合
function tbVnChristmas:ChechItem(tbItemObj)
	if Lib:CountTB(tbItemObj) <= 0 then
		return 0, "请放入不绑定魂石。";
	end
	local nAllCount = 0;
	for _, pItem in pairs(tbItemObj) do
		local szFollowCryStal 	= string.format("%s,%s,%s,%s", unpack(self.tbHunShi));
		local szItem		= string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if szFollowCryStal ~= szItem or  pItem[1].IsBind() ~= 0 then
			return 0, "请放入不绑定的魂石！";
		end;
		nAllCount = nAllCount + pItem[1].nCount;
	end
	
	if nAllCount ~= self.nNeedHunShi  then
		return 0, "你放入的魂石数量不对";
	end
	return 1;
end;

--------------------------------------------------------------
--call小妹
function tbVnChristmas:CallRabbit(nMapId, nX, nY)
	local pNpc = KNpc.Add(7223, 150, 0, SubWorldID2Idx(nMapId), nX, nY);
	if (pNpc) then
		local nMovX, nMovY = self:RandomPos(nX, nY);
		pNpc.AI_AddMovePos(nMovX, nMovY);
		pNpc.SetNpcAI(9, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0);
		pNpc.GetTempTable("Npc").nHongNuan = 0;
		pNpc.GetTempTable("Npc").tbPlayer = {};
		pNpc.SetLiveTime(120 * Env.GAME_FPS);
		pNpc.AddTaskState(1475);
        return pNpc.dwId;	
	end
	return 0;
end

--nX，nY点NRANGE范围内的随机点
function tbVnChristmas:RandomPos(nX,nY)
	local tbRX =  {math.floor(MathRandom(-self.NRANGE, -math.floor(self.NRANGE*0.6))), math.floor(MathRandom(math.floor(self.NRANGE*0.6), self.NRANGE))};
	local tbRY =  {math.floor(MathRandom(-self.NRANGE, -math.floor(self.NRANGE*0.6))), math.floor(MathRandom(math.floor(self.NRANGE*0.6), self.NRANGE))};
	local nTrX =  tbRX[math.floor(MathRandom(1, 2))] or 0;
	local nTrY =  tbRY[math.floor(MathRandom(1, 2))] or 0;
	local nMovX = nX + nTrX;
	local nMovY = nY + nTrY;
	return nMovX,nMovY;
end

---------------------------------------------------------------
--烤鸭

local tbDurk	= Item:GetClass("durk_vn");
tbDurk.tbHuoChai 		= {18, 1, 1089, 1};	--火柴
tbDurk.tbChristmasBox	= {18, 1, 1087, 1};	--圣诞礼包
tbDurk.nRateLimit	= 1;		--(1-100)

function tbDurk:OnUse()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.nLevel < 60 then
		me.Msg("您的等级不足60级！");
		return 0;
	end
	 if me.CountFreeBagCell() < 1 then
	  	me.Msg("包裹空间不足1格，请整理下！");
	  	return 0;
	end
	local nFlag = Item:GetClass("addbaseexp_base"):SureOnUse(0, 5000000, 2147, 6, 7, 20, 8, 100);
	local nRate = MathRandom(1,100);
	if nFlag == 1 and nNowDate >= SpecialEvent.tbVnChristmas.nChristmasStartTime 
			and nNowDate <= SpecialEvent.tbVnChristmas.nChristmasEndTime and nRate <= self.nRateLimit then
		me.AddItem(unpack(self.tbHuoChai));
	end
	return nFlag;
end

---------------------------------------------------------------
--烤鹅
local tbGoose	= Item:GetClass("goose_vn");
tbGoose.tbHuoChai = {18, 1, 1089, 1};			--火柴
tbGoose.nRateLimit	= 5;		--(1-100)
tbGoose.tbChristmasBoxEx = {18, 1, 1087, 1};		--圣诞礼包

function tbGoose:OnUse()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.nLevel < 60 then
		me.Msg("您的等级不足60级！");
		return 0;
	end
	 if me.CountFreeBagCell() < 3 then
	  	me.Msg("包裹空间不足3格，请整理下！");
	  	return 0;
	end	
	local nFlag = Item:GetClass("randomitem"):SureOnUse(134, 2147, 0, 0, 6, 7, 20, 11, 100, it);	
	if nFlag == 1 and me.GetTask(SpecialEvent.tbVnChristmas.TASKGID,SpecialEvent.tbVnChristmas.TASK_GOOSE_ALLCOUNT) >= 100 then
		local pItem = me.AddItem(unpack(self.tbChristmasBoxEx));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 30 *24 *3600);
			pItem.Sync();
		end
		me.SetTask(SpecialEvent.tbVnChristmas.TASKGID,SpecialEvent.tbVnChristmas.TASK_QUALIFICARION, 1);
		me.Msg("恭喜你获得购买奔宵马的资格，你可以到圣诞老人那里去购买！");
	end
	local nRate = MathRandom(1,100);
	if nFlag == 1 and nNowDate >= SpecialEvent.tbVnChristmas.nChristmasStartTime 
			and nNowDate <= SpecialEvent.tbVnChristmas.nChristmasEndTime and nRate <= self.nRateLimit then
		me.AddItem(unpack(self.tbHuoChai));
	end
	return nFlag;
end

---------------------------------------------------------------
--圣诞礼包

local tbChristmasBox	= Item:GetClass("ChristmasBox_vn");
tbChristmasBox.tbWeiWang 	= {18, 1, 236, 1};	--威望令牌
tbChristmasBox.tbQiFu		= {18, 1, 212, 4}	--初级祈福


function tbChristmasBox:OnUse()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.nLevel < 60 then
		me.Msg("您的等级不足60级！");
		return 0;
	end
	 if me.CountFreeBagCell() < 3 then
	  	me.Msg("包裹空间不足3格，请整理下！");
	  	return 0;
	end
	me.AddStackItem(self.tbWeiWang[1],self.tbWeiWang[2],self.tbWeiWang[3],self.tbWeiWang[4], nil, 2);
	me.AddItem(unpack(self.tbQiFu));
	return 1;
end

---------------------------------------------------------------
--火柴

local tbHuoChai	= Item:GetClass("HuoChai_vn");
tbHuoChai.DELAY_TIME          = 1;     --使用进度条的时间参数	1秒	
tbHuoChai.USECD_TIME          = 5;     --月果的使用CD	
tbHuoChai.AVAIL_AREA          = 20;    --月果使用的有效区域，?待定
tbHuoChai.RABBIT_TEMPLATEID   = 7223;   --卖火柴小妹CLASS ID	
tbHuoChai.EXPAWARD		= 20000000;	--每天第一次获得1500w经验
tbHuoChai.tbShengDanLiHe = {18, 1, 1087, 1};		--圣诞礼盒
tbHuoChai.nRateLimit		= 1;	--（1-100）

tbHuoChai.MSG_ERR  = {
	"使用失败，附近好像没有火柴小妹！" ,
     	"物品CD中,请稍候再试",
     	"小妹被哄得已经很暖和，不需要你的火柴了！"
	};
	
function tbHuoChai:OnUse()
    	--判断物品CD 
    	local nCount = it.GetGenInfo(2);
    	if nCount >=  3 then
    		if self:GetExpAward() == 1 then
    			return 1;
    		else
    			return 0;
    		end
    	end
	local nItemCD  = it.GetGenInfo(1);
	local nCurTime = GetTime(); 
	if (nItemCD + self.USECD_TIME) >= nCurTime then
		me.Msg(self.MSG_ERR[2]);
		return 0;
	end   
   	 --得到周围的npc
	local tbRabbit , nCount = self:GetRabbitAround();
	if nCount == 0 then
		me.Msg(self.MSG_ERR[1]);
		return 0;
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
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	GeneralProcess:StartProcess("烘暖小妹..." , self.DELAY_TIME* Env.GAME_FPS ,  {self.OnHelpRabbit , self , tbRabbit , it.dwId} , nil , tbEvent);	
end

function tbHuoChai:GetExpAward()
	 if me.CountFreeBagCell() < 1 then
	  	me.Msg("包裹空间不足1格，请整理下！");
	  	return 0;
	end
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_AWARD) ~= nCurDate then
		me.AddExp(self.EXPAWARD);
		me.SetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_AWARD, nCurDate);
	end	
	local nRate = MathRandom(1, 100);
	if nRate <= self.nRateLimit then
		local pItem = me.AddItem(unpack(self.tbShengDanLiHe));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 30 *24 *3600);
			pItem.Sync();
		end
	end
	return 1;
end

--将玩家身边的小妹的ID放进兔子表，返回小妹表及小妹数目
function tbHuoChai:GetRabbitAround()
	local tbTempRabbit = {};
	local nCount = 0;
	local tbVar = KNpc.GetAroundNpcList(me , self.AVAIL_AREA);
	for _ , pNpc in pairs(tbVar) do
		if pNpc.nTemplateId == self.RABBIT_TEMPLATEID then
			tbTempRabbit[pNpc.dwId] = 1;
			nCount = nCount + 1;
		end
	end
	return tbTempRabbit , nCount;
end

--检测小妹表中的小妹是否还在玩家身边，以此生成新的小妹表 
function tbHuoChai:CheckRabbitAround(tbRabbit)
	local tbTempRabbit = self:GetRabbitAround();
	local nCount = 0;
	for nRabbitId , _ in pairs(tbRabbit) do
		if tbTempRabbit[nRabbitId] then
	  		nCount = nCount + 1;
	  	else 
	  		tbRabbit[nRabbitId] = nil;
		end
	end
	return tbRabbit , nCount;
end

function tbHuoChai:OnHelpRabbit(tbRabbit , nItemId)
	local tbRabbit , nCount = self:CheckRabbitAround(tbRabbit); --读完条之后，再判断一次
	if nCount == 0 then 	
		me.Msg(self.MSG_ERR[1]);
		return 0;
	end
	for nRabbitId , _ in pairs(tbRabbit) do
		local pRabbit = KNpc.GetById(nRabbitId);		
		if pRabbit and (pRabbit.GetTempTable("Npc").nHongNuan < 10 and self:CheckIsUse(pRabbit) == 1) then
			pRabbit.GetTempTable("Npc").nHongNuan = pRabbit.GetTempTable("Npc").nHongNuan + 1;
			table.insert(pRabbit.GetTempTable("Npc").tbPlayer, me.nId);
			pRabbit.SendChat("谢谢你，好暖啊，你真是个好人！"); 
			self:GetAward(nItemId); -- 救助了小妹，得到奖励	
			return 1;
		end
	end
	me.Msg(self.MSG_ERR[3]);
	return 0;
end

function tbHuoChai:CheckIsUse(pRabbit)
	if not pRabbit.GetTempTable("Npc").tbPlayer then
		return 0;
	end
	local nUsed = 0;
	for i, nPlayerId in ipairs(pRabbit.GetTempTable("Npc").tbPlayer) do
		if me.nId == nPlayerId then
			nUsed = 1;
		end
	end
	if nUsed == 0 then
		return 1;
	end
	return 0;
end

-- 救助兔子，?奖励 
function tbHuoChai:GetAward(nItemId)
	--更新物品CD
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	local nCurTime = GetTime(); 
	pItem.SetGenInfo(1, nCurTime);
	pItem.SetGenInfo(2,pItem.GetGenInfo(2) + 1);
	pItem.Sync();
   	
   	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_HONGNUAN_DATA) < nCurDate then
		me.SetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_HONGNUAN_DATA, nCurDate);
		me.SetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_HONGNUAN_COUNT, 0);
	end
	
	local nCurCount = me.GetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_HONGNUAN_COUNT) + 1;
	me.SetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_HONGNUAN_COUNT, nCurCount);
   	
   	--加次数，100次加称号
	local nTotalCount = me.GetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_HONGNUAN_ALLCOUNT) + 1;
	me.SetTask(SpecialEvent.tbVnChristmas.TASKGID, SpecialEvent.tbVnChristmas.TASK_HONGNUAN_ALLCOUNT, nTotalCount);
	
	--100个时候给称号
	if nTotalCount == 100 then
		me.AddTitle(6,48,1,8);
		me.SetCurTitle(6,48,1,8);
	end	
	me.Msg("你成功烘暖了卖火柴的小妹，上帝会祝福你！");
	Dialog:SendBlackBoardMsg(me , "你成功烘暖了卖火柴的小妹，上帝会祝福你！");
end

function tbHuoChai:InitGenInfo()
	-- 设定有效期限	
	it.SetTimeOut(0, GetTime() + 30 * 24 * 3600);	
	return	{ };
end

