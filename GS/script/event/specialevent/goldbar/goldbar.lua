--文件名  : goldbar.lua
--创建者  : jiazhenwei
--创建日期: 2010-06-07 09:58:22
--描 述 :--金牌网吧--

SpecialEvent.tbGoldBar = SpecialEvent.tbGoldBar or {};
local tbGoldBar = SpecialEvent.tbGoldBar or {};

--金牌网吧IP list
tbGoldBar.GoldBarIpList = tbGoldBar.GoldBarIpList or {};
	
--奖励列表
tbGoldBar.tbAwordList = 
{
	{18, 1, 665, 1},					--金牌特权令
	{{1, 13, 68, 1},{1, 13, 69, 1}},		--专属面具1男，2女
	{{5, 13, 1, 9},{5, 13, 2, 9}},			--专属称号1男，2女
};

--任务组
tbGoldBar.TASK_GID				= 2126;
tbGoldBar.TASK_DATE				= 1;
tbGoldBar.TASK_IS_GETITEM		= 2;
tbGoldBar.TASK_IS_GETMASK		= 3;
tbGoldBar.TASK_IS_GETTITLE		= 4;
tbGoldBar.TASK_IS_GetBack			= 29;	--家族领取补偿

tbGoldBar.tbTaskList = {
	--积分任务变量，时间任务变量，每次积分值，最大上限值
	{5, 6, 2, 24},		--开启福袋1
	{7, 8, 2, 20},		--义军任务2
	{9, 10, 5, 10},		--祈福3
	{11, 12, 1, 50},		--家族光卡铜钱数4
	{13, 14, 5, 50},		--逍遥谷每层关卡5
	{15, 16, 10, 30},		--藏宝图通关6
	{17, 18, 2, 12},		--新服活动-家族挑战boss成功7
	{19, 20, 2, 16},		--新服活动-福禄神兽迎新派利8
	{21, 22, 10, 60},	--白虎堂每层9
	{23, 24, 20, 20},	--门派竞技积分超过500 10
	{25, 26, 1, 50},		--玩家升级11
	{27, 28, 250, 500},	--白虎堂击杀boss 12
};

tbGoldBar.nPageCount = 20;		--查询家族成员积分


tbGoldBar.tbGetAwardTime = {20120327, 20120328};
tbGoldBar.nCreatTimeLimit = 2012032708;
tbGoldBar.nMaxAward = 60;
tbGoldBar.tbAwardBack = {
	[1] = {2000000, {18, 1, 111, 3}},	--族长
	[2] = {1000000, {18, 1, 111, 2}},	--成员
	}


--金牌家族补偿
function tbGoldBar:OnDailog_Back()
	local szMsg = [[由于<color=red>战斗关系异常<color>导致的同家族相互pk，对此我们深表歉意，特此补偿奖励。
	
	1、补偿<color=green>家族资金2000000<color>；
	2、家族族长补偿<color=green>2个高级白虎令牌和200万绑定银两<color>，各成员补偿<color=green>2个中级白虎令牌和100万绑定银两<color>；
	3、每个家族最多60个人领取（每个玩家只能领取一次），每个家族只有1份族长奖励。
	]]
	local tbOpt = {
		{"领取族长奖励", self.GetBack_Kin, self, 1},
		{"领取成员奖励", self.GetBack_Kin, self, 2},
		{"Để ta suy nghĩ thêm"}
		}
	Dialog:Say(szMsg, tbOpt);
end

