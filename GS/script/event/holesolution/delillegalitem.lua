------------------------------------------------------
-- 文件名　：delillegalitem.lua
-- 创建者　：dengyong
-- 创建时间：2009-10-10 17:09:11
-- 描  述  ：加载黑名单文件并根据文件数据对玩家做相关的处理
------------------------------------------------------

--黑名单表tbBlackList结构
--{
--	[filename]= {..},
--	[filename]= {..},
--}
--tbBlackList的每个子表为从文件中读出来的带不同特性的表(tbFileList)，该子表的结构为
--{
--	[1] 		  = {tbItem1, ..., tbItemN, nTaskVar, ["Ext"]={{groupId1, supId1}, ..., {groupIdN, subIdN}}},
--  [玩家角色名]  = {num1,    ...,   numN,  nOthers, ["Ext"] = {n,..., m}},
--	[玩家角色名]  = {num1,    ...,   num3,  nOthers, ["Ext"] = {n,..., m}},
-- 	....,
--}(每一项是表，都按数字索引存储)
--其中tbItem1--tbItem5均是表，而且它们的结构相同，为{g,d,p,l,nValue};nValue指单个道具的价值量
if not SpecialEvent.HoleSolution then
	SpecialEvent.HoleSolution = {};
end

local HoleSolution = SpecialEvent.HoleSolution;
-- HoleSolution.nListItemCount = 5;  --单个表文件中描述物品的个数
HoleSolution.nOthersIndex = 0;  --将[others]选项的索引设为0

--------------------------------------------------------------------------------------------
if MODULE_GC_SERVER then

