-- 文件名  : TaobaoCooperate_gs.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-09-03 17:12:14
-- 描述    :  淘宝合作活动

if not MODULE_GAMESERVER then
	return;
end

SpecialEvent.tbTaobaoCooperate = SpecialEvent.tbTaobaoCooperate or {};
local tbTaobaoCooperate = SpecialEvent.tbTaobaoCooperate;


--服务器启动和定点0点添加npc
function tbTaobaoCooperate:AddNpc()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	local oldself = self;
	self = tbTaobaoCooperate;
	local nState = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_TAOBAOSWITCH);
	if nData >= self.nOpenTime and nData <= self.nCloseTime and self.nNpc == 0 and nState == 1 then	--活动期间内启动服务器
		for _, tbPos in ipairs(self.tbTaoBaoPoint) do
			if SubWorldID2Idx(tbPos[1]) >= 0 then
				KNpc.Add2(self.nTaoBaoDaShi, 100, -1, tbPos[1],tbPos[2],tbPos[3]);
			end
		end
		self.nNpc = 1;
	end
	self = oldself;
end

function tbTaobaoCooperate:LoadBuffer_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_TAOBAOCOOPERATE, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbTaoBaoInfo = tbBuffer;
	end
end

--使用物品
function tbTaobaoCooperate:OnUse(dwId, nPlayerId, nState, nKey, szCode)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then		
		return;
	end	
	--check
	local nFlag, szMsg = self:CheckCanUse(pPlayer);
	if nFlag == 1 then
		pPlayer.Msg(szMsg);
		return 0;		
	end
	--回调给奖励删物品解锁玩家
	if nKey then
		if nKey > 1 and nKey < 8 and szCode == "" then
			self:OnUse(dwId, nPlayerId, 0);
			return 0;
		end
		self:GetAward(pPlayer, nKey, szCode);
		local pItem = KItem.GetObjById(dwId);
		if pItem then
			pItem.Delete(pPlayer);
		end
		pPlayer.SetTask(self.TASK_GID, self.TASK_TASKID_USEBOX, pPlayer.GetTask(self.TASK_GID, self.TASK_TASKID_USEBOX) + 1);
		-- 解锁
		pPlayer.AddWaitGetItemNum(-1);
		Dbg:WriteLogEx(1, "TaoBaoCooPerate", "使用淘宝礼盒", pPlayer.szName);
		return;
	end
	
	-- 锁住玩家
	if nState == 1 then
		pPlayer.AddWaitGetItemNum(1);
	end
	
	 --随机奖励
	 self:RandomAward(dwId, pPlayer);
end

--随机奖励
function tbTaobaoCooperate:RandomAward(dwId, pPlayer)
	--del	
	local tbItemInfo1 =  Lib:CopyTB1(self.tbItemInfo);
	self:DeleteNotAccord(tbItemInfo1, pPlayer);

	--random
	local nAllRate = 0;
	for _, tbInfo in pairs(tbItemInfo1) do
		nAllRate = nAllRate + tbInfo[1];
	end
	local nRate = MathRandom(nAllRate);	
	local nRes = 0;
	for nKeyEx, tbInfo in pairs(tbItemInfo1) do
		nRes = nRes + tbInfo[1];
		if nRes >= nRate then
			--GC仲裁
			GCExcute({"SpecialEvent.tbTaobaoCooperate:CanGetAward", dwId, pPlayer.nId, nKeyEx});
			return;
		end
	end
end

function tbTaobaoCooperate:CheckCanUse(pPlayer)
	--使用的数量
	local nCount = pPlayer.GetTask(self.TASK_GID, self.TASK_TASKID_USEBOX);
	if nCount >= self.nMaxUse then
		return 1, "您已经不能再使用了，机会还是留给别人吧！";
	end
	--背包
	if pPlayer.CountFreeBagCell() < 2 then
	  	return 1, "包裹空间不足2格，请整理下！";
	end
	--绑银上限
	if pPlayer.GetBindMoney() + 20000 > pPlayer.GetMaxCarryMoney() then
		return 1, "你的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。";
	end
	return 0;
end

--删除掉不符合的奖励
function tbTaobaoCooperate:DeleteNotAccord(tbItemInfo1, pPlayer)
	for i, tbInfo in pairs(self.tbItemInfo) do
		local nFlag = self:GetCanUseCode(i);
		if tbInfo[3] == 2 and nFlag == 0 then
			tbItemInfo1[i] = nil;
		end
	end
	--自身已经中过的
	for i, nTaskId in ipairs(self.TASK_TASKID_GETAWARD) do
		if pPlayer.GetTask(self.TASK_GID, self.TASK_TASKID_GETAWARD[i]) == 1 then			
			tbItemInfo1[self.tbTaskInfo[i]] = nil;
		end
	end
	--一等奖2500个
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_TAOBAO_LIHE) >= self.nMaxTaoBox then
		tbItemInfo1[1] = nil;
	end
