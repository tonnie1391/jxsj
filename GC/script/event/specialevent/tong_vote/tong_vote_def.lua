-- 文件名　：Tong_Vote_def.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-05 14:14:15
-- 描  述  ：

SpecialEvent.Tong_Vote = SpecialEvent.Tong_Vote or {};
local tbTong = SpecialEvent.Tong_Vote;
tbTong.TIME_START 	= 20101008;
tbTong.TIME_END		= 20101021;
tbTong.ITEM_AWARD	= {18,1,919,1}; -- 胜利徽章
tbTong.ITEM_VOTE	= {18,1,1273,1}; -- 投票道具
tbTong.MOENY_AWARD	= 3333;
tbTong.LEVEL_LIMIT	= 60;
tbTong.AWARD_LIMIT	= 100; --100次内获得绑银

tbTong.TSK_GROUP 	  = 2143;
tbTong.TSK_VOTE_COUNT = 34;
tbTong.IVER_OPEN	  = 1;