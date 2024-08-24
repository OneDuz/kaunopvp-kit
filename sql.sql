--
-- Table structure for table `command_cooldowns`
--

CREATE TABLE `command_cooldowns` (
  `identifier` varchar(255) NOT NULL,
  `last_used` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for table `command_cooldowns`
--
ALTER TABLE `command_cooldowns`
  ADD PRIMARY KEY (`identifier`);