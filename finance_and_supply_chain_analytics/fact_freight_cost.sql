-- MySQL dump 10.13  Distrib 8.0.28, for Win64 (x86_64)
--
-- Host: localhost    Database: gdb0041
-- ------------------------------------------------------
-- Server version	8.0.28

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
-- Table structure for table `fact_freight_cost`
--

DROP TABLE IF EXISTS `fact_freight_cost`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fact_freight_cost` (
  `market` varchar(45) NOT NULL,
  `fiscal_year` year NOT NULL,
  `freight_pct` decimal(5,4) unsigned NOT NULL,
  `other_cost_pct` decimal(5,4) unsigned NOT NULL,
  PRIMARY KEY (`market`,`fiscal_year`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fact_freight_cost`
--

LOCK TABLES `fact_freight_cost` WRITE;
/*!40000 ALTER TABLE `fact_freight_cost` DISABLE KEYS */;
INSERT INTO `fact_freight_cost` VALUES ('Australia',2018,0.0188,0.0050),('Australia',2019,0.0304,0.0048),('Australia',2020,0.0254,0.0043),('Australia',2021,0.0254,0.0043),('Australia',2022,0.0254,0.0043),('Austria',2018,0.0272,0.0053),('Austria',2019,0.0292,0.0050),('Austria',2020,0.0294,0.0034),('Austria',2021,0.0294,0.0034),('Austria',2022,0.0294,0.0034),('Bangladesh',2018,0.0219,0.0058),('Bangladesh',2019,0.0249,0.0053),('Bangladesh',2020,0.0258,0.0035),('Bangladesh',2021,0.0258,0.0035),('Bangladesh',2022,0.0258,0.0035),('Brazil',2018,0.0239,0.0033),('Brazil',2019,0.0193,0.0046),('Brazil',2020,0.0298,0.0046),('Brazil',2021,0.0298,0.0046),('Brazil',2022,0.0298,0.0046),('Canada',2018,0.0264,0.0054),('Canada',2019,0.0217,0.0030),('Canada',2020,0.0273,0.0055),('Canada',2021,0.0273,0.0055),('Canada',2022,0.0273,0.0055),('Chile',2018,0.0267,0.0022),('Chile',2019,0.0223,0.0061),('Chile',2020,0.0219,0.0037),('Chile',2021,0.0219,0.0037),('Chile',2022,0.0219,0.0037),('China',2018,0.0204,0.0043),('China',2019,0.0216,0.0031),('China',2020,0.0311,0.0044),('China',2021,0.0311,0.0044),('China',2022,0.0311,0.0044),('Columbia',2018,0.0216,0.0028),('Columbia',2019,0.0256,0.0032),('Columbia',2020,0.0293,0.0025),('Columbia',2021,0.0293,0.0025),('Columbia',2022,0.0293,0.0025),('France',2018,0.0190,0.0038),('France',2019,0.0284,0.0055),('France',2020,0.0235,0.0060),('France',2021,0.0235,0.0060),('France',2022,0.0235,0.0060),('Germany',2018,0.0301,0.0061),('Germany',2019,0.0249,0.0043),('Germany',2020,0.0226,0.0060),('Germany',2021,0.0226,0.0060),('Germany',2022,0.0226,0.0060),('India',2018,0.0244,0.0026),('India',2019,0.0219,0.0057),('India',2020,0.0309,0.0029),('India',2021,0.0309,0.0029),('India',2022,0.0309,0.0029),('Indonesia',2018,0.0190,0.0042),('Indonesia',2019,0.0187,0.0052),('Indonesia',2020,0.0195,0.0023),('Indonesia',2021,0.0195,0.0023),('Indonesia',2022,0.0195,0.0023),('Italy',2018,0.0214,0.0033),('Italy',2019,0.0244,0.0059),('Italy',2020,0.0221,0.0027),('Italy',2021,0.0221,0.0027),('Italy',2022,0.0221,0.0027),('Japan',2018,0.0252,0.0042),('Japan',2019,0.0287,0.0045),('Japan',2020,0.0294,0.0051),('Japan',2021,0.0294,0.0051),('Japan',2022,0.0294,0.0051),('Mexico',2018,0.0264,0.0027),('Mexico',2019,0.0285,0.0044),('Mexico',2020,0.0262,0.0056),('Mexico',2021,0.0262,0.0056),('Mexico',2022,0.0262,0.0056),('Netherlands',2018,0.0255,0.0033),('Netherlands',2019,0.0252,0.0027),('Netherlands',2020,0.0310,0.0028),('Netherlands',2021,0.0310,0.0028),('Netherlands',2022,0.0310,0.0028),('Newzealand',2018,0.0228,0.0060),('Newzealand',2019,0.0287,0.0051),('Newzealand',2020,0.0259,0.0045),('Newzealand',2021,0.0259,0.0045),('Newzealand',2022,0.0259,0.0045),('Norway',2018,0.0260,0.0026),('Norway',2019,0.0218,0.0040),('Norway',2020,0.0311,0.0034),('Norway',2021,0.0311,0.0034),('Norway',2022,0.0311,0.0034),('Pakistan',2018,0.0241,0.0058),('Pakistan',2019,0.0227,0.0024),('Pakistan',2020,0.0276,0.0023),('Pakistan',2021,0.0276,0.0023),('Pakistan',2022,0.0276,0.0023),('Philiphines',2018,0.0199,0.0027),('Philiphines',2019,0.0287,0.0027),('Philiphines',2020,0.0285,0.0043),('Philiphines',2021,0.0285,0.0043),('Philiphines',2022,0.0285,0.0043),('Poland',2018,0.0211,0.0036),('Poland',2019,0.0206,0.0056),('Poland',2020,0.0232,0.0036),('Poland',2021,0.0232,0.0036),('Poland',2022,0.0232,0.0036),('Portugal',2018,0.0264,0.0029),('Portugal',2019,0.0287,0.0032),('Portugal',2020,0.0217,0.0040),('Portugal',2021,0.0217,0.0040),('Portugal',2022,0.0217,0.0040),('South Korea',2018,0.0293,0.0043),('South Korea',2019,0.0214,0.0036),('South Korea',2020,0.0210,0.0037),('South Korea',2021,0.0210,0.0037),('South Korea',2022,0.0210,0.0037),('Spain',2018,0.0189,0.0052),('Spain',2019,0.0305,0.0047),('Spain',2020,0.0222,0.0055),('Spain',2021,0.0222,0.0055),('Spain',2022,0.0222,0.0055),('Sweden',2018,0.0218,0.0023),('Sweden',2019,0.0312,0.0045),('Sweden',2020,0.0272,0.0055),('Sweden',2021,0.0272,0.0055),('Sweden',2022,0.0272,0.0055),('United Kingdom',2018,0.0224,0.0051),('United Kingdom',2019,0.0190,0.0041),('United Kingdom',2020,0.0217,0.0048),('United Kingdom',2021,0.0217,0.0048),('United Kingdom',2022,0.0217,0.0048),('USA',2018,0.0279,0.0027),('USA',2019,0.0263,0.0039),('USA',2020,0.0270,0.0052),('USA',2021,0.0270,0.0052),('USA',2022,0.0270,0.0052);
/*!40000 ALTER TABLE `fact_freight_cost` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-03-20 15:22:31