function tbGoldBar:GetBack_Kin(nType)
	local nKinId, nExcutorId = me.GetKinMember();
	if nKinId <= 0 then
		Dialog:Say("对不起，您没有家族不能领取奖励。");
		return;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		Dialog:Say("对不起，您没有家族不能领取奖励。");
		return;
	end
	local tbAward = self.tbAwardBack[nType];
	if not tbAward then
		return;
	end
	if tonumber(os.date("%Y%m%d%H", cKin.GetCreateTime())) >= self.nCreatTimeLimit then
		Dialog:Say("您的家族不符合条件。");
		return;
	end
	local nKinTemp = cKin.GetGoldBack();
	local nCount = math.floor(nKinTemp/10);
	local nKinFlag = math.mod(nKinTemp, 10);
	if nType == 1 and me.nKinFigure ~= 1 then
		Dialog:Say("您不是族长，不能领取奖励。");
		return;
	end
	if nType == 2 and me.nKinFigure == 1 then
		Dialog:Say("您是族长，请领取族长奖励。");
		return;
	end
	if nType == 1 and nKinFlag >= 1 then
		Dialog:Say("族长奖励只能领取一次。");
		return;
	end
	if nType == 2 and nCount >= self.nMaxAward then
		Dialog:Say("每个家族只有60份奖励，已经领取光了。");
		return;
	end
	if cKin.GetGoldLogo() <= 0 then
		Dialog:Say("您的家族不是金牌家族不能领取奖励。");
		return;
	end
	local bFlag = me.GetTask(self.TASK_GID, self.TASK_IS_GetBack);
	if bFlag >= 1 then
		Dialog:Say("您已经领取过奖励了。");
		return;
	end
	
	if me.GetBindMoney() + tbAward[1] > me.GetMaxCarryMoney() then
		Dialog:Say("您身上的绑定银两太多。");
		return;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ chỗ trống，需要2格背包空间。");
		return;
	end
	me.AddWaitGetItemNum(1);
	GCExcute({"SpecialEvent.tbGoldBar:CheckNum", nType, me.nId, nKinId});
end

