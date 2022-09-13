-- 文件名　：aprilevent_vn.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 09:15:38
-- 四月版本活动


SpecialEvent.tbAprilEvent_vn = SpecialEvent.tbAprilEvent_vn or {};
local tbAprilEvent_vn = SpecialEvent.tbAprilEvent_vn;
tbAprilEvent_vn.nOpenDate 		= 20100506	--开始日期
tbAprilEvent_vn.nCloseDate 		= 20100530	--结束日期
tbAprilEvent_vn.tbHorse_BX 		= {1, 12, 35, 4};	--奔宵马GDPL
tbAprilEvent_vn.tbHorse_FY 		= {1, 12, 33, 4};	--翻羽马GDPL
tbAprilEvent_vn.nRandom_BX 	= 5;			--奔宵马的概率（1-10000）
tbAprilEvent_vn.nRandom_FY 	= 1;			--奔宵马的概率（1-100000）
tbAprilEvent_vn.nRandom_QhYt 	= 1;			--情花和穿珠银帖的概率（1-100000）
tbAprilEvent_vn.nMaxAllCount	= 100;		--水袋子和干粮袋子最大使用数
tbAprilEvent_vn.nMaxDayCount	= 15;			--水袋子和干粮袋子每天最大使用数
tbAprilEvent_vn.nMaxHorse		= 5;			--服务器最大马牌数

tbAprilEvent_vn.tbQingHua		= {18,1,597,1,{}, 9999};	--9999情花
tbAprilEvent_vn.tbChuanZhu		= {18,1,541,4,{},1};		--穿珠银帖
tbAprilEvent_vn.tbKaiXunWine	= {18, 1, 1272, 1};		--凯旋酒

tbAprilEvent_vn.nMaxChangeWineDay	= 20;		--兑换凯旋酒每天数量
tbAprilEvent_vn.nMaxChangeWineAll	= 100;		--活动期间兑换凯旋酒数量

--task
tbAprilEvent_vn.TASK_GID 				= 2147;		--任务组
tbAprilEvent_vn.TASK_TASKID_S			= 37;			--水袋子数量
tbAprilEvent_vn.TASK_TASKID_S_DAY		= 38;		--水袋子日期
tbAprilEvent_vn.TASK_TASKID_S_ALL		= 39;		--水袋子总
tbAprilEvent_vn.TASK_TASKID_G			= 40;		--干粮袋子数量
tbAprilEvent_vn.TASK_TASKID_G_DAY	= 41;			--干粮袋子日期
tbAprilEvent_vn.TASK_TASKID_G_ALL		= 42;		--干粮袋子总
tbAprilEvent_vn.TASK_TASKID_WINE		= 43;		--兑换酒数量
tbAprilEvent_vn.TASK_TASKID_WINE_DAY	= 44;		--兑换酒数量日期
tbAprilEvent_vn.TASK_TASKID_WINE_ALL	= 45;		--总兑换酒数量

if MODULE_GC_SERVER then

--情花和穿珠银贴
function tbAprilEvent_vn:IsGetHorse_QhYt(nPlayerId)
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate_Q = KGblTask.SCGetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_GP);
	local nAllCountQ = KGblTask.SCGetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_GP) + 1;
	local nDate_C = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY);
	local nAllCountC = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_ALL) + 1;
	if nNowDate ~= nDate_Q and nAllCountQ <= self.nMaxHorse then
		GlobalExcute{"SpecialEvent.tbAprilEvent_vn:OnSpecialAward_QhYt",nPlayerId, 1};
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_GP, nNowDate);
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_GP, nAllCountQ);
	elseif nNowDate ~= nDate_C and nAllCountC <= self.nMaxHorse then
		GlobalExcute{"SpecialEvent.tbAprilEvent_vn:OnSpecialAward_QhYt",nPlayerId, 2};
		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY, nNowDate);
		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_VN_HUANGJINBAIYIN_ALL, nAllCountC);
	else
		GlobalExcute{"SpecialEvent.tbAprilEvent_vn:OnSpecialAward_QhYt",nPlayerId};
	end
end

end


if MODULE_GAMESERVER then

