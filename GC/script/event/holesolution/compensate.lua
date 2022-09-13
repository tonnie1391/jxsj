------------------------------------------------------
-- 文件名　：compensate.lua
-- 创建者　：dengyong
-- 创建时间：2009-10-10 17:08:27
-- 描  述  ：实现三种补偿方式
------------------------------------------------------

Require("\\script\\lib\\gift.lua");

if not SpecialEvent.HoleSolution then
	SpecialEvent.HoleSolution = {};
end

local HoleSolution = SpecialEvent.HoleSolution;

--申请了两条子任务变量
HoleSolution.TASK_COMPENSATE_GROUPID = 2105;		--补偿组任务变量
HoleSolution.TASK_SUBID_REASON = 1;		--用来记录玩家被扔到桃源的原因
--补偿任务的子变量数组，两位为一组，每组的第一位存放玩家欠的价值量，第二位存允许赔偿方式
--第一位作为判定的主变量，第二位主要辅助用。
HoleSolution.tbSubTaskGroup = 
{
	{2, 3},		
	{4, 5},
}

------------------------------------------------------------------
--任务变量位码含义（从低位到高位）
--第1位：降装备等级
--第2-6位：扣钱
	--第2位：普通银两
	--第3位：绑定银两	--目前没有单独使用该选项，被揉合到第5位中
	--第4位：绑金		--目前没有单独使用该选项，被揉合到第5位中
	--第5位：银两、绑银、绑金
	--第6位：金币		--目前还未使用该选项
--第7-9：扣玄
	--第7位：不绑玄
	--第8位：绑玄		--目前没有单独使用该选项，被揉合到第9位中
	--第9位：任意玄
--除了上面这些解释过的位之外，其它位不具备含义，即不做判定
--注：任务变量的位码只能用于解析选项目录，不能解析其它玩意儿 -_-
---------------------------------------------------------------------------------------------------------------
--用降低装备强化点数补偿待扣价值量的给予窗口
HoleSolution.tbDegradeEquipGiftDialog = Gift:New();
HoleSolution.tbDegradeEquipGiftDialog._szTitle = "弱化装备";
HoleSolution.tbDegradeEquipGiftDialog._szContent = "请在格子中放入强化过的装备！";

--用玄晶补偿待扣价值量的给予窗口
HoleSolution.tbXJGiftDialog = Gift:New();
HoleSolution.tbXJGiftDialog._szTitle = "扣除玄晶";
HoleSolution.tbXJGiftDialog._szContent = "请在下面的格子中放入玄晶吧！";
HoleSolution.tbXJGiftDialog.ITEM_CALSS = "xuanjing";
------------------------------------------------------------------

if not MODULE_GAMECLIENT then

--解析任务变量,将选项表存放到self.tbOpt中
--self.tbOpt的结构跟tbTaskBitValue一致，事实上tbOpt是tbTaskBitValue的一部分
function HoleSolution:__ParseTheTaskVar(nTaskVar)
	local tbTaskVar = {};
	--从低位到高位
	for i= 1, 32 do
		tbTaskVar[i] = nTaskVar%2;
		nTaskVar = math.floor(nTaskVar/2);
	end
	
	--未使用的选项先不加入到该表中，若要添加某上面已经存在的项，修改该表即可
	local tbTaskBitValue =
	{
		[1] = {"降低装备强化点数", self.__CompensateByDegradeEquip, self},
		[2] = {"普通银两", self.OnSelectMoneyType, self, "请输入银两的数量", 0},	--0表示银两
		[5] = {"银两、绑银或绑金", self.__SelectMoneyType, self, 5},	--5表示选项的索引
		[7] = {"不绑玄晶", self.__CompensateByXuanJing, self, 1},		--1表示只能用不绑玄
		[9] = {"任意玄晶", self.__CompensateByXuanJing, self},
	}
	
	local tbOpt = {};
	
	for nIndex, tbValue in pairs(tbTaskBitValue) do
		if tbTaskVar[nIndex] == 1 then
			table.insert(tbOpt, tbValue);
		end
	end
	
	return tbOpt;
