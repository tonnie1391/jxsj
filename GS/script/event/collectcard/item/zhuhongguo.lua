-------------------------------------------------------
-- 文件名　：yuanyuezhuhongguo.lua
-- 文件描述：圆月朱红果 救玉兔用
-- 创建者　：ZouNan1@kingsoft.com
-- 创建时间：2009-08-31 14:03
-------------------------------------------------------
local tbYueGuo= Item:GetClass("zhuhongguo"); 

tbYueGuo.DELAY_TIME          		= 1;     --使用进度条的时间参数	1秒	
tbYueGuo.USECD_TIME          	= 5;     --月果的使用CD	
tbYueGuo.NEEDED_BAGCELL      	= 1;     --至少需要背包空闲格子的数目	
tbYueGuo.AVAIL_AREA          		= 20;    --月果使用的有效区域，?待定			
tbYueGuo.RABBIT_TEMPLATEID   = 3707;   --兔子的CLASS ID	
tbYueGuo.EXPAWARD			= 20000;	--每天第一次获得1500w经验
tbYueGuo.nRateAward			= 30;		--获得卡片概率(1-100)
tbYueGuo.nCountMax			= 40;	--每天最多拯救多少只兔子
tbYueGuo.nLotteryItemMax		= 5;		--每天最多获得5张奖券
--任务变量 
tbYueGuo.TSK_GROUP     		= 2176;  
tbYueGuo.TSK_COUNT          	 	= 1;
tbYueGuo.TSK_DAY	         	= 2; 
tbYueGuo.TSK_TOTALCOUNT      	= 3;
tbYueGuo.TSK_EXP			= 4;
tbYueGuo.TSK_AWARDITEM 	= 4;
		
tbYueGuo.MSG_ERR  = {
	"使用失败，附近好像没有玉兔！" ,
	"包裹空间不足" ,
	"物品CD中,请稍候再试",
	"您今天已经救助了够多的兔子啦，机会还是留给其他人吧！",
	};
tbYueGuo.MSG_SUCC   = {
	"你成功救助了一只玉兔，代表月亮祝福你！",
	"你救助了额外的玉兔，得到中秋的祝福！",	
	};
tbYueGuo.RABBIT_MSG = {
	"哇哈哈 ，吃饱咯" ,
	"回家，回家~~~~~" ,
	"多谢大侠相助"  ,
	};

tbYueGuo.szName = "圆月朱红果";

function tbYueGuo:OnUse()
    --判断物品CD 
    --	local nCount = it.GetGenInfo(2);
    	--if nCount >=  3 then
    		--self:GetExpAward();
    	--	return 1;
    --	end
	local nItemCD  = it.GetGenInfo(1);
	local nCurTime = GetTime(); 
	if (nItemCD + self.USECD_TIME) >= nCurTime then
		me.Msg(self.MSG_ERR[3]);
		return 0;
	end   
	local nCount = me.GetTask(self.TSK_GROUP, self.TSK_COUNT);
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(self.TSK_GROUP, self.TSK_DAY) < nCurDate then
		nCount = 0;
	end
	if nCount >= self.nCountMax then
		me.Msg(self.MSG_ERR[4]);
		return 0;
	end
    --得到周围的兔子表
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
	GeneralProcess:StartProcess("喂养兔子中..." , self.DELAY_TIME* Env.GAME_FPS ,  {self.OnHelpRabbit , self , tbRabbit , it.dwId} , nil , tbEvent);	
end

function tbYueGuo:GetExpAward()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(self.TSK_GROUP, self.TSK_EXP) ~= nCurDate then
		me.AddExp(self.EXPAWARD);
		me.SetTask(self.TSK_GROUP, self.TSK_EXP, nCurDate);
	else
		me.Msg("袋子好像是空的！");
	end
end

--将玩家身边的兔子的ID放进兔子表，返回兔子表及兔子数目
function tbYueGuo:GetRabbitAround()
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

--检测兔子表中的兔子是否还在玩家身边，以此生成新的兔子表 
function tbYueGuo:CheckRabbitAround(tbRabbit)
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

