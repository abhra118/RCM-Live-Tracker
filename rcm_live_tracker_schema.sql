CREATE DATABASE  IF NOT EXISTS `rcm_live_tracker` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `rcm_live_tracker`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: rcm_live_tracker
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agent_dim`
--

DROP TABLE IF EXISTS `agent_dim`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_dim` (
  `agent_id` varchar(10) NOT NULL,
  `agent_name` varchar(100) NOT NULL,
  `team` varchar(50) NOT NULL,
  `role` varchar(100) DEFAULT NULL,
  `hourly_target` int NOT NULL,
  `baseline_accuracy` decimal(5,4) DEFAULT NULL,
  `active_flag` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`agent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `agent_hourly`
--

DROP TABLE IF EXISTS `agent_hourly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_hourly` (
  `activity_id` varchar(20) NOT NULL,
  `refresh_hour` datetime DEFAULT NULL,
  `agent_id` varchar(10) DEFAULT NULL,
  `agent_name` varchar(100) DEFAULT NULL,
  `team` varchar(50) DEFAULT NULL,
  `logged_in_hours` decimal(5,2) DEFAULT NULL,
  `claims_assigned` int DEFAULT NULL,
  `claims_processed` int DEFAULT NULL,
  `claims_paid` int DEFAULT NULL,
  `claims_denied` int DEFAULT NULL,
  `claims_pending` int DEFAULT NULL,
  `error_count` int DEFAULT NULL,
  `accuracy_rate` decimal(5,4) DEFAULT NULL,
  `claims_per_hour` decimal(8,2) DEFAULT NULL,
  `hourly_target` int DEFAULT NULL,
  `target_achievement_pct` decimal(6,4) DEFAULT NULL,
  `collection_amount_inr` decimal(12,2) DEFAULT NULL,
  `pending_workload` int DEFAULT NULL,
  `adherence_pct` decimal(5,4) DEFAULT NULL,
  PRIMARY KEY (`activity_id`),
  KEY `idx_activity_agent_hour` (`agent_id`,`refresh_hour`),
  CONSTRAINT `agent_hourly_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agent_dim` (`agent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `claim_fact`
--

DROP TABLE IF EXISTS `claim_fact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claim_fact` (
  `claim_id` varchar(20) NOT NULL,
  `claim_created_at` datetime DEFAULT NULL,
  `service_date` date DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `agent_id` varchar(10) DEFAULT NULL,
  `agent_name` varchar(100) DEFAULT NULL,
  `team` varchar(50) DEFAULT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `payer` varchar(100) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `procedure_name` varchar(100) DEFAULT NULL,
  `claim_status` varchar(30) DEFAULT NULL,
  `denial_reason` varchar(100) DEFAULT NULL,
  `billed_amount_inr` decimal(12,2) DEFAULT NULL,
  `paid_amount_inr` decimal(12,2) DEFAULT NULL,
  `outstanding_amount_inr` decimal(12,2) DEFAULT NULL,
  `days_in_ar` int DEFAULT NULL,
  `ar_bucket` varchar(20) DEFAULT NULL,
  `error_flag` varchar(10) DEFAULT NULL,
  `priority_flag` varchar(20) DEFAULT NULL,
  `last_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`claim_id`),
  KEY `agent_id` (`agent_id`),
  CONSTRAINT `claim_fact_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agent_dim` (`agent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `refresh_log`
--

DROP TABLE IF EXISTS `refresh_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_log` (
  `refresh_id` varchar(20) NOT NULL,
  `refresh_timestamp` datetime DEFAULT NULL,
  `rows_added_claims` int DEFAULT NULL,
  `rows_added_agent_activity` int DEFAULT NULL,
  `refresh_status` varchar(30) DEFAULT NULL,
  `data_source` varchar(100) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`refresh_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `vw_live_agent_performance`
--

DROP TABLE IF EXISTS `vw_live_agent_performance`;
/*!50001 DROP VIEW IF EXISTS `vw_live_agent_performance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_live_agent_performance` AS SELECT 
 1 AS `last_updated_at`,
 1 AS `agent_id`,
 1 AS `agent_name`,
 1 AS `team`,
 1 AS `role`,
 1 AS `logged_in_hours`,
 1 AS `claims_assigned`,
 1 AS `claims_processed`,
 1 AS `claims_paid`,
 1 AS `claims_denied`,
 1 AS `claims_pending`,
 1 AS `error_count`,
 1 AS `accuracy_rate`,
 1 AS `claims_per_hour`,
 1 AS `hourly_target`,
 1 AS `target_achievement_pct`,
 1 AS `collection_amount_inr`,
 1 AS `pending_workload`,
 1 AS `adherence_pct`,
 1 AS `performance_rank`,
 1 AS `performance_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_rcm_live_kpis`
--

DROP TABLE IF EXISTS `vw_rcm_live_kpis`;
/*!50001 DROP VIEW IF EXISTS `vw_rcm_live_kpis`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_rcm_live_kpis` AS SELECT 
 1 AS `last_updated_at`,
 1 AS `total_claims`,
 1 AS `paid_claims`,
 1 AS `denied_claims`,
 1 AS `pending_claims`,
 1 AS `in_process_claims`,
 1 AS `total_billed_inr`,
 1 AS `total_collections_inr`,
 1 AS `total_outstanding_ar_inr`,
 1 AS `collection_rate`,
 1 AS `denial_rate`,
 1 AS `ar_0_30_claims`,
 1 AS `ar_31_60_claims`,
 1 AS `ar_61_90_claims`,
 1 AS `ar_90_plus_claims`,
 1 AS `high_priority_claims`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_live_agent_performance`
--

/*!50001 DROP VIEW IF EXISTS `vw_live_agent_performance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_live_agent_performance` AS with `latest_refresh` as (select max(`agent_hourly`.`refresh_hour`) AS `latest_hour` from `agent_hourly`) select `h`.`refresh_hour` AS `last_updated_at`,`h`.`agent_id` AS `agent_id`,`h`.`agent_name` AS `agent_name`,`h`.`team` AS `team`,`d`.`role` AS `role`,`h`.`logged_in_hours` AS `logged_in_hours`,`h`.`claims_assigned` AS `claims_assigned`,`h`.`claims_processed` AS `claims_processed`,`h`.`claims_paid` AS `claims_paid`,`h`.`claims_denied` AS `claims_denied`,`h`.`claims_pending` AS `claims_pending`,`h`.`error_count` AS `error_count`,`h`.`accuracy_rate` AS `accuracy_rate`,`h`.`claims_per_hour` AS `claims_per_hour`,`h`.`hourly_target` AS `hourly_target`,`h`.`target_achievement_pct` AS `target_achievement_pct`,`h`.`collection_amount_inr` AS `collection_amount_inr`,`h`.`pending_workload` AS `pending_workload`,`h`.`adherence_pct` AS `adherence_pct`,dense_rank() OVER (ORDER BY `h`.`target_achievement_pct` desc,`h`.`accuracy_rate` desc )  AS `performance_rank`,(case when ((`h`.`target_achievement_pct` >= 1) and (`h`.`accuracy_rate` >= 0.97)) then 'Exceeding Target' when (`h`.`target_achievement_pct` >= 0.90) then 'On Track' else 'Needs Support' end) AS `performance_status` from ((`agent_hourly` `h` join `agent_dim` `d` on((`h`.`agent_id` = `d`.`agent_id`))) join `latest_refresh` `lr` on((`h`.`refresh_hour` = `lr`.`latest_hour`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_rcm_live_kpis`
--

/*!50001 DROP VIEW IF EXISTS `vw_rcm_live_kpis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_rcm_live_kpis` AS select max(`claim_fact`.`last_updated_at`) AS `last_updated_at`,count(0) AS `total_claims`,sum((`claim_fact`.`claim_status` = 'Paid')) AS `paid_claims`,sum((`claim_fact`.`claim_status` = 'Denied')) AS `denied_claims`,sum((`claim_fact`.`claim_status` = 'Pending')) AS `pending_claims`,sum((`claim_fact`.`claim_status` = 'In Process')) AS `in_process_claims`,round(sum(`claim_fact`.`billed_amount_inr`),2) AS `total_billed_inr`,round(sum(`claim_fact`.`paid_amount_inr`),2) AS `total_collections_inr`,round(sum(`claim_fact`.`outstanding_amount_inr`),2) AS `total_outstanding_ar_inr`,round((sum(`claim_fact`.`paid_amount_inr`) / nullif(sum(`claim_fact`.`billed_amount_inr`),0)),4) AS `collection_rate`,round((sum((`claim_fact`.`claim_status` = 'Denied')) / nullif(count(0),0)),4) AS `denial_rate`,sum((`claim_fact`.`ar_bucket` = '0-30')) AS `ar_0_30_claims`,sum((`claim_fact`.`ar_bucket` = '31-60')) AS `ar_31_60_claims`,sum((`claim_fact`.`ar_bucket` = '61-90')) AS `ar_61_90_claims`,sum((`claim_fact`.`ar_bucket` = '90+')) AS `ar_90_plus_claims`,sum((`claim_fact`.`priority_flag` = 'High')) AS `high_priority_claims` from `claim_fact` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-05  2:14:42
