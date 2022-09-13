------------------------------------------------------
-- 文件名　：switchbind.lua
-- 创建者　：dengyong
-- 创建时间：2010-08-30 17:43:44
-- 功能    ：装备绑定类型切换
------------------------------------------------------
Require("\\script\\partner\\define.lua");
Require("\\script\\item\\zhenyuan\\zhenyuan_define.lua");
Require("\\script\\item\\stone\\define.lua")

-- 装备类型定义
Item.SWITCHBIND_PARTNEREQUIP 	= 1;	-- 同伴装备
Item.SWITCHBIND_ZHENYUAN		= 2;	-- 真元
Item.SWITCHBIND_STONE			= 3;	-- 宝石

-- 操作类型定义
Item.SWITCHBIND_UNBIND			= 0;    -- 解绑操作
Item.SWITCHBIND_BIND			= 1; 	-- 申绑操作

Item.tbEquipSwitchBind = 
{
	[Item.SWITCHBIND_PARTNEREQUIP] =
	{
		checkfun = "IsPartnerEquip",	-- 类型检查函数
		szTip = "同伴装备",
		[Item.SWITCHBIND_UNBIND] = 
		{
			nCount = 1, 
			-- 主任务变量id,子任务变量id,起效时间，失效时间
			checktime = 
			{
				Partner.TASK_BIND_PARTNEREQ_GROUPID, Partner.TASK_BIND_PARTNEREQ_SUBID,
				Partner.BIND_PARTNERQUIP_MINTIME, Partner.BIND_PARTNERQUIP_MAXTIME
			},
			fnPostCallBack = "Partner:PostUnBind",
			fnExtCheckCallBack = "Partner:SwitchUnBind_Check",
		},
		[Item.SWITCHBIND_BIND] = { nCount = 16 }, 		-- 申绑没有限制，不需要检查时间
	},
	[Item.SWITCHBIND_ZHENYUAN] = 
	{
		checkfun = "IsZhenYuan",
		szTip = "真元",
		[Item.SWITCHBIND_UNBIND] = 
		{
			nCount = 5, 
			checktime = 
			{
				Item.tbZhenYuan.TASK_GID_UNBIND, Item.tbZhenYuan.TASK_SUBID_UNBIND,
				Item.tbZhenYuan.UNBIND_MIN_TIME, Item.tbZhenYuan.UNBIND_MAX_TIME
			},
			fnPostCallBack = "Item.tbZhenYuan:PostUnBind",
			fnExtCheckCallBack = "Item.tbZhenYuan:SwitchBind_Check",	-- 扩展检查函数
		},
		[Item.SWITCHBIND_BIND] = {nCount = 5},		
	},
	[Item.SWITCHBIND_STONE] =
	{
		checkfun = "GetStoneType",
		szTip = "宝石",
		[Item.SWITCHBIND_UNBIND] =  -- 解绑
		{
			nCount = 5,
			checktime = 
			{
				Item.tbStone.TASK_GID_UNBIND, Item.tbStone.TASK_SUBID_UNBIND,
				Item.tbStone.UNBIND_MIN_TIME, Item.tbStone.UNBIND_MAX_TIME,
			},
			fnPostCallBack = "Item.tbStone:PostUnBind",
			fnExtCheckCallBack = "Item.tbStone:SwitchBind_Check",
		},		
	},
}

Item.tbOperateStr = 
{
--操作类型 操作类型TIP 需求道具的绑定类型字符串 需求道具绑定类型INT
	[Item.SWITCHBIND_UNBIND] = {"解绑", "已绑定", 1},
	[Item.SWITCHBIND_BIND] = {"申绑", "未绑定", 0},
}

-- 打开解绑或申绑的给予界面
-- 参数1表示操作类型：0解绑，1申绑；参数2表示要操作的装备类型：1同伴装备，2真元
function Item:SwitchBindGift_Trigger(nPlayerId, nOpType, nEquipType)
	if not self.tbEquipSwitchBind[nEquipType] or not self.tbEquipSwitchBind[nEquipType][nOpType] then
		return;
	end
	
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	-- 配置项中有checktime，表示需要检查时间
	local tbCheckTime = self.tbEquipSwitchBind[nEquipType][nOpType].checktime;
	if (tbCheckTime) then
		local nApplyTime = pPlayer.GetTask(tbCheckTime[1], tbCheckTime[2]);
		if (nApplyTime == 0 or GetTime() - nApplyTime < tbCheckTime[3] or
			GetTime() - nApplyTime > tbCheckTime[4]) then
			me.Msg("尚未到可操作时间，请稍等。");
			return;
		end
	end	
	
	local szMsg = string.format("放入你想要%s的%s吧，最多可放入%d个。", 
		self.tbOperateStr[nOpType][1], 
		self.tbEquipSwitchBind[nEquipType].szTip,
		self.tbEquipSwitchBind[nEquipType][nOpType].nCount);
	Dialog:OpenGift(szMsg, {"Item:SwitchBindGift_Check", nOpType, nEquipType}, 
		{self.SwitchBindGift_OK, self, nOpType, nEquipType});
