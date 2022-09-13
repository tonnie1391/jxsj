
if not MODULE_GAMESERVER then
	return;
end
Require("\\script\\misc\\ipstatistics_base.lua")
Require("\\script\\misc\\serverevent.lua")
Require("\\script\\player\\playerevent.lua")

-- 格式说明：	{{20, 7},{2999, 1500}, 6},,表示IP登录账号数在[7, 20]中， 财富排名在[1500, 2999]中的角色属于类型6

IpStatistics.tbLevelDefine =
{
	{{6, nil},{1499, nil}, 1},
	{{6, nil},{2999, 1500}, 2},
	{{6, nil},{4999, 3000}, 3},
	{{6, nil},{nil, 5000}, 4},
	{{20, 7},{1499, nil}, 5},
	{{20, 7},{2999, 1500}, 6},
	{{20, 7},{4999, 3000}, 7},
	{{20, 7},{nil, 5000}, 8},
	{{50, 21},{1499, nil}, 9},
	{{50, 21},{2999, 1500}, 10},
	{{50, 21},{4999, 3000}, 11},
	{{50, 21},{nil, 5000}, 12},
	{{nil, 51},{1499, nil}, 13},
	{{nil, 51},{2999, 1500}, 14},
	{{nil, 51},{4999, 3000}, 15},
	{{nil, 51},{nil, 5000}, 16},
}

IpStatistics.tbStudioDefine = {11,12,15,16}


function IpStatistics:GetIP(pPlayer)
	local szIp = pPlayer.GetPlayerIpAddress(); -- 这个还带端口的
	if not szIp then
		return
	end

	local nIndex = string.find(szIp, ":")
	if not nIndex then
		return
	end

	szIp = string.sub(szIp, 1, nIndex - 1)

	return IpString2Dword(szIp);
end

function IpStatistics:OnLogin()
	if self:IsRecorded(me.szName) then
		return
	end

	local dwIp = self:GetIP(me)
	if not dwIp then
		print("IpStatistics:OnLogin, Error to GetIP")
		return
	end
	GCExecute({"IpStatistics:OnLogin", dwIp, me.szName})
end

function IpStatistics:GetPlayerType(pPlayer)
	local nRet = 1

	if not pPlayer then
		return nRet
	end

	local dwIp = self:GetIP(pPlayer)
	if not dwIp then
		return nRet
	end

	local nCount = self.tbResult[dwIp] or 0
	local nRank = PlayerHonor:GetPlayerHonorRank(pPlayer.nId, PlayerHonor.HONOR_CLASS_MONEY , 0)
	if not nRank or nRank <= 0 then
		nRank = 5000
	end

	for _, v in ipairs(self.tbLevelDefine) do
		if (not v[1] or (not v[1][1] or nCount <= v[1][1]) and (not v[1][2] or nCount >= v[1][2]))
			and (not v[2] or (not v[2][1] or nRank <= v[2][1]) and (not v[2][2] or nRank >= v[2][2])) then
			nRet = v[3]
			break
		end
	end
	return nRet
end

-- 尽量不要用这个函数，返回true，false不符合常用习惯
-- 使用CheckStudioRole替代该函数
function IpStatistics:IsStudioRole(pPlayer)
	local bRet = false

	local nType = self:GetPlayerType(pPlayer)
	for _, v  in pairs(self.tbStudioDefine) do
		if v == nType then
			bRet = true
			break;
		end
	end

	return bRet
end

function IpStatistics:CheckStudioRole(pPlayer)
	local nType = self:GetPlayerType(pPlayer)
	for _, v  in pairs(self.tbStudioDefine) do
		if v == nType then
			return 1;
		end
	end
	return 0;
end


function IpStatistics:ClearData()
	self.tbRecordedDataGroup = {}
	self.tbRecorded = {}
	self.tbResultDataGroup = {}
	self.tbResult = {}
end

function IpStatistics:DecreaseResultByGroupIndex(nIndex)
	local tbGroup = self.tbResultDataGroup[nIndex]
	self.tbResultDataGroup[nIndex] = {}
	self:DecreaseResultByGroup(tbGroup)
end

function IpStatistics:RemoveRecordedByGroupIndex(nIndex)
	local tbGroup = self.tbRecordedDataGroup[nIndex]
	self.tbRecordedDataGroup[nIndex] = {}
	self:RemoveRecordedByGroup(tbGroup)
end

function IpStatistics:OnLoginCallbackFromGC(dwIp, szName)
	if type(dwIp) ~= "number" or type(szName) ~= "string" then
		return
	end

	if self:IsRecorded(szName) then
		return
	end

	self:RecoredCount(dwIp)
	self:RecoredPlayer(szName)

	self:RecoredItem(dwIp, szName)
end

function IpStatistics:OnServerStart()
	self:InitDataBuffer()
	PlayerEvent:RegisterGlobal("OnLogin", IpStatistics.OnLogin, IpStatistics)
end


if not IpStatistics.bEventRegistered then
	ServerEvent:RegisterServerStartFunc(IpStatistics.OnServerStart, IpStatistics)
	IpStatistics.bEventRegistered = true
end