end

--扣除玩家一部分价值量之后，将剩余待扣价值量同步到任务变量中
--第一组有值的任务变量就是当前正在处理的数据
function HoleSolution:__SetBalanceValue(nArrearage)
	for nIndex, tbGroup in pairs(self.tbSubTaskGroup) do
		if KLib.Number2UInt(me.GetTask(self.TASK_COMPENSATE_GROUPID, tbGroup[1])) > 0 then
			me.SetTask(self.TASK_COMPENSATE_GROUPID, tbGroup[1], nArrearage);
			return;
		end
	end
	
	--如果执行到这里，说明有错，写个LOG
	Dbg:WriteLog("HoleSolution", "SpecialEvent.HoleSolution:__SetBalanceValue(): Error!");
end

--通过扣钱币来补偿, nSelectedValue表示目录中选项的索引值
--只有点击"银两、绑银或绑金"选项才会进入到这里
function HoleSolution:__SelectMoneyType(nSelectedValue)
	if nSelectedValue == 5 then 	--5表示"银两、绑银或绑金"的索引值
		local szMsg = "\n请选择你想扣除的钱币类型。";
		local tbDlgItem = {};
		
		table.insert(tbDlgItem, {"银两", self.OnSelectMoneyType, self, "请输入银两的数量", 0});
		table.insert(tbDlgItem, {"绑定银两", self.OnSelectMoneyType, self, "请输入绑银的数量", 1});
		table.insert(tbDlgItem, {"绑定金币", self.OnSelectMoneyType, self, "请输入绑金的数量", 2});	
		Dialog:Say(szMsg, tbDlgItem);
	end
end

function HoleSolution:OnSelectMoneyType(szTitle, nType)
	local tbMoneyType = 
	{--nType    szType       nNum
		[0] = {"普通银两", me.nCashMoney},
		[1] = {"绑定银两", me.GetBindMoney()},
		[2]	= {"绑定金币", me.nBindCoin},
	}
	local nMaxCount = tbMoneyType[nType][2];	--取出数量
	
	if 0 == nMaxCount then
		Dialog:Say(string.format("你的%s数量为0, 请选择其它补偿方式！",  tbMoneyType[nType][1]));
		return;
	end
	Dialog:AskNumber(szTitle, nMaxCount, self.__CompensateByMoney, self, nType);
end

--nType表示钱币类型: 0为银两，1为绑银或2为绑金.(凡是涉及到钱币类型，均是如此)
--nCount为要扣除钱币类型的数量
function HoleSolution:__CompensateByMoney(nType, nCount)
	if not nType and (nType > 2 or nType < 0) then
		return;
	end
	
	if nCount == 0 then
		return;
	end
	
	local nArrearage = self:GetBalanceValue();	
	local nCompensateValue = (nType == 2) and nCount * 100 or nCount;	 --绑金的价值量要乘100
	local szType = (nType == 2) and "绑定金币" or ((nType == 1) and "绑定银两" or "普通银两");
	
	local szMsg = "";
	szMsg = szMsg..string.format("你确定要扣除<color=yellow>%d%s<color>吗？你将补偿价值量<color=yellow>%d<color>,",
			nCount, szType, nCompensateValue);
	if nCompensateValue > nArrearage then
		szMsg = szMsg..string.format("这比你所欠的的价值量要多,但系统只会扣除等量的价值量,多余部分会返还给你！");
		if nType == 2 then		--如果是绑金
			local nExtraBindCoin = math.floor((nCompensateValue - nArrearage)/100);
			nCount = nCount - nExtraBindCoin;
		else
			nCount = nCount - nCompensateValue + nArrearage;
		end
		nCompensateValue = nArrearage;
	elseif nCompensateValue == nArrearage then
		szMsg = szMsg..string.format("这刚好抵消你所欠的价值量。")
	else
		szMsg = szMsg..string.format("这还不足于完全抵消你所欠的价值量,你将还欠我<color=red>%d<color>的价值量。", nArrearage-nCompensateValue);
	end
	
	Dialog:Say(szMsg,
	{
		{"是的,我确定", self.__CostPlayerMoney, self, nType, nCount, nCompensateValue, nArrearage},
		{"我再考虑考虑"},
	})
