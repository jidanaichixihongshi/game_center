/*
Navicat MySQL Data Transfer

Source Server         : game_center
Source Server Version : 50724
Source Host           : 192.168.177.129:3306
Source Database       : game_center

Target Server Type    : MYSQL
Target Server Version : 50724
File Encoding         : 65001

Date: 2018-11-26 18:30:52
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for account
-- ----------------------------
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account` (
  `uid` int(11) NOT NULL,
  `pwd` varchar(50) DEFAULT NULL,
  `secpwd` varchar(50) DEFAULT '123456',
  PRIMARY KEY (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- ----------------------------
-- Table structure for user_info
-- ----------------------------
DROP TABLE IF EXISTS `user_info`;
CREATE TABLE `user_info` (
  `uid` int(11) NOT NULL,
  `nickname` varchar(50) DEFAULT '佚名',
  `avatar` varchar(100) DEFAULT '<<"avatar.jpg">>',
  `mobile` varchar(20) DEFAULT NULL,
  `creat_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- ----------------------------
-- Records of user_info
-- ----------------------------
