-- 文件名  : SeventhEvening_gs.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-08 15:32:12
-- 描述    : 

Require("\\script\\event\\jieri\\201008_SeventhEvening\\SeventhEvening_def.lua");

SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local SeventhEvening = SpecialEvent.SeventhEvening or {};

--服务器启动和定点0点添加npc
function SeventhEvening:AddNpc()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	local oldself = self;
	self = SeventhEvening;
	if nData >= self.OpenTime and nData <= self.CloseTime and self.nNpc == 0 then	--活动期间内启动服务器
		for _, tbPos in ipairs(self.tbWangMuPoint) do
			if SubWorldID2Idx(tbPos[1]) >= 0 then
				Npc:OnSetFreeAI(tbPos[1], tbPos[2]*32, tbPos[3]*32, self.nWangMuAIId, 5, 3, 0, 1000, self.nWangMuId, 20, self.tbWangMuChat);
			end
		end
		if SubWorldID2Idx(self.tbQueShen[1]) >= 0 then
			KNpc.Add2(self.nQueShen, 100, -1, self.tbQueShen[1],self.tbQueShen[2],self.tbQueShen[3]);
		end
		self.nNpc = 1;
	end
	if nData >= 20100810 and nData <= 20100907 and self.nNpcXiGuNiang == 0 then
		if SubWorldID2Idx(29) >= 0 then
			KNpc.Add2(6871, 100, -1, 29,1584,3880);
		end
		self.nNpcXiGuNiang = 1;
	end
	if nData >= 20100822 and nData <= 20100907 and self.nNpcKuiXing == 0 then
		if SubWorldID2Idx(29) >= 0 then
			KNpc.Add2(6876, 100, -1, 29,1509,3771);
		end
		self.nNpcKuiXing = 1;
	end	
	self = oldself;
end

function SeventhEvening:LoadBuffer_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_QIXI_XIALV, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbXialvBuffer = tbBuffer;
	end
	local tbBuffer1 = GetGblIntBuf(GBLINTBUF_QIXI_XIALV_HEFU, 0);
	if tbBuffer1 and type(tbBuffer1) == "table" then
		self.tbXialvBuffer1 = tbBuffer1;
	end
end

function SeventhEvening:QueryXialv(nFrom)
	local szMsg = string.format("\n<color=cyan>%s%s%s<color>\n\n", Lib:StrFillL("", 3), Lib:StrFillL("侠侣姓名", 20), Lib:StrFillL("积分", 4));
	local tbOpt = {{"Ta hiểu rồi"}};
	local nCount = 4;
	local nLast = nFrom or 1;
	for i = nLast, #self.tbXialvBuffer do
		szMsg = szMsg .. string.format("<color=cyan>%s<color=yellow>%s%s\n%s%s<color>\n\n", 
			Lib:StrFillL(i..".", 3),
			Lib:StrFillL(self.tbXialvBuffer[i].szMaleName, 20),
			Lib:StrFillL(self.tbXialvBuffer[i].nPoint, 4),
			Lib:StrFillL(" ", 3),
			Lib:StrFillL(self.tbXialvBuffer[i].szFemaleName, 16)
		);
		nCount = nCount - 1;
		nLast = nLast + 1;
		if nCount <= 0 and nLast < #self.tbXialvBuffer then
			table.insert(tbOpt, 1, {"Trang sau", self.QueryXialv, self, nLast});
			break;
		end
	end
	Dialog:Say(szMsg, tbOpt);
end

function SeventhEvening:GetRank()
	for i = 1, 20 do
		if self.tbXialvBuffer[i] and (self.tbXialvBuffer[i].szMaleName == me.szName or self.tbXialvBuffer[i].szFemaleName == me.szName) then
			return i;
		end
	end
	for i = 1, 20 do
		if self.tbXialvBuffer1[i] and (self.tbXialvBuffer1[i].szMaleName == me.szName or self.tbXialvBuffer1[i].szFemaleName == me.szName) then
			return i;
		end
	end
	return 0;
end

function SeventhEvening:AddXialvPoint(pMale, pFemale, nPoint)
	if not pMale or not pFemale then
		return 0;
	end	
	if pMale.nSex == 1 then
		pMale, pFemale = pFemale, pMale;
	end
	local nTmpPoint = pMale.GetTask(self.TASKID_GROUP, self.TASK_XIALV_POINT) + nPoint;
	pMale.SetTask(self.TASKID_GROUP, self.TASK_XIALV_POINT, nTmpPoint);
	pFemale.SetTask(self.TASKID_GROUP, self.TASK_XIALV_POINT, nTmpPoint);
	local szMsg = string.format("恭喜你，获得<color=yellow>%s<color>点侠侣幸福积分。", nPoint);
	pMale.Msg(szMsg);
	pFemale.Msg(szMsg);
	Dbg:WriteLog("SeventhEvening", "10年七夕", pMale.szName, pFemale.szName, string.format("获得幸福指数：%s", nPoint));
	GCExcute({"SpecialEvent.SeventhEvening:UpdateBuffer_GC", pMale.szName, pFemale.szName, nTmpPoint});
end

ServerEvent:RegisterServerStartFunc(SeventhEvening.AddNpc, SeventhEvening);
ServerEvent:RegisterServerStartFunc(SeventhEvening.LoadBuffer_GS, SeventhEvening);
