-- 文件名　：lottery_gc.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-18 19:11:52
-- 描  述  ：
if not MODULE_GC_SERVER then
	return;
end
NewLottery.tbBufId2TblName = {
	[1] = "tbLottery",
	[2] = "tbAward",
	[3] = "tbGoldPlayerName",
	[4] = "tbStudioRoleList",
	};

-- [Name] = nScores;
NewLottery.tbNameScores = {};

function NewLottery:SaveTable()
	local tb = {};
	for nBufId, szTblName in pairs(self.tbBufId2TblName) do
		tb[nBufId] = self[szTblName];
	end
	SetGblIntBuf(GBLINTBUF_LOTTERY_200909, 0, 0, tb);
	
	if not self.tbGoldPlayerNameYear then
		self.tbGoldPlayerNameYear = {};
	end
	SetGblIntBuf(GBLINTBUF_LOTTERY_YEAR, 0, 0, self.tbGoldPlayerNameYear);
	
	if (not self.tbGoldPlayerNameYear_CoSub) then
		self.tbGoldPlayerNameYear_CoSub = {};
	end
	SetGblIntBuf(GBLINTBUF_LOTTERY_YEAR_COSUB, 0, 0, self.tbGoldPlayerNameYear_CoSub);
	
	if (not self.tbNameScores) then
		self.tbNameScores = {};
	end
	SetGblIntBuf(GBLINTBUF_LOTTERY_SCORES, 0, 0, self.tbNameScores);
end

function NewLottery:OnGCStart()

	--print("Lottery:OnGCStart()")
	local tb = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_LOTTERY_200909, 0);
	if tbBuf and type(tbBuf)=="table"  then
		tb = tbBuf;
	end
	local nLastDate = self:GetLastDate();
	local nFirstDate = self:GetFirstDate();
	if nLastDate < 0 then
		nLastDate = 0;
	end
	if nFirstDate < 0 then
		nFirstDate = 0;
	end	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"))
	local nSec = Lib:GetDate2Time(nLastDate) + self.AWARD_KEEP_DAY*24*3600;
	local nEndDate = tonumber(os.date("%Y%m%d", nSec));
	if nCurDate < nFirstDate or nCurDate > nEndDate then
		tb = {};
	end
	
	for nBufId, szTblName in pairs(self.tbBufId2TblName) do
		self[szTblName] = tb[nBufId] or {};
	end
	
	--取一年中中过金奖的人
	local tbBufEx = GetGblIntBuf(GBLINTBUF_LOTTERY_YEAR, 0);
	if tbBufEx and type(tbBufEx)=="table"  then
		self.tbGoldPlayerNameYear = tbBufEx;
	end
	
	-- 去合服后从服的中过奖金的人
	local tbBufEx = GetGblIntBuf(GBLINTBUF_LOTTERY_YEAR_COSUB, 0);
	if tbBufEx and type(tbBufEx)=="table"  then
		self.tbGoldPlayerNameYear_CoSub = tbBufEx;
	end
	
	local tbNameScores = GetGblIntBuf(GBLINTBUF_LOTTERY_SCORES, 0);
	if (tbNameScores and type(tbNameScores) == "table") then
		self.tbNameScores = tbNameScores;
	end
end

function NewLottery:OnGCShutDown()
	--print("NewLottery:OnGCShutDown()");
	self:SaveTable();
end

function NewLottery:OnRecConnectEvent(nConnectId)
	GSExcute(nConnectId, {"NewLottery:GSSynStart"});
	for nDate, tbAwardInDate in pairs(self.tbAward) do
		for szName, tbPlayerAward in pairs(tbAwardInDate) do
			for nAward, nAwardNum in pairs(tbPlayerAward) do
				GSExcute(nConnectId, {"NewLottery:__AddAwardEntry", szName, nAward, nAwardNum, nDate});
			end
		end
	end
	
	GSExcute(nConnectId, {"NewLottery:GSSynEnd"});
end