end

function HoleSolution:__CostPlayerMoney(nType, nCount, nCompensateValue, nArrearage)
	local szType;
	if 0 == nType then
		szType = "普通银两";
		GM:ClearMoney(nCount, 0, 0);
	elseif 1 == nType then
		szType = "绑定银两";
		GM:ClearMoney(0, nCount, 0);
	elseif 2 == nType then
		szType = "绑定金币";
		GM:ClearMoney(0, 0, nCount);
	end
	
	local szMsg = string.format("扣除<color=yellow>%d%s<color>", nCount, szType);
	me.Msg(szMsg);
	nArrearage = nArrearage - nCompensateValue;
	self:__SetBalanceValue(nArrearage);	--将剩余待扣价值量更新到任务变量中
end

--通过降低装备强化点来补偿
function HoleSolution:__CompensateByDegradeEquip()
	HoleSolution.tbDegradeEquipGiftDialog:OnOpen();
	--Dialog:Gift("HoleSolution.tbDegradeEquipGiftDialog");
end

--降低装备强化点一点
function HoleSolution:__DegradeEquip(tbDelEquip, nArrearage)
	--先写日志再剥夺装备的强化等级
	for _, tbEquip in pairs(tbDelEquip) do
		if tbEquip[1].nEnhTimes >= 0 then
			local nEnhTimes, _, nTotalValue = HoleSolution:CalcEquipEnhanceValue(tbEquip[1], nArrearage);
			
			if tbEquip[1].nStrengthen == 1 then
				Dbg:WriteLog("HoleSolution", "%s的装备%s的改造属性[%d改]被剥离", me.szName, tbEquip[1].szName, nEnhTimes);
			end
			if nEnhTimes > 0 then	--由于有了改造属性，所以有可能不需要弱化装备强化等级，只需要将改造属性剥离就可以了
				Dbg:WriteLog("HoleSolution", string.format("%s的装备%s强化等级下降为%d级", me.szName, tbEquip[1].szName, nEnhTimes));
			end
			
			if tbEquip[1].Regenerate(
				tbEquip[1].nGenre,
				tbEquip[1].nDetail,
				tbEquip[1].nParticular,
				tbEquip[1].nLevel,
				tbEquip[1].nSeries,
				nEnhTimes,
				tbEquip[1].nLucky,
				tbEquip[1].GetGenInfo(),
				0,
				tbEquip[1].dwRandSeed,
				0) == 1 then		--不管之前该装备是不是被改造过，只要到这里就会改造属性都会被剥离
				nArrearage = nArrearage - nTotalValue;
			end
		end
	end
	
	-- 多扣了~需要补偿回来
	local tbBuChang = {}; 
	if nArrearage < 0 then
		tbBuChang = Item:ValueToItem(math.abs(nArrearage), 4);  --用玄晶补偿（但是有丢失，不一定补偿跟传入值等价值量的玄晶）
		nArrearage = 0;
		self:__BuChangXuanJing(tbBuChang);
	end
	
	self:__SetBalanceValue(nArrearage);	--将剩余待扣价值量更新到任务变量中
end

--通过消耗玄晶来补偿
--bNotBind: 为1时，只能用非绑玄；否则可用任意玄晶
function HoleSolution:__CompensateByXuanJing(bNotBind)
	bNotBind = bNotBind or 0;
	HoleSolution.tbXJGiftDialog:OnOpen(bNotBind);
	--Dialog:Gift("HoleSolution.tbXJGiftDialog");
