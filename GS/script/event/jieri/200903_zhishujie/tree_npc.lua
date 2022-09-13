-- 09植树节 树

local tbTree = Npc:GetClass("tree_arbor_day_09");

function tbTree:OnDialog()
	if me.nId ~= SpecialEvent.ZhiShu2009:GetOwnerId(him) then
		return;
	end
	
	if SpecialEvent.ZhiShu2009:IsBigTree(him) == 0 then
		local nRes, szMsg = SpecialEvent.ZhiShu2009:CanIrrigate(me, him);
		local tbOpt = {{"知道了"}};
		if szMsg then
			if nRes == 1 then
				tbOpt = {
					{"浇水", SpecialEvent.ZhiShu2009.IrrigateBegin, SpecialEvent.ZhiShu2009, me, him},
					{"知道了"}
				};
			end
			Dialog:Say(szMsg, tbOpt);
		end
		return;
	else
		local nState, szMsg = SpecialEvent.ZhiShu2009:HasSeed(him);
		if nState == 0 then
			Dialog:Say("我已经从这棵树上摘过果子了。");
		elseif nState == 1 then
			if szMsg then
				local tbOpt = {{"知道了"}};
				Dialog:Say(szMsg, tbOpt);
			else
				Dialog:Say("果子还没有成熟。");
			end
		else
			local nDelta = SpecialEvent.ZhiShu2009.BIG_TREE_LIFE - (GetTime() - him.GetTempTable("Npc").tbPlantTree09.nBirthday);
			local szMsg = string.format("赶快收获，不然再<color=yellow>%s<color>后树木会消失。", Lib:TimeDesc(nDelta));
			local tbOpt = {
				{"摘果子", self.GatherSeed, self, me, him.dwId},
				{"再等等看"}
			};
			Dialog:Say(szMsg, tbOpt);
		end
	end
end

function tbTree:GatherSeed(pPlayer, dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		Dialog:Say("很可惜，你的树已经枯死了。");
		return;
	end
	
	local res, szMsg = SpecialEvent.ZhiShu2009:CanGatherSeed(pPlayer, pNpc) 
	if res == 1 then
		local szMsg = SpecialEvent.ZhiShu2009:GatherSeed(pPlayer, pNpc);
		Dialog:Say(szMsg);
	elseif szMsg then
		Dialog:Say(szMsg);
	end
end

local tbGetSeed = EventManager:GetClass("event_arbor_day_09_get_seed");
function tbGetSeed:OnDialog()
	local nRes, szMsg = SpecialEvent.ZhiShu2009:CanGiveSeed(me);
	if nRes == 1 then
		SpecialEvent.ZhiShu2009:GiveSeed(me);
		SpecialEvent.ZhiShu2009:FillJug(me, 1);
	elseif szMsg then
		Dialog:Say(szMsg);
	end
end

local tbFillJug = EventManager:GetClass("event_arbor_day_09_fill_jug");
function tbFillJug:OnDialog()
	local nRes, szMsg = SpecialEvent.ZhiShu2009:FillJug(me);
	if nRes == 0 and szMsg then
		Dialog:Say(szMsg);
	end
end

local tbHandupSeed = EventManager:GetClass("event_arbor_day_09_handup_seed");
function tbHandupSeed:OnDialog()
	Dialog:OpenGift("请放入饱满的树种。", nil, {self.CallBack, self});
end

function tbHandupSeed:CallBack(tbItem)
	local nRes, szMsg = SpecialEvent.ZhiShu2009:HandupSeed(me, tbItem);
	if nRes == 1 then
		return;
	elseif szMsg then
		Dialog:Say(szMsg);
	end
end

local tbIntro = EventManager:GetClass("event_arbor_day_09_intro");
tbIntro.tbIntroMsg = {
	[1] = "活动期间，60级以上的玩家可得到一个洒水壶，在种树浇水时使用。此壶可浇水10次，您可以随时到木良处装满水。",
	[2] = "树种种下后，你需要马上对其浇水，若1分钟还没浇水，树种就会死亡，需要重新种一粒。每次浇水后，过1分钟你才可以再次浇水，超过2分钟没浇水树苗也会死亡，务必注意。在浇水5次后，植树成功，你会看见“好大一棵树”，2分钟后能从上面摘取“饱满的树种”。成树存在1小时后会消失。",
	[3] = "树木成长过程中，你和你的队友都能获得经验奖励，队员种树越多经验越高。在对树木浇水时也有可能获得随机奖励，最后将“饱满的树种”交给新手村伐木小屋老板木良可以或得丰厚奖励。",
	}
	
function tbIntro:OnDialog(nIdx)
	if nIdx then
		local tbOpt = {{"Tôi hiểu", self.OnDialog, self}};	
		Dialog:Say(self.tbIntroMsg[nIdx], tbOpt);
		return;
	end
	
	local szMsg = "植树节活动开始了，你要了解什么呢？";
	local tbOpt = {
		{"关于领取洒水壶", self.OnDialog, self, 1},
	        {"关于种树过程",self.OnDialog, self, 2},
	        {"有什么奖励",self.OnDialog, self, 3},
	        {"我了解了"}
		};
		
	Dialog:Say(szMsg, tbOpt);
end

-- ?pl DoScript("\\script\\event\\jieri\\200903_zhishujie\\tree_npc.lua")