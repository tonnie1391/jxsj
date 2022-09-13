-- 文件名　：girl_vote_fensi.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-02-09 15:12:48
-- 功能    ：

local tbItem = Item:GetClass("girl_vote_fensi");

function tbItem:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống.");
		return 0;
	end
	me.AddItem(18,1,373,1);
	return 1;
end


local tbItem1 = Item:GetClass("girl_vote_muou");
tbItem1.nTempNpcId = 10026;		--玫瑰小仙子id
tbItem1.nLiveTime = 24 * 3600 * Env.GAME_FPS;	--npc生存时间

function tbItem1:OnUse()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if SpecialEvent.Girl_Vote:CheckState(2, 4) ~= 1 and SpecialEvent.Girl_Vote:CheckState(5, 6) ~= 1 then
		Dialog:Say("不在投票期，您还不能召唤玫瑰精灵。");
		return 0;
	end
	local tbOpt = {
		{"为自己召唤精灵助战", self.InputName, self, it.dwId, 1, me.szName},
		{"为其他美女召唤精灵助战", self.InputName, self, it.dwId},
		{"Ta chỉ xem qua Xóa bỏ"},
		}
	Dialog:Say("<color=yellow>2012年度武林美女海选<color>火爆进行中。<enter>您可以召唤出一个玫瑰精灵助战美女，在玫瑰精灵处投票会有额外20%的票数加成。<enter><enter>玫瑰精灵存在时间：24小时（每周二服务器重启后不足24小时的精灵也会消失）", tbOpt);
	return 0;
end

function tbItem1:InputName(dwId, nFlag, szName)	
	if nFlag == 1 then
		local pItem = KItem.GetObjById(dwId);
		if not pItem then
			Dialog:Say("您的道具过期。");
			return;
		end
		local nIsHave = SpecialEvent.Girl_Vote:IsHaveGirl(szName);
		local szIsHave = SpecialEvent.Girl_Vote:IsHaveGirl2Ex(szName)
		if nIsHave == 0 and SpecialEvent.Girl_Vote:CheckState(2, 4) == 1 then
			Dialog:Say(string.format("<color=green>%s<color>好像没有报名。", szName));
			return 0;
		end
		if not szIsHave and SpecialEvent.Girl_Vote:CheckState(5, 6) == 1 then
			Dialog:Say(string.format("<color=green>%s<color>好像没有进入决赛。", szName));
			return 0;
		end
		local bCheck, szErrMsg = self:CheckCanCall();		--检查位置
		if bCheck == 0 then
			Dialog:Say(szErrMsg);
			return 0;
		end
		local nMapId, x, y = me.GetWorldPos();
		local pNpc = KNpc.Add2(self.nTempNpcId, 1, -1, nMapId, x, y);
		if pNpc then
			pNpc.GetTempTable("Npc").szGril2012_Name = szName;
			pNpc.SetLiveTime(self.nLiveTime);
			pNpc.SetTitle("<color=green>"..szName.."<color>");
			--第2阶段改npc title为服务器名字
			if SpecialEvent.Girl_Vote:CheckState(4, 6) == 1 and szIsHave then
				pNpc.SetTitle("<color=green>"..(ServerEvent:GetServerNameByGateway(szIsHave) or "玫瑰精灵").."<color>");				
				pNpc.szName = szName;
			end
			pNpc.GetTempTable("Npc").nCastSkillTime = Timer:Register(10 * 60 * 18, SpecialEvent.Girl_Vote.CastSkill, SpecialEvent.Girl_Vote, pNpc.dwId);
			SpecialEvent.Girl_Vote:RandSendMsgWorld(szName, me.szName, 2);
			pItem.Delete(me);
			StatLog:WriteStatLog("stat_info", "prety_lady", "wizard_call", me.nId, 1);
		end
	else
		Dialog:AskString("请输入美女名", 16, self.InputName, self, dwId,  1);
	end
end

function tbItem1:CheckCanCall()
	local szMapClass = GetMapType(me.nMapId);
	if szMapClass ~= "city" and szMapClass ~= "new" then
		return 0, "只能在新手村或者城市召唤玫瑰精灵。";
	end
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, "这里会把<color=green>".. pNpc.szName.."<color>给挡住了，还是换个地方吧。";
		end
	end
	return 1;
end
