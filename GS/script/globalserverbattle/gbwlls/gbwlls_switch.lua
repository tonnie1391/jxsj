-- 文件名　：gbwlls_switch.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-12-16 11:15:59
-- 描述　  ：跨服联赛开关（必须大区内有一半以上的服务器开启了3届联赛，大区才开启第一届跨服联赛）

--本服传送给全局服自己联赛届数
function GbWlls:RegOnConnectGbServer(nConnect)
	local szGateway = GetGatewayName();
	local nSession = Wlls:GetMacthSession();
	GC_AllExcute({"GbWlls:Gb_GetServerConnect", szGateway, nSession});
end

function GbWlls:Gb_GetServerConnect(szGateway, nSession)
	GbWlls.tbZoneServer = GbWlls.tbZoneServer or {};
	GbWlls.tbZoneServer[szGateway] = nSession;

	if GbWlls.IsOpen ~= 1 then
		return 0;
	end

	local nOpenFlag = self:GetGblWllsOpenState();
	if (nOpenFlag > 0) then
		return 0;
	end

	local nZoneServerCount = ServerEvent:GetZoneServerCount(szGateway)
	if nZoneServerCount <= 1 then
		return 0;
	end
	local nOpenSession = 0;
	for _, nSession in pairs(self.tbZoneServer) do
		if nSession > 3 then
			nOpenSession = nOpenSession + 1;
		end
	end
	if nOpenSession*2 >= nZoneServerCount then
		--设置跨服联赛开启标志 todo
		self:SetGblWllsOpenState(1);
	end
end

if not GLOBAL_AGENT and MODULE_GC_SERVER then
GCEvent:RegisterConnectGBGCServerFunc({"GbWlls:RegOnConnectGbServer"})
end