end

function tbTaobaoCooperate:GetCanUseCode(nKey)
	if not self.tbTaoBaoInfo[nKey] then
		return 0;
	end
	for szCode, nFlag in pairs(self.tbTaoBaoInfo[nKey]) do
		if nFlag == 0 then
			return 1;
		end
	end
	return 0;
end

--获得奖励
function tbTaobaoCooperate:GetAward(pPlayer, nKey, szCode)
	local tbAward = self.tbItemInfo[nKey];
	if not tbAward then
		return;
	end
	local szAwardName =self.tbNameAward[tbAward[2]];
	--物品
	if tbAward[3] == 1 then
		pPlayer.AddStackItem(unpack(tbAward[4]));
	--淘宝码
	elseif tbAward[3] == 2 and szCode and szCode ~= "" then
		local szAwardMsgInfo = string.format("恭喜您在淘宝优惠活动中获得<color=yellow>%s<color>，对应编码为 <color=yellow>%s<color>,详情请见官网或者淘宝相关网站。\n<color=red>淘宝代金券使用说明及兑换地址：http://wwww.taobao.com/go/act/theme/info/tb-dijiaquan_080819.php\n淘宝红包使用说明及兑换地址：http://service.taobao.com/support/knowledge-1116444.hem#3<color>", szAwardName, szCode);
		KPlayer.SendMail(pPlayer.szName, "淘宝优惠奖励", szAwardMsgInfo);
	--绑银
	elseif tbAward[3] == 3 then
		pPlayer.AddBindMoney(tbAward[4]);
	end
	--设任务变量	
	for i, nKeyEx in ipairs(self.tbTaskInfo) do
		if nKeyEx == nKey then
			pPlayer.SetTask(self.TASK_GID, self.TASK_TASKID_GETAWARD[i], 1);
		end
	end
	self:SendMsg(pPlayer, tbAward, szAwardName);
end

--发Msg
function tbTaobaoCooperate:SendMsg(pPlayer, tbAward, szAwardName)
	--send msg
	local szMsg = string.format("恭喜您,获得%s", szAwardName);
	if tbAward[2] > 1 and tbAward[2] <= 5 then
		szMsg = szMsg..",详情请查看您的邮箱!"
	end
	pPlayer.Msg(szMsg);
	Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	if tbAward[2] <= 5  then
		Dialog:GlobalNewsMsg_GS(string.format("恭喜玩家【%s】在淘宝活动中获得【%s】", pPlayer.szName, szAwardName));
	end
end

function tbTaobaoCooperate:OnDialog()
	local szMsg = [[
	<color=red>注：该活动只在新开区服开放！<color>
	     <color=yellow>★剑雨风云 淘宝江湖★<color>

	  金秋来临，剑侠江湖再起风云，针对<color=yellow>新开区服<color>，“剑雨风云 淘宝江湖”活动火热开启。

 <color=green>活动时间：<color> 
	    <color=red>2010年10月10日-11月20日24:00<color>

 <color=green>活动内容：<color> 
	    1、众侠士通过击败1-75级怪以及55级世界boss，有一定几率获得字符：“剑”“雨”“风”“云”“淘”“宝”“江”“湖”。
	    2、集齐“ <color=yellow>剑雨风云<color>”，或“ <color=yellow>淘宝江湖<color>”4个字符，可在各大城市 <color=yellow>淘宝活动使者<color>处兑换【淘·礼盒】。
	    3、使用【淘·礼盒】有几率获得价值488元【淘·礼包】和不同面值的【淘宝红包】和【淘宝代金券】。

 <color=green>活动要点：<color> 
	    1、活动期间每位侠士最多可兑换30个【淘·礼盒】，且最多可开启30个【淘·礼盒】。
	    2、每个角色只能获得1次【淘·礼包】奖励和1次各面值的【淘宝红包】。
	    3、【淘宝红包】和【淘宝代金卷】通过 <color=yellow>邮件<color>发放给众位侠士，详情请见邮件！
]];
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.tbTaobaoCooperate.LoadBuffer_GS, SpecialEvent.tbTaobaoCooperate);
ServerEvent:RegisterServerStartFunc(SpecialEvent.tbTaobaoCooperate.AddNpc, SpecialEvent.tbTaobaoCooperate);
