-------------------------------------------------------------------
--File: 	equipitembox.lua
--Author: 	zhouchenfei
--Date: 	2011/3/24 17:29:07
--Describe:	获取装备宝箱物品，通用脚本
--第一个扩展参数代表随机表中的第几组
--只挂服务端


local tbEquipBox = Item:GetClass("equipitembox");
tbEquipBox.SZITEMFILE = "\\setting\\item\\001\\other\\equipitembox.txt";
function tbEquipBox:OnUse()	
	if self.tbItemList == nil then
		self.tbItemList = self:GetItemList();
	end
	local nKind = tonumber(it.GetExtParam(1));

	return self:SureOnUse(nKind, it.dwId);
end

function tbEquipBox:SureOnUse(nKind, dwItemId)
	local tbItemBox = self.tbItemList[nKind];
	if (not tbItemBox) then
		print("[ERROR] equipbox is not exit ", nKind);
		Dialog:Say("物品不存在，请联系管理员！");
		return;
	end
	
	local szDesc = tbItemBox.szDesc;
	local tbItemList = tbItemBox.tbItemList;
	local nSex = me.nSex;
	
	-- 如果是性别通用的那么就显示通用的
	if (tbItemList[2] and Lib:CountTB(tbItemList[2]) > 0) then
		nSex = 2;
	end
	
	local tbSeriesItem = tbItemList[nSex];

	local szMsg = string.format("通过%s你将获得下列物品中的一种，请选择：", szDesc);
	local tbOpt = {};
	
	for nIndex, tbInfo in pairs(tbSeriesItem) do
		table.insert(tbOpt, {string.format("<color=yellow>%s（%s）<color>", KItem.GetNameById(tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4]), Env.SERIES_NAME[nIndex]), self.OnGetItem, self, dwItemId, nKind, nSex, nIndex});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});

	Dialog:Say(szMsg, tbOpt);

end

function tbEquipBox:OnGetItem(dwItemId, nKind, nSex, nIndex, nFlag)
	-- 到这儿应该说明都正确的，还有异常干脆就直接报错吧
	local tbItemBox = self.tbItemList[nKind];	
	local szDesc = tbItemBox.szDesc;
	local tbSeriesItem = tbItemBox.tbItemList[nSex];

	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return 0;
	end

	if me.CountFreeBagCell() < 1 then
		Dialog:Say((string.format("你的背包不足，需要%s格背包空间。", 1)));
		return 0;
	end
	
	local tbInfo = tbSeriesItem[nIndex];

	local szItemName = KItem.GetNameById(tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4]);

	if (not nFlag or nFlag ~= 1) then
		Dialog:Say(string.format("您选择获取<color=yellow>%s（%s）<color>，确定吗？", szItemName, Env.SERIES_NAME[nIndex]), 
			{
				{"Xác nhận", self.OnGetItem, self, dwItemId, nKind, nSex, nIndex, 1},
				{"Để ta suy nghĩ thêm"},	
			});
		return;
	end

	local pIt = me.AddItem(tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4]);
	if (not pIt) then
		Dbg:WriteLog("Item", "EquipItembox", me.szName, szItemName, "Get Failed!!!!!!!!!!!!!");
	end
	
	if (pIt and tbInfo[5] == 1) then
		pIt.Bind(1);
	end
	
	pItem.Delete(me);
end

function tbEquipBox:GetItemList()
	local tbsortpos = Lib:LoadTabFile(self.SZITEMFILE);
	local nLineCount = #tbsortpos;
	local tbClassItemList = {};
	
	for nLine=2, nLineCount do
		local nClassParamID = tonumber(tbsortpos[nLine].ClassParamID);
		local szName = tbsortpos[nLine].Name;
		local szDesc = tbsortpos[nLine].Desc;
		local nSex	 = tonumber(tbsortpos[nLine].Sex) or 2;
		local nGenre = tonumber(tbsortpos[nLine].Genre);
		local nDetailType = tonumber(tbsortpos[nLine].DetailType);
		local nParticularType = tonumber(tbsortpos[nLine].ParticularType);
		local nLevel = tonumber(tbsortpos[nLine].Level);
		local nSeries = tonumber(tbsortpos[nLine].Series);
		local nBind = tonumber(tbsortpos[nLine].Bind) or 0;
		
		if tbClassItemList[nClassParamID] == nil then
			tbClassItemList[nClassParamID] = {};
			tbClassItemList[nClassParamID].tbItemList = {};
		end
		if (szDesc and szDesc ~= "") then
			tbClassItemList[nClassParamID].szDesc = szDesc;
		end
		if (nSex) then
			if (not tbClassItemList[nClassParamID].tbItemList[nSex]) then
				tbClassItemList[nClassParamID].tbItemList[nSex] = {};
			end
		end

		if (nSeries and nDetailType and nParticularType and nLevel and nGenre) then
			tbClassItemList[nClassParamID].tbItemList[nSex][nSeries] = {nGenre, nDetailType, nParticularType, nLevel, nBind};
		end
	end
	return tbClassItemList;
end

tbEquipBox.tbItemList = tbEquipBox:GetItemList()