--从文件中读取黑名单数据，并将数据写入到数据库中
--由于对应的BUFF里可能要存放好几张不同类型的表（每张表对应一个文件），因而在写入的时候注意不要将BUFF已经存在的数据覆盖掉。
--TODO:有一个严重的问题：当一个表格文件被读了两次，该表在数据库中也会存两份。需要考虑如何限制同一个文件被读取多次。
function HoleSolution:LoadBlackListToDataBase(szPath, szIndex)
	--当要使用一个已经存在的索引时，退出报错
	if self.tbBlackList and self.tbBlackList[szIndex] then
		return string.format("load error! Index [%s] already exist!", szIndex);
	end
	
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return "文件加载错误";
	end
	
	local szCurSeverGateWayName = _G.GetGatewayName();	--先取出本服的网关名
	local tbFileList = {};
	
	local nPlayerCount = 0;    --记录该次读取玩家信息的个数
	local szLogMsg = {};	--记录加载文件过程中出现的日志信息
	local nItemCountInList = 0;	-- 记录列表中一共涉及到几种不同的道具
	local nTaskCountInList = 0;	-- 记录列表中一共涉及到几种不同的任务变量的补偿
	for nId, tbParam in pairs(tbFile) do
		--如果填入的数据类型有误，则assert退出
		if nId == 1 then
			tbFileList[1] = {};
			
			local nItemCount = 1;
			while nItemCount do		
				-- 这要求配置表中道具的序列号必须从1开始且一定是连续的！！
				local szIndex = "Item"..nItemCount;
				if not tbParam[szIndex] then
					break;
				else
					tbFileList[1][szIndex] = self:TurnStrToNumTb(tbParam[szIndex] or ""); --itemi属性
				end
				nItemCount = nItemCount + 1;
			end
		
			nItemCountInList = nItemCount - 1;	-- 多加了一个1
			
			--others表示玩家可赔偿的方式，为必填项，如果没有该项，退出报错
			if not tbParam.others then
				return  "load error! [others] not exist!";
			else
				tbFileList[1][self.nOthersIndex] = self:TurnStrToNum(tbParam.others);
				if tbFileList[1][self.nOthersIndex] == 0 then 
					return "load error! first [others] value must be more than 0";
				end
			end
			
			-- 江湖威望，各种声望等的补偿信息
			local nTaskCount = 1;
			local tbReputeList = {}; 
			while nTaskCount do
				-- 这要求配置表中声望的序列号必须从1开始且一定是连续的！！
				local szIndex = "Ext"..nTaskCount;
				if not tbParam[szIndex] then
					break;
				else
					tbReputeList[nTaskCount] = self:TurnStrToNumTb(tbParam[szIndex]); --Exti属性
				end
				nTaskCount = nTaskCount + 1;
			end
			nTaskCountInList = nTaskCount - 1;
			tbFileList[1]["Ext"] = tbReputeList;			
		else	
			--GateWayName表示玩家所在服务器的网关名，为必填项，如果没有该项，退出报错
			if not tbParam.GateWayName then
				return "load error! [GateWayName] not exist!";
			end
			
			--如果表格文件中当前角色名的玩家的服务器网关名与当前的不同, 不做记录;相同才做记录
			if szCurSeverGateWayName == tbParam.GateWayName then						
				--如果表格文件中当前角色名的玩家的服务器网关名与当前的相同, 但在当前服务器中又找不到指定角色名的玩家时，做记录但要写LOG
				if not KGCPlayer.GetPlayerIdByName(tbParam.RoleName) then
					table.insert(szLogMsg, string.format("记录玩家\"%s\"的信息，但该玩家并不存在！", tbParam.RoleName));
				end
				
				if not tbFileList[tbParam.RoleName] then
					tbFileList[tbParam.RoleName] = {};
					
					-- 道具数据
					for i = 1, nItemCountInList do
						tbFileList[tbParam.RoleName][i] = (tbFileList[tbParam.RoleName][i] or 0) + self:TurnStrToNum(tbParam["Item"..i] or ""); --itemi个数
					end
					
					-- others			
					tbFileList[tbParam.RoleName][self.nOthersIndex] = (tbFileList[tbParam.RoleName][self.nOthersIndex] or 0) + self:TurnStrToNum(tbParam.others); --玩家所欠的其它价值量总数
					
					-- 声望数据
					for i = 1, nTaskCountInList do
						if not tbFileList[tbParam.RoleName]["Ext"] then
							tbFileList[tbParam.RoleName]["Ext"] = {};
						end
						tbFileList[tbParam.RoleName]["Ext"][i] = (tbFileList[tbParam.RoleName]["Ext"][i] or 0) + self:TurnStrToNum(tbParam["Ext"..i] or "");
					end

					nPlayerCount = nPlayerCount + 1;   --加载一条记录后，修改计数
				else
					--如果在同一个文件中同一个角色名有大于1条的记录，返回报错
					return "load error! rolename repetition!";
				end				
			end
		end
	end
 	
 	if nPlayerCount > 0 then
		-- self.tbBlackList = GetGblIntBuf(GBLINTBUF_BLACKLIST, 0);
		if not self.tbBlackList then
			self.tbBlackList = {};
		end
		self.tbBlackList[szIndex] = tbFileList;
		--写日志信息
		for _, szLog in pairs(szLogMsg) do
			Dbg:WriteLog("HoleSolution", szLog);
		end
	
		SetGblIntBuf(GBLINTBUF_BLACKLIST, 0, 1, self.tbBlackList); 
		self:LoadDataFromDataBase_GC(1);	  --要求所有GS同步数据
	end
	
	return  string.format("load success! Load %d record!", nPlayerCount);
end

--GC从数据库中读取数据
--bUpdateData 为1时表明不需要从数据库读数据,仅仅是GC和GS同步数据而已
function HoleSolution:LoadDataFromDataBase_GC(bUpdateData)
	bUpdateData = bUpdateData or 0;
	if bUpdateData ~= 1 then
		--GBLINTBUF_BLACKLIST全局GblIntBuf常量，表示BUF所在数据库索引值
		self.tbBlackList = GetGblIntBuf(GBLINTBUF_BLACKLIST, 0);
		if not self.tbBlackList then
			print("数据库数据为空，直接返回");
			return;
		end
	end

	if not self.tbBlackList then
		print("黑名单没有初始化，直接返回");
		return;
	end
		
	for szIndex, tbFileList in pairs(self.tbBlackList) do
		for szRecordKey, tbData in pairs(tbFileList) do 
			Dbg:WriteLog("HoleSolution", string.format("GC传送数据给GS：%s, %s", szIndex, tostring(szRecordKey)));
			GlobalExcute{"SpecialEvent.HoleSolution:UpdateDataFromGC", szIndex, szRecordKey, tbData};
		end
	end
end