end

--扣除玄晶
function HoleSolution:__DelPlayerXuanJing(tbItem, nArrearage)
	local nSumOfValue = 0;
	for i, pDelItem in pairs(tbItem) do
		local nCurValue = pDelItem.nValue;
		if me.DelItem(pDelItem) ~= 1 then
			Dbg:WriteLog("HoleSolution", "扣除玄晶时出错！");
		else
			nSumOfValue = nSumOfValue + nCurValue
		end
	end
	
	nArrearage = nArrearage - nSumOfValue;
	-- 多扣了~需要补偿回来
	if nArrearage < 0 then	
		local tbBuChang = Item:ValueToItem(math.abs(nArrearage), 4);  --用玄晶补偿（但是有丢失，不一定补偿跟传入值等价值量的玄晶）
		nArrearage = 0;
		self:__BuChangXuanJing(tbBuChang);
	end
	
	self:__SetBalanceValue(nArrearage);	--将剩余待扣价值量更新到任务变量中
end

--将多扣的价值量所兑换成的玄晶发给玩家
--先把补偿的玄晶直接给玩家，如果玩家背包已满，则将剩余的玄晶用邮件发送给他
function HoleSolution:__BuChangXuanJing(tbBuChang)
	if tbBuChang then
		for nLevel, nNum in pairs(tbBuChang) do
			for i = 1, nNum do
				local pItem = me.AddItem(18,1,114, nLevel);
				if not pItem then --and nLevel >= 5 then
					KPlayer.SendMail(me.szName, "补偿", "",
						0, 0, 1, 18,1,114,nLevel);
				end
			end
		end
		me.Msg("补偿玄晶已经发送给你,请注意查收！");
	end
	
	tbBuChang = {};
end

------------------------------------------------------------------------------------------
-- server callback interface
function HoleSolution.tbDegradeEquipGiftDialog:OnOK()
	local nArrearage = HoleSolution:GetBalanceValue();
	local pItem = self:First();
	if not pItem then
		Dialog:Say("你没放入任何物品！");
		return 0;
	end
	while pItem do
		if (pItem.szClass ~= "suite" or pItem.szClass ~= "equip") and pItem.nEnhTimes <= 0 then
			Dialog:Say("格子中只能存放强化过的装备!")
			return 0;
		end
		pItem = self:Next();
	end
	
	local nSumOfValue, tbItem = self:CalItemValue(nArrearage);
	local szMsg = string.format("按照这个方式,你将抵消价值量<color=yellow>%d<color>,", nSumOfValue);
	if nSumOfValue > nArrearage then
		local tbBuChang, szAddMsg = HoleSolution:GetBuChangInfo(nSumOfValue - nArrearage);
		if tbBuChang then
			szMsg = szMsg..szAddMsg;
		end
	elseif nSumOfValue == nArrearage then
		szMsg = szMsg.."这将刚好抵消你所欠的价值量。";
	else
		szMsg = szMsg..string.format("这还不足以完全抵消你所欠的价值量，你还欠<color=red>%d<color>的价值量。", nArrearage-nSumOfValue);
	end
	szMsg = szMsg.."为了安全起见，请你再次确认！";
	
	Dialog:Say(szMsg,
	{
		{"是的,我确定", HoleSolution.__DegradeEquip, HoleSolution, tbItem, nArrearage},
		{"我再考虑考虑"},
	});	
end

function HoleSolution.tbDegradeEquipGiftDialog:OnOpen()
	--先通知客户端更新数据，再打开窗口
	me.CallClientScript({"SpecialEvent.HoleSolution.tbDegradeEquipGiftDialog:OnUpdateParam"});
	Dialog:Gift("SpecialEvent.HoleSolution.tbDegradeEquipGiftDialog");
end

