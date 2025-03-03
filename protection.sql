CREATE TABLE IF NOT EXISTS `player_protection` (
    `citizenid` varchar(50) NOT NULL,
    `completed` boolean DEFAULT false,
    `remaining_time` int DEFAULT 0,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;