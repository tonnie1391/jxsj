
---

local tbNpc = Npc:GetClass("xoyonpc_dialog")

local tbDialogMsg = 
{
--	NPC ID   进度条字样		横幅字样
	[3251] = {"Khảo sát...",	"Đá đã rơi xuống, ngay lập tức một không khí ngột ngạp áp thẳng vào sườn đồi khi chúng tôi đến."},
	[3252] = {"Mở cơ quan...",	"Cơ quan đã được mở."},
	[3253] = {"Mở cơ quan...",	"Cơ quan đã được mở."},
	[3254] = {"Mở cơ quan...",	"Đá đã rơi xuống, cánh cổng sắt phía trước được mở ra."},
	[3255] = {"Mở cơ quan...",	"Đá đã rơi xuống, hầm bí mật được mở ra."},
	[3289] = {"Khảo sát...",	"Bức tượng đã đổ, thú dữ xuất hiện xung quanh rất nhiều..."},
	[3257] = {"Mở túi...",	"Ồ! Có rất nhiều trái cây ngon...Không! Quả nông ra rồi!"},
	[3258] = {"Mở rương...",	"Ồ! Có rất nhiều kho báu...Không! Đây là một cái bẫy..."},
	[3259] = {"Hái...",	"Quả đã được hái, thu hút rất nhiều lũ Khỉ Hoang..."},
	[3260] = {"Mở rương...",	"Có bẫy!..."},
	[3293] = {"Mở rương...",	"Rương trống trơn bên trong không có gì..."},
	[3298] = {"Khảo sát...",	"Có điều gì đó chẳng lành..."},
	[3299] = {"Khảo sát...",	"Thực sự đó là một cái bẫy..."},
	[3300] = {"Khảo sát...",	"Đó là một cái bẫy..."},
	[3304] = {"Mở túi...",	"Gửi lại dưa hấu cho ông ấy, xem có thể giúp được gì."},
	[4656] = {"Mở cơ quan...", "Bên kia cánh cổng đã được mở!"}, 
	[4657] = {"Mở cơ quan...", "Bên kia cánh cổng đã được mở!"}, 
	[4658] = {"Mở cơ quan...", "Bên kia cánh cổng đã được mở!"}, 
	[4659] = {"Mở cơ quan...", "Bên kia cánh cổng đã được mở!"},
	[7344] = {"Mở cơ quan...", "Vượt qua chướng ngại vật thôi!"},
	[10192] ={"Đang hái...","Một quả dưa hấu lớn!"},
	[10196] ={"Mở rương kho báu...","Mở rương kho báu thành công!"},
	[10203] ={"Đang tìm hiểu...","Một số chữ mơ hồ được ghi trên Bia Kiếm!"},
}

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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
}

function tbNpc:OnDialog()
	local nTime = tonumber(him.GetSctiptParam());
	if not nTime then
		self:EndProcess(him.dwId);
	else
		if him.GetTempTable("XoyoGame").nDontTalk then
			return;
		else
			if XoyoGame:IsInLock(him) == 1 then
				local szMsg = "Đang mở...";
	 			if tbDialogMsg[him.nTemplateId] then
	 				szMsg =  tbDialogMsg[him.nTemplateId][1];
	 			end
				GeneralProcess:StartProcess(szMsg, nTime * Env.GAME_FPS, {self.EndProcess, self, him.dwId}, nil, tbEvent);
			end
		end
	end
end

function tbNpc:EndProcess(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
 	end
 	XoyoGame:NpcUnLock(pNpc);
 	XoyoGame:NpcClearLock(pNpc);
 	local szMsg = "Mở thành công";
 	if tbDialogMsg[pNpc.nTemplateId] then
 		szMsg =  tbDialogMsg[pNpc.nTemplateId][2];
 	end
 	pNpc.Delete();
 	Dialog:SendBlackBoardMsg(me, szMsg);
 	
end

