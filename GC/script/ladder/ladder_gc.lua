-- 文件名　：ladder_gc.lua
-- 创建者　：zhouchenfei
-- 创建时间：2008-03-20 16:40:25

Require("\\script\\player\\playerhonor.lua");
Require("\\script\\ladder\\define.lua")

-- Ladder.tbLadderConfig 排行榜配置table
--
--
function Ladder:InitLadderConfig()
	self.tbLadderConfig	= {
		[PlayerHonor.HONOR_CLASS_WULIN] 		= { 
				nLadderClass	= self.LADDER_CLASS_WULIN, 
				nLadderType		= self.LADDER_TYPE_WULIN_HONOR_WULIN,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_WULIN,
				nEffectNum		= 5000,
				szLadderName	= "Vinh dự võ lâm",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách để có thể tìm kiếm thứ hạng của mình và người chơi khác.\n Đạt đủ điều kiện có thể mua Phi Phong tương ứng tại Tiền Trang.\n\n",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_FACTION]		= {
				nLadderClass	= self.LADDER_CLASS_WULIN, 
				nLadderType		= self.LADDER_TYPE_WULIN_HONOR_FACTION,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_FACTION,
				nEffectNum		= 1000,
				szLadderName	= "Môn phái",
				szPlayerContext	= "Điểm vinh dự : %d",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 1,	
		},
		[PlayerHonor.HONOR_CLASS_WLLS]			= {
				nLadderClass	= self.LADDER_CLASS_WLLS, 
				nLadderType		= self.LADDER_TYPE_WLLS_HONOR,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_WLLS,
				nEffectNum		= 5000,
				szLadderName	= "Liên đấu",
				szPlayerContext	= "Điểm vinh dự : %d",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,	
		},
		[PlayerHonor.HONOR_CLASS_BATTLE]		= {
				nLadderClass	= self.LADDER_CLASS_WULIN, 
				nLadderType		= self.LADDER_TYPE_WULIN_HONOR_SONGJINBATTLE,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_BATTLE,
				nEffectNum		= 1000,
				szLadderName	= "Mông Cổ-Tây Hạ",
				szPlayerContext	= "Điểm vinh dự : %d",	
				szPlayerSimpleInfo = "%d điểm",	
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,			
		},
		[PlayerHonor.HONOR_CLASS_LINGXIU]		= {
				nLadderClass	= self.LADDER_CLASS_LINGXIU, 
				nLadderType		= self.LADDER_TYPE_LINGXIU_HONOR_LINGXIU,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_LINGXIU,
				nEffectNum		= 5000,
				szLadderName	= "Vinh dự thủ lĩnh",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách để có thể tìm kiếm thứ hạng của mình và người chơi khác.\n Đạt đủ điều kiện có thể mua Phi Phong tương ứng tại Tiền Trang.\n",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_AREARBATTLE]	= {
				nLadderClass	= self.LADDER_CLASS_LINGXIU, 
				nLadderType		= self.LADDER_TYPE_LINGXIU_HONOR_AREABATTLE,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_AREARBATTLE,
				nEffectNum		= 1000,
				szLadderName	= "Tranh đoạt",
				szPlayerContext	= "Điểm vinh dự : %d",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 0,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_BAIHUTANG]		= {
				nLadderClass	= self.LADDER_CLASS_LINGXIU, 
				nLadderType		= self.LADDER_TYPE_LINGXIU_HONOR_BAIHUTANG,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_BAIHUTANG,
				nEffectNum		= 1000,
				szLadderName	= "Bạch hổ đường",
				szPlayerContext	= "Điểm vinh dự : %d",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 0,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_MONEY]			= {
				nLadderClass	= self.LADDER_CLASS_MONEY, 
				nLadderType		= self.LADDER_TYPE_MONEY_HONOR_MONEY,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_MONEY,
				nEffectNum		= 5000,
				szLadderName	= "Tài phú",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách để có thể tìm kiếm thứ hạng của mình và người chơi khác.\n Đạt đủ điều kiện có thể mua Phi Phong tương ứng tại Tiền Trang.\n",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
--		[PlayerHonor.HONOR_CLASS_SPRING]		= {
--				nLadderClass	= self.LADDER_CLASS_LADDER, 
--				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
--				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_SPRING,
--				nDataClass		= PlayerHonor.HONOR_CLASS_SPRING,
--				nEffectNum		= 5000,
--				szLadderName	= "民族大团圆",
--				szPlayerContext	= "搜集张数：%d\n点击列表模式可以查询自己和他人的排名情况\n",	
--				szPlayerSimpleInfo = "%d张",
--				nGCStartLoad	= 1,
--				nSubLadderLoad	= 0,		
--		},
		[PlayerHonor.HONOR_CLASS_DRAGONBOAT]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_DRAGONBOAT,
				nDataClass		= PlayerHonor.HONOR_CLASS_DRAGONBOAT,
				nEffectNum		= 5000,
				szLadderName	= "Vinh dự thiền cảnh hoa viên",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách có thể tìm kiếm thứ hạng của mình hoặc của người khác.\n\n",	
				szPlayerSimpleInfo = "%d điểm",	
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
				nNoChangeRank	= 1,	
		},
		[PlayerHonor.HONOR_CLASS_WEIWANG]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_WEIWANG,
				nDataClass		= PlayerHonor.HONOR_CLASS_WEIWANG,
				nEffectNum		= 5000,
				szLadderName	= "Uy danh",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách có thể tìm kiếm thứ hạng của mình hoặc của người khác.\n\n",	
				szPlayerSimpleInfo = "%d điểm",	
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
				nNoChangeRank	= 1,
		},
		[PlayerHonor.HONOR_CLASS_PRETTYGIRL]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_PRETTYGIRL,
				nDataClass		= PlayerHonor.HONOR_CLASS_PRETTYGIRL,
				nEffectNum		= 5000,
				szLadderName	= "Mỹ nữ",
				szPlayerContext	= "Bình chọn: %d\n Nhấn vào danh sách có thể tìm kiếm thứ hạng của mình hoặc của người khác.\n\n",	
				szPlayerSimpleInfo = "%d Lượt",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
				nNoChangeRank	= 1,
		},
		[PlayerHonor.HONOR_CLASS_BEAUTYHERO]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_BEAUTYHERO,
				nDataClass		= PlayerHonor.HONOR_CLASS_BEAUTYHERO,
				nEffectNum		= 5000,
				szLadderName	= "Chân kinh",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách để có thể tìm kiếm thứ hạng của mình và người chơi khác.\n",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_LADDER1]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_LADDER1,
				nDataClass		= PlayerHonor.HONOR_CLASS_LADDER1,
				nEffectNum		= 5000,
				szLadderName	= "Di tích Cổ",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách để có thể tìm kiếm thứ hạng của mình và người chơi khác.\n",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
				nNoChangeRank	= 1,
		},
		
		[PlayerHonor.HONOR_CLASS_LADDER2]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_LADDER2,
				nDataClass		= PlayerHonor.HONOR_CLASS_LADDER2,
				nEffectNum		= 5000,
				szLadderName	= "Vu Lan",
				szPlayerContext	= "Điểm vinh dự : %d\n Nhấn vào danh sách để có thể tìm kiếm thứ hạng của mình và người chơi khác.\n",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
		
		[PlayerHonor.HONOR_CLASS_LADDER3]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_LADDER3,
				nDataClass		= PlayerHonor.HONOR_CLASS_LADDER3,
				nEffectNum		= 5000,
				szLadderName	= "Xích Dạ Thiên Tường",
				szPlayerContext	= "%d",	
				szPlayerSimpleInfo = "%d",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_XOYOGAME]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_XOYOGAME,
				nDataClass		= PlayerHonor.HONOR_CLASS_XOYOGAME,
				nEffectNum		= 5000,
				szLadderName	= "Tiêu dao cốc",
				szPlayerContext	= "%d",	
				szPlayerSimpleInfo = "%d",	
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,	
		},
		[PlayerHonor.HONOR_CLASS_KAIMENTASK]		= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_ACTION,
				nLadderSmall	= self.LADDER_TYPE_LADDER_ACTION_KAIMENTASK,
				nDataClass		= PlayerHonor.HONOR_CLASS_KAIMENTASK,
				nEffectNum		= 5000,
				szLadderName	= "Nhiệm vụ Khắc Di Môn",
				szPlayerContext	= "%d",	
				szPlayerSimpleInfo = "%d",		
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,	
		},
		[PlayerHonor.HONOR_CLASS_FIGHTPOWER_TOTAL]			= {
				nLadderClass	= self.LADDER_CLASS_FIGHTPOWER, 
				nLadderType		= self.LADDER_TYPE_FIGHTPOWER_TOTAL,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_FIGHTPOWER_TOTAL,
				nEffectNum		= 3000,
				szLadderName	= "Xếp hạng Sức chiến đấu",
				szPlayerContext	= "%d",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_FIGHTPOWER_ACHIEVEMENT]	= {
				nLadderClass	= self.LADDER_CLASS_FIGHTPOWER, 
				nLadderType		= self.LADDER_TYPE_FIGHTPOWER_ACHIVEMENT,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_FIGHTPOWER_ACHIEVEMENT,
				nEffectNum		= 3000,
				szLadderName	= "Xếp hạng Thành tựu",
				szPlayerContext	= "%d",	
				szPlayerSimpleInfo = "%d điểm",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
		[PlayerHonor.HONOR_CLASS_LEVEL]	= {
				nLadderClass	= self.LADDER_CLASS_LADDER, 
				nLadderType		= self.LADDER_TYPE_LADDER_LEVEL,
				nLadderSmall	= 0,
				nDataClass		= PlayerHonor.HONOR_CLASS_LEVEL,
				nEffectNum		= 3000,
				szLadderName	= "Xếp hạng đẳng cấp",
				szPlayerContext	= "Ảnh hưởng bởi hiệu quả chiến đấu của bạn",
				szPlayerSimpleInfo = "%d",
				nGCStartLoad	= 1,
				nSubLadderLoad	= 0,
		},
	};