function tbAprilEvent_vn:OnSpecialAward_QhYt(nPlayerId, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	pPlayer.AddWaitGetItemNum(-1);
	if nFlag then
		local pItem =nil;
		if nFlag == 1 then
			pPlayer.AddStackItem(unpack(self.tbQingHua));
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("%s摆放胜利宴席获得9999情花，真是鸿运当头呀！", pPlayer.szName));
			Dbg:WriteLog("[越南5月活动]摆放胜利宴席获得9999情花");
		else
			pPlayer.AddStackItem(unpack(self.tbChuanZhu));
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("%s摆放胜利宴席获得1个穿珠银贴，真是鸿运当头呀！", pPlayer.szName));
			Dbg:WriteLog("[越南5月活动]摆放胜利宴席获得穿珠银贴");
		end
	end
end

--酒箱换凯旋酒
function tbAprilEvent_vn:ChangeWine()	
	Dialog:OpenGift("请放入1箱50瓶的酒", nil,{self.OnOpenGiftOk, self});
	return;
end

function tbAprilEvent_vn:OnOpenGiftOk(tbItemObj)
	if Lib:CountTB(tbItemObj) ~= 1 then
		me.Msg("你放入的物品不对。");
		return 0;
	end
	for _, pItem in pairs(tbItemObj) do			
		local szItem		= string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if "18,1,189,2" ~= szItem then
			me.Msg("你放入的物品不对。");
			return 0;
		end
		local nCount =  pItem[1].GetGenInfo(1);
		local nCountFirst= pItem[1].GetExtParam(1);
		if not nCount or not nCountFirst or nCount > 0 or nCountFirst ~= 50 then
			me.Msg("我想你这箱酒不足50瓶吧。");
			return 0;
		end		
	end
	for _, pItem in pairs(tbItemObj) do
		pItem[1].Delete(me);
	end
	for i =1, 3 do
		local pItem = me.AddItem(unpack(self.tbKaiXunWine));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 30*24*3600);
			pItem.Sync();
		end
	end
	return 1;
end

function tbAprilEvent_vn:OnDialog()	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	
	local nCountS = me.GetTask(self.TASK_GID, self.TASK_TASKID_S);
	local nDateS = me.GetTask(self.TASK_GID, self.TASK_TASKID_S_DAY);
	local nCountSALL = me.GetTask(self.TASK_GID, self.TASK_TASKID_S_ALL);
	
	local nCountG = me.GetTask(self.TASK_GID, self.TASK_TASKID_G);
	local nDateG = me.GetTask(self.TASK_GID, self.TASK_TASKID_G_DAY);
	local nCountGALL = me.GetTask(self.TASK_GID, self.TASK_TASKID_G_ALL);
	
	local nCountW = me.GetTask(self.TASK_GID, self.TASK_TASKID_WINE);
	local nDateW = me.GetTask(self.TASK_GID, self.TASK_TASKID_WINE_DAY);
	local nCountWALL = me.GetTask(self.TASK_GID, self.TASK_TASKID_WINE_ALL);
	
	local nCountChaqi = me.GetTask(2143, 32);
	local nCountDateChaqi = me.GetTask(2143, 31);
	local nCountAllChaqi = me.GetTask(2143, 33);
	if nDateS ~= nDate then
		nCountS = 0;
	end
	if nDateG ~= nDate then
		nCountG = 0;
	end
	if nDateW ~= nDate then
		nCountW = 0;
	end
	if nCountDateChaqi ~= nDate then
		nCountChaqi = 0;
	end
	local szMsg = string.format("你今天使用的<color=green>水袋子<color>数量：<color=yellow>%s<color>\n活动期间已经使用的<color=green>水袋子<color>数量：<color=yellow>%s<color>\n你今天使用的<color=green>干粮袋子<color>数量：<color=yellow>%s<color>\n活动期间已经使用的<color=green>干粮袋子<color>数量：<color=yellow>%s<color>\n你今天使用的<color=green>凯旋酒<color>数量：<color=yellow>%s<color>\n活动期间使用的<color=green>凯旋酒<color>数量：<color=yellow>%s<color>\n\n你今天<color=green>插旗子<color>数量：<color=yellow>%s<color>\n活动期间<color=green>总插旗子<color>数量：<color=yellow>%s<color>\n", nCountS, nCountSALL, nCountG, nCountGALL, nCountW, nCountWALL, nCountChaqi, nCountAllChaqi);
	Dialog:Say(szMsg);
	return;
end

end