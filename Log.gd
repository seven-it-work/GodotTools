## Log 日志静态工具类
## 参考 Java Log4j 设计的日志系统
## 依赖：DateUtils.gd 和 FileUtil.gd
## 特性：
##   1. 支持 debug / info / warn / error 四级日志过滤
##   2. init() 启动时归档旧的 log.log 到按日期命名的目录
##   3. 使用 Engine.capture_script_backtraces() 记录调用链路
##   4. 标准格式：yyyy-MM-dd HH:mm:ss [调用链路] [级别] 信息
## 使用说明：
##   在项目启动时调用一次 Log.init() 即可，之后通过 Log.info/debug/warn/error 输出日志
## 作者：开发团队
## 创建日期：2026-06-30
extends RefCounted
class_name Log

## 日志级别常量
static var LEVEL_DEBUG: int = 0
static var LEVEL_INFO: int = 1
static var LEVEL_WARN: int = 2
static var LEVEL_ERROR: int = 3

## 当前日志级别（低于该级别的日志将被过滤）
static var level: int = LEVEL_INFO

## 日志根目录（user://logs/，运行时可写）
static var LOG_DIR: String = "res://logs/"
## 当前会话写入的日志文件名
static var CURRENT_LOG_FILE: String = "log.log"
## 是否显示具体的堆栈链路
static var show_stack_trace: bool = false

## 日志文件句柄（保持打开，减少 IO 开销）
static var _file: FileAccess = null
## init() 是否已经调用过（防止重复初始化）
static var _inited: bool = false
## init() 被调用的时间戳，用于归档命名
static var _init_timestamp: int = 0

## 在程序启动时调用一次，完成两个职责：
##   1. 归档已有的 log.log 到按日期命名的目录
##   2. 创建并打开新的 log.log，供后续日志写入
static func init() -> void:
	if _inited:
		return
	_inited = true

	_init_timestamp = DateUtils.get_now()

	# 确保日志根目录存在
	FileUtil.mkdir(LOG_DIR)

	# 1) 归档旧的 log.log
	_archive_old_log()

	# 2) 打开新的 log.log
	var current_path = LOG_DIR+CURRENT_LOG_FILE
	FileUtil.touch(current_path)

	_file = FileAccess.open(current_path, FileAccess.READ_WRITE)
	if _file != null:
		_file.seek_end()
	else:
		print("[Log] 无法打开日志文件：", current_path)

## 将已有的 log.log 归档到按日期命名的目录下
## 目录结构示例：
##   user://logs/2026-06/30.log
## 参数 dir: 已打开的日志根目录
static func _archive_old_log() -> void:
	var old_path = LOG_DIR+CURRENT_LOG_FILE
	if not FileUtil.exist(old_path):
		return
	var date=DateUtils.format("yyyy-MM-dd HH-mm-ss").split(" ")
	var dir=LOG_DIR+date[0]+"/"
	FileUtil.mkdir(dir)
	var fileName=dir+date[1]+".log"
	FileUtil.move(old_path,fileName)

## 输出 DEBUG 级别日志
## 参数 message: 日志消息
static func debug(message: String) -> void:
	_write("DEBUG", message)

## 输出 INFO 级别日志
## 参数 message: 日志消息
static func info(message: String) -> void:
	_write("INFO", message)

## 输出 WARN 级别日志
## 参数 message: 日志消息
static func warn(message: String) -> void:
	_write("WARN", message)

## 输出 ERROR 级别日志
## 参数 message: 日志消息
static func error(message: String) -> void:
	_write("ERROR", message)

## 设置当前日志级别
## 参数 level_name: 级别名称，可选值 debug/info/warn/error
static func set_level(level_name: String) -> void:
	match level_name:
		"debug":
			level = LEVEL_DEBUG
		"info":
			level = LEVEL_INFO
		"warn":
			level = LEVEL_WARN
		"error":
			level = LEVEL_ERROR

## 内部写入方法：组装日志行并输出到控制台与文件
## 参数 level_str: 日志级别字符串 (DEBUG/INFO/WARN/ERROR)
## 参数 message: 日志消息
static func _write(level_str: String, message: String) -> void:
	# 级别过滤
	var level_map = {
		"DEBUG": LEVEL_DEBUG,
		"INFO": LEVEL_INFO,
		"WARN": LEVEL_WARN,
		"ERROR": LEVEL_ERROR,
	}
	if level_map.get(level_str, LEVEL_DEBUG) < level:
		return

	# 时间戳
	var ts = _format_timestamp()

	# 调用链路
	var caller = _extract_caller()

	# 组装日志行
	var log_line = "%s [%s] [%s] %s" % [ts,  level_str, caller, message]

	# 控制台输出
	match level_str:
		"DEBUG":
			print_debug(log_line)
		"INFO":
			print(log_line)
		"WARN":
			push_warning(log_line)
		"ERROR":
			push_error(log_line)

	# 写入文件（若 init 未调用则跳过文件写入，仍保证控制台输出）
	if _file != null:
		_file.store_line(log_line)
		_file.flush()

## 格式化当前时间戳为 yyyy-MM-dd HH:mm:ss
## 返回: 格式化后的时间字符串
static func _format_timestamp() -> String:
	var dt = Time.get_datetime_dict_from_system(false)
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second
	]

## 从脚本调用栈中提取完整的调用链路
## 跳过 Log 自身的栈帧，用 "->" 拼接成完整链路
## 返回: 形如 "A.gd:24->B.gd:26->C.gd:76" 的调用链路字符串
static func _extract_caller() -> String:
	var frames: Array[ScriptBacktrace] = Engine.capture_script_backtraces()
	if frames == null or frames.is_empty():
		return "unknown"

	var log_script_path = _get_self_path()
	var chain_parts: Array[String] = []

	# Engine.capture_script_backtraces() 返回每个脚本语言的 ScriptBacktrace 数组
	# 每个 ScriptBacktrace 内部包含多个栈帧，通过 get_frame_count() 和索引访问
	for bt: ScriptBacktrace in frames:
		if bt == null or bt.is_empty():
			continue
		# 遍历该 ScriptBacktrace 中的所有栈帧
		for i in bt.get_frame_count():
			var file: String = bt.get_frame_file(i)
			# 跳过 Log 自身的栈帧
			if file == log_script_path:
				continue
			var script_name: String = "?"
			var line: int = bt.get_frame_line(i)
			if file != "":
				var parts = file.split("/")
				script_name = parts[parts.size() - 1]
			chain_parts.append("%s:%d" % [script_name, line])

	if chain_parts.is_empty():
		return "unknown"
	chain_parts.reverse()
	if show_stack_trace:
		var result: String = ""
		for i in chain_parts.size():
			if i > 0:
				result += "->"
			result += chain_parts[i]
		return result
	else:
		return chain_parts.back()

## 获取 Log.gd 自身的资源路径，用于在调用栈中过滤掉自身栈帧
## 返回: res:// 路径字符串
static func _get_self_path() -> String:
	return "res://addons/godot_tool/Log.gd"

## 关闭日志文件句柄（程序退出时可选调用）
static func shutdown() -> void:
	if _file != null:
		_file.flush()
		_file.close()
		_file = null