--修改GC内存中的黑名单数据。
--bSetBuf为1时表明需要将数据写到数据库中，否则看计数器是否达到计数要求
function HoleSolution:ModifyData_GC(bSetBuf, szIndex, szRoleName)
	if not szIndex then
		return;
	end
	
	bSetBuf = bSetBuf or 0;
	
	--修改self.tbBlackList中的数据
	if szIndex and szRoleName then
		if not self.nCount then
			self.nCount = 0;   --用来计算已经处理了多少个玩家的数据
		end
		self.nCount = self.nCount + 1;
		Dbg:WriteLog("HoleSolution", string.format("GC删除黑名单条目——玩家对象为:%s", szRoleName));
		self.tbBlackList[szIndex][szRoleName] = nil;
		if self:IsTableNull(self.tbBlackList[szIndex]) == 1 then
			self.tbBlackList[szIndex] = nil;
			GlobalExcute{"SpecialEvent.HoleSolution:DelDataFromGC", szIndex};	--GC要求所有GS同步，删除该索引下的数据(删除一个文件的信息)
		else
			GlobalExcute{"SpecialEvent.HoleSolution:DelDataFromGC", szIndex, szRoleName};	--GC要求所有GS同步，删除该索引下的数据（只删除一条记录）
		end
	end
	
	--写数据库
	if bSetBuf == 1 or self.nCount%10 == 0 then
		self:SetBufToDataBase();
	end
end

--将内存中的黑名单数据写到数据库中
function HoleSolution:SetBufToDataBase()
	--GBLINTBUF_BLACKLIST全局GblIntBuf常量，表示BUF在数据库中的索引值
	if not self.tbBlackList then
		Dbg:WriteLog("HoleSolution", "黑名单数据未初始化，不能写入数据库！");
	else
		SetGblIntBuf(GBLINTBUF_BLACKLIST, 0, 1, self.tbBlackList);
	end
end

--0表示不等，1表示等
function HoleSolution:CompareTab(tb1, tb2)
	--不允许出现NIL值
	if not tb1 or not tb2 then
		return 0;
	end
	
	--只能比较表
	if type(tb1) ~= "table" or type(tb2) ~= "table" then
		return 0;
	end
	
	--先对两张表的长度进行判断
	--Lib:CountTB()已经考虑到了索引不连续的情况
	if Lib:CountTB(tb1)~= Lib:CountTB(tb2) then	
		return 0;
	end
	
	for i, v in pairs(tb1) do
		if not tb2[i] then
			return 0;
		end
		
		if type(v) ~= type(tb2[i]) then		--类型要相同
			return 0;
		elseif type(v) == "table" then		--如果两个类型都是表，递归一下
			local nRet = self:CompareTab(v, tb2[i]);
			if nRet == 0 then
				return 0;
			end
		elseif v ~= tb2[i] then		--不是表，直接比较两个值是否相等
			return 0;			
		end
	end
	
	return 1;
end

-- 合服操作
function HoleSolution:CoZoneUpdateBlackListBuf(tbCoZoneBlackListBuf)
	print("[CoZoneUpdateBlackListBuf] started!!!");
	self:LoadDataFromDataBase_GC();	
	if not self.tbBlackList then
		self.tbBlackList = {};
	end
	
	for szIndex, tbFileList in pairs(tbCoZoneBlackListBuf) do
		if self.tbBlackList[szIndex] then
			local tbTag_Buf = self.tbBlackList[szIndex][1];
			local tbTag_CoZone	= tbFileList[1];
			--两个文件的索引(szIndex)相同但TAG{tbItem1, tbItem2, tbItem3, tbItem4, tbItem5, nTaskVar}信息不同时在主服的BUF下
			--新加一个索引来保存从服的数据，但是实际情况下，这种情况是不应该出现的，因而写个日志
			if self:CompareTab(tbTag_CoZone, tbTag_Buf) ~= 1 then
				local szNewIndex = string.format("%s_c%s", szIndex, GetTime());
				self.tbBlackList[szNewIndex] = tbFileList;
				Dbg:WriteLog("[CoZoneUpdateBlackListBuf] Combine same index", string.format("the orginal index is [%s], the new index is [%s]", szIndex, szNewIndex));
			else			
				--两个文件可以合并，将CoZone里的数据加到tbBuf中
				for varIndex, tbData in pairs(tbFileList) do
					--只需要把玩家的信息加过去就可以了，玩家信息的索引都是string类型
					if type(varIndex) == "string" then
						if self.tbBlackList[szIndex][varIndex] then
							for i = 1, #tbData do
								--玩家的信息子表里存的都是数值，直接累加
								self.tbBlackList[szIndex][varIndex][i] = self.tbBlackList[szIndex][varIndex][i] + tbData[i] ;
							end
						else
							self.tbBlackList[szIndex][varIndex] = tbData;
						end
					end
				end
			end
		else
			self.tbBlackList[szIndex] = tbFileList;
		end
	end
	self:SetBufToDataBase();