function HoleSolution.tbXJGiftDialog:OnOK()
	local pItem = self:First();
	local tbItem = {};
	if not pItem then
		Dialog:Say("你没放入任何物品！");
		return 0;
	end
	while pItem do
		if pItem.szClass == HoleSolution.tbXJGiftDialog.ITEM_CALSS then
			table.insert(tbItem, pItem);
		else
			Dialog:Say("格子中只能放入玄晶！");
			tbItem = {};
			return 0;
		end		
		if HoleSolution.tbXJGiftDialog.bNotBind == 1 and pItem.IsBind() == 1 then
			Dialog:Say("需要用不绑玄！");
			tbItem = {};
			return 0;
		end		
		pItem = self:Next();
	end
	
	local nArrearage = HoleSolution:GetBalanceValue();
	local nSumOfValue = self:CalItemValue();
	local szMsg = string.format("你在格子中放入玄晶的总价值量为<color=yellow>%d<color>,", nSumOfValue);
	if nSumOfValue > nArrearage then
		local tbBuChang, szAddMsg = HoleSolution:GetBuChangInfo(nSumOfValue - nArrearage);
		if tbBuChang then
			szMsg = szMsg..szAddMsg;
		end
	elseif nSumOfValue == nArrearage then
		szMsg = "这刚好抵消你所欠的价值量。";
	else
		szMsg = szMsg..string.format("这还不足于抵消你所欠的价值量,你还欠<color=red>%d<color>的价值量。", nArrearage-nSumOfValue);
	end
	szMsg = szMsg.."为了安全起见，请你再次确认！";
		
	Dialog:Say(szMsg,
	{
		{"是的,我确定", SpecialEvent.HoleSolution.__DelPlayerXuanJing, SpecialEvent.HoleSolution, tbItem, nArrearage},
		{"我再考虑考虑"},
	});	
end

function HoleSolution.tbXJGiftDialog:OnOpen(bNotBind)
	me.CallClientScript({"SpecialEvent.HoleSolution.tbXJGiftDialog:OnUpdateParam", bNotBind});
	Dialog:Gift("SpecialEvent.HoleSolution.tbXJGiftDialog");
end

end		-- if not MODULE_GAMECLIENT then else 
------------------------------------------------------------------------------------------
--客户端函数
function HoleSolution.tbDegradeEquipGiftDialog:OnUpdate()
	local pFindItem = HoleSolution.tbDegradeEquipGiftDialog:First();
	if not pFindItem then
		self._szContent = "请在格子中放入强化过的装备！";
	else
		local nSumOfValue, tbItem = self:CalItemValue(self.nArrearage);
		if tbItem then
			self._szContent = "";
			self._szContent = self._szContent..string.format("你当前欠我<color=red>%d<color>的价值量。", self.nArrearage);
			self._szContent = self._szContent..string.format("你将按照以下的方式补偿：\n<color=green>装备名称, 弱化情况, 抵消价值量<color>");
			for _, tbSingleItem in pairs(tbItem) do
				local szChanged = "";
				if tbSingleItem[1].nStrengthen == 1 then
					szChanged = string.format("去掉改%d属性，降%d级", tbSingleItem[1].nEnhTimes, tbSingleItem[1].nEnhTimes - tbSingleItem[2]);
				else
					szChanged = string.format("降%d级", tbSingleItem[1].nEnhTimes - tbSingleItem[2]);
				end
				self._szContent = self._szContent..string.format("\n<color=yellow>%s<color>, <color=yellow>%s<color>, <color=yellow>%d<color>;", tbSingleItem[1].szName, szChanged, tbSingleItem[3]);
			end
			self._szContent = self._szContent..string.format("\n共抵消价值量<color=yellow>%d<color>,", nSumOfValue);
		end
		--如果扣除的价值量比欠的价值量要多，则给出玄晶补偿信息
		if nSumOfValue > self.nArrearage then
			local tbBuChang, szAddMsg = HoleSolution:GetBuChangInfo(nSumOfValue - self.nArrearage);
			if tbBuChang then
				self._szContent = self._szContent..szAddMsg;
			end
		end
	end
