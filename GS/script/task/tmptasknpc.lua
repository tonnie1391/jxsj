
Task.DestroyItem = Task.DestroyItem or {};
Task.DestroyItem.tbGiveForm = Gift:New();

local tbDestroyForm = Task.DestroyItem.tbGiveForm;

tbDestroyForm._szTitle = "销毁任务道具";
tbDestroyForm._szContent = "请放入要毁的任务道具";

Task.DESTROY_ITEM_LIST_FILE = "\\setting\\task\\itemdestroylist.txt";

-- 弹给与界面
function tbDestroyForm:OnOK()
	local nDel = 0;
	local nNDel = 0;
	local pFind = self:First();
	while pFind do
		if (Task:CheckCanDestroy(pFind) == 1) then
			me.DelItem(pFind, Player.emKLOSEITEM_TYPE_DESTROY);
			nDel = 1;
		else
			nNDel = 1;
		end
		pFind = self:Next();
	end
	
	if (nDel == 1 and nNDel == 1) then
		me.Msg("部分非任务道具不能销毁！");
	elseif (nDel == 0 and nNDel == 1) then
		me.Msg("只能销毁任务道具！");
	end 
end;


function Task:_OnLoginTempLogic()
	local pPlayer = me;
	if (self:HaveDoneSubTask(pPlayer, tonumber("A0", 16), tonumber("13C", 16)) == 1 or
		self:HaveDoneSubTask(pPlayer, tonumber("9E", 16), tonumber("13A", 16)) == 1 or 
		Task:HaveDoneSubTask(pPlayer, tonumber("9F", 16), tonumber("13B", 16)) == 1) then
			pPlayer.SetTask(1021, 8, 1, 1);
		end
		
	if (Task:HaveDoneSubTask(pPlayer, tonumber("1", 16), tonumber("1", 16)) == 1 or
		Task:HaveDoneSubTask(pPlayer, tonumber("6", 16), tonumber("34", 16)) == 1 or 
		Task:HaveDoneSubTask(pPlayer, tonumber("A", 16), tonumber("4B", 16)) == 1) then
			pPlayer.SetTask(1022, 108, 1, 1)
		end
		
end

-- 加载可销毁的非任务道具列表
function Task:LoadDestroyItemList()
	local tbFile = Lib:LoadTabFile(self.DESTROY_ITEM_LIST_FILE);
	if not tbFile then
		return;
	end
	
	self.tbDestroyItemList = {};
	for _, tbData in pairs(tbFile) do
		local szGDPL = string.format("%s,%s,%s,%s", tbData.G, tbData.D, tbData.P, tbData.L);
		local bLimitBind = tonumber(tbData.bBind) or -1;
		
		self.tbDestroyItemList[szGDPL] = bLimitBind;
	end
end

-- 是否是可销毁
function Task:CheckCanDestroy(pItem)
	local nRet = 0;
	
	self.tbDestroyItemList = self.tbDestroyItemList or {};
	if pItem.szClass == "taskitem" then
		nRet = 1;	-- 任务道具可销毁
	else
		local bLimitBind = self.tbDestroyItemList[pItem.SzGDPL()];
		if bLimitBind and (bLimitBind == -1 or bLimitBind == pItem.IsBind()) then
			nRet = 1;
		end
	end	
	
	return nRet;
end	

Task:LoadDestroyItemList();
PlayerEvent:RegisterGlobal("OnLogin", Task._OnLoginTempLogic, Task);
