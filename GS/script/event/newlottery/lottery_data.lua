-- 文件名　：lottery_data.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-18 19:12:49
-- 描  述  ：
NewLottery.tbLottery = {}; -- [szName] -> used_ticket_number
NewLottery.tbStudioRoleList = {};
NewLottery.tbAward = {}; -- [nDate] ->{[szName] -> {gold_num, silver_num, bronze_num}, ...} 每个玩家的获奖状况用1,2,3索引，分别代表金银铜，可能为nil
NewLottery.tbGoldPlayerName = {};
NewLottery.tbGoldPlayerNameYear = {};
NewLottery.tbGoldPlayerNameYear_CoSub = {};