/*
Navicat MySQL Data Transfer

Source Server         : tuita101
Source Server Version : 50511
Source Host           : 61.135.210.177:3306
Source Database       : tuita

Target Server Type    : MYSQL
Target Server Version : 50511
File Encoding         : 65001

Date: 2018-11-27 10:32:57
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for service_account
-- ----------------------------
DROP TABLE IF EXISTS `service_account`;
CREATE TABLE `service_account` (
  `srv_id` int(32) NOT NULL AUTO_INCREMENT,
  `secret` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `srv_title` varchar(100) NOT NULL,
  `srv_avatar` varchar(1024) NOT NULL,
  `cate_id` int(32) NOT NULL,
  `is_interactive` tinyint(1) NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  PRIMARY KEY (`srv_id`),
  KEY `IDX_SA_20140827` (`cate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of service_account
-- ----------------------------
INSERT INTO `service_account` VALUES ('21', 'Njh22hHAiBg0dAUi', '零拍', 'http://souyue-image.b0.upaiyun.com/sysimg/lingpai.png', '2', '0', '2014-08-27 17:04:38', '2014-08-27 17:04:38');
INSERT INTO `service_account` VALUES ('22', 'GTUbFNjYPICYarOs', '老虎机', 'http://souyue-image.b0.upaiyun.com/sysimg/laohuji.png', '2', '0', '2014-09-01 10:50:32', '2014-09-01 10:50:32');
INSERT INTO `service_account` VALUES ('23', 'KdUC_WjaXGLWpbzy', '兴趣圈', 'http://souyue-image.b0.upaiyun.com/sysimg/xingququan.png', '2', '0', '2014-09-01 10:52:36', '2014-09-01 10:52:36');
INSERT INTO `service_account` VALUES ('24', 'dIkzToFk3u9cDkMw', '活动', 'http://souyue-image.b0.upaiyun.com/sysimg/huodong.png', '2', '0', '2014-09-01 10:55:20', '2014-09-01 10:55:20');
INSERT INTO `service_account` VALUES ('25', 'dMbowfZUDBXx3YH6', '搜小悦-搜悦官方客服号', 'http://souyue-image.b0.upaiyun.com/sysimg/xiaoyuenew.png', '1', '1', '2014-09-01 14:10:57', '2014-09-01 14:10:57');
INSERT INTO `service_account` VALUES ('26', 'uxrB36lOfsZudKXE', '搜悦积分', 'http://souyue-image.b0.upaiyun.com/sysimg/xiaoyue.png', '1', '0', '2014-11-03 10:00:08', '2014-11-03 10:00:08');
INSERT INTO `service_account` VALUES ('27', 'aAiZdcoErXS7KMsE', '审核消息', 'http://sns-img.b0.upaiyun.com/Interest/1412/2213/56/11419227801.png', '2', '0', '2014-12-22 14:02:44', '2014-12-22 14:02:44');
INSERT INTO `service_account` VALUES ('28', 'lfbqKgR5ZRu57hfA', '会员消息', 'http://souyue-image.b0.upaiyun.com/y/member.png', '2', '0', '2015-04-07 15:56:16', '2015-04-07 15:56:16');
INSERT INTO `service_account` VALUES ('29', 'uyX5dEf5YTpZlirI', '随手报错', 'http://souyue-image.b0.upaiyun.com/sy/baocuo.png', '2', '0', '2015-04-13 17:25:18', '2015-05-07 11:02:22');
INSERT INTO `service_account` VALUES ('30', 'tq9y9wfvyz4m6L84', '新词制作', 'http://souyue-image.b0.upaiyun.com/sy/a5e931149015b54598478b4f6e9a6549.png', '2', '0', '2015-04-13 17:26:43', '2015-04-13 17:43:32');
