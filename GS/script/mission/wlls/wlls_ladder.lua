-- 文件名　：wlls_ladder.lua 联赛排行榜文件
-- 创建者　：zhouchenfei
-- 创建时间：2008-10-16 15:07:15

Require("\\script\\ladder\\define.lua")

Wlls.LADDER_CLASS				= Ladder.LADDER_CLASS_WLLS;
Wlls.LADDER_TYPE_CUR_PRIMAY		= Ladder.LADDER_TYPE_WLLS_CUR_PRIMAY	-- 当届联赛初级榜
Wlls.LADDER_TYPE_CUR_ADV 		= Ladder.LADDER_TYPE_WLLS_CUR_ADV 		-- 当届联赛高级榜
Wlls.LADDER_TYPE_HONOR			= Ladder.LADDER_TYPE_WLLS_HONOR			--  Danh hiệu 
Wlls.LADDER_TYPE_LAST_PRIMAY	= Ladder.LADDER_TYPE_WLLS_LAST_PRIMAY	-- 上届联赛初级榜
Wlls.LADDER_TYPE_LAST_PRIMAY	= Ladder.LADDER_TYPE_WLLS_LAST_PRIMAY	-- 上届联赛高级榜

Wlls.LADDER_FACTIONNAME = {
		[Env.FACTION_ID_NOFACTION]	= "Võ Lâm";
		[Env.FACTION_ID_SHAOLIN]	= "Thiếu Lâm";
		[Env.FACTION_ID_TIANWANG]	= "Thiên Vương";
		[Env.FACTION_ID_TANGMEN]	= "Đường Môn";
		[Env.FACTION_ID_WUDU]		= "Ngũ Độc";
		[Env.FACTION_ID_EMEI]		= "Nga Mi";
		[Env.FACTION_ID_CUIYAN]		= "Thúy Yên";
		[Env.FACTION_ID_GAIBANG]	= "Cái Bang";
		[Env.FACTION_ID_TIANREN]	= "Thiên Nhẫn";
		[Env.FACTION_ID_WUDANG]		= "Võ Đang";
		[Env.FACTION_ID_KUNLUN]		 = "Côn Lôn";
		[Env.FACTION_ID_MINGJIAO]	 = "Minh Giáo";
		[Env.FACTION_ID_DALIDUANSHI] = "Đoàn Thị";
		[Env.FACTION_ID_GUMU]		= "Cổ Mộ";
	};

if (MODULE_GC_SERVER) then
-- 更新联赛 Danh hiệu 
function Wlls:UpdateWllsHonorLadder()
	print("武林联赛排行榜开始");
	local nType = 0;
	local tbLadderCfg = Ladder.tbLadderConfig[PlayerHonor.HONOR_CLASS_WLLS];
	nType = Ladder:GetType(0, tbLadderCfg.nLadderClass, tbLadderCfg.nLadderType, tbLadderCfg.nLadderSmall);
	UpdateTotalLadder(nType, tbLadderCfg.nDataClass, 0);	

	local tbShowLadder	= GetTotalLadderPart(nType, 1, 10);
	local szContext		= string.format("Danh hiệu %s (sau khi kết thúc giải đấu)", self.LADDER_FACTIONNAME[0]);
	local szLadderName	= string.format("Danh hiệu %s ", self.LADDER_FACTIONNAME[0]);
	PlayerHonor:SetShowLadder(tbShowLadder, nType, szLadderName, szContext, tbLadderCfg.szPlayerContext, tbLadderCfg.szPlayerSimpleInfo);

	UpdateLadderDataForFaction(nType, 1);
	-- 分榜
	for i=1, Env.FACTION_NUM do
		local tbSubShow = GetTotalLadderPart(nType + i, 1, 10);
		local szSubContext	= string.format("Danh hiệu %s (sau khi kết thúc giải đấu)", self.LADDER_FACTIONNAME[i]);
		local szLadderName	= string.format("Danh hiệu %s ", self.LADDER_FACTIONNAME[i]);
		PlayerHonor:SetShowLadder(tbSubShow, nType + i, szLadderName, szSubContext, tbLadderCfg.szPlayerContext, tbLadderCfg.szPlayerSimpleInfo);
	end
	
	PlayerHonor:GetHonorStatInfo(PlayerHonor.HONOR_CLASS_WLLS, 100, "wllshonor", "Wlls");
	print("武林联赛排行榜结束");
end

function Wlls:GetType(nType, nNum1, nNum2, nNum3)
	nType = KLib.SetByte(nType, 3, nNum1);
	nType = KLib.SetByte(nType, 2, nNum2);
	nType = KLib.SetByte(nType, 1, nNum3);
	return nType;
end

end -- end MODULE_GC_SERVER


if (MODULE_GAMESERVER) then
	
end
