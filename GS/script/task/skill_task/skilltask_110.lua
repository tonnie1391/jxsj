-------------------------------------------------------
-- 文件名　：skilltask_110.lua
-- 文件描述：110级技能获得任务中Nộp vật phẩm脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2009-07-27 08:37:35
-------------------------------------------------------

local tbNpc = Npc:GetClass("npc_110");

-- 所需物品及个数
local REQUIRE_ITEM = { 
			[1] = 
			{
				{
					{
						string.format("%s,%s,%s,%s", 18, 1, 205, 1),
					}, 
					800
				},
			},
			[3] = 
			{
				{
					{
						string.format("%s,%s,%s,%s", 18, 1, 200, 1),
						string.format("%s,%s,%s,%s", 18, 1, 201, 1),
						string.format("%s,%s,%s,%s", 18, 1, 202, 1),
						string.format("%s,%s,%s,%s", 18, 1, 203, 1),
						string.format("%s,%s,%s,%s", 18, 1, 204, 1),
					}, 
					5,
				},
				{
					{
						string.format("%s,%s,%s,%s", 18, 1, 263, 1),
						string.format("%s,%s,%s,%s", 18, 1, 264, 1),
						string.format("%s,%s,%s,%s", 18, 1, 265, 1),
						string.format("%s,%s,%s,%s", 18, 1, 266, 1),
						string.format("%s,%s,%s,%s", 18, 1, 267, 1),
					}, 
					5,
				},
			},
		};

local NPC_TASKID = {
		[3511] = 203,
		[3502] = 204,
		[3517] = 205,
		[3521] = 206,
		[3529] = 207,
		[3535] = 208,
		[3539] = 209,
		[3544] = 210,
		[3550] = 211,
		[3559] = 212,
		[3478] = 213,
		[3497] = 214,
	};
	
function tbNpc:OnDialog()
	if (not NPC_TASKID[him.nTemplateId]) then
		return;
	end;
	
	local nValue = me.GetTask(1022, NPC_TASKID[him.nTemplateId]);

	if (nValue ~= 1 and nValue ~= 3) then
		local tbOpt = {{"Kết thúc đối thoại"}};
		local szMsg = "<color=red>" .. me.szName .. "<color>, xin chào!";
		Dialog:Say(szMsg, tbOpt);
		return;
	end;
	
	local tbOpt = {
			{"Nộp vật phẩm", self.TakeInItem, self, nValue, NPC_TASKID[him.nTemplateId]},
			{"Kết thúc đối thoại"},
		}
	local szMsg = "Nộp vật phẩm";
	Dialog:Say(szMsg, tbOpt);
end;

function tbNpc:TakeInItem(nValue, nTaskId)
	local szMsg = "Nộp vật phẩm";
	if (nValue == 1) then
		szMsg = "Hãy đặt vào 800 Ngũ Hành Hồn Thạch";
	end;
	if (nValue == 3) then
		szMsg = "Hãy đặt vào\n 5 thành phẩm tranh đoạt\n 5 thành phẩm tiêu dao cốc"
	end; 
	Dialog:OpenGift(szMsg, nil, {self.OnOpenGiftOk, self, nValue, nTaskId});
end;

function tbNpc:OnOpenGiftOk(nValue, nTaskId, tbItemObj)
	local tbItemList	= {};
		
	for _, pItem in pairs(tbItemObj) do
		if (self:ChechItem(pItem, REQUIRE_ITEM[nValue], tbItemList) ~= 1) then
			me.Msg("Vật phẩm không phù hợp!");
			return 0;
		end;
	end

	local bResult 	= false;
	for i = 1, #REQUIRE_ITEM[nValue] do
		if (REQUIRE_ITEM[nValue][i][2] ~= tbItemList[i]) then
			bResult = true;
		end;
	end;
	
	if (bResult) then
		me.Msg("Số lượng không đúng!");
		return 0;
	end;
	
	for _, pItem in pairs(tbItemObj) do
		if me.DelItem(pItem[1]) ~= 1 then
			return 0;
		end
	end
	
	if (nValue == 1) then
		me.SetTask(1022, nTaskId, 2);
	end;
	
	if (nValue == 3) then
		me.SetTask(1022, nTaskId, 4);
	end;
end;

-- 检测是否是需要的物品
function tbNpc:ChechItem(pItem, tbItemList, tbCountList)
	if (not pItem) then
		return 0;
	end;
	local szItem		= string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
	
	for i = 1, #tbItemList do
		local tbI = tbItemList[i];
		for j = 1, #tbI[1] do
			if (szItem == tbI[1][j]) then
				tbCountList[i] = (tbCountList[i] or 0) + pItem[1].nCount;
				return 1;
			end;
		end;
	end;

	return 0;
end;