end

if (not MODULE_GC_SERVER) then
	return;
end

function Ladder:gc_SyncPlayerHonor(nPlayerId, nHonorId, nNewValue)
	KGCPlayer.SetHonorTask(nPlayerId, nHonorId, nNewValue);
	SetPlayerHonor(nPlayerId, nHonorId, 0, nNewValue);
	GSExcute(-1, {"Ladder:gs_OnSyncPlayerHonor", nPlayerId, nHonorId, nNewValue});
end

function Ladder:LoadLevelLadder()
	print("Bảng xếp hạng.......");
	local tbLevelLadderResult = UpdateLevelLadder();
	self:SetLevelShowLadder(tbLevelLadderResult);
	print("Hoàn thành danh sách.......");
end

function Ladder:SetLevelShowLadder(tbLevelLadderResult)
	if (not tbLevelLadderResult) then
		print("Đánh giá danh sách.....");
		return;
	end
	local nNowTime	= GetTime();
	local tbToday	= os.date("*t", nNowTime - 3600*24);
	local szDate	= string.format("%d月%d日", tbToday.month, tbToday.day);
	local nType 	= self:GetType(0, self.LADDER_CLASS_LADDER, self.LADDER_TYPE_LADDER_LEVEL, 0);
	local szContext		= szDate .. self.tbFacContext[0];
	local szLadderName	= self.tbFacContext[0];
	
	for i=0, Env.FACTION_NUM do
		DelShowLadder(nType + i);
		AddNewShowLadder(nType + i);
		SetShowLadderName(nType + i, self.tbFacContext[i], string.len(self.tbFacContext[i]) + 1);
	end
	
	self:ProcessLevelShowLadderDetail(tbLevelLadderResult.tbLevelWorldLadder, nType, szContext, szLadderName);
	for i, tbLadder in pairs(tbLevelLadderResult.tbLevelFactLadder) do
		szContext		= szDate .. self.tbFacContext[i];
		szLadderName	= self.tbFacContext[i];
		self:ProcessLevelShowLadderDetail(tbLadder, nType + i, szContext, szLadderName);
	end
