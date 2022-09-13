--
-- FileName: diancangka.lua
-- Author: lgy
-- Time: 2012/7/3 11:30
-- Comment: 2012活动典藏卡
--
SpecialEvent.tbShengXia2012 =  SpecialEvent.tbShengXia2012 or {};
local tbShengXia2012 = SpecialEvent.tbShengXia2012;

local tbItem = Item:GetClass("shengxia_diancangka_2012");

-- 使用
function tbItem:OnUse()
	local bOk, szErrorMsg = tbShengXia2012:CommonCheck(me);
	if bOk == 0 then
		Dialog:Say(szErrorMsg);
		return;
	end
	--本次鉴定次数
	local nDay = TimeFrame:GetServerOpenDay();
	local nNumber = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JIANDING);
	nNumber = nNumber + 1;
	if nNumber >10 then
		Dialog:Say("你今天已经使用了10张典藏卡啦！");
		return 0;
	end
	local tbAward = Lib._CalcAward:RandomAward(3, 3, 2, tbShengXia2012.tbJiaZhiLiang[nNumber], Lib:_GetXuanReduce(nDay), {8,2,0});
	local nNum,tbXuan = tbShengXia2012:ReturnXuan(tbAward);
	local szXuanjing = ""
	for i=1, nNum do
		szXuanjing = szXuanjing..tbXuan[i].."级玄晶、"
	end
	local szMsg = "2012年盛夏活动宝物卡，<color=green>右键点击<color>打开将有机会<color=green>点亮收集<color>一个盛夏活动项目，每人每天可最多打开<color=green>10张<color>典藏卡，打开典藏卡的同时将有机会获得<color=green>六种小游龙阁声望令牌<color>[帽子/衣服/腰带/鞋子/戒指/护身符]中的一种。\n\n这是你今天第<color=red>"..nNumber.."<color>次打开典藏卡，奖励选项包括：<color=yellow>"..szXuanjing.."大量绑银、<color><color=yellow>小游龙阁声望令牌<color>。\n\n<color=red>此卡有效期截止为今晚23点59分<color>";
	local tbOpt = {
			{"点击使用",self.UseThis, self,it.dwId},
			{"Để ta suy nghĩ lại\n"}
	};
	if nNumber >=4 and nNumber<=10 then
		tbOpt[1][1]=tbOpt[1][1].."\n<color=yellow>(消耗"..tbShengXia2012.tbNeedGanLan[nNumber].."个橄榄枝)<color>"
	end
	Dialog:Say(szMsg, tbOpt);
end

