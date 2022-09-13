-- 文件名　：dayplayerback_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-03 11:17:44
-- 功能    ：

SpecialEvent.tbDayPlayerBack = SpecialEvent.tbDayPlayerBack or {};
local tbDayPlayerBack = SpecialEvent.tbDayPlayerBack or {};

tbDayPlayerBack.TASK_GID 			= 2195;
tbDayPlayerBack.TASK_ID_BATCH	= 45;
tbDayPlayerBack.TASK_RATE_BACK	= 46;
tbDayPlayerBack.TASK_TIME_BATCH	= 47;

tbDayPlayerBack.nTimeLimit = 7 * 24 * 3600;
tbDayPlayerBack.nLevelLimit = 50;

tbDayPlayerBack.tbChangeTime = {20121008, 20121115, 1.5}		--调整时间及参数

tbDayPlayerBack.tbLing = {18,1,1754,1};	--征战江湖令

tbDayPlayerBack.tbAwardList = {
	--奖励名字，基础量，最大量，具体奖励类型及参数，有效期（不填表示永久）,领取批次，领取时间
	{"Lệnh Chinh Chiến Giang Hồ", 		1, 1, 		[[AddItem:"18,1,1754,1",1,1,43200]], nil, 1, 2},
	{"Nhận thời gian tu luyện", 		6*60, 72*60, 	"ExeAddXiulianTime: %s", nil, 3, 4},
	{"Nhận thời gian ủy thác rời mạng", 	24 * 60, 240 * 60, 	"AddOfflineTime: %s", nil, 5, 6},
	{"Nhận cơ hội mở Túi phúc", 	30, 360, 	"AddExOpenFuDai: %s", nil, 7, 8},
	{"Nhận cơ hội chúc phúc", 		3, 36, 	"AddExOpenQiFu: %s", nil, 9, 10},
	{"Nhận Túi Phúc (20 Túi Phúc)", 	1, 5, [[AddItem:"18,1,303,2",%s,1,""]], nil, 11, 12},
	{"Nhận số lần Tàng Bảo Đồ", 			3, 15,"AddGTask:%s,%s,%s", nil, 13, 14},
	{"Hiệp Khách Ấn", 			2*24*60, 8*24*60, [[AddItem:"1,18,%s,1",1,1,%s]], 20121115, 15, 16, 20121008},
	{"Giảm 80%% Rương Hồn Thạch (1000 cái)", 			1, 5, [[AddItem:"18,1,1696,1",%s,1,""]], nil, 17, 18},
	{"Vé đồng khóa trả lại (1000 điểm)", 		1, 5,  [[AddItem:"18,1,1309,1",%s,1,""]], nil, 19, 20},
	{"Phiếu hoàn trả Bạc khóa (500000 điểm)", 	1, 5,  [[AddItem:"18,1,1352,2",%s,1,""]], nil, 21, 22},
	{"Thỏi bạc Gia tộc", 	1, 15,  [[AddItem:"18,1,1787,1",%s,1,""]], 20121115, 51, 52, 20121008},
	}

tbDayPlayerBack.tbEventList = {
	--征战令牌活动，基础量，最大量，可以参加的次数，已经参加的次
	{"Truy Nã", 	9, 36, 23,24},
	{"Tiêu Dao Cốc", 	3, 15, 25,26},
	{"Tàng Bảo Đồ", 	3, 15, 27, 28},
	{"Bạch Hổ Đường", 	2, 10, 29, 30},
	{"Quân doanh", 		3, 30, 31, 32},
	{"Đoán Hoa Đăng ", 	2, 20, 33, 34},
	{"Ải Gia Tộc (Sơ)", 2, 10, 35, 36},
	{"Ải Gia Tộc (Cao)", 2, 10, 37, 38},
	{"Tranh đoạt lãnh thổ", 1, 5, 39, 40},
	{"Trồng cây Gia tộc", 6, 60, 41, 42},
	{"Nhiệm vụ hiệp khách", 1, 4, 43, 44},
	}

tbDayPlayerBack.tbTreasureLing = {
	["18,1,995,2"] = 2,
	["18,1,995,3"] = 3,
	["18,1,995,4"] = 4,
	["18,1,996,2"] = 3,
	["18,1,996,3"] = 4,
	["18,1,996,4"] = 5,
	["18,1,997,2"] = 4,
	["18,1,997,3"] = 5,
	["18,1,997,4"] = 6,
	["18,1,998,2"] = 7,
	["18,1,998,3"] = 8,
	["18,1,998,4"] = 9,
	["18,1,999,2"] = 5,
	["18,1,999,3"] = 6,
	["18,1,999,4"] = 7,
	["18,1,1019,1"] = 4,
	["18,1,1019,2"] = 5,
	["18,1,1019,3"] = 6,
}

tbDayPlayerBack.tbNameTreasure = {
	[3] = "Thông dụng",
	[4] = "Đào Chu Công Mộ Chủng",
	[5] = "Đại Mạc Cổ Thành",
	[6] = "Vạn Hoa Cốc",
	[7] = "Thiên Quỳnh Cung",
	[8] = "Long Môn Phi Kiếm",
	[9] = "Bích Lạc Cốc",
	}

tbDayPlayerBack.tbLevelLimit = {
	[1] = 50,
	[2] = 60,
	[3] = 70,
	[4] = 80,
	[5] = 90,
	[6] = 100,
	[7] = 110,
	[8] = 120,	
	[9] = 130,	
	}