end

function Ladder:ProcessLevelShowLadderDetail(tbLevelLadder, nType, szContext, szLadderName)
	local tbShowWorldLadder = {};
	for i, tbInfo in ipairs(tbLevelLadder) do
		local tbPlayerInfo = GetPlayerInfoForLadderGC(tbInfo.szName);
		if (tbPlayerInfo) then
			local tbShowInfo = {};
			tbShowInfo.szName		= tbInfo.szName;
			tbShowInfo.szTxt1		= string.format("Cấp: %d", tbInfo.nValue);
			tbShowInfo.szContext	= string.format("Cấp: %d", tbInfo.nValue);
			tbShowInfo.dwImgType	= tbPlayerInfo.nSex;
			tbShowInfo.szTxt2		= Player:GetFactionRouteName(tbPlayerInfo.nFaction, tbPlayerInfo.nRoute);
			tbShowInfo.szTxt3		= string.format("Cấp: %d", tbPlayerInfo.nLevel);
			local szKinName			= tbPlayerInfo.szKinName
			if (not szKinName or string.len(szKinName) <= 0) then
				szKinName	= "Không phải thành viên gia tộc";
			end
			tbShowInfo.szTxt4 = "Gia tộc: " .. szKinName;
			
			local szTongName			= tbPlayerInfo.szTongName
			if (not szTongName or string.len(szTongName) <= 0) then
				szTongName	= "Không phải thành viên bang hội";
			end
			tbShowInfo.szTxt5 = "Bang hội: " .. szTongName;
			tbShowInfo.szTxt6	= "0";
			tbShowWorldLadder[#tbShowWorldLadder + 1] = tbShowInfo;
		end
	end
	SetShowLadder(nType, szContext, string.len(szContext) + 1, tbShowWorldLadder);
	SetShowLadderName(nType, szLadderName, string.len(szLadderName) + 1);
end

function Ladder:LoadTotalLadder(nType)
	LoadTotalLadder(nType);
end

function Ladder:SaveTotalLadder(nType)
	SaveTotalLadder(nType);
end

function Ladder:UpdateFactionHonorLadder()
	UpdateFactionHonorLadder(); -- 表示是需要保存到数据库中的
end


function Ladder:SetLadder(nType, szContext, nLen, tbLadderList)
	SetLadder(nType, szContext, nLen, tbLadderList);
end

function Ladder:GetType(nLadderType, nClass, nType, nNum3)
	if (nClass == 4 and nType == 3) then -- 因为不能移植联赛排行榜，所以干脆就做特殊处理
		nClass = 3;
	end
	return self:CalculateType(nLadderType, nClass, nType, nNum3);
end

function Ladder:CalculateType(nLadderType, nNum1, nNum2, nNum3)
	nLadderType = KLib.SetByte(nLadderType, 3, nNum1);
	nLadderType = KLib.SetByte(nLadderType, 2, nNum2);
	nLadderType = KLib.SetByte(nLadderType, 1, nNum3);
	return nLadderType;
end

function Ladder:GetClassByType(nLadderType)
	local nClass 		= KLib.GetByte(nLadderType, 3);
	local nType 		= KLib.GetByte(nLadderType, 2);
	local nNum  		= KLib.GetByte(nLadderType, 1);
	local nClassType 	= nLadderType - nClass*2^16 - nType*2^8 - nNum;
	return nClassType, nClass, nType, nNum;
end

function Ladder:WriteDbg(...)
	if (MODULE_GC_SERVER) then
		Dbg:Output("Ladder", unpack(arg));
	end
end

function Ladder:DailySchedule()
	self:LoadLevelLadder();
end

-- 加载门派荣誉排行榜
function Ladder:LoadFacHonor()
	local nType = 0;
	nType = self:GetType(0, self.LADDER_CLASS_WULIN, self.LADDER_TYPE_WULIN_HONOR_FACTION, 0);
	if (0 == LoadHonorLadderData(nType, PlayerHonor.HONOR_CLASS_FACTION, 0)) then
		self:WriteDbg("There is no ladder data, id is ", self.LADDER_CLASS_WULIN, self.LADDER_TYPE_WULIN_HONOR_FACTION, 0);
	end
	if (0 == LoadHonorLadderDataForFaction(nType)) then
		self:WriteDbg("Load faction ladder failed ", self.LADDER_CLASS_WULIN, self.LADDER_TYPE_WULIN_HONOR_FACTION, 0);
	end

end

function Ladder:LoadTotalLadders()
	print("Nạp dữ liệu xếp hạng");
	local nType			= 0;
	local nMigrateFlag	= 0;
	local nFlag = KGblTask.SCGetDbTaskInt(DBTASD_LADDER_MODIFYOLDLADDER);
	
	-- 0表示还没进行旧数据移植，和更新旧排行榜
	if (2 > nFlag) then
		print("Nạp lại dữ liệu xếp hạng");
		self:WriteDbg("LoadTotalLadders", "Migrate the Ladder data and the honor ladder");
		KGblTask.SCSetDbTaskInt(DBTASD_LADDER_MODIFYOLDLADDER, 2);
		nMigrateFlag = 1;
	end
	
	self:LoadFacHonor();
	if (1 == nMigrateFlag) then
		PlayerHonor:OnSchemeLoadFactionHonorLadder();
		local nType = self:GetType(0,2,2,0);
		DelShowLadder(nType);
	end

	for nClass, tbInfo in pairs(self.tbLadderConfig) do
		if (tbInfo.nGCStartLoad == 1) then
			self:LoadTotalLadder(tbInfo);
		end
		
		if (tbInfo.nSubLadderLoad == 1) then
			self:LoadSubTotalLadder(tbInfo);
		end
	end
	
	--删除原旧门派榜数据
--	if (tonumber(GetLocalDate("%Y%m%d%H")) <= 2009052612) then
--		for i=3, 12 do
--			local nType = self:GetType(0, self.LADDER_CLASS_LADDER, self.LADDER_TYPE_LADDER_ACTION, i);
--			DelShowLadder(nType);
--		end
--	end
	
	print("Hoàn thành dữ liệu xếp hạng");
	
end

function Ladder:LoadTotalLadder(tbInfo)
	local nType = self:GetType(0, tbInfo.nLadderClass, tbInfo.nLadderType, tbInfo.nLadderSmall);
	if (0 == LoadHonorLadderData(nType, tbInfo.nDataClass, 0, (tbInfo.nNoChangeRank or 0))) then
		self:WriteDbg("There is no ladder, id is ", tbInfo.nLadderClass, tbInfo.nLadderType, tbInfo.nLadderSmall);
	end
end

function Ladder:LoadSubTotalLadder(tbInfo)
	local nType = self:GetType(0, tbInfo.nLadderClass, tbInfo.nLadderType, tbInfo.nLadderSmall);
	if (0 == LoadHonorLadderDataForFaction(nType)) then
		self:WriteDbg("Load faction ladder failed ", tbInfo.nLadderClass, tbInfo.nLadderType, tbInfo.nLadderSmall);
	end
end

function Ladder:RefreshLadderName()
	GlobalExcute{"Ladder:RefreshLadderName"};
end

function Ladder:ClearTotalLadderData(nLadderType,nDataClass, nDataType, bAddNew)
	ClearTotalLadderData(nLadderType,nDataClass, nDataType, bAddNew);
	GlobalExcute({"Ladder:ClearTotalLadderData",nLadderType,nDataClass, nDataType, bAddNew});
end

Ladder:InitLadderConfig();

if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(Ladder.LoadTotalLadders, Ladder);
end
