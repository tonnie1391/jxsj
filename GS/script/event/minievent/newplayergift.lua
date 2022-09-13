--新手礼包：福利版推出后，所有新玩家可以领取一个新手礼包，每到一定等级均可从新手礼包中获得一定数量的金钱级道具奖励，总价值100RMB+

SpecialEvent.NewPlayerGift = {};
local NewPlayerGift = SpecialEvent.NewPlayerGift;
NewPlayerGift.IS_OPEN	= EventManager.IVER_bOpenNewPlayerGift;
NewPlayerGift.TASK_GROUP_ID = 2034;
NewPlayerGift.TASK_CURRENT_INDEX = 10;

NewPlayerGift.OPEN_DAY = 365 * 10; --开服n天内建的角色才有礼包

NewPlayerGift.SERVER_OPEN_DAY = 20080101; -- 这天之后开的服才能

NewPlayerGift.SHOW_OPTION_UNTIL = 20090825; -- 只在这天之前显示选项


NewPlayerGift.tbData = {
	[1] = {1, -- 所需等级
		{{18,1,195,1},1, nil, 7*24*60}, -- {{物品GDPL}, 个数, GenInfo(可选), 时限}
		},
	[2] = {10, 
		{{18,1,85,1},1},
		},
	[3] = {20,
		{{18,1,71,2},2},
		{{18,1,392,1},2,10},
		},
	[4] = {30,
		{{18,1,113,1},1},
		{{18,1,2,3},1},
		},
	[5] = {40,
		{"BindCoin",1000},
		{{18,1,114,4},10, nil, 30*24*60}
		},
	[6] = {50,
		{{21,5,1,1},1},
		{"BindMoney", 200000},
		},
	[7] = {60,
		{"BindCoin", 2000},
		{{18,1,393,1},5},
		},
	[8] = {69,
		{{18,1,114,7},2, nil, 30*24*60},
		{{18,1,394,1},5},
		},
	[9] = {79,
		{{18,1,394,1},10},
		{{18,1,212,1},2},
		},
	[10] = {89,
		{{18,1,394,1},10},
		{{18,1,212,1},3},
		},
	[11] = {99,
		{{18,1,395,1},2},
		},
};

-- 台湾版改动
if (IVER_g_nTwVersion == 1) then
NewPlayerGift.tbData = {
	[1] = {1, -- 所需等级
		{{18,1,71,1},2},
		{{18,1,195,1},1,nil,7*24*60}, -- 一周无限传送符
		{"BindCoin",50},
		{"BindMoney", 500},
		},
	[2] = {10, 
		{{18,1,71,1},3},
		{{18,1,77,1},2},	-- 铜钥匙
		{{18,1,85,1},1},	-- 乾坤符
		{"BindCoin",100},
		{"BindMoney", 1000},
		},
	[3] = {20,
		{{18,1,114,2},10},	-- 2级玄晶
		{{18,1,24,1},3},	-- 九转续命丸
		{{18,1,71,1},3},
		{"BindCoin",200},
		{"BindMoney", 2000},		
		},
	[4] = {30,
		{{18,1,114,3},10},	-- 3级玄晶
		{{18,1,258,1},2},	-- 修炼丹
		{{18,1,113,1},1},	-- 小传声海螺
		{"BindCoin",300},
		},
	[5] = {40,
		{{18,1,114,4},10},	-- 4级玄晶
		{{18,1,258,1},2},	-- 修炼丹
		{{18,1,85,1},1},	-- 乾坤符
		{{18,1,2,3},1},		-- 金犀3级
		{"BindCoin",400},
		},
	[6] = {50,
		{{18,1,258,1},3},	-- 修炼丹
		{{21,3,1,1},1},		-- 8格包
		{{18,1,113,1},1},	-- 小传声海螺
		{{18,1,195,1},1,nil,7*24*60}, -- 一周无限传送符
		{"BindCoin", 500},
		},
	[7] = {60,
		{{18,1,114,5},5},	-- 5级玄晶
		{{18,1,82,1},3},	-- 银钥匙
		{{18,1,244,1},1},	-- 魂石箱（100）
		{{18,1,195,1},1,nil,7*24*60}, -- 一周无限传送符
		{"BindCoin", 600},
		},
	[8] = {69,
		{{18,1,114,6},3},	-- 6级玄晶
		{{18,1,82,1},3},	-- 银钥匙
		{{18,1,258,1},3},	-- 修炼丹
		{{18,1,2,4},1},		-- 金犀4级
		{{18,1,195,1},1,nil,7*24*60}, -- 一周无限传送符
		{"BindCoin", 700},
		},
	[9] = {79,
		{{18,1,114,6},5},	-- 6级玄晶
		{{18,1,258,1},3},	-- 修炼丹
		{{18,1,212,1},2},	-- 初级祈福令牌
		{{18,1,244,1},1},	-- 魂石箱（100）
		{{18,1,195,1},1,nil,7*24*60}, -- 一周无限传送符
		{"BindCoin", 800},
		},
	[10] = {89,
		{{18,1,187,1},2},	-- 金钥匙
		{{18,1,212,1},2},	-- 初级祈福令牌
		{{18,1,114,6},2},	-- 6级玄晶
		{{18,1,195,1},1,nil,7*24*60}, -- 一周无限传送符
		{{18,1,85,1},1},	-- 乾坤符
		{{18,1,244,1},10},	-- 魂石箱（100）
		{"BindCoin", 900},
		},
	[11] = {99,
		{{18,1,187,1},3},	-- 金钥匙
		{{18,1,212,1},3},	-- 初级祈福令牌
		{{18,1,114,6},3},	-- 6级玄晶
		{{18,1,195,1},1,nil,7*24*60}, -- 一周无限传送符
		{{18,1,85,1},1},	-- 乾坤符
		{{18,1,244,1},10},	-- 魂石箱（100）
		{"BindCoin", 2000},
		},
};	
end