function tbGoldBar:CheckNum(nType, nPlayerId, nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return;
	end
	local nKinTemp = cKin.GetGoldBack();
	local nCount = math.floor(nKinTemp/10);
	local nKinFlag = math.mod(nKinTemp, 10);
	if nType == 1 and nKinFlag >= 1 then
		GlobalExcute({"SpecialEvent.tbGoldBar:AddAward_Back", nType, nPlayerId, nKinId, 3});
	elseif nType == 2 and nCount >= self.nMaxAward then
		GlobalExcute({"SpecialEvent.tbGoldBar:AddAward_Back", nType, nPlayerId, nKinId, 2});
	else
		if nType == 1 then
			cKin.SetGoldBack(nKinTemp + 1);
			Kin:AddFund_GC(nKinId, -1, 2000000);
		else
			cKin.SetGoldBack(nKinTemp + 10);
		end
		GlobalExcute({"SpecialEvent.tbGoldBar:AddAward_Back", nType, nPlayerId, nKinId, 1});
	end
end

function tbGoldBar:AddAward_Back(nType, nPlayerId, nKinId, nFlag)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return;
	end
	local tbAward = self.tbAwardBack[nType];
	if not tbAward then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if nFlag == 1 then
		if pPlayer then
			pPlayer.AddWaitGetItemNum(-1);
			pPlayer.AddBindMoney(tbAward[1]);
			pPlayer.AddStackItem(tbAward[2][1], tbAward[2][2], tbAward[2][3], tbAward[2][4], {bForceBind = 1}, 2);
			pPlayer.SetTask(self.TASK_GID, self.TASK_IS_GetBack, 1);
		end
		if nType == 1 then
			cKin.SetGoldBack(cKin.GetGoldBack() + 1);
		else
			cKin.SetGoldBack(cKin.GetGoldBack() + 10);
		end
	else
		if pPlayer then
			Setting:SetGlobalObj(pPlayer);
			me.AddWaitGetItemNum(-1);
			if nFlag == 2 then
				Dialog:Say("每个家族只有60份奖励，已经领取光了。");
			else
				Dialog:Say("族长奖励只能领取一次。");
			end
			Setting:RestoreGlobalObj();
		end
	end
end

--增加一次任务
function tbGoldBar:AddTask(pPlayer, nTaskId, nNum)
	local nSec = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nDate = tonumber(os.date("%Y%m", nSec));
	if nDate ~= Kin.GOLD_LS_SERVERDAY then
		return 0;
	end
	if not pPlayer or not nTaskId or not self.tbTaskList[nTaskId] then
		return;
	end
	local nKinId, nExcutorId = pPlayer.GetKinMember();
	--记名和非家族的加不了
	if nKinId <= 0 or pPlayer.nKinFigure <= 0 or pPlayer.nKinFigure == 4 then
		return;
	end
	local nGrade = pPlayer.GetTask(self.TASK_GID, self.tbTaskList[nTaskId][1]);
	local nTime = pPlayer.GetTask(self.TASK_GID, self.tbTaskList[nTaskId][2]);
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nTime ~= nNowTime then
		pPlayer.SetTask(self.TASK_GID, self.tbTaskList[nTaskId][2], nNowTime);
		nGrade = 0;
	end
	--每日积分上限
	if nGrade >= self.tbTaskList[nTaskId][4] then
		return;
	end
	local nAddGrade = self.tbTaskList[nTaskId][3];
	if nNum then
		nAddGrade = math.min(nAddGrade * nNum, self.tbTaskList[nTaskId][4] - nGrade);
	end
	nGrade = nGrade + nAddGrade;
	pPlayer.SetTask(self.TASK_GID, self.tbTaskList[nTaskId][1], nGrade);
	GCExcute({"Kin:AddGoldLSTask_GC", nKinId, nExcutorId, nAddGrade});
	Dbg:WriteLog("GoldBar", pPlayer.szName, string.format("[金牌联赛]获得金牌联赛积分%s,任务%s", nAddGrade, nTaskId));
	pPlayer.Msg(string.format("获得金牌联赛积分<color=yellow>%s<color>点。", nAddGrade));
end

function tbGoldBar:QueryKinGrade(pPlayer, nPage, tbPlayerGradeList)
	if not pPlayer then
		return;
	end
	local nKinId, nExcutorId = pPlayer.GetKinMember();
	if nKinId < 0 then
		me.Msg("对不起，您还没有家族。");
		return;
	end
	if pPlayer.nKinFigure ~= 1 then
		pPlayer.Msg("对不起，您不是族长。");
		return 0;
	end
	tbPlayerGradeList = tbPlayerGradeList or {};	
	local pKin = KKin.GetKin(nKinId);
	if not nPage then
		if (pKin) then
			local itor = pKin.GetMemberItor();
			local cMember = itor.GetCurMember();
			while cMember do
				local nPlayerId = cMember.GetPlayerId();
				local szName = KGCPlayer.GetPlayerName(nPlayerId);
				local nGrade = cMember.GetGoldLS();			
				table.insert(tbPlayerGradeList, {szName, nGrade});
				cMember = itor.NextMember();
			end
		end
		local function _OnSort(tbA, tbB)
			return tbA[2] > tbB[2];
		end
		table.sort(tbPlayerGradeList, _OnSort);
	end
	local szMsg = "当前家族金牌联赛积分排名：\n";
	if pKin and pKin.GetGoldLogo() == 1 then
		szMsg = szMsg.."<color=green>（注：家族已经激活金牌联赛标志）<color>\n";
	else
		szMsg = szMsg.."<color=red>（注：家族尚未激活金牌联赛标志）<color>\n";
	end
	local tbOpt = {{"Để ta suy nghĩ thêm"}};
	nPage = nPage or 1;
	local nCount = 0;
	for i, tbInfo in ipairs(tbPlayerGradeList) do
		if nCount >= self.nPageCount then
			break;
		end
		if i <= self.nPageCount * nPage and i > self.nPageCount * (nPage - 1) then
			szMsg = szMsg..string.format("%s  %s  %s分\n" , i, tbInfo[1], tbInfo[2]);
			nCount = nCount + 1;
		end
	end
	if nPage == 1 and #tbPlayerGradeList  > self.nPageCount then
		table.insert(tbOpt, 1, {"Trang sau", self.QueryKinGrade, self, pPlayer, nPage + 1, tbPlayerGradeList});
	elseif nPage > 1 and #tbPlayerGradeList - nPage * self.nPageCount < self.nPageCount then
		table.insert(tbOpt, 1, {"Trang trước", self.QueryKinGrade, self, pPlayer, nPage - 1, tbPlayerGradeList});
	elseif nPage > 1 and #tbPlayerGradeList - nPage * self.nPageCount > self.nPageCount then
		table.insert(tbOpt, 1, {"Trang sau", self.QueryKinGrade, self, pPlayer, nPage + 1, tbPlayerGradeList});
		table.insert(tbOpt, 1, {"Trang trước", self.QueryKinGrade, self, pPlayer, nPage - 1, tbPlayerGradeList});		
	end
	Setting:SetGlobalObj(pPlayer);
	Dialog:Say(szMsg, tbOpt);
	Setting:RestoreGlobalObj();
end

--对话 活动系统控制
function tbGoldBar:OnDialog()
	local szMsg = "  您现在身处金牌网吧中，可以在我这里领取很丰富的奖励哦！";
	local tbOpt = 
	{ 		
		{"Để ta suy nghĩ thêm"}
	 };
	 --称号
	 local szColor = "white";
	 if me.GetTask(self.TASK_GID, self.TASK_IS_GETTITLE) == 1 then
		szColor = "gray";
	end
	table.insert(tbOpt, 1, {string.format("<color=%s>专属称号<color>",szColor), self.GetTitle, self});
	--面具
	szColor = "white";
	if  me.GetTask(self.TASK_GID, self.TASK_IS_GETMASK) == 1 then
		szColor = "gray";		
	end
	table.insert(tbOpt, 1, {string.format("<color=%s>专属面具<color>",szColor),  self.GetMask, self});
	--特权令
	szColor = "white";
	if Player:CheckTask(self.TASK_GID, self.TASK_DATE, "%Y%m%d", self.TASK_IS_GETITEM, 1) == 0 then
		szColor = "gray";
	end
	table.insert(tbOpt, 1, {string.format("<color=%s>金牌特权令<color>",szColor), self.GetAword, self});	
	Dialog:Say(szMsg, tbOpt);
end

--领取金牌特权令
function tbGoldBar:GetAword()
	if self:CheckPlayer(me) == 0 then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请预留1格背包空间再来吧！");
		return 0;
	end
	if Player:CheckTask(self.TASK_GID, self.TASK_DATE, "%Y%m%d", self.TASK_IS_GETITEM, 1) == 0 then
		Dialog:Say("您今天已经领取过了，明天再来吧！");
		return 0;
	end
	local pItem = me.AddItem(unpack(self.tbAwordList[1]));
	if pItem then
		me.SetTask(self.TASK_GID, self.TASK_IS_GETITEM, 1);
		Dbg:WriteLog("GoldBar", me.szName, string.format("[金牌网吧]获得物品%s,IP地址%s", pItem.szName, Lib:IntIpToStrIp(me.dwIp)));
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[金牌网吧]获得物品%s,IP地址%s", pItem.szName, Lib:IntIpToStrIp(me.dwIp)));	
	end	
end

--选择面具
function tbGoldBar:GetMask()
	local szMsg = "请选择您心仪的面具。";
		local tbOpt = 
		{
			{"金龙郎君", self.GetMaskEx, self, 1},
			{"金玉佳人", self.GetMaskEx, self, 2},
			{"Để ta suy nghĩ thêm"}
		 };
	Dialog:Say(szMsg, tbOpt);
end

--获得面具
function tbGoldBar:GetMaskEx(nType)
	if self:CheckPlayer(me) == 0 then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请预留1格背包空间再来吧！");
		return 0;
	end
	if me.GetTask(self.TASK_GID, self.TASK_IS_GETMASK) == 1 then
		Dialog:Say("您已经领取过了！");
		return 0;
	end
	local pItem = me.AddItem(unpack(self.tbAwordList[2][nType]));
	if pItem then
		me.SetTask(self.TASK_GID, self.TASK_IS_GETMASK, 1);
		pItem.SetTimeOut(0, GetTime() + 3 * 30 * 24 * 3600);
		pItem.Sync();
		Dbg:WriteLog("GoldBar", me.szName, string.format("[金牌网吧]获得物品%s,IP地址%s", pItem.szName, Lib:IntIpToStrIp(me.dwIp)));
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[金牌网吧]获得物品%s,IP地址%s", pItem.szName, Lib:IntIpToStrIp(me.dwIp)));	
	end
end

--获得称号
function tbGoldBar:GetTitle()
	if self:CheckPlayer(me) == 0 then
		return 0;
	end
	if me.GetTask(self.TASK_GID, self.TASK_IS_GETTITLE) == 1 then
		Dialog:Say("您已经领取过了！")
		return 0;
	end
	local nType = me.nSex + 1;
	me.AddTitle(unpack(self.tbAwordList[3][nType]));
	me.SetCurTitle(unpack(self.tbAwordList[3][nType]));
	me.SetTask(self.TASK_GID, self.TASK_IS_GETTITLE, 1);
end

--检查IP
function tbGoldBar:CheckPlayer(pPlayer)
	local szIp = Lib:IntIpToStrIp(pPlayer.dwIp);
	local tbIp = self:SplitStrIp(szIp);
	local szIpEx = tbIp[1]..".".. tbIp[2]..".".. tbIp[3];
	if self.GoldBarIpList[szIpEx] and (self.GoldBarIpList[szIpEx].nAll or self.GoldBarIpList[szIpEx][szIp]) then
		return 1;
	end
	return 0;
end

--读Ip配置文件
function tbGoldBar:ReadGateWayFile(szDataPath)
	local tbData		= Lib:LoadTabFile(szDataPath);
	if not tbData then
		print("【金牌网吧】读取文件错误，文件不存在!",szDataPath);
		return "【金牌网吧】读取文件错误，文件不存在!";
	end
	self.GoldBarIpList = self.GoldBarIpList or {};
	for nId, tbParam in ipairs(tbData) do
		if nId >= 1 then
			local szIp = tbParam.szIp;
			local szKey,nAll = self:GetIpKey(szIp);
			if szKey then
				self.GoldBarIpList[szKey] = self.GoldBarIpList[szKey] or {};
				if nAll then
					self.GoldBarIpList[szKey].nAll = 1;
				else
					self.GoldBarIpList[szKey][szIp] = self.GoldBarIpList[szKey][szIp] or 1;
				end				
			end
		end
	end
	if (MODULE_GC_SERVER) then
		self:SaveData();
		GlobalExcute({"SpecialEvent.tbGoldBar:ReadGateWayFile", "\\..\\gamecenter"..szDataPath});
	end
	return 1;
end

--获取ip值是ip段还是具体的ip值
function tbGoldBar:GetIpKey(szIp)
	if not szIp or szIp == "" then
		return;		
	end
	local tbIp = self:SplitStrIp(szIp);
	local szIpEx = tbIp[1]..".".. tbIp[2]..".".. tbIp[3];
	local szStar, szEnd = string.find(szIp, "*");
	if szStar then
		return szIpEx, 1;
	else
		return szIpEx;
	end
end

--将ip差分成table
function tbGoldBar:SplitStrIp(szStrConcat)	
	local	szSep = "%.";	
	local tbStrElem = {};
	local nSepLen = 1;
	local nStart = 1;
	local nAt = string.find(szStrConcat, szSep);
	while nAt do
		tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart, nAt - 1);
		nStart = nAt + nSepLen;
		nAt = string.find(szStrConcat, szSep, nStart);
	end
	tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart);
	return tbStrElem;
