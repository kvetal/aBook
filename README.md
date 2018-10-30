Проект созданный исключительно для того, что бы разобраться с QtE5 и mysql-native, и попрактиковаться.

-dmd required. http://dlang.org/ <br>
-QtE5 required. https://github.com/MGWL/QtE5 <br>
-mysql-native required. https://github.com/mysql-d/mysql-native <br>


mysql -u mysql_user -p -h MySQL_Host <br>
\u mysql <br>
CREATE USER 'test'@'host' IDENTIFIED BY 'pass'; <br>
GRANT ALL PRIVILEGES ON storage.* to 'test'@'192.168.1.10'; <br>
FLUSH PRIVILEGES; <br>

MySQL Table create;
CREATE TABLE `person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `m_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `l_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sex` char(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `b_date` date DEFAULT NULL,
  `mobile_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `postcode` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `house` int(11) DEFAULT NULL,
  `building` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `apartment` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
