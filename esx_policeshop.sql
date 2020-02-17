USE `essentialmode`;

CREATE TABLE `policeshop` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`store` varchar(100) NOT NULL,
	`item` varchar(100) NOT NULL,
	`price` int(11) NOT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `policeshop` (store, item, price) VALUES
	('policeshop','bread',5),
	('policeshop','water',5),
	('policeshop','bandage',50),
	('policeshop','fixkit',100)
;