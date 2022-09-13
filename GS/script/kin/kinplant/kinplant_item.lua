
local tbSeed = Item:GetClass("KinPlantSeed");

function tbSeed:OnUse()
	   
	if KinPlant:GetState() == 0 then
		Dialog:Say("Không phải thời gian hoạt động.",{"Biết rồi"});
		return 0;
	end
		
	if me.nLevel < KinPlant.nAttendMinLevel then
		Dialog:Say(string.format("Chưa đạt cấp %s, không được trồng trọt!", KinPlant.nAttendMinLevel),{"Biết rồi"});
		return 0;
	end
	if me.nFaction == 0 then
		Dialog:Say("Hãy gia nhập môn phái trước.",{"Biết rồi"});
		return 0;
	end	
	 self:PlantTree(me, it.dwId);
	return 0;
end

function tbSeed:PlantTree(pPlayer, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		Dialog:Say("Hạt giống đã quá hạn.");
		return;
	end
	
	local nRes, szMsg = KinPlant:CanPlantTree(pPlayer, pItem);
	if nRes == 1 then
		local tbEvent = 
			{
				Player.ProcessBreakEvent.emEVENT_MOVE,
				Player.ProcessBreakEvent.emEVENT_ATTACK,
				Player.ProcessBreakEvent.emEVENT_SITE,
				Player.ProcessBreakEvent.emEVENT_USEITEM,
				Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
				Player.ProcessBreakEvent.emEVENT_DROPITEM,
				Player.ProcessBreakEvent.emEVENT_SENDMAIL,
				Player.ProcessBreakEvent.emEVENT_TRADE,
				Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
				Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
				Player.ProcessBreakEvent.emEVENT_LOGOUT,
				Player.ProcessBreakEvent.emEVENT_DEATH,
			};
		GeneralProcess:StartProcess("Đang trồng...", 3 * Env.GAME_FPS, {KinPlant.Plant1stTree, KinPlant, pPlayer, dwItemId}, nil, tbEvent);
	 elseif szMsg then
		Dialog:Say(szMsg);
	end
end

function tbSeed:GetTip()
	local nIndex = tonumber(it.GetExtParam(1));
	if not nIndex or not KinPlant.tbPlantNpcInfo[nIndex] then
		return  "Hạt giống đã hết hạn.";
	end
	local tbName = {"Lương thực", "Hoa quả", "Hoa tươi"};
	local tbTypeInfo = {"Kinh nghiệm khá nhiều", "Huyền tinh khá nhiều", "Bạc khóa khá nhiều"};
	local tbWeather = {"Mưa", "Nắng gắt" , "Tuyết"};	
	local tbGrade = KinPlant.tbPlantNpcInfo[nIndex].tbGrade;
	local nType = KinPlant.tbPlantNpcInfo[nIndex].nType;
	local tbExp = KinPlant.tbPlantNpcInfo[nIndex].tbExp;
	local tbWeatherInfo = KinPlant.tbPlantNpcInfo[nIndex].tbWeather;
	local nDredging = KinPlant.tbPlantNpcInfo[nIndex].nDredging;
	local nMaxAwardCount = KinPlant.tbPlantNpcInfo[nIndex].nMaxAwardCount;
	local tbTime = KinPlant.tbPlantNpcInfo[nIndex].tbTime;
	local nChengzhang =0;
	local nChengshu = tbTime[#tbTime];
	for i = 1, #tbTime -1 do
		nChengzhang = nChengzhang + tbTime[i];
	end
	local tbDredgingFigure = {[0] = "Không thể bị nhổ đi", [1] = "Tộc trưởng", [2] = "Tộc phó trở lên", [3] = "Thành viên chính thức trở lên", [4] = "Thành viên danh dự trở lên", [5] = "Tất cả"}
	local szMsg = "";
	local nExpMsg = "";
	local nWeatherMsg = "";
	szMsg = szMsg.."<color=blue>Loại "..tbName[nType].."\n\n<color>";
	for i = 1, 3 do
		local szColor = "green";
		local szColorExp = "White";
		if tbGrade[i] and tbGrade[i] > 0 then
			if me.GetReputeLevel(14, i) < tbGrade[i] then
				szColor = "red";
			end
			if it.GetGenInfo(1) ~= 1 then
				szMsg = szMsg..string.format("<color=%s>Cần chuyên tinh %s (cấp %s)<color>\n", szColor,  tbName[i], tbGrade[i]);
			end
			if me.GetReputeLevel(14, i) ~= tbGrade[i] then
				szColorExp = "gray";
			end
		end
		if tbExp[i] > 0 then
			nExpMsg = nExpMsg..string.format("Trưởng thành chuyên tinh: <color=%s>%s <color> \n",szColorExp, tbName[i]);
		end
		local szInfo = "";
		local szWeatherColor = "";
		if tbWeatherInfo[i] < 0 then
			szInfo = "Giảm sản lượng";
			szWeatherColor = "red";
		elseif tbWeatherInfo[i] > 0 then
			szInfo = "Tăng sản lượng";
			szWeatherColor = "green";
		end
		if szInfo ~= "" and szColor ~= "" then
			nWeatherMsg = nWeatherMsg..string.format("<color=%s>Thời tiết: %s (%s)<color>\n", szWeatherColor, tbWeather[i], szInfo);
		end
	end	
	if it.GetGenInfo(1) == 1 then
		szMsg = szMsg.."<color=green>Đặt mua thực vật không yêu cầu cấp chuyên tinh\n<color>"
	end
	szMsg = szMsg.."\n";	
	szMsg = szMsg..nExpMsg;
	szMsg = szMsg..nWeatherMsg;
	szMsg = szMsg..string.format("Sản lượng lớn nhất: %s\n", nMaxAwardCount);
																		   
	szMsg = szMsg..string.format("Tỷ trọng phần thưởng: %s\n", tbTypeInfo[nType]);
	szMsg = szMsg..string.format("Thời gian trưởng thành: %s giờ %s phút %s giây\n", Lib:TransferSecond2NormalTime(nChengzhang));
	szMsg = szMsg..string.format("Thời gian chín: %s giờ %s phút %s giây\n", Lib:TransferSecond2NormalTime(nChengshu));
	return szMsg;
end
