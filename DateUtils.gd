## DateUtils 时间工具类
## 仿照 Java Hutool DateUtils 实现的时间处理工具
## 提供时间格式化、日期获取等工具方法
class_name DateUtils
extends RefCounted

## 默认构造函数
func _init():
	pass

## 格式化时间戳为指定格式的字符串（本地时区）
## 参数 pattern: 格式模板，支持占位符 yyyy/MM/dd/HH/mm/ss
## 参数 timestamp: 时间戳（秒），默认-1表示当前系统时间
## 返回: 格式化后的时间字符串
static func format(pattern: String, timestamp: int = -1) -> String:
	var ts: int = timestamp if timestamp >= 0 else Time.get_unix_time_from_system()
	
	# 获取系统时区偏移（分钟，东半球为正，北京时间=+480）
	var tz_bias_min: int = Time.get_time_zone_from_system().bias
	var local_ts: int = ts + tz_bias_min * 60
	
	# 用 UTC→local_ts 得到本地时间字典
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(local_ts)
	
	var r := pattern
	r = r.replace("yyyy", "%04d" % dt.year)
	r = r.replace("MM", "%02d" % dt.month)
	r = r.replace("dd", "%02d" % dt.day)
	r = r.replace("HH", "%02d" % dt.hour)
	r = r.replace("mm", "%02d" % dt.minute)
	r = r.replace("ss", "%02d" % dt.second)
	return r

## 获取当前系统时间戳（秒）
## 返回: 当前时间戳（从1970年1月1日00:00:00 UTC开始的秒数）
static func get_now() -> int:
	return Time.get_unix_time_from_system()

## 获取当前日期字符串（本地时区）
## 返回: 格式为 "yyyy-MM-dd" 的日期字符串
static func get_date_str() -> String:
	return Time.get_date_string_from_system(false)


## 获取当前日期时间字符串（本地时区）
## 返回: 格式为 "yyyy-MM-dd HH:mm:ss" 的日期时间字符串
static func get_datetime_str() -> String:
	return Time.get_datetime_string_from_system(false, true)

## 获取当前时间字符串（本地时区，不含日期）
## 返回: 格式为 "HH:mm:ss" 的时间字符串
static func get_time_str() -> String:
	# 获取当前系统时间字典（本地时区）
	var dt = Time.get_datetime_dict_from_system(false)
	return "%02d:%02d:%02d" % [dt.hour, dt.minute, dt.second]