end

--当向容器里放入东西
--pPickItem指从给予窗口中拿出的物品，pDropItem指向窗口中放入的物品(下同)
function HoleSolution.tbDegradeEquipGiftDialog:OnSwitch(pPickItem, pDropItem, nX, nY)
	if pDropItem then
		if pDropItem.szClass ~= "suite" and pDropItem.szClass ~= "equip" then		--放入的物品不是装备
			me.Msg("请放入装备!");
			return 0;
		end
		if pDropItem.nEnhTimes <= 0 then		--放入的装备没有强化过
			me.Msg("该装备没有强化价值量，请重新放入强化过的装备!");
			return 0;
		end
	end
	if pPickItem then
		local pFindItem = HoleSolution.tbDegradeEquipGiftDialog:First();
		if not pFindItem then		--格子中没有装备了
			self._szContent = "请在格子中放入强化过的装备！";
			return 1;
		end
	end
		
	return 1;
end

--服务器通知客户端更新数据
function HoleSolution.tbDegradeEquipGiftDialog:OnUpdateParam()
	HoleSolution.tbDegradeEquipGiftDialog.nArrearage = HoleSolution:GetBalanceValue();
end

function HoleSolution.tbXJGiftDialog:OnUpdate()
	local nSumOfValue = self:CalItemValue();
	local szTipInfo = (self.bNotBind == 1) and "(不绑玄)" or "(任意玄)";
	self._szContent = string.format("请在格子中放入玄晶吧！<color=green>%s<color><enter>你当前一共欠我<color=red>", szTipInfo);
	self._szContent = self._szContent..string.format("%d<color>的价值量,",self.nArrearage);
	self._szContent = self._szContent..string.format("格子里的玄晶共值<color=yellow>%d<color>的价值量。", nSumOfValue);
	--self._szContent = self._szContent.."\n<color=green>(提示：如果你提交的价值量比实际价值量高，多余的部分将会以低等级形式的玄晶来补偿。)<color>";
	--如果扣除的价值量比欠的价值量要多，则给出玄晶补偿信息
	if nSumOfValue > self.nArrearage then
		local tbBuChang, szAddMsg = HoleSolution:GetBuChangInfo(nSumOfValue - self.nArrearage);
		if tbBuChang then
			self._szContent = self._szContent..szAddMsg;
		end
	end
end

-- 当向容器里放入东西
function HoleSolution.tbXJGiftDialog:OnSwitch(pPickItem, pDropItem, nX, nY)	
	if pDropItem then
		if pDropItem.szClass ~= self.ITEM_CALSS then
			me.Msg("格子中只能放入玄晶！");
			return 0;
		end
		if self.bNotBind == 1 and pDropItem.IsBind() == 1 then
			me.Msg("请放入不绑玄！");
			return 0;
		end
	end
									
	return 1;
end

function HoleSolution.tbXJGiftDialog:OnUpdateParam(bNotBind)
	print("执行OnUpdateParam", bNotBind);
	self.nArrearage = HoleSolution:GetBalanceValue();
	self.bNotBind = bNotBind;
end
------------------------------------------------------------------------------------------
--服务器客户端共用
--取出第一组欠的价值量和补偿方式码值
function HoleSolution:GetBalanceValue()
	local nArrearage, nTaskVar = 0, 0;
	for nIndex, tbGroup in pairs(self.tbSubTaskGroup) do
		nArrearage = me.GetTask(self.TASK_COMPENSATE_GROUPID, tbGroup[1]);
		nTaskVar = me.GetTask(self.TASK_COMPENSATE_GROUPID, tbGroup[2]);
		nArrearage = KLib.Number2UInt(nArrearage);
		if nArrearage > 0 then
			return nArrearage, nTaskVar;
		end
	end
	return nArrearage, nTaskVar;
end