-- tbSubbuf1 == tbGoldPlayerNameYear
-- tbSubbuf2 == tbGoldPlayerNameYear_CoSub
function NewLottery:CozoneNewLotteryBuffer(tbSubbuf1, tbSubbuf2)
	local tbBufEx = GetGblIntBuf(GBLINTBUF_LOTTERY_YEAR, 0);
	if tbBufEx and type(tbBufEx)=="table"  then
		self.tbGoldPlayerNameYear = tbBufEx;
	end
	SetGblIntBuf(GBLINTBUF_LOTTERY_YEAR, 0, 0, self.tbGoldPlayerNameYear);
	
	print("CozoneNewLotteryBuffer start!!");
	tbSubbuf1 = tbSubbuf1 or {};
	tbSubbuf2 = tbSubbuf2 or {};
	local tbBufEx = GetGblIntBuf(GBLINTBUF_LOTTERY_YEAR_COSUB, 0);
	if tbBufEx and type(tbBufEx)=="table"  then
		self.tbGoldPlayerNameYear_CoSub = tbBufEx;
	end
	
	if (not self.tbGoldPlayerNameYear_CoSub) then
		self.tbGoldPlayerNameYear_CoSub = {};
	end
	
	if (not self.tbGoldPlayerNameYear) then
		self.tbGoldPlayerNameYear = {};
	end
	
	for nDate, szName in pairs(tbSubbuf1) do
		if (self.tbGoldPlayerNameYear_CoSub[szName]) then
			print("CozoneNewLotteryBuffer tbSubbuf1 ", szName, nDate);
		else
			self.tbGoldPlayerNameYear_CoSub[szName] = nDate;
		end		
	end
	
	for szName, nDate in pairs(tbSubbuf2) do
		if (self.tbGoldPlayerNameYear_CoSub[szName]) then
			print("CozoneNewLotteryBuffer tbSubbuf2 ", szName, nDate);
		else
			self.tbGoldPlayerNameYear_CoSub[szName] = nDate;
		end
	end
	
	SetGblIntBuf(GBLINTBUF_LOTTERY_YEAR_COSUB, 0, 0, self.tbGoldPlayerNameYear_CoSub);
	print("CozoneNewLotteryBuffer end!!");
end

function SpecialEvent:PayAwardScheduleTask()
	local tbParam = {};
	-- EventManager.tbChongZhiEvent.nEventId_Avtive 这个要注意
	local tbEvent = EventManager:GetEventTableEx(101);
	
	if (not tbEvent or not tbEvent.tbEvent) then
		return 0;
	end
	
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nStartTime = Lib:GetDate2Time(tbEvent.tbEvent.nStartDate) or 0;
	local nEndTime = Lib:GetDate2Time(tbEvent.tbEvent.nEndDate) or 0;
	
	if (tbEvent.tbEvent.nEndDate <= 0) then
		return 0;
	end
		
	local nStartDate = tonumber(os.date("%Y%m%d", nStartTime));
	local nEndDate = tonumber(os.date("%Y%m%d%H", nEndTime));
	if (nNowDate ~= nStartDate) then
		return 0;
	end
	local nMonth = tonumber(GetLocalDate("%m"));
	
	local szTitle = string.format("%s月充值促销活动", Lib:Transfer4LenDigit2CnNum(nMonth));
	local szContent = string.format([[尊敬的各位武林侠客：
    《剑侠世界》<color=red>情浓%s月中秋国庆豪华盛宴<color>：寒武魂珠持续热战、玲珑宝盒超值返券、辉煌荣耀炫丽礼包、新品燕小楼七技能同伴。<color=yellow>六大特色礼包<color>幸福/极致/尊贵/荣耀/尊享/无价至尊大礼包囊括丰厚的福利回馈、方便实用的便利道具，更有超值的游戏增值货币（五行魂石/游龙古币等）以及高端珍品的购买资格。
    游戏内点击主界面右上角小地图下方按钮<color=yellow>福利特权<color>-><color=yellow>充值优惠奖励<color>即可进入 <link=openwnd:全新充值奖励领取界面,UI_PAYAWARD,1>，可领取豪华大礼，活动详情请点击%s月<link=url:充值专题,充值促销网页,http://jxsj.xoyo.com/zt/2012/09/10/cz/index.shtml>。


             西山居《剑侠世界》运营团队敬上]], Lib:Transfer4LenDigit2CnNum(nMonth), nMonth);

	Mail.BatchMail:AddIntoGblBuf(szTitle, szContent, nEndDate);

	
	self.tbNameScores = {};
	SetGblIntBuf(GBLINTBUF_LOTTERY_SCORES, 0, 0, self.tbNameScores);

	return 1;
end

GCEvent:RegisterGCServerStartFunc(NewLottery.OnGCStart, NewLottery);
GCEvent:RegisterGCServerShutDownFunc(NewLottery.OnGCShutDown, NewLottery);

--?gc DoScript("\\script\\event\\newlottery\\lottery_gc.lua")
