-------------------------------------------------------
-- 文件名　：qiandaizi.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-03-20 17:21:44
-- 文件描述：剑网转剑世相关--奖励钱袋子
-------------------------------------------------------

Require("\\script\\event\\manager\\define.lua");

-- 定义标示名字："\\setting\\item\\001\\other\scriptitem.txt"
local tbQianDaiziItem = Item:GetClass("qiandaizi");

-- 定义奖励类型
tbQianDaiziItem.AWARD_COIN_G	= 1;	-- 绑定金币
tbQianDaiziItem.AWARD_MONEY_G	= 2;	-- 绑定银两
tbQianDaiziItem.AWARD_MONEY_S	= 3;	-- 不绑定银两

function tbQianDaiziItem:OnUse()
	
	-- 奖励空了，则干掉钱袋子物件
	if me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_COIN_G) <= 0
	and me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_G) <= 0
	and me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_S) <= 0 then
		me.Msg("你的钱袋子使用完毕已经消失。");
		return 1;
	end
	
	-- 条件选项：
	-- 1. 领取绑定金币；2. 领取绑定银两；3. 领取银两；4. 我又不想领了
	-- *保存物件ID：it.dwId，传递给后面操作，不能用self
	local tbOpt = {
		{"领取绑定金币", self.OnUseTakeOut, self, self.AWARD_COIN_G, it.dwId},
		{"领取绑定银两", self.OnUseTakeOut, self, self.AWARD_MONEY_G, it.dwId},
		{"领取银两", self.OnUseTakeOut, self, self.AWARD_MONEY_S, it.dwId},
		{"我又不想领了"},
	}
	
	-- 读玩家身上任务标记
	local szMsg = string.format("钱总是不够用。不过您的钱袋子，目前还有些钱：\n\n" 
		.."<color=yellow>\t绑定金币：\t%d\n<color>" 
		.."<color=yellow>\t绑定银两：\t%d\n<color>" 
		.."<color=yellow>\t银两：\t%d\n<color>",
		me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_COIN_G),
		me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_G),
		me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_S)
		);
		
	Dialog:Say(szMsg, tbOpt);
	
	-- 不自动删除
	return 0;
end

-- 取出奖励，按种类选择
function tbQianDaiziItem:OnUseTakeOut(nType, nItemId)
	
	-- 数字对话框最大数量
	local nMaxTakeOutCount = 0;
	local szMsg = "你的钱袋子中已经没有";
	
	-- 判断取出奖励类型，分别设置
	if nType == self.AWARD_COIN_G then
		nMaxTakeOutCount = me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_COIN_G);
		szMsg = string.format(szMsg.."绑定金币。");
		
	elseif nType == self.AWARD_MONEY_G then
		nMaxTakeOutCount = me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_G);
		szMsg = string.format(szMsg.."绑定银两。");
	
	elseif nType == self.AWARD_MONEY_S then
		nMaxTakeOutCount = me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_S);
		szMsg = string.format(szMsg.."银两。");
		
	else
		return 0;
	end
	
	if nMaxTakeOutCount <= 0 then
		Dialog:Say(szMsg, {"Ta hiểu rồi"});
		return 0;
	end
	
	-- 会不会有啥作用域的因素？
	Dialog:AskNumber("请输入取出的数量：", nMaxTakeOutCount, self.OnUseTakeOutSure, self, nType, nItemId);
end

-- 发送奖励
function tbQianDaiziItem:OnUseTakeOutSure(nType, nItemId, nTakeOutCount)
		
	-- 加强检查一下
	if nTakeOutCount <= 0 then
		return 0;
	end
	
	-- 通过物品ID找到物件对象
	local pItem = KItem.GetObjById(nItemId);
	
	-- 找不到返回
	if not pItem then
		return 0;
	end
	
	-- 绑定金币
	if nType == self.AWARD_COIN_G then
		
		-- 取当前记录
		local nCount = me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_COIN_G)
	
		-- 加强判定
		if nTakeOutCount > nCount then
			return 0;
		end
		
		-- 设置余额
		me.SetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_COIN_G, nCount - nTakeOutCount);	
	
		-- 增加绑金
		me.AddBindCoin(nTakeOutCount, Player.emKBINDCOIN_ADD_CHANGELIFE);
		
		Dbg:WriteLog("SpecialEvent.ChangeLive", "剑网转剑世", me.szAccount, me.szName, "获得绑定金币："..nTakeOutCount);
				
	-- 绑定银两
	elseif nType == self.AWARD_MONEY_G then
	
		-- 取当前记录
		local nCount = me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_G)
	
		-- 加强判定
		if nTakeOutCount > nCount then
			return 0;
		end
		
		-- 判断是否会超过绑定银两携带上限
		if nTakeOutCount + me.GetBindMoney() > me.GetMaxCarryMoney() then
			Dialog:Say(string.format("对不起，领取后，您身上的绑定银两将会达到上限，请整理后再来领取。")); 	
			return 0;
		end
		
		-- 设置余额
		me.SetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_G, nCount - nTakeOutCount);	
	
		-- 增加绑银
		me.AddBindMoney(nTakeOutCount, Player.emKBINDMONEY_ADD_CHANGELIVE);
		
		Dbg:WriteLog("SpecialEvent.ChangeLive", "剑网转剑世", me.szAccount, me.szName, "获得绑定银两："..nTakeOutCount);
			
	-- 非绑定银两
	elseif nType == self.AWARD_MONEY_S then
	
		-- 取当前记录
		local nCount = me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_S)

		-- 加强判定
		if nTakeOutCount > nCount then
			return 0;
		end
		
		-- 判断是否出超出银两携带上限	
		if nTakeOutCount + me.nCashMoney > me.GetMaxCarryMoney() then
			Dialog:Say(string.format("对不起，领取后，您身上的银两将会达到上限，请整理后再来领取。"));
			return 0;
		end
		
		-- 设置余额
		me.SetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_S, nCount - nTakeOutCount);	
	
		-- 增加银两: 第二个参数形式为：Player.emXXX，定义在"\\script\\player\\define.lua"
		me.Earn(nTakeOutCount, Player.emKEARN_CHANGELIVE_MONEY);
		
		Dbg:WriteLog("SpecialEvent.ChangeLive", "剑网转剑世", me.szAccount, me.szName, "获得银两："..nTakeOutCount);
	end
	
	-- 用光了则销毁掉
	if me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_COIN_G) <= 0
	and me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_G) <= 0
	and me.GetTask(SpecialEvent.ChangeLive.TASKGID, SpecialEvent.ChangeLive.TASK_CHANGELIVE_MONEY_S) <= 0 then
		pItem.Delete(me);
		me.Msg("你的钱袋子使用完毕已经消失。");
	end
end