end

-- 存档
function tbGoldBar:SaveData()
	SetGblIntBuf(GBLINTBUF_GOLDBAR_IPLIST, 0, 1, self.GoldBarIpList or {});
end

-- 读档
function tbGoldBar:LoadData()
	local tbSaveData	= GetGblIntBuf(GBLINTBUF_GOLDBAR_IPLIST, 0);
	if (type(tbSaveData) ~= "table") then
		self.GoldBarIpList	= {};
	else
		self.GoldBarIpList = tbSaveData;
	end	
end

--增加ip到iplist   10.20.104.* 表示增加一个ip段
function tbGoldBar:AddIp(szIp)
	if not szIp or szIp == "" then
		return;
	end
	local szKey, nAll = self:GetIpKey(szIp);
	if szKey then
		self.GoldBarIpList[szKey] = self.GoldBarIpList[szKey] or {};
		if nAll then
			self.GoldBarIpList[szKey].nAll = 1;
		else
			self.GoldBarIpList[szKey][szIp] = self.GoldBarIpList[szKey][szIp] or 1;
		end
	else
		return "ip值不正确！";
	end
	if (MODULE_GC_SERVER) then
		self:SaveData();
		GlobalExcute({"SpecialEvent.tbGoldBar:AddIp", szIp});
	end
	return 1;
