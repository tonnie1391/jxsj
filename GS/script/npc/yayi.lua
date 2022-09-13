-- 衙役

local tbNpc = Npc:GetClass("yayi");

tbNpc.nLinanYayiId		= 29;		-- 临安府衙役的地图ID
tbNpc.nBianjingYayiId 	= 23;		-- 汴京府衙役的地图ID
tbNpc.nYayiX_Linan		= 1688;		-- 临安府衙役的X坐标
tbNpc.nYayiY_Linan		= 3771;		-- 临安府衙役的Y坐标
tbNpc.nYayiX_Bianjing	= 1639;		-- 汴京府衙役的X坐标
tbNpc.nYayiY_Bianjing	= 3094;		-- 汴京府衙役的Y坐标

tbNpc.nLinanDalaoId		= 223;		-- 临安府大牢的地图ID
tbNpc.nBianjingDalaoId	= 222;		-- 汴京府大牢的地图ID
tbNpc.nDalaoX			= 1651;		-- 大牢的X坐标
tbNpc.nDalaoY			= 3260;		-- 大牢的Y坐标

function tbNpc:OnDialog()
	Dialog:Say("Tình hình thế giới đang rất hỗn loạn, rất nhiều kẻ sát nhân máu lạnh đang lộng hành. Ngươi đến đây làm gì?",
				{
					{"Ta đi đến tự thú", self.Zishou, self},
					{"Ta không biết"}
				});
end

-- 玩家自首,与衙役的对话
function tbNpc:Zishou()
	local nExpPercent = math.floor(me.GetExp() * (-100) / me.GetUpLevelExp());
	
	-- 恶名值不大于0,不用坐牢
	if (me.nPKValue <= 0) then
		Dialog:Say(me.szName..": Ta đã vô tình đã thương người khác.<enter><enter>"..
			"Nha Dịch: Nha môn đã điều tra, ngươi chỉ tự vệ, nên không có tội gì!");
		return;
	end
	-- 异常情况下越狱了
	if (me.GetTempTable("Npc").nNpcYuzuTimerId ~= nil) then
		Dialog:Say("Nha Dịch: Ngươi vẫn chưa mãn hạn tù. Hãy tiếp tục thọ án!");
		self:TransferPos(me.GetMapId(), me);
		return;
	end
	-- 负经验值低于50%
	if (nExpPercent > 50) then
		me.Msg("Lệnh của triều đình: Những ai có kinh nghiệm trên 50% không được thọ án!");
		Dialog:Say("Nha Dịch: Một tên máu lạnh như ngươi lại xin được thọ án sao? Ngươi xứng đáng bị truy sát!");
		return;
	end
	Dialog:Say(me.szName..": Ta đã vô tình đã thương người khác, xin hãy giảm nhẹ hình phạt",  {"Tiếp tục", self.FollowWithYayiDialog, self});
end

-- 自首的玩家和衙役继续对话
function tbNpc:FollowWithYayiDialog()
	local tbNpcYuzu 					= Npc:GetClass("yuzu");
	local nReduceOnePkHour, nSumTimer	= tbNpcYuzu:OnePkTime(me.nPKValue);
	local szXiaoshi, szShichen			= Lib:GetCnTime(nSumTimer);
	local szMsg = string.format("Nha Dịch: Tay ngươi nhuốm đầy máu, hãy ăn năn trong đại lao trước khi được tại ngoại.\n\n Bản án của ngươi như sau: %s Trị PK: %s, thời gian mãn hạn tù: %s", me.szName, me.nPKValue, szXiaoshi);
	Dialog:Say(szMsg,
				{
					{"Tiến vào Đại lao", self.Renzui, self},
					{"Cho ta suy nghĩ lại"}
				});
end

-- 认罪
function tbNpc:Renzui()
	local tbNpcYuzu = Npc:GetClass("yuzu");
	me.SetTask(tbNpcYuzu.tbTaskIdReduceOnePkSec[1], tbNpcYuzu.tbTaskIdReduceOnePkSec[2], 0);
	self:TransferPos(me.GetMapId(), me);
end

function tbNpc:TransferPos(nMapId, pPlayer)
	if (nMapId == self.nLinanYayiId) then						-- 从临安府衙役处进大牢
		pPlayer.NewWorld(self.nLinanDalaoId, self.nDalaoX, self.nDalaoY);
	elseif (nMapId == self.nBianjingYayiId) then				-- 从汴京府衙役处进大牢
		pPlayer.NewWorld(self.nBianjingDalaoId, self.nDalaoX, self.nDalaoY);
	elseif (nMapId == self.nLinanDalaoId) then					-- 从临安府大牢处出来至临安符的衙役处
		pPlayer.NewWorld(self.nLinanYayiId, self.nYayiX_Linan, self.nYayiY_Linan);
	else														-- 从汴京府大牢处出来至汴京府的衙役处
		pPlayer.NewWorld(self.nBianjingYayiId, self.nYayiX_Bianjing, self.nYayiY_Bianjing);
	end
	
	me.SetFightState(0);
end
