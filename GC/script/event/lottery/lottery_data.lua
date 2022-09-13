Lottery.tbLottery = {}; -- [szName] -> used_ticket_number
Lottery.tbAward = {}; -- [nDate] ->{[szName] -> {gold_num, silver_num, bronze_num}, ...} 每个玩家的获奖状况用1,2,3索引，分别代表金银铜，可能为nil
Lottery.tbGoldPlayerName = {};
Lottery.tbDayAward = {};
Lottery.tbGoldPlayerNameSubZone = {}; -- 保存从服金奖数据