end

function HoleSolution:_print(tbBuf)
	for p, v in pairs(tbBuf) do
		print("=========", p, v);
		if (type(v) == "table") then
			for p1, v1 in pairs(v) do
				print("--------", p1, v1);
				if (type(v1) == "table") then
					Lib:ShowTB(v1);
				end
			end
		end
	end
end

--注册在GC启动后执行从数据库读取黑名单数据的事件
GCEvent:RegisterGCServerStartFunc(SpecialEvent.HoleSolution.LoadDataFromDataBase_GC, SpecialEvent.HoleSolution);
--注册在GC正常关闭时将黑名单数据写入到数据库中的事件
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.HoleSolution.SetBufToDataBase, SpecialEvent.HoleSolution);

end		--if MODULE_GC_SERVER then
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
if MODULE_GAMESERVER then
	
--主动向GC索取数据
function HoleSolution:AskDataForGC()
	GCExcute{"SpecialEvent.HoleSolution:LoadDataFromDataBase_GC", 1};
end

--根据参数将指定索引的数据赋值
function HoleSolution:UpdateDataFromGC(szIndex, szRecordKey, tbData)
	if not self.tbBlackList then
		self.tbBlackList = {};
	end

	if not HoleSolution.tbBlackList[szIndex] then
		HoleSolution.tbBlackList[szIndex] = {};
	end
	
	HoleSolution.tbBlackList[szIndex][szRecordKey] = tbData;
end

--删除指定索引的一条记录或一个文件
--szRecordKey为nil时表示删除索引为szIndex的数据，如果两个参数都不为nil则删除第一重索引为szIndex第二重索引为szRecordKey的数据，
function HoleSolution:DelDataFromGC(szIndex, szRecordKey)
	--第一个参数不能为空
	if not szIndex then
		return;
	end
	
	--szRecordKey为nil时表示删除索引为szIndex的数据
	if not szRecordKey then
		HoleSolution.tbBlackList[szIndex] = nil;
		return;
	end
	
	--删除第一重索引为szIndex第二重索引为szRecordKey的数据
	HoleSolution.tbBlackList[szIndex][szRecordKey] = nil;
end

--判断玩家是否在黑名单中
function HoleSolution:IsPlayerInList()
	if not self.tbBlackList then
		return;
	end
	
	for szIndex, tbFileList in pairs(self.tbBlackList) do
		local tbItemTag = tbFileList[1];	--道具信息表
		--如果有该玩家的记录
		if tbFileList[me.szName] then
			--当两组任务变量中有空值或者该操作的选项值（tbItemTag[self.nOthersIndex]）与某组任务变量中的值相同时才进行操作
			--可以用来存储当前操作的任务变量索引（0、1、2），返回值大于0时表示可以进行操作
			local nTaskIndex = self:CanSetValue(tbItemTag[self.nOthersIndex]); 
			if nTaskIndex > 0 then
				local nBalanceValue = self:DeductIlleageItem(tbItemTag, tbFileList[me.szName]);
				GCExcute{"SpecialEvent.HoleSolution:ModifyData_GC", 0, szIndex, me.szName};	--通知GC修改数据
				if nBalanceValue > 0 then		
					self:SetTaskValue(nBalanceValue, tbItemTag[self.nOthersIndex], nTaskIndex);
				end
			end
		end
	end
	
	--若玩家已经在桃源中，不做操作；否则如果玩家有欠价值量，将他放入桃源
	local tbTaoYuanMapId = 
	{
		[1497] = 1, 
		[1498] = 1,
		[1499] = 1,
		[1500] = 1,
		[1501] = 1,
		[1502] = 1,
		[1503] = 1,
	}
	local nMapId = me.GetWorldPos();
	if self:GetBalanceValue() > 0 then
		if not tbTaoYuanMapId[nMapId] then
	 		Player:Arrest(me.szName);
	 		me.SetTask(self.TASK_COMPENSATE_GROUPID, self.TASK_SUBID_REASON, 1);	--在将玩家扔到桃源时，将原因设置到任务变量中
	   		KPlayer.SendMail(me.szName, "扣除非法物品", "由于你通过不合法的手段刷取个人财富，系统已经自动删除当前你仍持有的这些物品。");
	   		Dbg:WriteLog("HoleSolution", string.format("角色名为%s的玩家因为非法获得游戏财富被送入桃源。", me.szName));
	 	end
	end