--取出玩家获得补偿玄晶的信息
function HoleSolution:GetBuChangInfo(nValue)
	local tbBuChang = Item:ValueToItem(math.abs(nValue), 4);  --得到补偿玄晶信息表	
	local szMsg = "";	
	if tbBuChang then
		szMsg = szMsg.."这比你所欠的价值量多，如果你提交,你将得到以下玄晶作为补偿：<color=green> ";
		for nLevel, nNum in pairs(tbBuChang) do
			szMsg = szMsg..string.format("%d级玄晶%d个;", nLevel, nNum);
		end
		szMsg = szMsg.."<color>";
	end
	
	return tbBuChang, szMsg;
end

--计算弱化装备给予窗口中需要扣除的总价值量
function HoleSolution.tbDegradeEquipGiftDialog:CalItemValue(nArrearage)
	local nValue = nArrearage;
	local nSumOfVlaue = 0;
	local tbItem = {};
	
	local pItem = self:First();
	if not pItem then
		return nSumOfVlaue;
	end
	while pItem do
		if pItem.szClass == "suite" or pItem.szClass == "equip" then
			local nEnhTimes, nNewValue, nTotalValue = HoleSolution:CalcEquipEnhanceValue(pItem, nValue);	
			nValue = nNewValue;
			
			nSumOfVlaue = nSumOfVlaue + nTotalValue;
			table.insert(tbItem, {pItem, nEnhTimes, nTotalValue});
			if nValue <= 0 then
				break;
			end
		end
		
		pItem = self:Next();
	end
		
	return nSumOfVlaue, tbItem;
end

--计算扣除玄晶给予窗口中所有玄晶的总价值量
function HoleSolution.tbXJGiftDialog:CalItemValue()
	local nSumOfVlaue = 0;
	
	local pItem = self:First();
	if not pItem then
		return nSumOfVlaue;
	end
	while pItem do
		if pItem.szClass == self.ITEM_CALSS then
			
			local tbBaseProp = KItem.GetItemBaseProp(Item.SCRIPTITEM, 1, 1, pItem.nLevel);
			nSumOfVlaue = nSumOfVlaue + tbBaseProp.nValue;
		end
		
		pItem = self:Next();
	end
		
	return nSumOfVlaue;
end

-- 计算装备的强化价值量
--返回值：剩余强化点数，剩余价值量，总价值量
function HoleSolution:CalcEquipEnhanceValue(pItem, nValue)
	local nTotalValue = 0;	--单个装备被弱化所抵消的价值量
	local tbSetting = Item:GetExternSetting("value", pItem.nVersion);
	local nEnhTimes = pItem.nEnhTimes;
	if (tbSetting) then
		local nTypeRate = ((tbSetting.m_tbEquipTypeRate[pItem.nDetail] or 100) / 100) or 1;
		--如果有改造的，先计算改造的价值量
		if pItem.nStrengthen == 1 then
			local nStrengthenValue = tbSetting.m_tbStrengthenValue[pItem.nEnhTimes] * nTypeRate * 1.1;	-- TODO:汇率算200的，所以价值量要*1.1，以后这个数值根据汇率计算出来 
			nValue = nValue - nStrengthenValue;
			nTotalValue = nStrengthenValue + nTotalValue;
			if nValue <= 0 then
				return pItem.nEnhTimes, nValue, nTotalValue;
			end
		end
		
		repeat
			local nEnhValue = math.floor((tbSetting.m_tbEnhanceValue[nEnhTimes] or 0) * nTypeRate * 1.1);  -- TODO:汇率算200的，所以价值量要*1.1，以后这个数值根据汇率计算出来 
			nValue = nValue - nEnhValue;
			nTotalValue = nTotalValue + nEnhValue;
			nEnhTimes = nEnhTimes - 1;
		until (nEnhTimes <= 0 or nValue <= 0);
	end
	return nEnhTimes, nValue, nTotalValue;
end


---------------------------------------------------------------------------------------------------------------

