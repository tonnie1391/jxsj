-------------------------------------------------------------------
--File: 	eventpart.lua
--Author: sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统
--InterFace1:Init(...) 初始化数据
--InterFace2:CreatePart() 建立小活动类.
--InterFace3:
-------------------------------------------------------------------
local EventPart = {}
EventManager.EventPart = EventPart;

function EventPart:Init(tbEvent, tbEventPart, bGmCmd)
	--初始化数据
	self.tbEvent = tbEvent;
	
	self.tbEventPart = tbEventPart;
--	self.tbEventPart.nId 			= tbEventPart.nId;
--	self.tbEventPart.szName 		= tbEventPart.szName;
--	--self.tbEventPart.szKind 		= tbEventPart.szKind;
--	self.tbEventPart.szSubKind 		= tbEventPart.szSubKind;
--	self.tbEventPart.szExClass		= tbEventPart.szExClass;
--	self.tbEventPart.nStartDate 	= tbEventPart.nStartDate;
--	self.tbEventPart.nEndDate 		= tbEventPart.nEndDate;
--	self.tbEventPart.tbParam		= tbEventPart.tbParam;
--  self.tbEventKind = nil;
--  self.EventSubKindMergeTable  = nil;
	self.tbDialog = {};
	self.tbTimer = {};
	self.tbNpcDrop = {};
	self:CreatePart(bGmCmd);
	self:CreateDialog();
	self:CreateTimer();
	self:CreateNpcDrop();
end

function EventPart:CreatePart(bGmCmd)
	--根据基类创建
	--虚函数
	--local szKind = self.tbEventPart.szKind; 
	local szSubKind = self.tbEventPart.szSubKind
	--if EventManager.EventKind[szKind] == nil then
	--	print("【活动系统出错】表中没有该类别:", szKind);
	--	return 1;
	--end
	local tbSubClass = EventManager.EventKind.Module[szSubKind];
	if not tbSubClass then
		print("【活动系统出错】表中没有该子类别,默认使用default类别", szSubKind);
		tbSubClass = EventManager.EventKind.Module.default;
		--return 1;
	end
	
	--GC调用定时器类,其他类GC不读取.(所有base文件放GCGS,该判断可删除)
--	if (MODULE_GC_SERVER) then
--		local tbTimerS 	= EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "TimerStart", 1);
--		local tbTimerE	= EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "TimerEnd", 1);
--		local tbDropNpcS = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "DropNpc", 1);
--		local tbDropNpcT = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "DropNpcType", 1);
--		if #tbTimerS == 0  and #tbTimerE == 0 and #tbDropNpcS == 0 and 	#tbDropNpcT == 0 and szSubKind ~= "Default" then
--			return 1;
--		end
--	end
	
	--基类EventPart函数
	self.tbEventKind = self.tbEventKind or Lib:NewClass(EventManager.EventKindBase);
	self.tbEventKind.SubKind = {};
	--基类SubClass函数
	self.EventSubKindMergeTable = self.EventSubKindMergeTable or Lib:NewClass(tbSubClass);
	
	Lib:MergeFunTable(self.tbEventKind.SubKind, self.EventSubKindMergeTable);
	
	self.tbEventKind:Init(self.tbEvent, self.tbEventPart, bGmCmd);
	
	--扩展函数
	local szExClass = self.tbEventPart.szExClass;
	if szExClass ~= "" and szExClass ~= nil then
		if EventManager.EventKind.ExClass[szExClass] == nil then
			EventManager.EventKind.ExClass[szExClass] = {};
		end
		Lib:MergeFunTable(self.tbEventKind.SubKind, EventManager.EventKind.ExClass[szExClass]);
		Lib:MergeFunTable(EventManager.EventKind.ExClass[szExClass], self.tbEventKind);
		Lib:MergeFunTable(EventManager.EventKind.ExClass[szExClass], self.tbEventKind.SubKind);
		EventManager.EventKind.ExClass[szExClass].GetParam = EventManager.tbFun.GetSelfParam;
	end
end

function EventPart:CreateDialog()
	local tbKindDialog = self.tbEventKind.tbDialog;
	if tbKindDialog ~= nil and #tbKindDialog ~= 0 then
		--把对话插入tbDialog中.
		for nNpc, tbItem in pairs(tbKindDialog) do
			local tbDialog = {nNpcId = tbItem.varNpc, tbDialog = tbItem.tbDialog, tbPartTime = {self.tbEventPart.nStartDate, self.tbEventPart.nEndDate}};
			table.insert(self.tbDialog, tbDialog);
		end
	end
end

function EventPart:CreateTimer()
	local tbKindTimer = self.tbEventKind.tbTimer;
	if tbKindTimer ~= nil then
		if #tbKindTimer.tbStartTime ~= 0 or #tbKindTimer.tbEndTime ~= 0 then
			local tbTimer = {tbStartTime = tbKindTimer.tbStartTime, tbEndTime = tbKindTimer.tbEndTime};
			table.insert(self.tbTimer, tbTimer);
		end
	end
end

function EventPart:CreateNpcDrop()
	local tbKindNpcDrop = self.tbEventKind.tbNpcDrop;
	if tbKindNpcDrop ~= nil and #tbKindNpcDrop ~= 0 then
		--把对话插入tbDialog中.
		for nNpc, tbItem in pairs(tbKindNpcDrop) do
			local tbNpcDrop = {nId = self.tbEventPart.nId, nNpcId = tbItem.nNpcId, szNpcName = tbItem.szNpcName, tbFun = tbItem.tbFun, nStartDate = self.tbEventPart.nStartDate, nEndDate = self.tbEventPart.nEndDate};
			table.insert(self.tbNpcDrop, tbNpcDrop);
		end
	end
end

function EventPart:GetDialog()
	return self.tbDialog;
end

function EventPart:GetTimer()
	return self.tbTimer;
end

function EventPart:GetNpcDrop()
	return self.tbNpcDrop;
end