end

--删除ip 没有参数表示清光整个list表, 10.20.104.* 表示删除一个ip段
function tbGoldBar:DelIp(szIp)
	if not szIp or szIp == "" then
		self.GoldBarIpList = {};
	else
		local szKey, nAll = self:GetIpKey(szIp);
		if szKey then			
			self.GoldBarIpList[szKey] = self.GoldBarIpList[szKey] or {};
			if nAll and self.GoldBarIpList[szKey] then
				self.GoldBarIpList[szKey] = nil;
			elseif self.GoldBarIpList[szKey] and self.GoldBarIpList[szKey][szIp] then
				self.GoldBarIpList[szKey][szIp] = nil;
			end
		else
			return "ip值不正确！";
		end		
	end
	if (MODULE_GC_SERVER) then
		self:SaveData();
		GlobalExcute({"SpecialEvent.tbGoldBar:DelIp", szIp});
	end
	return 1;
end

--Gc启动事件
if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbGoldBar.LoadData, SpecialEvent.tbGoldBar);
	GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.tbGoldBar.SaveData, SpecialEvent.tbGoldBar);
end

--Gs启动事件
if (MODULE_GAMESERVER) then	
	ServerEvent:RegisterServerStartFunc(SpecialEvent.tbGoldBar.LoadData, SpecialEvent.tbGoldBar);
end