NewPlayerGift.tbNeededSpace = {};
NewPlayerGift.tbLevel = {};
NewPlayerGift.tbAward = {}

function NewPlayerGift:Init()
	for i, tb in ipairs(self.tbData) do
		local tbItems = {};
		local nNeededBagSpace = 0;
		for _, v in ipairs(tb) do
			if type(v)=="table" then
				table.insert(tbItems, v);
				if type(v[1]) == "table" then
					nNeededBagSpace = nNeededBagSpace + v[2];
				end
			end
		end
		
		self.tbLevel[i] = tb[1];
		self.tbNeededSpace[i] = nNeededBagSpace;
		self.tbAward[i] = tbItems;
	end
end

if EventManager.IVER_bOpenZaiXian == 0 or EventManager.IVER_bOpenZaiXian4 == 0  then
	NewPlayerGift:Init();
end

function NewPlayerGift:GetCurrData(pPlayer)
	local nIndex =  pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX);	
	if nIndex >= #self.tbData + 1 then
		return nil;
	end
	
	if nIndex == 0 then
		nIndex = 1;
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, 1);
	end	
	return self.tbLevel[nIndex], self.tbNeededSpace[nIndex], self.tbAward[nIndex];
end

function NewPlayerGift:CanGetAward(pPlayer)
	local nLevel, nNeededSpace, tbItems = self:GetCurrData(pPlayer);
	if not nLevel then
		return 0, "你已经领到这个礼包里面的所有礼物啦！";
	end
	
	if me.nLevel < nLevel then
		return 0, string.format("你需要达到%d级才能再领礼物。", nLevel);
	end
	
	if me.CountFreeBagCell() < nNeededSpace then
		return 0, string.format("Hành trang không đủ chỗ trống，请空出%d格之后再开启", nNeededSpace);
	end
	return 1;
end