end

-- 两个参数分别分：tbFile[1], tbFile[RoleName]
function HoleSolution:DeductIlleageItem(tbItemTag, tbSingleRecord)
	local nBalanceValue = 0;
	local nItemCount = 1;
	local nTaskCount = 1;
	
	-- 先扣除配置表中指定的道具
	-- 这要求配置表中道具的序列号必须从1开始且一定是连续的！！
	while tbItemTag["Item"..nItemCount] do
		local tbItemInfo = tbItemTag["Item"..nItemCount];
		local nValue = tbItemInfo[5];	--单个物品的价值量
		if tbSingleRecord[nItemCount] and tbSingleRecord[nItemCount] > 0 then			
			--先找出玩家拥有的该类型物品数量，再一一扣除
			local tbFind = GM:GMFindAllRoom({tbItemInfo[1], tbItemInfo[2], tbItemInfo[3], tbItemInfo[4]});
			for _, tbDelItem in pairs(tbFind) do
				tbSingleRecord[nItemCount] = GM:_ClearOneItem(tbDelItem.pItem, tbDelItem.pItem.IsBind(), tbSingleRecord[nItemCount]);
				if tbSingleRecord[nItemCount] == 0 then break end
			end
			--玩家物品不够扣
			if tbSingleRecord[nItemCount] > 0 then
				nBalanceValue = nBalanceValue + nValue * tbSingleRecord[nItemCount];
			end
		end
		
		nItemCount = nItemCount + 1;
	end
	
	-- 再扣除配置表上指定的声望及威望
	if tbItemTag["Ext"] then
		while tbItemTag["Ext"][nTaskCount] do
			local nGoupId, nSubId = tbItemTag["Ext"][nTaskCount][1], tbItemTag["Ext"][nTaskCount][2];
			if nGoupId == 0 and nSubId == 0 then   -- 江湖威望不是存在任务变量中的，需要特殊处理
				local nOrgPrestige = KGCPlayer.GetPlayerPrestige(me.nId);
				local nNewPrestige = nOrgPrestige - tbSingleRecord["Ext"][nTaskCount];
				-- 如果出现了不够扣的情况，现在是将它降到0，如果将来有把它转成价值量的想法，再做处理
				nNewPrestige = nNewPrestige > 0 and nNewPrestige or 0;
				KGCPlayer.SetPlayerPrestige(me.nId, nNewPrestige);
			else	-- 是各种类型的声望，都是存在任务变量里的
				local nOrgValue = me.GetTask(nGoupId, nSubId);
				local nNewValue = nOrgValue - tbSingleRecord["Ext"][nTaskCount];
				-- 如果出现了不够扣的情况，现在是将它降到0，如果将来有把它转成价值量的想法，再做处理
				nNewPrestige = nNewPrestige > 0 and nNewPrestige or 0;
				me.SetTask(nGoupId, nSubId, nNewValue);
			end
				
			nTaskCount = nTaskCount + 1;
		end
	end	
	
	-- others
	nBalanceValue = nBalanceValue + tbSingleRecord[self.nOthersIndex];
	return nBalanceValue;	
end

--第一个参数表示欠的价值量，第二个表示可赔偿方式，第三个表示提供给使用的任务数组索引
function HoleSolution:SetTaskValue(nValue, nTaskVar, nIndex)
	--先取出原来的值，先将值加入进去
	local nPreValue = me.GetTask(self.TASK_COMPENSATE_GROUPID, self.tbSubTaskGroup[nIndex][1]);
	me.SetTask(self.TASK_COMPENSATE_GROUPID, self.tbSubTaskGroup[nIndex][1], nPreValue + nValue);
	me.SetTask(self.TASK_COMPENSATE_GROUPID, self.tbSubTaskGroup[nIndex][2], nTaskVar);
end

