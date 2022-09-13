------------------------------------------------------
-- 文件名　：itemtaskdatamgr.lua
-- 创建者　：dengyong
-- 创建时间：2012-02-28 15:19:58
-- 描  述  ：道具任务变量数据处理器
------------------------------------------------------
Item.TASKDATA_MAIN_STONE		= 1;	-- 宝石数据
Item.TASKDATA_MAIN_EQUIPEX		= 2;	-- 装备扩展信息

-- 装备扩展信息子ID
Item.ITEM_TASKVAL_EX_SUBID_ENHID		= 1;	-- 强化属性ID
Item.ITEM_TASKVAL_EX_SUBID_ExRefLevel	= 2;	-- 扩展炼化次数
Item.ITEM_TASKVAL_EX_SUBID_CastLevel	= 3;	-- 精铸级别

Item.tbTaskDataLen = 
{
	[Item.TASKDATA_MAIN_STONE] 		= 6;
	[Item.TASKDATA_MAIN_EQUIPEX]	= 3;
}


function Item:GetItemTaskData(pItem)
	if not pItem then
		return;
	end
	
	local tbTaskData = pItem.GetTaskDataTable();
	if not tbTaskData or Lib:CountTB(tbTaskData) == 0 then
		return;
	end
	
	local tbRet = {};
	for i, v in pairs(tbTaskData) do
		-- key由两部分数据处理，低16位是主任务ID，高16们是副任务ID
		local mainKey = Lib:LoadBits(i, 0, 15);
		local subKey = Lib:LoadBits(i, 16, 31);
		
		tbRet[mainKey] = tbRet[mainKey] or {};
		tbRet[mainKey][subKey] = v;		
	end
	
	return tbRet;
end

-- 设置孔的数据，需要两个值，是否特殊孔和孔的等级
function Item:SetEquipHoleTask(tbInfo, nHoleIdx, bSpeical, nHoleLevel)
	local nValue = Lib:SetBits(nHoleLevel, bSpeical, 8, 31);
	
	local nIndex = nHoleIdx * 2 - 1;
	tbInfo[nIndex] = nValue;
	return tbInfo;
end

-- 设置宝石的数据，需要宝石的g,d,p,l
-- g:8Bits 0~7, d:4Bits 8~11, p:12Bits 12~23, l:18bit 24~31 
function Item:SetEquipStoneTask(tbInfo, nHoleIdx, g, d, p, l)
	local nValue = 0;
	nValue = Lib:SetBits(nValue, g, 0, 7);
	nValue = Lib:SetBits(nValue, d, 8, 11);
	nValue = Lib:SetBits(nValue, p, 12, 23);
	nValue = Lib:SetBits(nValue, l, 24, 31);
	
	local nIndex = nHoleIdx * 2;
	tbInfo[nIndex] = nValue;
	return tbInfo;
end

-- 注意，因为这里不太好检查参数，所以请在调用的地方确保参数正确
function Item:SetItemTaskValue(tbInfo, nMainKey, nSubKey, varValue)
	if not tbInfo then
		return;
	end
	
	tbInfo[nMainKey] = tbInfo[nMainKey] or {};
	-- 原来已经就有值，检查一下类型是匹配
	if tbInfo[nMainKey][nSubKey] then
		local var = tbInfo[nMainKey][nSubKey];
		if type(var) ~= type(varValue) then   -- 逻辑上不允许改变数据的类型
			assert(false, "Invalid data type!");
			return;		-- 故意返回nil,表示执行有误	
		end
	end
	
	tbInfo[nMainKey][nSubKey] = varValue;
	return tbInfo;
end

-- 要填充成完整的表
function Item:FullFilTable(tbInfo)
	if not tbInfo then
		return;
	end
	
	for i = self.TASKDATA_MAIN_STONE, self.TASKDATA_MAIN_EQUIPEX do
		if not tbInfo[i] then
			tbInfo[i] = {};
		end
		
		for j = 1, self.tbTaskDataLen[i] do 
			if not tbInfo[i][j] then
				tbInfo[i][j] = 0;
			end
		end
	end
	
	return tbInfo;
end