function NewPlayerGift:GetAward(pPlayer, pItem)
	local nRes, szMsg = self:CanGetAward(pPlayer);
	if nRes == 0 then
		return 0, szMsg;
	end
	
	local nLevel, nNeededSpace, tbItems = self:GetCurrData(pPlayer);
	local tbAddedItem = {};
	local szAward = "";
	for _, tbItem in ipairs(tbItems) do
		if tbItem[1] == "BindCoin" then
			pPlayer.AddBindCoin(tbItem[2], Player.emKBINDCOIN_ADD_EVENT);
			szAward = szAward .. "绑定".. IVER_g_szCoinName .. tbItem[2] .. ",";
			KStatLog.ModifyAdd("bindcoin", "[产出]新手礼包", "总量", tbItem[2]);
		elseif tbItem[1] == "BindMoney" then
			pPlayer.AddBindMoney(tbItem[2], Player.emKBINDMONEY_ADD_EVENT);
			szAward = szAward .. "绑银" .. tbItem[2] .. ",";
			KStatLog.ModifyAdd("bindjxb", "[产出]新手礼包", "总量", tbItem[2]);
		else
			for i = 1, tbItem[2] do
				local pItem = pPlayer.AddItem(unpack(tbItem[1]));
				if tbItem[3] then
					--pItem.SetGenInfo(1, tbItem[3]);
					--pItem.Sync();
				end
				if tbItem[4] and tbItem[4] ~= 0 then
					pPlayer.SetItemTimeout(pItem, tbItem[4], 0)
				end
				pItem.Bind(1);
				Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, "升级奖励", pItem);
				szAward = szAward .. pItem.szName .. ",";
			end
		end
	end
	
	Dbg:WriteLog("SpecialEvent.NewPlayerGift", string.format("%s 获得新手礼包%d级物品：%s", me.szName, nLevel, szAward));
	local nIndex =  pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX);
	nIndex = nIndex + 1;
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, nIndex);
	if pItem then
		if self.tbLevel[nIndex] then
			pItem.SetGenInfo(1, self.tbLevel[nIndex]);
			pItem.Sync();
		end
		if nIndex >= #self.tbData + 1 then
			pItem.Delete(pPlayer);
			pPlayer.Msg("恭喜你达到99级，你已经领到这个礼包里面的所有礼物！");
		end
	end
	return 1;
end

-- 在这个时间之前建的号可以可以给礼包
function NewPlayerGift:GetCreateRoleDeadline()
	local nServerStartTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	return nServerStartTime + self.OPEN_DAY * 86400;
end

function NewPlayerGift:ShowOption()
	if GetTime() <= Lib:GetDate2Time(self.SHOW_OPTION_UNTIL) and
		self.SERVER_OPEN_DAY <= tonumber(os.date("%Y%m%d", KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))) then
		return 1;
	end
		
end

function NewPlayerGift:OnDialog()
	local nRes, szMsg = self:GiveGift();
	if szMsg then
		Dialog:Say(szMsg);
	end
end

function NewPlayerGift:GiveGift()
	if self.IS_OPEN ~= 1 then
		return 0;
	end

	if (IVER_g_nTwVersion == 0) then
		--6月5号后开的服
		if tonumber(os.date("%Y%m%d", KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))) < self.SERVER_OPEN_DAY then
			return 0, "本服务器不参与新手礼包活动";
		end
		
		--福利版已开启
		if SpecialEvent:IsWellfareStarted_Remake() ~= 1 then
			return 0, "福利版功能尚未开启,敬请期待。";
		end
		
		local nCreateTime = tonumber(me.GetRoleCreateDate());
		local nDeadline = self:GetCreateRoleDeadline();
		
		--开服20内建的角色
		if tonumber(os.date("%Y%m%d", nDeadline)) < nCreateTime then
			local tbTime = os.date("*t", nDeadline);
			return 0, string.format("只有在%d年%d月%d日之前创建的角色才能够拿到新手礼包。", tbTime.year, tbTime.month, tbTime.day);
		end
		
		if me.GetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX) ~= 0 then
			return 0, "你已经领取过新手礼包了。";
		end
	end
	
	if me.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ 1 chỗ trống"
	end
	
	local pItem = me.AddItem(18, 1, 351, 1);
	if pItem then
		me.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, 1);
		pItem.SetGenInfo(1, self.tbLevel[1]);
		pItem.Sync();
		Dbg:WriteLog("SpecialEvent.NewPlayerGift", string.format("%s 获得新手礼包", me.szName));
	end
	
	return 1;
end

local tbGift = Item:GetClass("newplayergift"); 
tbGift.WULINSHIJIA_STARTTIME = 20090922;  
tbGift.WULINSHIJIA_ENDTIME   = 20091030;
tbGift.WULINSHIJIA_ITEM_TIME = 30*24*60;