-- 使用典藏卡
function tbItem:UseThis(nItemId)
	
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return 0;
	end
	
	if me.CountFreeBagCell() < 2 then
			Dialog:Say("你的背包空间不足，请先整理至少出2个背包空间。");
		return 0;
	end
	
	--鉴定数量加1
	local nNumber = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JIANDING);
	nNumber = nNumber + 1;
	if nNumber >10 then
		Dialog:Say("你今天已经使用了10张典藏卡啦！");
		return 0;
	end
	
	local nDay = TimeFrame:GetServerOpenDay();	
	local tbAward = Lib._CalcAward:RandomAward(3, 3, 2, tbShengXia2012.tbJiaZhiLiang[nNumber], Lib:_GetXuanReduce(nDay), {8,2,0});
	local nMaxBindMoney = tbShengXia2012:GetMaxBandMoney(tbAward);
	if me.GetBindMoney() + nMaxBindMoney + 50000 > me.GetMaxCarryMoney() then
		Dialog:Say("你所携带的绑银将达上限，请整理后再来领取。");
		return 0;
	end	
	--今天鉴定了几次卡片
	local szMsg = "";
	if nNumber >=1 and nNumber <4 then	
		-- 删卡片
		local nRet = pItem.Delete(me);
		if nRet ~= 1 then
			Dbg:WriteLog("2012盛夏活动删除典藏卡失败", me.szAccount, me.szName);
			return;
		end
		local bOk,szMsg,nType,nLevel = tbShengXia2012:RandomItem(me, tbAward);
		if bOk == 1 then
			StatLog:WriteStatLog("stat_info", "olympic2012", "card_light", me.nId, tbShengXia2012.tbNeedGanLan[nNumber] or 0, nType, nLevel);
		end
	elseif nNumber>=4 and nNumber<=10 then
		--判断身上有没有足够的橄榄枝
		local nCount = me.GetItemCountInBags(unpack(tbShengXia2012.nGanLanId));
		if nCount < tbShengXia2012.tbNeedGanLan[nNumber] then
			--购买橄榄枝
			Dialog:Say("本轮需要<color=yellow>橄榄枝"..tbShengXia2012.tbNeedGanLan[nNumber].."个<color>，您的橄榄枝数量不足，是否在奇珍阁购买？\n\n<color=green>橄榄枝：<color>    <color=yellow>20金币 / 个<color>\n<color=green>橄榄束·箱：<color><color=yellow>2000金币 / 个（包含橄榄枝100个）<color>",{{"购买橄榄枝", tbShengXia2012.BuyItem, self, 1},{"购买橄榄束·箱", tbShengXia2012.BuyItem, self, 2},{"Để ta suy nghĩ thêm"}})
			return 0;
		end
		
		--扣橄榄枝
		local nRet = me.ConsumeItemInBags2(tbShengXia2012.tbNeedGanLan[nNumber], unpack(tbShengXia2012.nGanLanId));	
		if nRet ~= 0 then
			Dbg:WriteLog("2012盛夏活动扣除橄榄枝失败。", me.szAccount, me.szName);
			return;
		end
		
		-- 删卡片
		local nRet = pItem.Delete(me);
		if nRet ~= 1 then
			Dbg:WriteLog("2012盛夏活动删除典藏卡失败", me.szAccount, me.szName);
			return;
		end
		
		local nGetMost = self:GetLevel(me);
		local nGetNow = me.GetTask(tbShengXia2012.TASKGID,tbShengXia2012.TASK_YOULONG)
		local nRand = MathRandom(1, 10000);
		if nRand <= tbShengXia2012.tbPaiZi[nNumber] and nGetNow < nGetMost then
		 	--获得小游龙牌子
		 	local nLevelLingTu	   		= me.GetReputeLevel(8, 1);
		 	local nLevelWuLinLianSai	 = me.GetReputeLevel(7, 1);
		
		 	--判断声望等级
		 	local nRand = 1;
		 	if nLevelLingTu<4 and nLevelWuLinLianSai<4 then
		 		nRand = MathRandom(3, 6);	
		 	elseif nLevelLingTu<4 and nLevelWuLinLianSai>=4 then
		 		nRand = MathRandom(2, 6);
		 	elseif nLevelLingTu>=4 and nLevelWuLinLianSai<4 then
		 		nRand = MathRandom(2, 6);
		 		if nRand == 2 then
					nRand = 1;
				end
		 	else
		 		nRand = MathRandom(1, 6);
		 	end	
			local pItemEx = me.AddItemEx(unpack(tbShengXia2012.tbYouLong[nRand]));
			if not pItemEx then
				Dbg:WriteLog("2012shengxia", "Give YOULONG failed",me.szName);
				return;
			end	
			--记录log
			StatLog:WriteStatLog("stat_info", "olympic2012", "card_light", me.nId, tbShengXia2012.tbNeedGanLan[nNumber] or 0, 0, 0, string.format("%s_%s_%s_%s",unpack(tbShengXia2012.tbYouLong[nRand])));
			--活动期间获得游龙阁令牌数量
			me.SetTask(tbShengXia2012.TASKGID,tbShengXia2012.TASK_YOULONG, nGetNow + 1);
			me.SendMsgToFriend("Hảo hữu [<color=yellow>"..me.szName.."<color>]在盛夏典藏集卡活动中，成功获得<color=yellow>"..pItemEx.szName.."<color>")
			Player:SendMsgToKinOrTong(me, "在盛夏典藏集卡活动中，成功获得<color=yellow>"..pItemEx.szName.."<color>", 1)
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, "恭喜[<color=yellow>"..me.szName.."<color>]在盛夏典藏集卡活动中，成功获得<color=yellow>"..pItemEx.szName.."<color>");
			szMsg = szMsg.."恭喜你获得了<color=red>"..pItemEx.szName.."<color>声望令牌。"
	    	else
			local bOk,szMsg,nType,nLevel = tbShengXia2012:RandomItem(me, tbAward);
			if bOk == 1 then
				--记录log
				StatLog:WriteStatLog("stat_info", "olympic2012", "card_light", me.nId, tbShengXia2012.tbNeedGanLan[nNumber] or 0, nType, nLevel);
		    		if nType == 1 and nLevel >=8 then
		    			me.SendMsgToFriend("Hảo hữu [<color=yellow>"..me.szName.."<color>]在盛夏典藏集卡活动中，成功获得<color=yellow>"..szMsg.."<color>");
					Player:SendMsgToKinOrTong(me, "在盛夏典藏集卡活动中，成功获得<color=yellow>"..szMsg.."<color>", 1);
		    			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, "恭喜[<color=yellow>"..me.szName.."<color>]在盛夏典藏集卡活动中，成功获得<color=yellow>"..szMsg.."<color>");
		    		end
		    	end
	   	 end
	end
	local nRand = MathRandom(1, 26);
	if (me.GetTask(tbShengXia2012.TASKGID,nRand)) == 1 then
		--加绑银50000
		me.AddBindMoney(50000);	-- 加绑银
		szMsg = szMsg.."你已经点亮了<color=red>"..tbShengXia2012.AoYunName[nRand].."<color>卡片，获得基础奖励<color=red>绑银50000<color>一份"
	else
		--点亮卡片
		me.SetTask(tbShengXia2012.TASKGID,nRand,1)
		szMsg = szMsg.."恭喜你收集了<color=red>"..tbShengXia2012.AoYunName[nRand].."<color>卡片"
	    --点亮数量+1
	    local nNumber = me.GetTask(tbShengXia2012.TASKGID,tbShengXia2012.TASK_DIANLIANG);
	    nNumber = nNumber + 1;
	    me.SetTask(tbShengXia2012.TASKGID,tbShengXia2012.TASK_DIANLIANG,nNumber);
	end
	
	local bLingjiang = me.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGJIANG)
	local tbFind = me.FindItemInAllPosition(unpack(tbShengXia2012.nShengXiaDianCangCe));
	if #tbFind == 0  and bLingjiang ==0 then
		--给手册
		me.AddItemEx(unpack(tbShengXia2012.nShengXiaDianCangCe));
	end
	
	--鉴定次数
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JIANDING, nNumber);
	Dialog:Say(szMsg);
	return;
end

function tbItem:InitGenInfo()
	local nTime = tonumber(os.date("%Y%m%d", GetTime() + 3600*24));
	nTime = Lib:GetDate2Time(nTime) - 1;
	it.SetTimeOut(0,nTime);	--当天有效
	return {};
end

function tbItem:GetLevel(pPlayer)
	local tbReputeInfo ={
		{8, 1, 5},
		{7, 1, 5},
		{5, 2, 2},
		{10, 1, 2},
		{11, 1, 2},
		{5, 4, 4},
		}
	local bGolden = 1;
	local bSliver = 1;
	for i, tb in ipairs(tbReputeInfo) do
		if pPlayer.GetReputeLevel(tb[1], tb[2]) < tb[3] then
			return 4;
		elseif pPlayer.GetReputeLevel(tb[1], tb[2]) == tb[3] then
			bGolden = 0;
		end		
	end
	if bGolden == 1 then
		return 1;
	elseif bSliver ==1 then
		return 2;
	end
	return 4;
end