-- 文件名　：201108_tanabata_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-25 14:54:56
-- 描述：2011七夕npc


SpecialEvent.Tanabata201108 =  SpecialEvent.Tanabata201108 or {};
local Tanabata201108 = SpecialEvent.Tanabata201108;

--冷清王母----------------------
local tbBigBoss = Npc:GetClass("lengqingwangmu");

function tbBigBoss:OnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	local nPlayerId = pPlayer and pPlayer.nId or 0;
	--drop东西
	local bStoneBorn = KGblTask.SCGetDbTaskInt(DBTASK_QX_STONE_BORN);
	him.DropRateItem(Tanabata201108.szBigBossDropFile01,16,-1,-1,nPlayerId);
	if bStoneBorn ~= 1 then
		him.DropRateItem(Tanabata201108.szBigBossDropFile02,2,-1,-1,nPlayerId);
	end
	local szMsg = string.format("不食人间烟火的<color=green>冷情王母<color>已经被侠客们击败。柔情似水，佳期如梦，祝侠客们七夕快乐！");
	KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL,szMsg);
	KDialog.MsgToGlobal(szMsg);
end


---冷清绝------------------
local tbNormalBoss = Npc:GetClass("lengqingjue");

function tbNormalBoss:OnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	local nPlayerId = pPlayer and pPlayer.nId or 0;
	--drop东西
	him.DropRateItem(Tanabata201108.szNormalBossDropFile01,16,-1,-1,nPlayerId);
	him.DropRateItem(Tanabata201108.szNormalBossDropFile02,1,-1,-1,nPlayerId);
	local szMsg = string.format("<color=green>%s<color>的<color=green>冷情绝<color>已经被侠客们击败。金风玉露一相逢，便胜却人间无数，祝侠客们七夕快乐！",GetMapNameFormId(him.nMapId));
	KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL,szMsg);
	KDialog.MsgToGlobal(szMsg);
end



---烛火--------------------------
local tbFire = Npc:GetClass("QX_fire");

function tbFire:AddExp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nAddExpTimer = pNpc.GetTempTable("SpecialEvent").nAddExpTimer;
	if not nAddExpTimer or nAddExpTimer == 0 then
		return 0;
	end
	local bCouple = pNpc.GetTempTable("SpecialEvent").bCouple or 0;
	local tbBaseExp = KinGame.LevelBaseExp;	--基准经验，已经有读取过的，拿来重用
	local tbPlayer,nCount = KNpc.GetAroundPlayerList(nNpcId,30);
	local szMaleName = pNpc.GetTempTable("SpecialEvent").szMaleName;
	local szFemaleName = pNpc.GetTempTable("SpecialEvent").szFemaleName;
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				if pPlayer.szName == szMaleName or pPlayer.szName == szFemaleName then
					local nAddExp = tbBaseExp[pPlayer.nLevel] * (bCouple == 1 and (60 * 4) or (60 * 2));
					local nAddExpPerMin = nAddExp / 60 ; 
					pPlayer.AddExp(nAddExpPerMin);
				end
			end
		end
	end
	if not pNpc.GetTempTable("SpecialEvent").nAddExpTimes then
		pNpc.GetTempTable("SpecialEvent").nAddExpTimes = 0;
	else
		pNpc.GetTempTable("SpecialEvent").nAddExpTimes = pNpc.GetTempTable("SpecialEvent").nAddExpTimes + 1;
	end
	if pNpc.GetTempTable("SpecialEvent").nAddExpTimes * 5 >= 300 then	--超过5分钟
		pNpc.Delete();
		return 0;
	end
end


function tbFire:WaitHope(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nWaitHopeTimer = pNpc.GetTempTable("SpecialEvent").nWaitHopeTimer;
	if not nWaitHopeTimer or nWaitHopeTimer == 0 then
		return 0;
	end
	local bHoped = pNpc.GetTempTable("SpecialEvent").bDoHope or 0;
	if bHoped ~= 1 then
		pNpc.Delete();
	end
	pNpc.GetTempTable("SpecialEvent").nWaitHopeTimer = 0;
	return 0;
end