tbGift.TASK_GROUP_ID = 2027;
tbGift.TASK_GET_BUFF = 80;
tbGift.TASK_GET_YAOPAI = 81;

function tbGift:OnUse()	
	local nCurSec =  Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")));
	local nKaifuSec = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nMinSec = math.min(nCurSec, nKaifuSec);
	local nMaxSec = math.max(nCurSec, nKaifuSec);
	local nItemId = it.dwId;
	local nItemLevel = NewPlayerGift:GetCurrData(me);
	
	if (EventManager.IVER_bOpenOrgNewPlayerAward == 0) then
		if EventManager.IVER_bOpenZaiXian == 1 and EventManager.IVER_bOpenZaiXian4 == 1  then
			Dialog:Say("  该礼包已经不可以领取奖励了，您可以<color=yellow>按快捷键J或是通过小地图旁边的按钮<color>,打开<color=yellow>在线领奖<color>界面继续领取升级奖励！");
			return 1;
		end
	end
	
	if (not nItemLevel) then
		Dialog:Say("已经没有礼物可以领取！");
		return 0;
	end
	
	local tbOpt = {
		{string.format("<color=yellow>%s级<color>领取新手礼包奖励", nItemLevel), self.GetAwardLibao,self, nItemId},
	};
	if nMaxSec <= Lib:GetDate2Time(self.WULINSHIJIA_ENDTIME) and nMinSec >=  Lib:GetDate2Time(self. WULINSHIJIA_STARTTIME) then
		if me.GetTask(self.TASK_GROUP_ID, self.TASK_GET_BUFF) == 0 then
			table.insert(tbOpt , {"获得雏凤清鸣状态效果", self.GetAwardBuff,  self});
		end
		if me.GetTask(self.TASK_GROUP_ID, self.TASK_GET_YAOPAI) == 0 then
			table.insert(tbOpt , {"领取武林世家腰牌", self.GetAwardYaopai, self});
		end
	end
	table.insert(tbOpt , {"Ta chỉ xem qua"});
	local szMsg = "请选择您所需要的服务";
	Dialog:Say(szMsg, tbOpt); 	
end

function tbGift:GetAwardBuff()
	local szMsg ="";
	local nGetBuff = me.GetTask(self.TASK_GROUP_ID, self.TASK_GET_BUFF);
	if me.nLevel >= 50 then
		Dialog:Say("您已经超过50级，不能领取。");
		return;
	end	
	if nGetBuff ~= 0 then
		Dialog:Say("您已经领取过了，不能再领。");	
		return;
	end	
	--幸运值880, 4级30点,，打怪经验879, 6级（70％）
	me.AddSkillState(880, 4, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	--磨刀石 攻击
	me.AddSkillState(387, 6, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);	
	--护甲片 血
	me.AddSkillState(385, 8, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.SetTask(self.TASK_GROUP_ID, self.TASK_GET_BUFF, 1);	
	Dialog:Say("您成功获得雏凤清鸣状态效果。");
	return;
end

function tbGift:GetAwardYaopai()
	local nGetYaopai = 	me.GetTask(self.TASK_GROUP_ID, self.TASK_GET_YAOPAI);
	if me.nFaction == 0 then
		Dialog:Say("只有加入门派才能领取腰牌。");
		return; 
	end
	if nGetYaopai ~= 0 then
		Dialog:Say("您已经领取过了。");	
		return;
	end	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("领奖需要1格背包空间。");
		return;
	end    
    local pItem = me.AddItem(18,1,480,1);   
    if not  pItem then    
    	Dialog:Say("领取失败。");
    	return;
    end 
    me.SetTask(self.TASK_GROUP_ID, self.TASK_GET_YAOPAI,1);
    me.SetItemTimeout(pItem, 30*24*60, 0);
    me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[活动]增加物品"..pItem.szName);		
	Dbg:WriteLog("[增加物品]"..pItem.szName, me.szName);
    Dialog:Say("领取成功。");
end

function tbGift:GetAwardLibao(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return ;
	end
	local nRes, szMsg = NewPlayerGift:GetAward(me, pItem);
	if szMsg then
		Dialog:Say(szMsg);
	end
end
