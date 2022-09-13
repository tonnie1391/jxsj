--
-- FileName: yinglingtiaozhanling.lua
-- Author: lgy
-- Time: 2012/3/22 11:30
-- Comment: 英灵挑战令
--

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");
local tbQingMing2012 = SpecialEvent.tbQingMing2012;
local tbItem = Item:GetClass("qingming_tiaozhanling_2012");

-- 使用
function tbItem:OnUse()
	self:CallProcess(it.dwId);
	return 0;
end

--召唤
function tbItem:CallProcess(nItemId, nSure)
	--资格判定
	local bOk, szErrorMsg = tbQingMing2012:CanCallYingLingBoss(me);
	if bOk == 0 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg, {"Ta hiểu rồi"});
		end
		return;
	end

	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	
	if me.nFightState == 0 then
		Dialog:Say("战斗区域使用。");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("您确定要召唤吗？");
		local tbOpt = {
			{"我确定要召唤", self.CallProcess, self, pItem.dwId, 1},
			{"Để ta suy nghĩ lại"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if me.DelItem(pItem) ~= 1 then
		return;
	end

	local nMapId, nPosX, nPosY = me.GetWorldPos();
	local pNpc = KNpc.Add2(tbQingMing2012.tbBoss.nNpcId, tbQingMing2012.tbBoss.nLevel, -1, nMapId, nPosX, nPosY, 0, 1);
	if pNpc then
		me.Msg(string.format("您成功召唤出了%s。", pNpc.szName));
		pNpc.SetLiveTime(tbQingMing2012.nBossLiveTime);
	end
	
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp then
		return;
	end
	
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	local szKinName = cKin and cKin.GetName() or "未知";
	tbTemp.nKinId = nKinId;
	pNpc.szName = szKinName.."家族的英灵";
	
	--记录log
	StatLog:WriteStatLog("stat_info", "qingmingjie2012", "use_token", me.nId, 1);

	local szMsg = string.format("本家族在<pos=%d,%d,%d>召唤出了英灵，齐心合力击败他吧！", nMapId, nPosX, nPosY);
	KKin.Msg2Kin(nKinId, szMsg);
end

function tbItem:InitGenInfo()
	local nNowSecond = GetTime() + 24*3600;
	it.SetTimeOut(0, nNowSecond);	--相对对时间
	return {};
end
