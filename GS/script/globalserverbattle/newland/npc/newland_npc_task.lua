-------------------------------------------------------
-- 文件名　：newland_npc_task.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-10-07 17:22:06
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbNpc = Npc:GetClass("newland_npc_task");

tbNpc.TASK_GID 				= 1025;			-- 令牌任务组ID
tbNpc.TASK_CHENGZHU_SHOP 	= 17;			-- 开启城主商店
tbNpc.TASK_SHIWEI_SHOP		= 18;			-- 开启侍卫商店
tbNpc.TASK_IS_FINSH 		= 19;			-- 城主交和氏璧的数目是否够200(0 or 1)
tbNpc.TASK_GID_CCHENGZHU	= 2125			-- 城主令牌任务交和氏璧任务组
tbNpc.TASK_ALREADY_NUM 		= 21			-- 城主交和氏璧的数目
tbNpc.NeedNum 				= 10;			-- 需要的和氏璧数目
tbNpc.szItemGDPL 			= "18,1,377,1";	-- 和氏璧GDPL
tbNpc.nTaskID 				= 471;			-- 城主任务ID
tbNpc.tbShop 				= {173, 174};	-- 侍卫马店173，城主马店174

function tbNpc:OnDialog()
	
	local szMsg = "Ai sẽ khóc, ai sẽ cười khi hiệp sĩ như người đã nằm xuống?\n\n";
	local tbOpt = {{"Ta hiểu rồi"}};
	
	if me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 then		
		table.insert(tbOpt, 1, {"Mua phi phong Trục Nhật", self.GetPiFengAward, self, 2});
	end
	if me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 then		
		table.insert(tbOpt, 1, {"Mua phi phong Lăng Thiên", self.GetPiFengAward, self, 1});
	end
	
	if me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 and
		me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 then
		szMsg = szMsg .. "Ngươi có thể mua phi phong <color=yellow>Trục Nhật và Lăng Thiên<color>. ";
	elseif me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 then
		szMsg = szMsg .. "Nhận tư cách mua phi phong <color=yellow>Trục Nhật<color>. ";
	elseif me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 then
		szMsg = szMsg .. "Nhận tư cách mua <color=yellow>Lăng Thiên<color>. ";
	end
	
	local nLevel, nState, nTime = me.GetSkillState(1629);
	if nLevel == 1 and nTime > 0 then
		szMsg = szMsg .. "Nhận tư cách mua chiến mã <color=yellow>Trục Nhật<color>.";
		table.insert(tbOpt, 1, {"Mua Trục Nhật", self.OpenHorseShop, self, 1});
	end
	
	local nLevel2, nState2, nTime2 = me.GetSkillState(2000);
	if nLevel2 == 2 and nTime2 > 0 then
		szMsg = szMsg .. "Nhận tư cách mua chiến mã <color=yellow>Lăng Thiên<color>.";
		table.insert(tbOpt, 1, {"Mua Lăng Thiên", self.OpenHorseShop, self, 2});
	end
	
	if Task:GetPlayerTask(me).tbTasks[self.nTaskID] and Task:GetPlayerTask(me).tbTasks[self.nTaskID].nCurStep == 5 then
		szMsg = szMsg .. " Có thể giao nộp Hòa Thị Bích hoàn thành nhiệm vụ <color=yellow>Khải Hoàn Thiết Phù Thành<color>";
		table.insert(tbOpt, 1, {"<color=yellow>Nộp Hòa Thị Bích<color>", self.HandInHeshibi, self});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OpenHorseShop(nLevel)
	me.OpenShop(self.tbShop[nLevel], 3);
end

function tbNpc:GetPiFengAward(nId)
	if me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 and nId == 1 then		
		me.OpenShop(172, 3);
	end
	if me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 and nId == 2  then
		me.OpenShop(171, 3);
	end	
end

function tbNpc:HandInHeshibi()
	if not Task:GetPlayerTask(me).tbTasks[self.nTaskID] and Task:GetPlayerTask(me).tbTasks[self.nTaskID].nCurStep == 5 then
		Dialog:Say("Không có nhiệm vụ <color=yellow>Khải Hoàn Thiết Phù Thành<color>, không thể giao vật phẩm", {"Ta hiểu rồi"});	
		return 0;
	end
	if me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM) >= self.NeedNum then
		Dialog:Say("Ngươi đã nộp đủ Hòa Thị Bích rồi!", {"Ta hiểu rồi"});	
		return 0;
	end
	local nCount = me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM);
	local szContent = string.format("Hãy đặt Hòa Thị Bích vào\nĐã nộp %s, cần nộp thêm %s.", nCount, self.NeedNum - nCount);
	Dialog:OpenGift(szContent, nil, {self.OnOpenGiftOk, self});
end

function tbNpc:OnOpenGiftOk(tbItemObj)
	local nAlreadyCount = me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM);
	local nNeedCount = self.NeedNum - nAlreadyCount;
	for _, tbItem in pairs(tbItemObj) do
		local szItemInfo = string.format("%s,%s,%s,%s", tbItem[1].nGenre, tbItem[1].nDetail, tbItem[1].nParticular, tbItem[1].nLevel);
		if szItemInfo ~= self.szItemGDPL then
			Dialog:Say("Vật phẩm không chính xác!", {"Ta hiểu rồi"});
			return 0;
		end
	end
	local nCount = 0;
	for _, tbItem in pairs(tbItemObj) do
		nCount = nCount + tbItem[1].nCount;
	end
	if nNeedCount < nCount then
		Dialog:Say("Số lượng không đúng!", {"Ta hiểu rồi"});
		return 0;
	end
	for _, tbItem in pairs(tbItemObj) do
		tbItem[1].Delete(me);
	end
	me.SetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM, me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM) + nCount);
	if me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM) >= self.NeedNum then
		me.SetTask(self.TASK_GID, self.TASK_IS_FINSH, 1);
	end
	EventManager:WriteLog(string.format("[铁浮城城主令牌任务]上交和氏璧%s", nCount), me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[铁浮城城主令牌任务]上交和氏璧%s", nCount));	
end
