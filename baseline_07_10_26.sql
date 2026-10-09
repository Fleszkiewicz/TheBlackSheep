-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: hopper.proxy.rlwy.net    Database: theblacksheep
-- ------------------------------------------------------
-- Server version	9.4.0

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
-- Table structure for table `moneda`
--

DROP TABLE IF EXISTS `moneda`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `moneda` (
  `id` int NOT NULL AUTO_INCREMENT,
  `moneda` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `moneda`
--

LOCK TABLES `moneda` WRITE;
/*!40000 ALTER TABLE `moneda` DISABLE KEYS */;
INSERT INTO `moneda` VALUES (1,'ars'),(2,'usd'),(3,'mixto');
/*!40000 ALTER TABLE `moneda` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicio`
--

DROP TABLE IF EXISTS `servicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicio` (
  `viaje_id` varchar(6) NOT NULL,
  `servicio_tipo_id` tinyint NOT NULL,
  `valor` decimal(12,2) unsigned NOT NULL,
  `pagado_por` enum('pablo','soledad','mariana','pendiente','mixto') DEFAULT 'pendiente',
  `moneda_id` int DEFAULT NULL,
  `cotizacion` decimal(12,2) DEFAULT NULL,
  `observacion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`viaje_id`,`servicio_tipo_id`),
  KEY `fk_servicio_tipo` (`servicio_tipo_id`),
  KEY `fk_servicio_moneda_idx` (`moneda_id`),
  CONSTRAINT `fk_servicio_moneda` FOREIGN KEY (`moneda_id`) REFERENCES `moneda` (`id`),
  CONSTRAINT `servicio_ibfk_1` FOREIGN KEY (`viaje_id`) REFERENCES `viaje` (`id`) ON DELETE CASCADE,
  CONSTRAINT `servicio_ibfk_2` FOREIGN KEY (`servicio_tipo_id`) REFERENCES `servicio_tipo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicio`
--

LOCK TABLES `servicio` WRITE;
/*!40000 ALTER TABLE `servicio` DISABLE KEYS */;
INSERT INTO `servicio` VALUES ('TBS001',1,2293.00,'pablo',2,1500.00,NULL),('TBS001',7,2870.00,'soledad',2,1500.00,NULL),('TBS001',8,100.00,'pablo',2,1500.00,NULL),('TBS002',1,564.00,'soledad',2,1500.00,NULL),('TBS002',3,124.00,'soledad',2,1500.00,NULL),('TBS002',7,1924.00,'soledad',2,1500.00,NULL),('TBS002',8,176.00,'soledad',2,1500.00,NULL),('TBS003',1,1668.00,'pablo',2,1500.00,NULL),('TBS003',8,30.00,'pablo',2,1500.00,NULL),('TBS004',1,1060.00,'pablo',2,1500.00,NULL),('TBS004',6,198.00,'pablo',2,1500.00,NULL),('TBS004',7,3825.00,'pablo',2,1500.00,NULL),('TBS005',1,660.00,'pablo',2,1500.00,NULL),('TBS005',3,770000.00,'pablo',1,0.00,NULL),('TBS005',6,116.00,'pablo',2,1500.00,NULL),('TBS005',7,1336.00,'pablo',2,1500.00,NULL),('TBS005',8,110.00,'pablo',2,1500.00,NULL),('TBS006',1,2850.00,'pablo',2,1500.00,NULL),('TBS006',2,300.00,'pablo',2,1500.00,NULL),('TBS006',6,150.00,'pablo',2,1500.00,NULL),('TBS006',7,2770.00,'soledad',2,1500.00,NULL),('TBS017',1,593.00,'soledad',2,1500.00,NULL),('TBS017',3,512760.00,'pablo',1,0.00,NULL),('TBS017',4,128600.00,'pablo',1,0.00,NULL),('TBS017',7,719.00,'pablo',2,1500.00,NULL),('TBS030',1,357.00,'soledad',2,1500.00,NULL),('TBS030',3,256380.00,'pablo',1,1500.00,NULL),('TBS030',4,64300.00,'pablo',1,1500.00,NULL),('TBS030',7,359.00,'pablo',2,1500.00,NULL),('TBS030',8,170.00,'pablo',2,1500.00,NULL),('TBS037',7,4400.00,'soledad',2,1500.00,NULL),('TBS038',1,1716.00,'soledad',2,1500.00,NULL),('TBS038',2,100.00,'pablo',2,1500.00,NULL),('TBS038',3,663370.00,'soledad',1,1500.00,NULL),('TBS038',7,1517.00,'soledad',2,1500.00,NULL),('TBS038',8,140.00,'pablo',2,1500.00,NULL),('TBS039',1,344100.00,'pablo',1,NULL,NULL),('TBS039',2,54317.00,'pablo',1,NULL,NULL),('TBS039',7,213403.00,'soledad',1,NULL,NULL),('TBS043',1,440377.00,'soledad',1,NULL,NULL),('TBS043',3,469000.00,'pablo',1,NULL,NULL),('TBS043',7,1193793.00,'pablo',1,NULL,NULL),('TBS043',8,42830.00,'pablo',1,NULL,NULL),('TBS044',1,4080.00,'soledad',2,1500.00,'hotel maceio y maragoggi'),('TBS044',2,200.00,'mariana',2,1500.00,NULL),('TBS044',7,3100.00,'soledad',2,1500.00,NULL),('TBS044',8,170.00,'soledad',2,1500.00,NULL),('TBS045',1,1710.00,'soledad',2,1500.00,NULL),('TBS045',6,200.00,'soledad',2,1500.00,NULL),('TBS045',7,2350.00,'soledad',2,1500.00,NULL),('TBS045',8,90.00,'soledad',2,1500.00,NULL),('TBS046',1,1300.00,'soledad',2,1500.00,NULL),('TBS046',3,4200.00,'soledad',2,1500.00,'entradas a parques'),('TBS046',6,262.00,'soledad',2,1500.00,NULL),('TBS046',7,2500.00,'soledad',2,1500.00,NULL),('TBS046',8,200.00,'pablo',2,1500.00,NULL),('TBS047',7,309.00,'soledad',2,1500.00,NULL),('TBS048',1,1212.00,'soledad',2,1500.00,NULL),('TBS048',2,75.00,'soledad',2,1500.00,'ganancia de financiación'),('TBS048',6,320.00,'soledad',2,1500.00,NULL),('TBS048',7,1900.00,'soledad',2,1500.00,NULL),('TBS048',8,191.00,'soledad',2,1500.00,NULL),('TBS049',1,1311.00,'soledad',2,1500.00,NULL),('TBS049',5,550.00,'soledad',2,1500.00,NULL),('TBS049',6,240.00,'soledad',2,1500.00,NULL),('TBS049',7,2050.00,'mariana',2,1500.00,NULL),('TBS050',3,370000.00,'soledad',1,NULL,NULL),('TBS050',7,1295500.00,'soledad',1,NULL,'incluye hotel y traslados'),('TBS051',7,614.00,'mariana',2,1500.00,NULL),('TBS051',10,36.00,'soledad',2,1500.00,NULL),('TBS052',1,5919.00,'soledad',2,1500.00,NULL),('TBS052',6,259.00,'soledad',2,1500.00,NULL),('TBS052',7,2950.00,'mariana',2,1500.00,NULL),('TBS053',1,2678.00,'soledad',2,1500.00,NULL),('TBS053',6,300.00,'soledad',2,1500.00,NULL),('TBS053',7,2390.00,'pablo',2,1500.00,NULL),('TBS053',8,200.00,'soledad',2,1500.00,NULL),('TBS054',1,2438.00,'soledad',2,1500.00,'hotel en brickell y hollywood'),('TBS054',6,262.00,'soledad',2,1500.00,NULL),('TBS054',7,3893.00,'mariana',2,1500.00,NULL),('TBS054',8,519.00,'soledad',2,1500.00,NULL),('TBS054',9,2670.00,'soledad',2,1500.00,'bahamas'),('TBS055',3,300000.00,'pablo',1,NULL,NULL),('TBS055',7,3463380.00,'soledad',1,NULL,NULL),('TBS056',1,1053.00,'soledad',2,1500.00,NULL),('TBS056',6,406.00,'mariana',2,1500.00,NULL),('TBS056',7,1250.00,'soledad',2,1500.00,NULL),('TBS056',8,160.00,'soledad',2,1500.00,NULL),('TBS057',1,457.00,'soledad',2,1500.00,NULL),('TBS057',6,94.00,'mixto',2,1500.00,'pago sole y pablo'),('TBS057',7,848.00,'pablo',2,1500.00,NULL),('TBS057',8,150.00,'soledad',2,1500.00,NULL),('TBS058',1,2050.00,'soledad',2,1480.00,NULL),('TBS058',6,230.00,'soledad',2,1480.00,NULL),('TBS058',7,2200.00,'soledad',2,1480.00,NULL),('TBS058',8,215.00,'soledad',2,1480.00,NULL),('TBS059',6,240.00,'soledad',2,1480.00,NULL),('TBS059',7,2920.00,'soledad',2,1480.00,NULL),('TBS059',10,402.00,'soledad',2,1480.00,NULL),('TBS060',1,5080.00,'soledad',2,1480.00,NULL),('TBS060',7,5800.00,'soledad',2,1480.00,NULL),('TBS060',8,180.00,'soledad',2,1480.00,NULL),('TBS061',1,2150.00,'soledad',2,1480.00,NULL),('TBS061',6,478.00,'soledad',2,1480.00,NULL),('TBS061',7,3382.00,'soledad',2,1480.00,NULL),('TBS061',8,400.00,'soledad',2,1480.00,NULL),('TBS061',10,287.00,'soledad',2,1480.00,NULL),('TBS062',7,5280.00,'soledad',2,1480.00,NULL),('TBS063',7,524.00,'soledad',2,1480.00,NULL),('TBS064',1,2118.00,'mixto',2,1480.00,'pague yo 1500 usd resto sole'),('TBS064',6,215.00,'soledad',2,1440.00,NULL),('TBS064',7,2123.00,'soledad',2,1440.00,NULL),('TBS064',8,191.00,'soledad',2,1440.00,NULL),('TBS065',1,332.00,'pablo',2,1440.00,NULL),('TBS065',5,277.00,'pablo',2,1440.00,NULL),('TBS065',6,104.00,'mixto',2,1440.00,'62 usd pague yo 42 pago sole'),('TBS065',7,1160.00,'soledad',2,1440.00,NULL),('TBS066',7,1644953.00,'pablo',1,NULL,'pago de paquete completo'),('TBS066',8,127000.00,'pablo',1,NULL,'traslado de la ida'),('TBS067',7,2041499.00,'soledad',1,NULL,NULL),('TBS068',7,535.00,'soledad',2,1450.00,NULL),('TBS068',10,11.00,'soledad',2,1450.00,NULL),('TBS069',1,2550.00,'soledad',2,1450.00,NULL),('TBS069',6,175.00,'soledad',2,1450.00,NULL),('TBS069',7,2820.00,'pablo',2,1450.00,NULL),('TBS069',8,300.00,'soledad',2,1450.00,NULL),('TBS070',1,2595.00,'soledad',2,1440.00,NULL),('TBS070',6,259.00,'soledad',2,1440.00,NULL),('TBS070',7,3100.00,'soledad',2,1440.00,NULL),('TBS070',8,300.00,'soledad',2,1400.00,NULL),('TBS071',1,752.00,'pablo',2,1440.00,NULL),('TBS071',7,808.00,'soledad',2,1440.00,NULL),('TBS072',1,980.00,'soledad',2,1450.00,NULL),('TBS072',6,220.00,'pablo',2,1450.00,NULL),('TBS072',7,810.00,'pablo',2,1450.00,NULL),('TBS072',8,300.00,'soledad',2,1450.00,NULL),('TBS073',1,2612.00,'soledad',2,1450.00,NULL),('TBS073',6,160.00,'pablo',2,1450.00,NULL),('TBS073',7,2755.00,'soledad',2,1450.00,NULL),('TBS073',8,152.00,'soledad',2,1450.00,NULL),('TBS074',1,1585.00,'soledad',2,1450.00,NULL),('TBS074',7,14404.00,'soledad',2,1450.00,NULL),('TBS074',10,1260.00,'soledad',2,1450.00,NULL),('TBS075',6,90.00,'pablo',2,1450.00,NULL),('TBS075',7,592.00,'pablo',2,1450.00,NULL),('TBS076',7,623.00,'soledad',2,1450.00,NULL),('TBS077',6,220.00,'pablo',2,1450.00,NULL),('TBS077',7,2547.00,'pablo',2,1450.00,NULL),('TBS078',1,555.00,'pablo',2,1450.00,'290 maragoggi 265 porto galinhas'),('TBS078',6,160.00,'pablo',2,1450.00,NULL),('TBS078',7,1350.00,'pablo',2,1450.00,NULL),('TBS078',8,234.00,'pablo',2,1450.00,NULL),('TBS079',1,520.00,'soledad',2,1450.00,NULL),('TBS079',6,40.00,'pablo',2,1450.00,NULL),('TBS079',7,815.00,'pablo',2,1450.00,NULL),('TBS079',8,48.00,'soledad',2,1450.00,NULL),('TBS079',10,175.00,'soledad',2,1450.00,NULL),('TBS080',1,7150.00,'soledad',2,1435.00,NULL),('TBS080',6,253.00,'soledad',2,1435.00,NULL),('TBS080',7,2954.00,'mixto',2,1435.00,'2500 pago sole 454 pague yo'),('TBS080',8,140.00,'soledad',2,1435.00,NULL),('TBS081',7,1066.00,'soledad',2,1490.00,'paquete completo'),('TBS081',10,182.00,'soledad',2,1490.00,NULL),('TBS082',7,8344.00,'soledad',2,1490.00,NULL),('TBS082',10,348.00,'soledad',2,1490.00,NULL),('TBS083',1,481389.00,'soledad',1,NULL,'equivale a 332 usd'),('TBS083',7,904856.00,'soledad',1,NULL,'equivale a 612 usd'),('TBS083',8,95000.00,'pablo',1,NULL,NULL),('TBS084',7,1240398.00,'mixto',1,NULL,'pague yo $700000 y sole $540389 en dolares usd374'),('TBS085',1,940.00,'soledad',2,1450.00,NULL),('TBS085',6,180.00,'soledad',2,1450.00,NULL),('TBS085',7,1192.00,'soledad',2,1450.00,NULL),('TBS085',8,150.00,'soledad',2,1450.00,NULL),('TBS085',10,503.00,'soledad',2,1450.00,NULL),('TBS086',1,1810.00,'soledad',2,1450.00,NULL),('TBS086',6,300.00,'soledad',2,1450.00,NULL),('TBS086',7,2141.00,'soledad',2,1450.00,NULL),('TBS086',8,210.00,'soledad',2,1450.00,NULL),('TBS086',10,402.00,'soledad',2,1450.00,NULL),('TBS087',1,2031.00,'soledad',2,1450.00,NULL),('TBS087',7,1680.00,'soledad',2,1450.00,NULL),('TBS087',8,60.00,'soledad',2,1450.00,NULL),('TBS088',1,2890.00,'soledad',2,1450.00,NULL),('TBS088',7,2503.00,'soledad',2,1450.00,NULL),('TBS088',8,90.00,'soledad',2,1450.00,NULL),('TBS089',1,4603.00,'soledad',2,1450.00,NULL),('TBS089',6,195.00,'soledad',2,1450.00,NULL),('TBS089',7,2128.00,'soledad',2,1450.00,NULL),('TBS089',8,270.00,'soledad',2,1450.00,NULL),('TBS089',10,125.00,'soledad',2,1450.00,'ganancia '),('TBS090',1,1680.00,'pendiente',2,NULL,NULL),('TBS090',6,155.00,'soledad',2,1450.00,NULL),('TBS090',7,2548.00,'mixto',2,1450.00,'2000 usd pague yo usd 548 paga sole'),('TBS090',8,90.00,'pendiente',2,NULL,NULL),('TBS091',1,3525.00,'mixto',2,1410.00,'pague yo 2830  paga sole 695'),('TBS091',6,240.00,'soledad',2,1410.00,NULL),('TBS091',7,2760.00,'soledad',2,1410.00,NULL),('TBS091',8,200.00,'pablo',2,1410.00,NULL),('TBS092',6,280.00,'soledad',2,1405.00,NULL),('TBS092',7,1520.00,'soledad',2,1405.00,NULL),('TBS092',10,117.00,'soledad',2,1400.00,NULL),('TBS093',1,1908.00,'pendiente',2,NULL,'hotel playa del carmen 593 usd hotel cancun 1315'),('TBS093',6,235.00,'soledad',2,1420.00,NULL),('TBS093',7,3208.00,'mixto',2,1405.00,'pago sole 2800 pague yo 408'),('TBS094',7,10933.00,'soledad',2,1420.00,NULL),('TBS095',8,190000.00,'pablo',1,NULL,NULL),('TBS095',11,830000.00,'pablo',1,NULL,NULL),('TBS096',1,5495.00,'soledad',2,1410.00,NULL),('TBS096',6,275.00,'soledad',2,1410.00,NULL),('TBS096',7,3200.00,'soledad',2,1410.00,NULL),('TBS097',1,1535.00,'soledad',2,1420.00,NULL),('TBS097',6,220.00,'soledad',2,1420.00,NULL),('TBS097',7,2526.00,'soledad',2,1420.00,NULL),('TBS097',8,400.00,'soledad',2,1420.00,NULL),('TBS097',9,2990.00,'soledad',2,1420.00,NULL),('TBS098',6,244.00,'soledad',2,1420.00,NULL),('TBS098',7,2996.00,'soledad',2,1420.00,NULL),('TBS099',11,1762000.00,'pablo',1,NULL,NULL),('TBS100',1,1625.00,'pendiente',2,NULL,NULL),('TBS100',6,180.00,'pablo',2,NULL,NULL),('TBS100',7,2019.00,'pablo',2,NULL,NULL),('TBS101',1,1350.00,'pendiente',2,NULL,NULL),('TBS101',6,225.00,'soledad',2,NULL,NULL),('TBS101',7,1525.00,'soledad',2,NULL,NULL),('TBS101',8,225.00,'pendiente',2,NULL,NULL),('TBS102',1,2250.00,'pendiente',2,NULL,NULL),('TBS102',6,375.00,'soledad',2,NULL,NULL),('TBS102',7,2541.00,'soledad',2,NULL,NULL),('TBS102',8,350.00,'pendiente',2,NULL,NULL),('TBS103',1,1650.00,'pendiente',2,NULL,NULL),('TBS103',6,180.00,'soledad',2,NULL,NULL),('TBS103',7,2130.00,'soledad',2,NULL,NULL),('TBS103',8,100.00,'pendiente',2,NULL,NULL),('TBS104',1,975.00,'soledad',2,1420.00,NULL),('TBS104',7,1570.00,'soledad',2,1420.00,NULL),('TBS104',8,205.00,'soledad',2,1420.00,NULL),('TBS105',8,210000.00,'pablo',1,NULL,NULL),('TBS105',11,1285400.00,'pablo',1,NULL,NULL),('TBS106',1,2275.00,'soledad',2,1465.00,NULL),('TBS106',6,180.00,'soledad',2,1645.00,NULL),('TBS106',7,2380.00,'soledad',2,1465.00,NULL),('TBS106',8,195.00,'soledad',2,1465.00,NULL),('TBS107',11,1074650.00,'pablo',1,NULL,NULL),('TBS108',1,5105.00,'soledad',2,1530.00,NULL),('TBS108',6,450.00,'soledad',2,1530.00,NULL),('TBS108',7,5729.00,'soledad',2,1530.00,NULL),('TBS109',1,1690.00,'soledad',2,1520.00,NULL),('TBS109',6,100.00,'pablo',2,1520.00,NULL),('TBS109',7,1350.00,'pablo',2,1520.00,NULL),('TBS109',8,100.00,'soledad',2,1520.00,NULL),('TBS110',1,1044625.00,'soledad',1,1525.00,'equivale a 685 esd'),('TBS110',3,318400.00,'pablo',1,NULL,NULL),('TBS110',7,3120706.00,'soledad',1,1490.00,'equivale a 1247+177'),('TBS110',8,130666.00,'pablo',1,NULL,NULL),('TBS111',1,1050.00,'soledad',2,NULL,NULL),('TBS111',3,525.00,'pablo',2,NULL,NULL),('TBS111',6,225.00,'soledad',2,NULL,NULL),('TBS111',7,1910.00,'soledad',2,NULL,NULL),('TBS111',8,270.00,'pendiente',2,NULL,NULL),('TBS111',10,373.00,'soledad',2,NULL,NULL),('TBS112',1,1350.00,'pendiente',2,NULL,'600 usd hotel rio 750 hotel cabo frio'),('TBS112',6,130.00,'soledad',2,NULL,NULL),('TBS112',7,1070.00,'soledad',2,NULL,NULL),('TBS112',8,200.00,'pendiente',2,NULL,NULL),('TBS113',1,5780.00,'mixto',2,NULL,'SOLE 5000 Y YO 780'),('TBS113',3,4106.00,'soledad',2,NULL,'ENTRADAS DE PARQUES'),('TBS114',7,1326014.00,'soledad',1,1517.00,'PAGO SOLE 872 USD'),('TBS115',7,1160.00,'pablo',2,NULL,NULL),('TBS116',1,3490.00,'mixto',2,NULL,'pago pablo 490 pago sole 3000'),('TBS116',7,8165.00,'mixto',2,NULL,'pago pablo 1165 pago sole 7000'),('TBS116',10,1560.00,'soledad',2,NULL,'ganancia financiacion'),('TBS117',1,3160.00,'soledad',2,NULL,NULL),('TBS117',2,90.00,'soledad',2,NULL,NULL),('TBS117',6,210.00,'soledad',2,NULL,NULL),('TBS117',7,1350.00,'soledad',2,NULL,NULL),('TBS117',8,90.00,'soledad',2,NULL,NULL),('TBS118',1,3100.00,'mixto',2,NULL,'pago sole 2500 usd pago pablo 600 usd'),('TBS118',3,3000.00,'pablo',2,NULL,'entradas de disney'),('TBS118',6,200.00,'pablo',2,NULL,NULL),('TBS118',7,1790.00,'pablo',2,NULL,NULL),('TBS118',8,150.00,'pablo',2,NULL,NULL),('TBS119',11,5900.00,'soledad',2,NULL,NULL),('TBS120',1,4517.00,'soledad',2,156.00,NULL),('TBS120',6,140.00,'soledad',2,1560.00,NULL),('TBS120',7,3477.00,'mixto',2,1560.00,'pague yo 2800 paga sole 677'),('TBS121',1,1540.00,'soledad',2,1560.00,NULL),('TBS121',6,90.00,'soledad',2,1560.00,NULL),('TBS121',7,1792.00,'soledad',2,1560.00,NULL),('TBS122',1,434.00,'soledad',2,1560.00,NULL),('TBS122',6,100.00,'soledad',2,1560.00,NULL),('TBS122',7,1039.00,'soledad',2,1560.00,NULL),('TBS122',8,150.00,'soledad',2,1560.00,NULL),('TBS123',11,0.00,'pendiente',1,NULL,NULL);
/*!40000 ALTER TABLE `servicio` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_actualizar_estado_viaje` AFTER INSERT ON `servicio` FOR EACH ROW BEGIN
  DECLARE servicios_pendientes INT;

  SELECT COUNT(*) INTO servicios_pendientes
  FROM servicio
  WHERE viaje_id = NEW.viaje_id AND pagado_por = 'pendiente';

  IF servicios_pendientes = 0 THEN
    UPDATE viaje
    SET estado = 'finalizado'
    WHERE id = NEW.viaje_id;
  ELSE
    UPDATE viaje
    SET estado = 'pendiente'
    WHERE id = NEW.viaje_id;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_calcular_costo_insert` AFTER INSERT ON `servicio` FOR EACH ROW BEGIN

    DECLARE v_moneda_viaje INT;

    SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = NEW.viaje_id;



    IF v_moneda_viaje = 1 THEN -- ARS

        UPDATE viaje SET 

            costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),

            costo_usd = 0

        WHERE id = NEW.viaje_id;

    ELSEIF v_moneda_viaje = 2 THEN -- USD

        UPDATE viaje SET 

            costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),

            costo = 0

        WHERE id = NEW.viaje_id;

    ELSEIF v_moneda_viaje = 3 THEN -- MIXTO

        UPDATE viaje SET 

            costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),

            costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0)

        WHERE id = NEW.viaje_id;

    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_actualizar_estado_viaje_update` AFTER UPDATE ON `servicio` FOR EACH ROW BEGIN
  DECLARE servicios_pendientes INT;

  SELECT COUNT(*) INTO servicios_pendientes
  FROM servicio
  WHERE viaje_id = NEW.viaje_id AND pagado_por = 'pendiente';

  IF servicios_pendientes = 0 THEN
    UPDATE viaje
    SET estado = 'finalizado'
    WHERE id = NEW.viaje_id;
  ELSE
    UPDATE viaje
    SET estado = 'pendiente'
    WHERE id = NEW.viaje_id;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_calcular_costo_update` AFTER UPDATE ON `servicio` FOR EACH ROW BEGIN

    DECLARE v_moneda_viaje INT;

    SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = NEW.viaje_id;



    IF v_moneda_viaje = 1 THEN -- ARS

        UPDATE viaje SET 

            costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),

            costo_usd = 0

        WHERE id = NEW.viaje_id;

    ELSEIF v_moneda_viaje = 2 THEN -- USD

        UPDATE viaje SET 

            costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),

            costo = 0

        WHERE id = NEW.viaje_id;

    ELSEIF v_moneda_viaje = 3 THEN -- MIXTO

        UPDATE viaje SET 

            costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),

            costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0)

        WHERE id = NEW.viaje_id;

    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_calcular_costo_delete` AFTER DELETE ON `servicio` FOR EACH ROW BEGIN

    DECLARE v_moneda_viaje INT;

    SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = OLD.viaje_id;



    IF v_moneda_viaje = 1 THEN -- ARS

        UPDATE viaje SET 

            costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0),

            costo_usd = 0

        WHERE id = OLD.viaje_id;

    ELSEIF v_moneda_viaje = 2 THEN -- USD

        UPDATE viaje SET 

            costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0),

            costo = 0

        WHERE id = OLD.viaje_id;

    ELSEIF v_moneda_viaje = 3 THEN -- MIXTO

        UPDATE viaje SET 

            costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0),

            costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0)

        WHERE id = OLD.viaje_id;

    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `servicio_tipo`
--

DROP TABLE IF EXISTS `servicio_tipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicio_tipo` (
  `id` tinyint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicio_tipo`
--

LOCK TABLES `servicio_tipo` WRITE;
/*!40000 ALTER TABLE `servicio_tipo` DISABLE KEYS */;
INSERT INTO `servicio_tipo` VALUES (4,'alquiler de ropa'),(5,'alquiler de vehiculo'),(6,'asistencia al viajero'),(9,'crucero'),(2,'equipaje'),(3,'excursiones'),(10,'financiacion'),(1,'hospedaje'),(11,'Paquete Nacional'),(7,'tickets aereos'),(8,'traslados');
/*!40000 ALTER TABLE `servicio_tipo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_cambio`
--

DROP TABLE IF EXISTS `tipo_cambio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_cambio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `moneda_id` int DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `valor_base` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `moneda_id` (`moneda_id`),
  CONSTRAINT `tipo_cambio_ibfk_1` FOREIGN KEY (`moneda_id`) REFERENCES `moneda` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_cambio`
--

LOCK TABLES `tipo_cambio` WRITE;
/*!40000 ALTER TABLE `tipo_cambio` DISABLE KEYS */;
INSERT INTO `tipo_cambio` VALUES (2,2,'2025-09-09',1400.00),(5,2,'2025-09-09',1400.00),(6,2,'2025-09-18',1400.00),(7,2,'2025-09-18',1000.00),(8,2,'2025-09-18',1200.00);
/*!40000 ALTER TABLE `tipo_cambio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id` tinyint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(20) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'pablo','pablog_105@hotmail.com'),(2,'soledad','seitan@outlook.com.ar'),(4,'fran','leszkiewiczfranco@gmail.com'),(5,'juan','juandauberte@gmail.com'),(6,'marian','ale_plate@hotmail.com'),(7,'Soledad','riccosoledad42@gmail.com'),(8,'pablo','pablogarciapga494@gmail.com');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `viaje`
--

DROP TABLE IF EXISTS `viaje`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `viaje` (
  `id` varchar(6) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `apellido` varchar(50) NOT NULL,
  `valor_total` decimal(12,2) unsigned NOT NULL,
  `valor_total_usd` decimal(12,2) DEFAULT NULL,
  `ganancia` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ganancia_usd` decimal(12,2) DEFAULT '0.00',
  `costo` decimal(12,2) NOT NULL DEFAULT '0.00',
  `costo_usd` decimal(12,2) DEFAULT '0.00',
  `estado` enum('pendiente','finalizado','cancelado') DEFAULT 'pendiente',
  `destino` enum('internacional','nacional') DEFAULT NULL,
  `fecha_ida` date DEFAULT NULL,
  `fecha_vuelta` date DEFAULT NULL,
  `moneda_id` int DEFAULT NULL,
  `cotizacion` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_viaje_moneda_idx` (`moneda_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `viaje`
--

LOCK TABLES `viaje` WRITE;
/*!40000 ALTER TABLE `viaje` DISABLE KEYS */;
INSERT INTO `viaje` VALUES ('TBS001','2024-10-18 00:00:00','weintein luciano',0.00,6350.00,0.00,1087.00,0.00,5263.00,'finalizado','internacional','2024-11-23','2024-12-07',2,1500.00),('TBS002','2024-12-15 00:00:00','romero leonardo',0.00,3560.00,0.00,772.00,0.00,2788.00,'finalizado','internacional','2025-01-04','2025-01-11',2,1500.00),('TBS003','2024-12-30 00:00:00','lavalle valentin',0.00,2200.00,0.00,502.00,0.00,1698.00,'finalizado','internacional','2025-01-02','2025-01-11',2,1500.00),('TBS004','2025-01-07 00:00:00','papillu jorge',0.00,6040.00,0.00,957.00,0.00,5083.00,'finalizado','internacional','2025-11-15','2025-11-22',2,1500.00),('TBS005','2025-01-23 00:00:00','fernandez stella',0.00,2960.00,0.00,738.00,0.00,2222.00,'finalizado','internacional','2025-03-23','2025-03-30',2,1500.00),('TBS006','2025-04-09 00:00:00','macias alejandro',0.00,6890.00,0.00,820.00,0.00,6070.00,'finalizado','internacional','2026-01-02','2026-01-09',2,1500.00),('TBS017','2025-04-14 00:00:00','botheatoz leandro',820000.00,1590.00,178640.00,278.00,641360.00,1312.00,'finalizado','nacional','2025-08-15','2025-08-18',3,1500.00),('TBS030','2026-04-14 00:00:00','actis dato',410000.00,1130.00,89320.00,244.00,320680.00,886.00,'finalizado','nacional','2026-08-15','2026-08-18',3,1500.00),('TBS037','2025-05-09 00:00:00','depauli eduardo',0.00,4500.00,0.00,100.00,0.00,4400.00,'finalizado','internacional','2025-07-14','2025-07-29',2,1500.00),('TBS038','2025-05-21 00:00:00','sassone martin',980000.00,4550.00,316630.00,1077.00,663370.00,3473.00,'finalizado','nacional','2025-07-19','2025-07-26',3,1500.00),('TBS039','2025-05-20 00:00:00','giglio jonathan',861990.00,0.00,250170.00,0.00,611820.00,0.00,'finalizado','nacional','2025-06-03','2025-06-06',1,NULL),('TBS043','2025-05-21 00:00:00','sanchez liliana',2290000.00,0.00,144000.00,0.00,2146000.00,0.00,'finalizado','nacional','2025-06-18','2025-06-23',1,NULL),('TBS044','2025-05-27 00:00:00','sanchez paulina',0.00,11650.00,0.00,4100.00,0.00,7550.00,'finalizado','internacional','2025-08-03','2025-08-13',2,1500.00),('TBS045','2025-08-04 00:00:00','uzandizaga cristian',0.00,5550.00,0.00,1200.00,0.00,4350.00,'finalizado','internacional','2025-11-30','2025-12-09',2,1500.00),('TBS046','2025-08-05 00:00:00','zaiz lelia',0.00,10320.00,0.00,1858.00,0.00,8462.00,'finalizado','internacional','2025-11-01','2025-11-11',2,1500.00),('TBS047','2025-08-19 00:00:00','cavagniola sergio',0.00,385.00,0.00,76.00,0.00,309.00,'finalizado','internacional','2025-09-18','2025-09-19',2,1500.00),('TBS048','2025-08-22 00:00:00','zarate vanesa',0.00,4905.00,0.00,1207.00,0.00,3698.00,'finalizado','internacional','2026-01-12','2026-01-22',2,1500.00),('TBS049','2025-08-25 00:00:00','lucchesi mauricio',0.00,5500.00,0.00,1349.00,0.00,4151.00,'finalizado','internacional','2026-02-28','2026-03-14',2,1500.00),('TBS050','2025-08-26 00:00:00','macherette leonardo',2271750.00,0.00,606250.00,0.00,1665500.00,0.00,'finalizado','nacional','2026-01-02','2026-01-05',1,NULL),('TBS051','2025-08-29 00:00:00','chulqui daniel',0.00,840.00,0.00,190.00,0.00,650.00,'finalizado','internacional','2025-10-18','2025-11-09',2,1500.00),('TBS052','2025-09-02 00:00:00','pedace damian',0.00,10360.00,0.00,1232.00,0.00,9128.00,'finalizado','internacional','2025-11-01','2025-11-10',2,1500.00),('TBS053','2025-09-05 00:00:00','sartor olinda',0.00,6480.00,0.00,912.00,0.00,5568.00,'finalizado','internacional','2025-12-12','2025-12-20',2,1500.00),('TBS054','2025-09-13 00:00:00','perkins homero',0.00,11720.00,0.00,1938.00,0.00,9782.00,'finalizado','internacional','2025-11-29','2025-12-09',2,1500.00),('TBS055','2025-09-17 00:00:00','sole lucio',4160000.00,0.00,396620.00,0.00,3763380.00,0.00,'finalizado','nacional','2025-11-17','2025-11-22',1,NULL),('TBS056','2025-09-29 00:00:00','vilma quiroga',0.00,3310.00,0.00,441.00,0.00,2869.00,'finalizado','internacional','2026-03-15','2026-04-06',2,1500.00),('TBS057','2025-10-13 00:00:00','trinidad schaer',0.00,1950.00,0.00,401.00,0.00,1549.00,'finalizado','internacional','2025-12-13','2025-12-20',2,1500.00),('TBS058','2025-10-15 00:00:00','leandro botehatoz',0.00,5584.00,0.00,889.00,0.00,4695.00,'finalizado','internacional','2026-03-08','2026-03-16',2,1500.00),('TBS059','2025-10-16 00:00:00','mauro loupias',0.00,3982.00,0.00,420.00,0.00,3562.00,'finalizado','internacional','2026-08-06','2026-10-27',2,1480.00),('TBS060','2025-10-17 00:00:00','ariel frias',0.00,12900.00,0.00,1840.00,0.00,11060.00,'finalizado','internacional','2026-02-02','2026-02-09',2,1480.00),('TBS061','2025-10-21 00:00:00','hernan sardella',0.00,7990.00,0.00,1293.00,0.00,6697.00,'finalizado','internacional','2026-01-26','2026-02-04',2,1480.00),('TBS062','2025-10-23 00:00:00','soledad ricco',0.00,5400.00,0.00,120.00,0.00,5280.00,'finalizado','internacional','2026-04-03','2026-04-10',2,1480.00),('TBS063','2025-10-24 00:00:00','rosana raccio',0.00,623.00,0.00,99.00,0.00,524.00,'finalizado','internacional','2025-12-10','2026-03-10',2,1480.00),('TBS064','2025-10-25 00:00:00','gudtavo orqueida',0.00,5640.00,0.00,993.00,0.00,4647.00,'finalizado','internacional','2026-01-02','2026-01-10',2,1480.00),('TBS065','2025-10-31 00:00:00','walter ocampo',0.00,2400.00,0.00,527.00,0.00,1873.00,'finalizado','internacional','2026-04-05','2026-04-12',2,1440.00),('TBS066','2025-10-31 00:00:00','paulina sanchez',1914600.00,0.00,142647.00,0.00,1771953.00,0.00,'finalizado','nacional','2026-02-11','2026-02-17',1,NULL),('TBS067','2025-11-05 00:00:00','marcos zarate',2371500.00,0.00,330001.00,0.00,2041499.00,0.00,'finalizado','nacional','2025-11-21','2025-11-24',1,NULL),('TBS068','2025-11-07 00:00:00','daniel chulqui',0.00,654.00,0.00,108.00,0.00,546.00,'finalizado','internacional','2025-12-04','2025-12-05',2,1450.00),('TBS069','2025-11-11 00:00:00','claudia garcia',0.00,6800.00,0.00,955.00,0.00,5845.00,'finalizado','internacional','2026-03-01','2026-03-08',2,1450.00),('TBS070','2025-12-02 00:00:00','facundo herrera',0.00,7100.00,0.00,846.00,0.00,6254.00,'finalizado','internacional','2026-03-01','2026-03-09',2,1440.00),('TBS071','2025-12-02 00:00:00','bianca fortece',0.00,2040.00,0.00,480.00,0.00,1560.00,'finalizado','internacional','2026-02-10','2026-02-17',2,1440.00),('TBS072','2025-12-11 00:00:00','esteba picirilo',0.00,2750.00,0.00,440.00,0.00,2310.00,'finalizado','internacional','2026-04-06','2026-04-18',2,1450.00),('TBS073','2025-12-18 00:00:00','yamila guasconi',0.00,6700.00,0.00,1021.00,0.00,5679.00,'finalizado','internacional','2026-11-21','2026-11-28',2,1440.00),('TBS074','2026-03-30 00:00:00','hernan sardella',0.00,18750.00,0.00,1501.00,0.00,17249.00,'finalizado','internacional','2026-07-11','2026-07-31',2,1450.00),('TBS075','2025-12-27 00:00:00','mauro roveda',0.00,832.00,0.00,150.00,0.00,682.00,'finalizado','internacional','2026-03-06','2026-03-14',2,1450.00),('TBS076','2025-12-22 00:00:00','lorenzo rocca',0.00,800.00,0.00,177.00,0.00,623.00,'finalizado','nacional','2026-04-27','2026-04-30',2,1450.00),('TBS077','2025-12-28 00:00:00','ricardo schelgel',0.00,3070.00,0.00,303.00,0.00,2767.00,'finalizado','internacional','2025-12-30','2026-01-15',2,1450.00),('TBS078','2025-12-30 00:00:00','camila gallo',0.00,2814.00,0.00,515.00,0.00,2299.00,'finalizado','internacional','2026-01-23','2026-02-03',2,1450.00),('TBS079','2025-12-30 00:00:00','florencia guasconi',0.00,1850.00,0.00,252.00,0.00,1598.00,'finalizado','internacional','2026-11-21','2026-11-28',2,1450.00),('TBS080','2026-01-06 00:00:00','lelia saiz',0.00,11560.00,0.00,1063.00,0.00,10497.00,'finalizado','internacional','2026-02-11','2026-02-22',2,1435.00),('TBS081','2026-01-12 00:00:00','stella fernandez',0.00,1520.00,0.00,272.00,0.00,1248.00,'finalizado','nacional','2026-08-09','2026-08-16',2,1425.00),('TBS082','2026-01-12 00:00:00','marcos fortece',0.00,9148.00,0.00,456.00,0.00,8692.00,'finalizado','internacional','2026-05-13','2026-06-04',2,1490.00),('TBS083','2026-01-22 00:00:00','agustin cardoso',1697000.00,0.00,215755.00,0.00,1481245.00,0.00,'finalizado','nacional','2026-02-14','2026-02-18',1,NULL),('TBS084','2026-01-28 00:00:00','marianela centurion',1471700.00,0.00,231302.00,0.00,1240398.00,0.00,'finalizado','nacional','2026-03-07','2026-03-14',1,NULL),('TBS085','2026-01-31 00:00:00','ignacio castelli',0.00,3554.00,0.00,589.00,0.00,2965.00,'finalizado','internacional','2026-11-07','2026-11-16',2,1450.00),('TBS086','2026-02-04 00:00:00','alfredo fortece',0.00,5772.00,0.00,909.00,0.00,4863.00,'finalizado','internacional','2026-03-17','2026-03-23',2,1450.00),('TBS087','2026-02-05 00:00:00','mirta garcia',0.00,4190.00,0.00,419.00,0.00,3771.00,'finalizado','internacional','2026-11-09','2026-11-19',2,1450.00),('TBS088','2026-02-06 00:00:00','cecilia sotto',0.00,5990.00,0.00,507.00,0.00,5483.00,'finalizado','internacional','2026-11-09','2026-11-19',2,1450.00),('TBS089','2026-02-24 00:00:00','cintia uliano',0.00,7915.00,0.00,594.00,0.00,7321.00,'finalizado','internacional','2026-03-21','2026-03-30',2,1450.00),('TBS090','2026-03-11 00:00:00','marcela lopez',0.00,5070.00,0.00,597.00,0.00,4473.00,'pendiente','internacional','2026-11-14','2026-11-21',2,1450.00),('TBS091','2026-04-01 00:00:00','jorge tarsetti',0.00,7520.00,0.00,795.00,0.00,6725.00,'finalizado','internacional','2026-06-10','2026-06-18',2,1410.00),('TBS092','2026-04-09 00:00:00','karina correa',0.00,2070.00,0.00,153.00,0.00,1917.00,'finalizado','internacional','2026-06-06','2026-09-01',2,1400.00),('TBS093','2026-04-13 00:00:00','mariana fernandez',0.00,5895.00,0.00,544.00,0.00,5351.00,'pendiente','internacional','2027-01-03','2027-01-14',2,1400.00),('TBS094','2026-04-21 00:00:00','CONTINGENTE',0.00,12285.00,0.00,1352.00,0.00,10933.00,'finalizado','internacional','2026-06-26','2026-07-05',2,1420.00),('TBS095','2026-04-29 00:00:00','ALICIA HAFFNER',1170000.00,0.00,150000.00,0.00,1020000.00,0.00,'finalizado','nacional','2026-08-04','2026-08-07',1,NULL),('TBS096','2026-04-30 00:00:00','SILVINA LAIN',0.00,9250.00,0.00,280.00,0.00,8970.00,'finalizado','internacional','2026-06-12','2026-06-20',2,1410.00),('TBS097','2026-05-12 00:00:00','JOSE SCMITD',0.00,8580.00,0.00,909.00,0.00,7671.00,'finalizado','internacional','2026-07-02','2026-07-16',2,1420.00),('TBS098','2026-05-13 00:00:00','CINTIA ULIANO',0.00,3540.00,0.00,300.00,0.00,3240.00,'finalizado','internacional','2026-10-14','2026-10-21',2,1420.00),('TBS099','2026-05-14 00:00:00','SANDRA LUCHINI',1942000.00,0.00,180000.00,0.00,1762000.00,0.00,'finalizado','nacional','2026-09-01','2026-09-04',1,1420.00),('TBS100','2026-05-20 00:00:00','elias obregon',0.00,4350.00,0.00,526.00,0.00,3824.00,'pendiente','internacional','2026-12-31','2027-01-11',2,1430.00),('TBS101','2026-05-29 00:00:00','cristian uzandizaga',0.00,3795.00,0.00,470.00,0.00,3325.00,'pendiente','internacional','2027-01-03','2027-01-12',2,1425.00),('TBS102','2026-05-29 00:00:00','favio amondaray',0.00,6250.00,0.00,734.00,0.00,5516.00,'pendiente','internacional','2027-01-03','2027-01-12',2,1425.00),('TBS103','2026-05-29 00:00:00','leonardo macherette',0.00,4650.00,0.00,590.00,0.00,4060.00,'pendiente','internacional','2027-01-02','2027-01-10',2,1425.00),('TBS104','2026-05-19 00:00:00','christian piccione',0.00,2940.00,0.00,190.00,0.00,2750.00,'finalizado','internacional','2026-05-19','2026-05-21',2,1420.00),('TBS105','2026-06-12 00:00:00','romina bustamante',1645400.00,0.00,150000.00,0.00,1495400.00,0.00,'finalizado','nacional','2026-07-06','2026-07-09',1,NULL),('TBS106','2026-06-16 00:00:00','paulina sanches',0.00,5625.00,0.00,595.00,0.00,5030.00,'finalizado','internacional','2026-08-20','2026-08-27',2,1465.00),('TBS107','2026-06-17 00:00:00','lucrecia silva',1194650.00,0.00,120000.00,0.00,1074650.00,0.00,'finalizado','nacional','2026-07-25','2026-07-28',1,NULL),('TBS108','2026-06-22 00:00:00','roberto macherett',0.00,12175.00,0.00,891.00,0.00,11284.00,'finalizado','internacional','2026-12-30','2027-01-11',2,1530.00),('TBS109','2026-07-07 00:00:00','laura villagran',0.00,3690.00,0.00,450.00,0.00,3240.00,'finalizado','internacional','2026-08-08','2026-08-15',2,1520.00),('TBS110','2026-06-17 00:00:00','ruben baiz',4893024.00,0.00,278627.00,0.00,4614397.00,0.00,'finalizado','nacional','2026-07-27','2026-07-31',1,NULL),('TBS111','2026-07-08 00:00:00','mario petrazzuela',0.00,4983.00,0.00,630.00,0.00,4353.00,'pendiente','internacional','2027-01-04','2027-01-11',2,1525.00),('TBS112','2026-07-23 00:00:00','nicolas gallardo',0.00,3050.00,0.00,300.00,0.00,2750.00,'pendiente','internacional','2027-01-02','2027-01-11',2,1550.00),('TBS113','2026-07-30 00:00:00','CLAUDIO GIUFRETT',0.00,10525.00,0.00,639.00,0.00,9886.00,'finalizado','internacional','2026-12-28','2027-01-11',2,1545.00),('TBS114','2026-08-04 00:00:00','GABRIELA RAZETTI',1480000.00,0.00,153986.00,0.00,1326014.00,0.00,'finalizado','nacional','2026-09-23','2026-09-27',1,NULL),('TBS115','2026-08-05 00:00:00','marcos fortece',0.00,1290.00,0.00,130.00,0.00,1160.00,'finalizado','internacional','2027-01-21','2027-01-24',2,1545.00),('TBS116','2026-08-05 00:00:00','hernan sardella',0.00,14560.00,0.00,1345.00,0.00,13215.00,'finalizado','internacional','2026-12-28','2027-01-08',2,1445.00),('TBS117','2026-08-10 00:00:00','gonzalo cravino',0.00,5350.00,0.00,450.00,0.00,4900.00,'finalizado','internacional','2027-03-08','2027-03-18',2,1540.00),('TBS118','2026-08-14 00:00:00','miguel curulli',0.00,9050.00,0.00,810.00,0.00,8240.00,'finalizado','internacional','2027-05-09','2027-05-21',2,1540.00),('TBS119','2026-08-14 00:00:00','hernan piquera',0.00,6350.00,0.00,450.00,0.00,5900.00,'finalizado','internacional','2026-11-05','2026-11-09',2,1540.00),('TBS120','2026-08-22 00:00:00','silvina lain',0.00,8500.00,0.00,366.00,0.00,8134.00,'finalizado','internacional','2026-10-28','2026-11-02',2,1560.00),('TBS121','2026-08-27 00:00:00','federico ledesma',0.00,3815.00,0.00,393.00,0.00,3422.00,'finalizado','internacional','2026-11-16','2026-11-23',2,1560.00),('TBS122','2026-09-11 00:00:00','araceli pulido',0.00,1960.00,0.00,237.00,0.00,1723.00,'finalizado','internacional','2026-10-04','2026-10-10',2,1560.00),('TBS123','2026-09-22 00:00:00','walter mandel',2270000.00,0.00,2270000.00,0.00,0.00,0.00,'pendiente','nacional','2026-11-09','2026-11-13',1,NULL);
/*!40000 ALTER TABLE `viaje` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_viaje_id` BEFORE INSERT ON `viaje` FOR EACH ROW BEGIN
  IF NEW.id IS NULL OR NEW.id = '' THEN
    -- Inserta un registro en viaje_seq para generar el prÃ³ximo nÃºmero
    INSERT INTO viaje_seq () VALUES ();
    -- LAST_INSERT_ID() devuelve ese AUTO_INCREMENT
    SET NEW.id = CONCAT(
      'TBS',
      LPAD(LAST_INSERT_ID(), 3, '0')
    );
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `trg_actualizar_ganancia_before_update_valTotal` BEFORE UPDATE ON `viaje` FOR EACH ROW BEGIN
  DECLARE v_base_ars DECIMAL(14,2);
  DECLARE v_base_usd DECIMAL(14,2);
  SET v_base_ars = COALESCE(NULLIF(NEW.valor_total, 0), OLD.valor_total, 0);
  SET v_base_usd = COALESCE(NULLIF(NEW.valor_total_usd, 0), OLD.valor_total_usd, 0);
  IF NEW.moneda_id = 1 THEN
    -- ARS puro: no necesita cotización
    SET NEW.valor_total     = ROUND(v_base_ars, 2);
    SET NEW.valor_total_usd = 0;
    SET NEW.ganancia        = ROUND(COALESCE(NEW.valor_total, 0) - COALESCE(NEW.costo, 0), 2);
    SET NEW.ganancia_usd    = 0;
  ELSEIF NEW.moneda_id = 2 THEN
    IF NEW.cotizacion IS NULL OR NEW.cotizacion <= 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cotizacion invalida para convertir a USD';
    END IF;
    SET NEW.valor_total_usd = ROUND(v_base_usd + (v_base_ars / NEW.cotizacion), 2);
    SET NEW.valor_total     = 0;
    SET NEW.ganancia_usd    = ROUND(COALESCE(NEW.valor_total_usd, 0) - COALESCE(NEW.costo_usd, 0), 2);
    SET NEW.ganancia        = 0;
  ELSEIF NEW.moneda_id = 3 THEN
    SET NEW.valor_total     = ROUND(v_base_ars, 2);
    SET NEW.valor_total_usd = ROUND(v_base_usd, 2);
    SET NEW.ganancia        = ROUND(COALESCE(NEW.valor_total, 0) - COALESCE(NEW.costo, 0), 2);
    SET NEW.ganancia_usd    = ROUND(COALESCE(NEW.valor_total_usd, 0) - COALESCE(NEW.costo_usd, 0), 2);
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `viaje_seq`
--

DROP TABLE IF EXISTS `viaje_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `viaje_seq` (
  `seq` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `viaje_seq`
--

LOCK TABLES `viaje_seq` WRITE;
/*!40000 ALTER TABLE `viaje_seq` DISABLE KEYS */;
INSERT INTO `viaje_seq` VALUES (1),(2),(3),(4),(5),(6),(17),(28),(29),(30),(37),(38),(39),(40),(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69),(70),(71),(72),(73),(74),(75),(76),(77),(78),(79),(80),(81),(82),(83),(84),(85),(86),(87),(88),(89),(90),(91),(92),(93),(94),(95),(96),(97),(98),(99),(100),(101),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(114),(115),(116),(117),(118),(119),(120),(121),(122),(123);
/*!40000 ALTER TABLE `viaje_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'theblacksheep'
--
/*!50003 DROP PROCEDURE IF EXISTS `actualizar_servicio_viaje` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_servicio_viaje`(
    IN p_viaje_id VARCHAR(6), 
    IN p_servicio_tipo_id TINYINT, 
    IN p_valor DECIMAL (12,2), 
    IN p_pagado_por ENUM ('pablo','soledad', 'mariana','pendiente'), 
    IN p_moneda_id INT, 
    IN p_cotizacion DECIMAL (12,2)
)
BEGIN
    UPDATE servicio
    SET valor = IFNULL(p_valor, valor),
        pagado_por = IFNULL(p_pagado_por, pagado_por),
        moneda_id = IFNULL(p_moneda_id, moneda_id),
        cotizacion = IFNULL(p_cotizacion, cotizacion)
    WHERE viaje_id = p_viaje_id
      AND servicio_tipo_id = p_servicio_tipo_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `actualizar_viaje` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_viaje`(

IN p_id VARCHAR(6), 

IN p_apellido VARCHAR(50), 

IN p_valor_total DECIMAL (12,2),

IN p_valor_total_usd DECIMAL (12,2),

IN p_destino ENUM ('nacional','internacional'),

IN p_fecha DATE,

IN p_fecha_ida DATE,

IN p_fecha_vuelta DATE,

IN p_moneda_id INT,

IN p_cotizacion DECIMAL(12,2)

)
BEGIN

    UPDATE viaje

    SET

        apellido = IFNULL(p_apellido, apellido),

        valor_total = IFNULL(p_valor_total, valor_total),

        valor_total_usd = IFNULL(p_valor_total_usd, valor_total_usd),

        destino = IFNULL(p_destino, destino),

        moneda_id = IFNULL(p_moneda_id, moneda_id),

        fecha_ida = IFNULL(p_fecha_ida, fecha_ida),

        fecha_vuelta = IFNULL(p_fecha_vuelta, fecha_vuelta),

        cotizacion = IFNULL(p_cotizacion, cotizacion),

        fecha = IFNULL(p_fecha, fecha)

    WHERE id = p_id;

    

    SELECT p_id AS id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `eliminar_servicio_viaje` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_servicio_viaje`(IN p_viaje_id VARCHAR(6), IN p_servicio_tipo_id TINYINT)
BEGIN
	DELETE FROM servicio WHERE viaje_id = p_viaje_id AND servicio_tipo_id = p_servicio_tipo_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `eliminar_viaje` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_viaje`(IN p_id VARCHAR(6))
BEGIN
	DELETE FROM viaje WHERE id = p_id ;
    SELECT p_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insertar_servicio_viaje` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_servicio_viaje`(
    IN p_viaje_id VARCHAR(6),
    IN p_servicio_tipo_id TINYINT,
    IN p_valor DECIMAL (12,2),
    IN p_pagado_por ENUM ('pablo','soledad', 'mariana','pendiente'),
    IN p_moneda_id INT,
    IN p_cotizacion DECIMAL (12,2)
)
BEGIN
    INSERT INTO servicio (viaje_id, servicio_tipo_id, valor, pagado_por, moneda_id, cotizacion)
    VALUES (p_viaje_id, p_servicio_tipo_id, p_valor, p_pagado_por, p_moneda_id, p_cotizacion);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insertar_viaje` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_viaje`(
        IN p_apellido VARCHAR(50),
        IN p_valor_total DECIMAL(12,2),
        IN p_valor_total_usd DECIMAL(12,2),
        IN p_destino ENUM('nacional', 'internacional'),
        IN p_fecha DATE,
        IN p_fecha_ida DATE,
        IN p_fecha_vuelta DATE,
        IN p_moneda_id INT,
        IN p_cotizacion DECIMAL(12,2)
      )
BEGIN
        DECLARE new_id VARCHAR(6);

        INSERT INTO viaje (fecha, apellido, valor_total, valor_total_usd, destino, fecha_vuelta, fecha_ida, moneda_id, cotizacion)
        VALUES (
          p_fecha,
          p_apellido,
          p_valor_total,
          IFNULL(p_valor_total_usd, 0),
          p_destino,
          p_fecha_vuelta,
          p_fecha_ida,
          p_moneda_id,
          p_cotizacion
        );

        SELECT id INTO new_id FROM viaje ORDER BY fecha DESC LIMIT 1;
        SELECT new_id AS id;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_usuario`(IN p_email VARCHAR(100))
BEGIN
SELECT * FROM usuario u WHERE u.email = p_email;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_viaje` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_viaje`(IN p_id VARCHAR(6))
BEGIN

    SELECT 

      v.id,

      v.fecha,

      v.estado,

      v.apellido,

      v.valor_total,

      v.valor_total_usd,

      v.fecha_ida,

      v.fecha_vuelta,

      m.moneda,

      v.ganancia,

      v.ganancia_usd,

      v.costo,

      v.costo_usd,

      v.destino,

      v.cotizacion,

      COALESCE(

        (

          SELECT JSON_ARRAYAGG(

            JSON_OBJECT(

              "id", st.id,

              "nombre", st.nombre,

              "pagado_por", s.pagado_por,

              "valor", s.valor,

              "moneda", m_s.moneda,

              "cotizacion", s.cotizacion,

              "observacion", s.observacion

            )

          )

          FROM servicio s

          LEFT JOIN servicio_tipo st ON s.servicio_tipo_id = st.id

          LEFT JOIN moneda m_s ON m_s.id = s.moneda_id

          WHERE s.viaje_id = v.id

        ), JSON_ARRAY()

      ) AS servicios

    FROM viaje v

    LEFT JOIN moneda m ON m.id = v.moneda_id

    WHERE v.id = p_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_viajes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_viajes`(
  IN filtro VARCHAR(20),   
  IN p_limit INT,
  IN p_offset INT,
  IN p_mes INT,           
  IN p_anio INT,
  IN p_search VARCHAR(50)   
)
BEGIN

  DECLARE filtros TEXT DEFAULT '';
  DECLARE orden VARCHAR(10) DEFAULT 'DESC';

  IF p_limit IS NULL OR p_limit <= 0 THEN SET p_limit = 10; END IF;
  IF p_offset IS NULL OR p_offset < 0 THEN SET p_offset = 0; END IF;

  IF LOWER(filtro) = 'asc' THEN SET orden = 'ASC';
  ELSEIF LOWER(filtro) = 'desc' THEN SET orden = 'DESC';
  END IF;

  IF LOWER(filtro) IN ('pendiente', 'finalizado', 'cancelado') THEN
    SET filtros = CONCAT(filtros, ' AND v.estado = "', filtro, '"');
  END IF;

  IF p_mes IS NOT NULL AND (p_anio IS NULL OR p_anio = 0) THEN
    SET filtros = CONCAT(filtros, ' AND MONTH(v.fecha) = ', p_mes, ' AND YEAR(v.fecha) = YEAR(CURDATE())');
  ELSEIF p_anio IS NOT NULL AND (p_mes IS NULL OR p_mes = 0) THEN
    SET filtros = CONCAT(filtros, ' AND YEAR(v.fecha) = ', p_anio);
  ELSEIF p_mes IS NOT NULL AND p_anio IS NOT NULL THEN
    SET filtros = CONCAT(filtros, ' AND MONTH(v.fecha) = ', p_mes, ' AND YEAR(v.fecha) = ', p_anio);
  END IF;

  -- Novedad: Búsqueda server-side por ID o Apellido
  IF p_search IS NOT NULL AND p_search != '' THEN
    SET filtros = CONCAT(filtros, ' AND (v.id LIKE CONCAT("%", "', p_search, '", "%") OR LOWER(v.apellido) LIKE CONCAT("%", LOWER("', p_search, '"), "%"))');
  END IF;

  SET @query = CONCAT(
    'SELECT 
      v.id,
      v.fecha,
      v.estado,
      v.apellido,
      v.valor_total,
      v.valor_total_usd,
      v.fecha_ida,
      v.fecha_vuelta,
      m.moneda,
      v.ganancia,
      v.ganancia_usd,
      v.costo,
      v.costo_usd,
      v.destino,
      v.cotizacion,
      COALESCE(
        (
          SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              "id", st.id,
              "nombre", st.nombre,
              "pagado_por", s.pagado_por,
              "valor", s.valor,
              "moneda", m_s.moneda,
              "cotizacion", s.cotizacion,
              "observacion", s.observacion
            )
          )
          FROM servicio s
          LEFT JOIN servicio_tipo st ON s.servicio_tipo_id = st.id
          LEFT JOIN moneda m_s ON m_s.id = s.moneda_id
          WHERE s.viaje_id = v.id
        ), JSON_ARRAY()
      ) AS servicios
    FROM viaje v
    LEFT JOIN moneda m ON m.id = v.moneda_id
    WHERE 1=1 ',
    filtros,
    ' GROUP BY v.id, v.fecha, v.estado, v.apellido, v.valor_total, v.valor_total_usd, m.moneda, v.ganancia, v.ganancia_usd, v.costo, v.costo_usd, v.destino, v.fecha_ida, v.fecha_vuelta, v.cotizacion',
    ' ORDER BY v.fecha ', orden,
    ' LIMIT ', p_limit,
    ' OFFSET ', p_offset
  );

  PREPARE stmt FROM @query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  SET @count_query = CONCAT(
    'SELECT COUNT(*) AS total FROM viaje v WHERE 1=1 ', filtros
  );

  PREPARE stmt2 FROM @count_query;
  EXECUTE stmt2;
  DEALLOCATE PREPARE stmt2;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `recalcular_viaje_costo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `recalcular_viaje_costo`(IN p_viaje_id VARCHAR(6))
BEGIN
    DECLARE v_moneda_viaje INT;
    DECLARE v_costo DECIMAL(15,2);

    SELECT moneda_id INTO v_moneda_viaje
    FROM viaje
    WHERE id = p_viaje_id;
    
    SELECT COALESCE(SUM(
        CASE
            WHEN s.moneda_id = v_moneda_viaje THEN s.valor
            WHEN v_moneda_viaje = 1 AND s.moneda_id = 2 AND s.tipo_cambio_id IS NOT NULL THEN s.valor * (
                SELECT tc.valor_base
                FROM tipo_cambio tc
                WHERE tc.id = s.tipo_cambio_id
            )

            WHEN v_moneda_viaje = 2 AND s.moneda_id = 1 AND s.tipo_cambio_id IS NOT NULL THEN s.valor / (
                SELECT tc.valor_base
                FROM tipo_cambio tc
                WHERE tc.id = s.tipo_cambio_id
            )
            ELSE 0
        END
    ), 0) INTO v_costo
    FROM servicio s
    WHERE s.viaje_id = p_viaje_id;

    UPDATE viaje
    SET costo = v_costo,
        ganancia = valor_total - v_costo
    WHERE id = p_viaje_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `resumen_financiero` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `resumen_financiero`(
  IN p_mes INT,
  IN p_anio INT,
  IN p_moneda INT
)
BEGIN
    SELECT
        T.moneda,
        MONTHNAME(T.fecha_ref) AS mes,
        MONTH(T.fecha_ref) AS mes_num,
        SUM(T.ingreso) AS ingreso,
        SUM(T.egreso) AS egreso,
        SUM(T.ingreso) - SUM(T.egreso) AS ganancia
    FROM (
        SELECT 'ars' AS moneda, 1 AS moneda_id, v.fecha AS fecha_ref,
               v.valor_total AS ingreso, IFNULL(v.costo, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 1 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

        UNION ALL

        SELECT 'usd' AS moneda, 2 AS moneda_id, v.fecha AS fecha_ref,
               IFNULL(v.valor_total_usd, 0) AS ingreso, IFNULL(v.costo_usd, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 2 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

        UNION ALL

        SELECT 'ars' AS moneda, 1 AS moneda_id, v.fecha AS fecha_ref,
               IFNULL(v.valor_total, 0) AS ingreso, IFNULL(v.costo, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 3 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

        UNION ALL

        SELECT 'usd' AS moneda, 2 AS moneda_id, v.fecha AS fecha_ref,
               IFNULL(v.valor_total_usd, 0) AS ingreso, IFNULL(v.costo_usd, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 3 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

    ) AS T
    WHERE (p_moneda IS NULL OR T.moneda_id = p_moneda)
      AND (p_mes IS NULL OR MONTH(T.fecha_ref) = p_mes)
    GROUP BY T.moneda, T.moneda_id, MONTH(T.fecha_ref), MONTHNAME(T.fecha_ref)
    ORDER BY mes_num, T.moneda;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-07 17:33:44