function tbYueGuo:OnHelpRabbit(tbRabbit , nItemId)
	if me.CountFreeBagCell() < self.NEEDED_BAGCELL then
	  	me.Msg(self.MSG_ERR[2]);
	  	return 0;
	end
	local nCount = 0;
	tbRabbit , nCount = self:CheckRabbitAround(tbRabbit); --读完条之后，再判断一次
	if nCount == 0 then 	
		me.Msg(self.MSG_ERR[1]);
		return 0;
	end
	for nRabbitId , _ in pairs(tbRabbit) do
		local pRabbit = KNpc.GetById(nRabbitId);
		if pRabbit and (pRabbit.GetTempTable("Npc").tbRabbitAbout and (pRabbit.GetTempTable("Npc").tbRabbitAbout.bIsCatch == 0)) then
			pRabbit.GetTempTable("Npc").tbRabbitAbout = pRabbit.GetTempTable("Npc").tbRabbitAbout or {};
			pRabbit.GetTempTable("Npc").tbRabbitAbout.bIsCatch = 1; --通知rabbit 吃饱，可以删了
			local nPos = math.floor(MathRandom(1, 3));
			pRabbit.SendChat(self.RABBIT_MSG[nPos]); 
			self:GetAward(nItemId); -- 救助了兔子，得到奖励	
			return 1;         
		end
 	end
 	me.Msg(self.MSG_ERR[1]);
 	return 0;
end

-- 救助兔子，?奖励 
function tbYueGuo:GetAward(nItemId)
	--更新物品CD
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	local nCurTime = GetTime(); 
	pItem.SetGenInfo(1, nCurTime);
	--pItem.SetGenInfo(2,pItem.GetGenInfo(2) + 1);
	pItem.Sync();
    
    --更新救助兔子的数目
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(self.TSK_GROUP, self.TSK_DAY) < nCurDate then
		me.SetTask(self.TSK_GROUP, self.TSK_DAY, nCurDate);
		me.SetTask(self.TSK_GROUP, self.TSK_COUNT, 0);
		me.SetTask(self.TSK_GROUP, self.TSK_AWARDITEM, 0);
	end
	
	local nCurCount = me.GetTask(self.TSK_GROUP, self.TSK_COUNT) + 1;
	me.SetTask(self.TSK_GROUP, self.TSK_COUNT, nCurCount);
	local nTotalCount = me.GetTask(self.TSK_GROUP, self.TSK_TOTALCOUNT) + 1;
	me.SetTask(self.TSK_GROUP, self.TSK_TOTALCOUNT, nTotalCount);	
	--每50张给一张奖券
	local nLotteryCount = me.GetTask(self.TSK_GROUP, self.TSK_AWARDITEM);	
	if MathRandom(100) <= self.nRateAward and nLotteryCount < self.nLotteryItemMax then
		local pItemEx = me.AddItem(18,1,1464,1);
		if pItemEx then
			pItemEx.SetTimeOut(0, Lib:GetDate2Time(201109132159));
			pItemEx.Sync();
			me.SetTask(self.TSK_GROUP, self.TSK_AWARDITEM, nLotteryCount + 1);
		end
	end
	me.AddExp(self.EXPAWARD);
	--100个时候给称号
	if nTotalCount == 100 then
		me.AddTitle(6,88,1,1);
		me.SetCurTitle(6,88,1,1);
	end	
	me.Msg(self.MSG_SUCC[1]);
	Dialog:SendBlackBoardMsg(me , self.MSG_SUCC[1]);
end

function tbYueGuo:GetTip(nState)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCurCount = me.GetTask(self.TSK_GROUP, self.TSK_COUNT);
	if me.GetTask(self.TSK_GROUP, self.TSK_DAY) < nCurDate then
		nCurCount = 0;
	end
	--local nCount = it.GetGenInfo(2);
	--local szColor = "green";
	--if nCount < 3 then
	--	szColor = "gray";
	--end
	local szTip = string.format("<color=yellow>今天已救助玉兔数量:%s\n总共已救助玉兔数量:%s<color>",
		  nCurCount, me.GetTask(self.TSK_GROUP, self.TSK_TOTALCOUNT));	
	return szTip;
end

local tbYuebing= Item:GetClass("yuebing2011"); 

function tbYuebing:OnUse()	
	if me.GetBindMoney() + 100 > me.GetMaxCarryMoney() then
		Dialog:Say("你的绑定银两携带达上限了，请先整理背包的绑定银两。");
		return 0;
	end
	me.AddBindMoney(100);
	return 1;
end