end

-- 给予界面客户端放入道具检查函数
function Item:SwitchBindGift_Check(tbGiftSelf, pPickItem, pDropItem, nX, nY, nOpType, nEquipType)
	
	if pDropItem then
		local szExtCheckFun = self.tbEquipSwitchBind[nEquipType][nOpType].fnExtCheckCallBack;
		if szExtCheckFun then
			local _, nRet = Lib:CallBack({szExtCheckFun, pDropItem});
			if nRet == 0 then
				return 0;
			end
		end
		local nCount = 0;
		local pItem = tbGiftSelf:First();
		while(pItem) do
			nCount = nCount + 1;
			pItem = tbGiftSelf:Next();
		end
				
		if (nCount > self.tbEquipSwitchBind[nEquipType][nOpType].nCount - 1) then
			me.Msg(string.format("一次最多只能%s%d件%s的%s！", 
				self.tbOperateStr[nOpType][1],
				self.tbEquipSwitchBind[nEquipType][nOpType].nCount,
				self.tbOperateStr[nOpType][2],
				self.tbEquipSwitchBind[nEquipType].szTip)
			);
			return 0;
		end
	
		local szCheckFun = self.tbEquipSwitchBind[nEquipType].checkfun;	
		if szCheckFun and pDropItem[szCheckFun]() == 0 or
			pDropItem.IsBind() ~= self.tbOperateStr[nOpType][3] then
			me.Msg(string.format("只能放入%s的%s！", 
				self.tbOperateStr[nOpType][2],
				self.tbEquipSwitchBind[nEquipType].szTip)
			);
			return 0;
		end
	end	
	
	return 1;
end

-- 给予界面服务端确定执行函数
function Item:SwitchBindGift_OK(nOpType, nEquipType, tbItemObj)	
	if (Lib:CountTB(tbItemObj) > self.tbEquipSwitchBind[nEquipType][nOpType].nCount or
		Lib:CountTB(tbItemObj) <= 0) then
		return;
	end

	local nSucCount = 0;
	local szCheckFun = self.tbEquipSwitchBind[nEquipType].checkfun;
	local szExtCheckFun = self.tbEquipSwitchBind[nEquipType][nOpType].fnExtCheckCallBack;
	for i, tbItem in pairs(tbItemObj) do
		if szExtCheckFun then
			local _, nRet = Lib:CallBack({szExtCheckFun, tbItem[1]});
			if nRet == 0 then
				break;
			end
		end

		if (not szCheckFun or tbItem[1][szCheckFun]() == 1) then
			tbItem[1].Bind(nOpType);		-- 修改绑定类型
			tbItem[1].Sync();
			nSucCount = nSucCount + 1;
			self:SwitchBindLog(tbItem[1], nOpType);
		else
			Partner:SendClientMsg(string.format("只能放入%s！", self.tbEquipSwitchBind[nEquipType].szTip));
			break;
		end
	end

	local szfun = self.tbEquipSwitchBind[nEquipType][nOpType].fnPostCallBack;
	if szfun and nSucCount > 0 then
		Lib:CallBack({szfun, nSucCount});
	end
end

function Item:SwitchBindLog(pItem, nOpType)
	if (pItem.IsZhenYuan() == 1 and nOpType == self.SWITCHBIND_UNBIND) then
		Dbg:WriteLog("真元解绑", me.szName, string.format("真元：%s, 价值量：%d，真元星级：%d_%d_%d_%d", pItem.szName, 
			Item.tbZhenYuan:GetZhenYuanValue(pItem), Item.tbZhenYuan:GetAttribPotential1(pItem), 
			Item.tbZhenYuan:GetAttribPotential2(pItem), Item.tbZhenYuan:GetAttribPotential3(pItem),
			Item.tbZhenYuan:GetAttribPotential4(pItem))
		);
	end
end
