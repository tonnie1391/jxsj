-- 文件名　：vneventfun.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 17:30:30
--越南服务器限制产出道具通用脚本

SpecialEvent.tbEventFun_vn = SpecialEvent.tbEventFun_vn or {};
local tbEventFun_vn = SpecialEvent.tbEventFun_vn;

--变量集
tbEventFun_vn.tbGlobalTaskInt = {
	{DATASK_VN_BENXIAO_LAST_DAY, DATASK_VN_BENXIAO_ALL_COUNT},
	{DBTASK_VN_BENXIAO_LAST_DAY_YH, DBTASK_VN_BENXIAO_ALL_COUNT_YH},	
	{DBTASK_VN_BENXIAO_LAST_DAY_GP, DBTASK_VN_BENXIAO_ALL_COUNT_GP},
	{DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY, DBTASD_EVENT_VN_HUANGJINBAIYIN_ALL},
	}

--对应变量的限制总数量
tbEventFun_vn.tbGlobalTaskIntLimit = {
	{1, 10},
	{1, 5},	
	}


--对应上面每个变量的具体
tbEventFun_vn.tbMsg = {
	{"%s打开干粮袋子获得奔宵马牌，真是鸿运当头呀！","[越南5月活动]打开干粮袋子获得奔宵马牌"},
	{"%s打开功勋箱获得翻羽马牌，真是鸿运当头呀！","[越南5月活动]打开功勋箱获得翻羽马牌"},
	}

tbEventFun_vn.tbItem = {
	{1, 12, 35, 4, 1, 1,180*24*3600},
	{1, 12, 33, 4, 1, 0,0},
	}

if MODULE_GC_SERVER then

tbEventFun_vn.Global_Pici = 2;		--全局变量批次

--越南活动全局变量重置

function tbEventFun_vn:GCStartFunction()
	local nFlag = KGblTask.SCGetDbTaskInt(DBTASK_VN_TASKID_PICI);
	if nFlag ~= self.Global_Pici then
		for _,tbGlobalTaskInt in pairs(self.tbGlobalTaskInt) do
			KGblTask.SCSetDbTaskInt(tbGlobalTaskInt[1], 0);
			KGblTask.SCSetDbTaskInt(tbGlobalTaskInt[2], 0);
		end		
	end
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbEventFun_vn.GCStartFunction,SpecialEvent.tbEventFun_vn);

--gc获得服务器产出量限制物品接口
function tbEventFun_vn:IsGetHorse(nPlayerId, nType)
	local tbGlobalTaskInt = self.tbGlobalTaskInt[nType];
	local tbGlobalTaskIntLimit = self.tbGlobalTaskIntLimit[nType];	
	if not tbGlobalTaskInt or not tbGlobalTaskIntLimit then		
		GlobalExcute{"SpecialEvent.tbEventFun_vn:OnSpecialAward",nPlayerId, nType};
		return;
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = math.floor(KGblTask.SCGetDbTaskInt(tbGlobalTaskInt[1]) / 100);
	local nCount = math.fmod(KGblTask.SCGetDbTaskInt(tbGlobalTaskInt[1]), 100) + 1;
	local nAllCount = KGblTask.SCGetDbTaskInt(tbGlobalTaskInt[2]) + 1;
	if nNowDate ~= nDate then
		nCount = 1;
	end	
	if nCount <= tbGlobalTaskIntLimit[1] and nAllCount <= tbGlobalTaskIntLimit[2] then
		GlobalExcute{"SpecialEvent.tbEventFun_vn:OnSpecialAward",nPlayerId, nType, 1};
		KGblTask.SCSetDbTaskInt(tbGlobalTaskInt[1], nNowDate*100 + nCount);
		KGblTask.SCSetDbTaskInt(tbGlobalTaskInt[2], nAllCount);
	else
		GlobalExcute{"SpecialEvent.tbEventFun_vn:OnSpecialAward",nPlayerId, nType};
	end
end

end

if MODULE_GAMESERVER then
	
function tbEventFun_vn:OnSpecialAward(nPlayerId, nType, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end	
	pPlayer.AddWaitGetItemNum(-1);	
	local tbMsg = self.tbMsg[nType];
	local tbItem = self.tbItem[nType];
	if not tbMsg or not tbItem then		
		return;
	end
	if nFlag then
		for i = 1 , tbItem[5] do
			local pItem = pPlayer.AddItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
			if pItem then
				if tbItem[6] == 1 then
					pItem.Bind(1);
				end
				if tbItem[7] > 0 then
					pItem.SetTimeOut(0, GetTime() + tbItem[7]);
					pItem.Sync();
				end				
			end
		end
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format(tbMsg[1], pPlayer.szName));
		Dbg:WriteLog(tbMsg[2]);
	end	
end

end