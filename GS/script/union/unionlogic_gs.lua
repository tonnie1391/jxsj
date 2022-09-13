-------------------------------------------------------------------
--File: unionlogic_gs.lua
--Author: zhangyuhua
--Date: 2009-6-6 15:17
--Describe: Gameserver 联盟逻辑
-------------------------------------------------------------------
if not Union then --调试需要
	Union = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
else
	if not MODULE_GAMESERVER then
		return
	end
end

if not Union.aUnionCreateApply then
	Union.aUnionCreateApply={};
end

-- 创建联盟申请_GS1
function Union:ApplyCreateUnion_GS1(tbPlayerInfo, szUnionName, nPlayerId)
	local szMsg = "联盟创建失败！"

	--帮会名字合法性检查
	if self.aUnionCreateApply[nPlayerId] then
		szMsg = szMsg.."创建联盟名申请已提交！"
		Dialog:Say(szMsg);
		return 0;
	end

	local nLen = GetNameShowLen(szUnionName);
	if nLen < 6 or nLen > 12 then
		szMsg = szMsg.."输入的名称长度不符合要求（3～6个汉字）！"
		Dialog:Say(szMsg);
		return 0;
	end
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szUnionName) ~= 1 then
		szMsg = szMsg.."名称只能包含中文简繁体字及· 【 】符号！"
		Dialog:Say(szMsg);
		return 0;
	end
	--是否包含敏感字串
	if IsNamePass(szUnionName) ~= 1 then
		szMsg = szMsg.."对不起，您输入的联盟名称包含敏感字词，请重新设定"
		Dialog:Say(szMsg);
		return 0;
	end

	--检查联盟名是否已占用
	if KUnion.FindUnion(szUnionName) ~= nil then
		szMsg = szMsg.."对不起，检查联盟名已被占用，请重新设定"
		Dialog:Say(szMsg);
		return 0;
	end
	
	_DbgOut("Union:CreateUnion_GS1")
	self.aUnionCreateApply[nPlayerId] = szUnionName;
	return GCExcute{"Union:ApplyCreateUnion_GC", tbPlayerInfo, szUnionName, nPlayerId};
end

-- 创建联盟申请_GS2
function Union:ApplyCreateUnion_GS2(nPlayerId, nSucess)
	self.aUnionCreateApply[nPlayerId] = nil;
	if nSucess ~= 1 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg("创建联盟失败");
		end
	end
	return 1;
end

-- 创建联盟_GS2
function Union:CreateUnion_GS2(tbTongId, szUnionName, nCreateTime)
	local pUnion, nUnionId = self:CreateUnion(tbTongId, szUnionName, nCreateTime)
	if not pUnion then
		return 0;
	end
	for _, nTongId in ipairs(tbTongId) do
		KTong.Msg2Tong(nTongId, string.format("联盟[%s]建立了", pUnion.GetName()));
		Tong:JoinUnion_GS2(nTongId, szUnionName, nUnionId);
	end
	return 1;
end

-- 解散联盟_GS2
function Union:DisbandUnion_GS2(nUnionId, nLeaveTime, bNoMsg)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	
	local pTongItor = pUnion.GetTongItor();
	local nTongId = pTongItor.GetCurTongId();
	while nTongId ~= 0 do
		Tong:LeaveUnion_GS2(nTongId, pUnion.GetName(), nLeaveTime);
		if bNoMsg ~= 1 then
			KTong.Msg2Tong(nTongId, string.format("联盟[%s]解散了", pUnion.GetName()));
		end
		nTongId = pTongItor.NextTongId();
	end
	KUnion.DelUnion(nUnionId);
	return 1;
end

-- 增加帮会成员_GS2
function Union:TongAdd_GS2(nUnionId, nTongId, nCreateTime, nDataVer)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pUnion.AddTong(nTongId, nCreateTime);
	Domain.nDataVer = nDataVer;
	local szMsg = "["..pTong.GetName().."]加入了联盟["..pUnion.GetName().."]";
	Union:Msg2UnionTong(nUnionId, szMsg);
	return 1;
end

-- 删除帮会成员_GS2，有离开和开除两种形式
function Union:TongDel_GS2(nUnionId, nTongId, nPlayerId, nMethod) 
	local pUnion = KUnion.GetUnion(nUnionId)
	if not pUnion then
		return 0;
	end

	local pTong = KTong.GetTong(nTongId);
	if pTong then
		local szMsg = "["..pTong.GetName().."]离开了联盟["..pUnion.GetName().."]";
		Union:Msg2UnionTong(nUnionId, szMsg);
	end

	local nRet = pUnion.DelTong(nTongId);
	if nRet == nil or nRet == 0 then
		return 0;
	end
	
	return 1;
end

--更换盟主_GS2
function Union:ChangeMaster_GS2(nUnionId, nNewTongId, szNewMasterName)
	local pUnion = KUnion.GetUnion(nUnionId);
	if (not pUnion) then
		return 0;
	end	
	pUnion.SetUnionMaster(nNewTongId);
	local szMsg = string.format("[%s]被任命为新盟主", szNewMasterName);
	Union:Msg2UnionTong(nUnionId, szMsg)
end

