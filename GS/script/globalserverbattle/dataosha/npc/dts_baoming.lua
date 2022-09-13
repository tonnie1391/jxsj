-- 文件名　：dts_baoming.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-13
-- 描  述  ：英雄岛报名官

local tbNpc = Npc:GetClass("dataosha_baoming");

function tbNpc:OnDialog()
	local nFlag = 0;
	local nTime = tonumber(GetLocalDate("%H%M"));
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nWeek = tonumber(GetLocalDate("%w"));
	if nDate >= DaTaoSha.nStatTime and nDate <= DaTaoSha.nEndTime then
		if (nTime >= DaTaoSha.OPENTIME[1] and nTime <= DaTaoSha.CLOSETIME[1]) or (nTime >= DaTaoSha.OPENTIME[2] and nTime <= DaTaoSha.CLOSETIME[2] and nWeek ~= 6) then
			nFlag = 1;
		end
	end
	if nFlag == 0 then
		Dialog:Say(string.format("Bây giờ chưa đến thời gian tham gia hoạt động.\n\nThời gian hoạt động: \n<color=yellow>%s-%s\n+ 10 giờ-14 giờ\n+ 18 giờ-23 giờ<color>\n<color=red>Lưu ý: Tối thứ 7 không mở.<color>", os.date("%Y年%m月%d日",Lib:GetDate2Time(DaTaoSha.nStatTime)), os.date("%Y-%m-%d",Lib:GetDate2Time(DaTaoSha.nEndTime))), {"Ta hiểu"});
		return;
	end
	
	local nLevel = DaTaoSha.MACTH_PRIM;
	local tbOpt = {
		{"Tham gia cá nhân", DaTaoSha.tbNpc.JoinOne, DaTaoSha.tbNpc, DaTaoSha.MACTH_PRIM},
		{"Tham gia theo tổ đội", DaTaoSha.tbNpc.JoinTeam, DaTaoSha.tbNpc, DaTaoSha.MACTH_PRIM},
		--{"请送我去高级场", DaTaoSha.tbNpc.Join, DaTaoSha.tbNpc, DaTaoSha.MACTH_ADV},
		--{"参加大逃杀", DaTaoSha.tbNpc.Join, DaTaoSha.tbNpc, nLevel},
		{"Không"},
	};	
	Dialog:Say("Hàn phong trường mạc mạc, vũ hầu chinh tứ phương. Tuyết hồn thích ly thương, ngạo tuyết độc phi dương. Giữa bầu trời đầy băng tuyết này, mấy ai hiểu được trận chiến hỏa vô tình năm xưa?", tbOpt);	
end


