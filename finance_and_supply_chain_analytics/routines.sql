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
-- Temporary view structure for view `gross_sales`
--

DROP TABLE IF EXISTS `gross_sales`;
/*!50001 DROP VIEW IF EXISTS `gross_sales`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `gross_sales` AS SELECT 
 1 AS `date`,
 1 AS `fiscal_year`,
 1 AS `customer_code`,
 1 AS `customer`,
 1 AS `market`,
 1 AS `product_code`,
 1 AS `product`,
 1 AS `variant`,
 1 AS `sold_quantity`,
 1 AS `gross_price_per_item`,
 1 AS `gross_price_total`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `sales_postinv_discount`
--

DROP TABLE IF EXISTS `sales_postinv_discount`;
/*!50001 DROP VIEW IF EXISTS `sales_postinv_discount`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `sales_postinv_discount` AS SELECT 
 1 AS `date`,
 1 AS `fiscal_year`,
 1 AS `customer_code`,
 1 AS `market`,
 1 AS `product_code`,
 1 AS `product`,
 1 AS `variant`,
 1 AS `sold_quantity`,
 1 AS `gross_price_total`,
 1 AS `pre_invoice_discount_pct`,
 1 AS `net_invoice_sales`,
 1 AS `post_invoice_discount_pct`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `net_sales`
--

DROP TABLE IF EXISTS `net_sales`;
/*!50001 DROP VIEW IF EXISTS `net_sales`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `net_sales` AS SELECT 
 1 AS `date`,
 1 AS `fiscal_year`,
 1 AS `customer_code`,
 1 AS `market`,
 1 AS `product_code`,
 1 AS `product`,
 1 AS `variant`,
 1 AS `sold_quantity`,
 1 AS `gross_price_total`,
 1 AS `pre_invoice_discount_pct`,
 1 AS `net_invoice_sales`,
 1 AS `post_invoice_discount_pct`,
 1 AS `net_sales`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `sales_preinv_discount`
--

DROP TABLE IF EXISTS `sales_preinv_discount`;
/*!50001 DROP VIEW IF EXISTS `sales_preinv_discount`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `sales_preinv_discount` AS SELECT 
 1 AS `date`,
 1 AS `fiscal_year`,
 1 AS `product_code`,
 1 AS `customer_code`,
 1 AS `market`,
 1 AS `product`,
 1 AS `variant`,
 1 AS `sold_quantity`,
 1 AS `gross_price`,
 1 AS `gross_price_total`,
 1 AS `pre_invoice_discount_pct`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `gross_sales`
--

/*!50001 DROP VIEW IF EXISTS `gross_sales`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `gross_sales` AS select `s`.`date` AS `date`,`s`.`fiscal_year` AS `fiscal_year`,`s`.`customer_code` AS `customer_code`,`c`.`customer` AS `customer`,`c`.`market` AS `market`,`s`.`product_code` AS `product_code`,`p`.`product` AS `product`,`p`.`variant` AS `variant`,`s`.`sold_quantity` AS `sold_quantity`,`g`.`gross_price` AS `gross_price_per_item`,(`s`.`sold_quantity` * `g`.`gross_price`) AS `gross_price_total` from (((`fact_sales_monthly` `s` join `fact_gross_price` `g` on((`s`.`product_code` = `g`.`product_code`))) join `dim_customer` `c` on((`s`.`customer_code` = `c`.`customer_code`))) join `dim_product` `p` on(((`s`.`product_code` = `p`.`product_code`) and (`s`.`fiscal_year` = `g`.`fiscal_year`)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sales_postinv_discount`
--

/*!50001 DROP VIEW IF EXISTS `sales_postinv_discount`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `sales_postinv_discount` AS select `s`.`date` AS `date`,`s`.`fiscal_year` AS `fiscal_year`,`s`.`customer_code` AS `customer_code`,`s`.`market` AS `market`,`s`.`product_code` AS `product_code`,`s`.`product` AS `product`,`s`.`variant` AS `variant`,`s`.`sold_quantity` AS `sold_quantity`,`s`.`gross_price_total` AS `gross_price_total`,`s`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct`,(`s`.`gross_price_total` - (`s`.`pre_invoice_discount_pct` * `s`.`gross_price_total`)) AS `net_invoice_sales`,(`po`.`discounts_pct` + `po`.`other_deductions_pct`) AS `post_invoice_discount_pct` from (`sales_preinv_discount` `s` join `fact_post_invoice_deductions` `po` on(((`s`.`date` = `po`.`date`) and (`s`.`product_code` = `po`.`product_code`) and (`s`.`customer_code` = `po`.`customer_code`)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `net_sales`
--

/*!50001 DROP VIEW IF EXISTS `net_sales`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `net_sales` AS select `sales_postinv_discount`.`date` AS `date`,`sales_postinv_discount`.`fiscal_year` AS `fiscal_year`,`sales_postinv_discount`.`customer_code` AS `customer_code`,`sales_postinv_discount`.`market` AS `market`,`sales_postinv_discount`.`product_code` AS `product_code`,`sales_postinv_discount`.`product` AS `product`,`sales_postinv_discount`.`variant` AS `variant`,`sales_postinv_discount`.`sold_quantity` AS `sold_quantity`,`sales_postinv_discount`.`gross_price_total` AS `gross_price_total`,`sales_postinv_discount`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct`,`sales_postinv_discount`.`net_invoice_sales` AS `net_invoice_sales`,`sales_postinv_discount`.`post_invoice_discount_pct` AS `post_invoice_discount_pct`,((1 - `sales_postinv_discount`.`post_invoice_discount_pct`) * `sales_postinv_discount`.`net_invoice_sales`) AS `net_sales` from `sales_postinv_discount` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sales_preinv_discount`
--

/*!50001 DROP VIEW IF EXISTS `sales_preinv_discount`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `sales_preinv_discount` AS select `s`.`date` AS `date`,`s`.`fiscal_year` AS `fiscal_year`,`s`.`product_code` AS `product_code`,`s`.`customer_code` AS `customer_code`,`c`.`market` AS `market`,`p`.`product` AS `product`,`p`.`variant` AS `variant`,`s`.`sold_quantity` AS `sold_quantity`,`g`.`gross_price` AS `gross_price`,round((`g`.`gross_price` * `s`.`sold_quantity`),2) AS `gross_price_total`,`pre`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct` from ((((`fact_sales_monthly` `s` join `dim_customer` `c` on((`s`.`customer_code` = `c`.`customer_code`))) join `dim_product` `p` on((`s`.`product_code` = `p`.`product_code`))) join `fact_gross_price` `g` on(((`g`.`product_code` = `s`.`product_code`) and (`g`.`fiscal_year` = `s`.`fiscal_year`)))) join `fact_pre_invoice_deductions` `pre` on(((`pre`.`customer_code` = `s`.`customer_code`) and (`pre`.`fiscal_year` = `s`.`fiscal_year`)))) */;
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

-- Dump completed on 2024-03-20 15:22:43