--判定当前类型的赔偿方式是否可用,在tbSubTaskGroup数组中查找有没有可以使用的空间（有则返回空间的索引，否则返回0）
--先判断该类型是否可以叠加到某个已经使用的空间上（有相同的值）；再判断有没有空闲的空间（值为0）；否则不能使用
function HoleSolution:CanSetValue(nTaskVar)
	local nZeroIndex = 0;  --记录数组中第一组没有设定值的索引，在不能叠加的情况下返回该索引以供使用。
	for nIndex, tbGroup in pairs(self.tbSubTaskGroup) do
		local nPreValue = me.GetTask(self.TASK_COMPENSATE_GROUPID, tbGroup[2]);
		if nPreValue == nTaskVar then
			return nIndex;
		end
		--取出数组中第一组没有使用空间的索引
		nZeroIndex = (nZeroIndex == 0 and nPreValue == 0) and nIndex or nZeroIndex;
	end
	
	return nZeroIndex;  --如果没有可以使用的空间，则返回0。
end

PlayerEvent:RegisterOnLoginEvent(SpecialEvent.HoleSolution.IsPlayerInList, SpecialEvent.HoleSolution);
ServerEvent:RegisterServerStartFunc(SpecialEvent.HoleSolution.AskDataForGC, SpecialEvent.HoleSolution);

end  	--if MODULE_GAMESERVER then
--------------------------------------------------------------------------------------------
--将一个字符转化成数字, 做一些验证操作
function HoleSolution:TurnStrToNum(str)
	--当表文件中没有对某数字项填值时，则默认为0
	if str == "" then
		return 0;
	end
	
	local nNum = assert(tonumber(str));
	return nNum;
end

--将表文件中读出来的表示道具信息的字符串解析成一个整型数组。
function HoleSolution:TurnStrToNumTb(str)
	--当表文件中没有对某ITEM项填值时，读出来的字符串为空，这时返回一张空表。
	if str == "" then
		return nil;
	end
	
	local tbStr = Lib:SplitStr(str, "|");
		
	--数据被正确填入时，数组长度应该为5{g,d,p,l,nValue}。
	assert(tbStr);
	
	--将字符串表转换成整型表
	for index, szNum in pairs(tbStr) do
		tbStr[index] = tonumber(szNum);
		--如果不能转换成整型，则填入的数据类型有误
		assert(tbStr[index]);
	end
	
	return tbStr;
end

--统计玩家当前欠的价值量类型数量
function HoleSolution:GetPlayerDebetCount()
	local tbAllTaskVar, nCount = {}, 0;
	local tbBlackList = self.tbBlackList or {};
	for szIndex, tbFileList in pairs(tbBlackList) do
		if tbFileList[me.szName] and tbFileList[1][self.nOthersIndex] ~= 0 and not tbAllTaskVar[tbFileList[1][self.nOthersIndex]] then
			tbAllTaskVar[tbFileList[1][self.nOthersIndex]] = tbFileList[1][self.nOthersIndex];
			nCount = nCount + 1;
		end
	end
	
	for nIndex, tbGroup in pairs(self.tbSubTaskGroup) do
		local nArrearage = me.GetTask(self.TASK_COMPENSATE_GROUPID, tbGroup[1]);
		local nTaskVar = me.GetTask(self.TASK_COMPENSATE_GROUPID, tbGroup[2]);
		if nArrearage ~=0 and nTaskVar ~= 0 and not tbAllTaskVar[nTaskVar] then
			tbAllTaskVar[nTaskVar] = nTaskVar;
			nCount = nCount + 1;
		end
	end
	
	return nCount;
end

--返回指定黑名单指定索引的数据（为一张表）
--bDataBase为1时表明取数据库中的黑名单，否则取内存中的黑名单（默认值）
function HoleSolution:GetData(szIndex, bDataBase)
	local tbBlackList = {};
	bDataBase = bDataBase or 0;
	if bDataBase ~= 0 then
		tbBlackList = GetGblIntBuf(GBLINTBUF_BLACKLIST, 0);
	else
		tbBlackList = self.tbBlackList;
	end
		
	if not tbBlackList then
		return;
	end
	
	if szIndex then
		return tbBlackList[szIndex];
	end
end

--判断某个黑名单表里玩家的数据是否为空了。
--返回值： 1为真（空），0为假（不空）
function HoleSolution:IsTableNull(tbFileList)
	for key, tbData in pairs(tbFileList) do
		if key ~= 1 then
			return 0;
		end
	end
	
	return 1;
end
