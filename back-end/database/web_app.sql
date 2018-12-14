DROP DATABASE web_app;

CREATE DATABASE IF NOT EXISTS web_app;

USE web_app;

CREATE TABLE IF NOT EXISTS user (
  id INT AUTO_INCREMENT PRIMARY KEY, /* Not visible to the user */
  first_name VARCHAR(15) NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  user_name VARCHAR(20) UNIQUE, /* Should be unique */
  password VARCHAR(20) NOT NULL, /* At least 10 characters */
  email VARCHAR(30) NOT NULL UNIQUE,
  phone_number BIGINT UNIQUE
);

CREATE TABLE IF NOT EXISTS product (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20) NOT NULL UNIQUE,
  description VARCHAR(100) NOT NULL,
  /*company VARCHAR(20) NOT NULL,*/
  category VARCHAR(20) NOT NULL,
  stars DECIMAL(2,1) NOT NULL,
  withdrawn BOOLEAN DEFAULT 0 /* False */
);

CREATE TABLE IF NOT EXISTS product_tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  FOREIGN KEY product_id(id)
  REFERENCES product(id),
  tag VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS product_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  FOREIGN KEY product_id(id)
  REFERENCES product(id),
  data VARCHAR(20)
);


CREATE TABLE IF NOT EXISTS store (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  address VARCHAR(30) NOT NULL,
  lat DECIMAL(10,8) NOT NULL,
  lng DECIMAL(11,8) NOT NULL,
  withdrawn BOOLEAN DEFAULT 0
);

CREATE TABLE IF NOT EXISTS store_tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  FOREIGN KEY store_id(id)
  REFERENCES store(id),
  tag VARCHAR(20)
);


CREATE TABLE IF NOT EXISTS has_product (
  id INT AUTO_INCREMENT PRIMARY KEY,
  FOREIGN KEY user_id(id)
  REFERENCES user(id),
  FOREIGN KEY product_id(id)
  REFERENCES product(id),
  FOREIGN KEY store_id(id)
  REFERENCES store(id),
  price DOUBLE(5,2) NOT NULL,
  date_from DATE NOT NULL, /* format: YYYY-MM-DD */
  date_to DATE NOT NULL,
  stars DECIMAL(2,1) NOT NULL
);

/* First name constraint, only alphabetic characters are allowed */

DELIMITER $$

CREATE PROCEDURE `check_first_name`(IN first_name VARCHAR(15))
BEGIN
    IF (NOT(first_name REGEXP '^[A-Za-z]+$')) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check constraint on first_name failed';
    END IF;
END$$

DELIMITER ;

-- Before insert
DELIMITER $$
CREATE TRIGGER `first_name_before_insert` BEFORE INSERT ON `user`
FOR EACH ROW
BEGIN
    CALL check_first_name(new.first_name);
END$$
DELIMITER ;

-- before update
DELIMITER $$
CREATE TRIGGER `first_name_before_update` BEFORE UPDATE ON `user`
FOR EACH ROW
BEGIN
    CALL check_first_name(new.first_name);
END$$
DELIMITER ;


/* Last name constraint, only alphabetic characters are allowed */

DELIMITER $$

CREATE PROCEDURE `check_last_name`(IN last_name VARCHAR(20))
BEGIN
    IF (NOT(last_name REGEXP '^[A-Za-z]+$')) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check constraint on last_name failed';
    END IF;
END$$

DELIMITER ;

-- Before insert
DELIMITER $$
CREATE TRIGGER `last_name_before_insert` BEFORE INSERT ON `user`
FOR EACH ROW
BEGIN
    CALL check_last_name(new.last_name);
END$$
DELIMITER ;

-- before update
DELIMITER $$
CREATE TRIGGER `last_name_before_update` BEFORE UPDATE ON `user`
FOR EACH ROW
BEGIN
    CALL check_last_name(new.last_name);
END$$
DELIMITER ;


/* Password constraint, at least 10 characters */

DELIMITER $$

CREATE PROCEDURE `check_password`(IN password VARCHAR(20))
BEGIN
    IF (CHAR_LENGTH(password) < 10) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check constraint on user.password failed';
    END IF;
END$$

DELIMITER ;

-- Before insert
DELIMITER $$
CREATE TRIGGER `password_before_insert` BEFORE INSERT ON `user`
FOR EACH ROW
BEGIN
    CALL check_password(new.password);
END$$
DELIMITER ;

-- before update
DELIMITER $$
CREATE TRIGGER `password_before_update` BEFORE UPDATE ON `user`
FOR EACH ROW
BEGIN
    CALL check_password(new.password);
END$$
DELIMITER ;

/* Phone number constraint, exactly 10 numbers */

DELIMITER $$

CREATE PROCEDURE `check_phone_number`(IN phone_number BIGINT)
BEGIN
    IF (phone_number > 9999999999 OR phone_number < 1000000000) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check constraint on user.phone_number failed';
    END IF;
END$$

DELIMITER ;

-- before insert
DELIMITER $$
CREATE TRIGGER `phone_number_before_insert` BEFORE INSERT ON `user`
FOR EACH ROW
BEGIN
    CALL check_phone_number(new.phone_number);
END$$
DELIMITER ;
-- before update
DELIMITER $$
CREATE TRIGGER `phone_number_before_update` BEFORE UPDATE ON `user`
FOR EACH ROW
BEGIN
    CALL check_phone_number(new.phone_number);
END$$
DELIMITER ;



/* Stars constraint, values in {0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0} */

DELIMITER $$

CREATE PROCEDURE `check_stars`(IN stars DECIMAL(2,1))
BEGIN
    IF (stars > 5 OR stars < 0.5 OR FLOOR(2*stars) <> 2*stars) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check constraint on stars failed';
    END IF;
END$$

DELIMITER ;

-- Before insert
DELIMITER $$
CREATE TRIGGER `stars_before_insert` BEFORE INSERT ON `product`
FOR EACH ROW
BEGIN
    CALL check_stars(new.stars);
END$$
DELIMITER ;

-- before update
DELIMITER $$
CREATE TRIGGER `stars_before_update` BEFORE UPDATE ON `product`
FOR EACH ROW
BEGIN
    CALL check_stars(new.stars);
END$$
DELIMITER ;

INSERT INTO user (first_name, last_name, user_name, password, email, phone_number)
VALUES ('John', 'Doe', 'johnDoe', '1234567891', 'johnDoe@ntua.gr', 1234567891),
('Freddy', 'Milk', 'freddyMilk', '1234567891', 'freddyMilk@ntua.gr', 1234567892);