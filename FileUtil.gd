## FileUtil 文件工具类
## 模仿 Java Hutool FileUtils 实现的文件处理工具
## 提供常用的文件操作功能，如读写、复制、删除、检查等
class_name FileUtil
extends RefCounted

## 默认构造函数
func _init():
	pass

## 检查文件是否存在
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 返回: 文件存在返回 true，否则返回 false
static func exist(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)

## 检查目录是否存在
## 参数 dir_path: 目录路径（支持 res:// 和 user:// 协议）
## 返回: 目录存在返回 true，否则返回 false
static func exist_dir(dir_path: String) -> bool:
	return DirAccess.dir_exists_absolute(dir_path)

## 创建目录（如果不存在）
## 参数 dir_path: 目录路径（支持 res:// 和 user:// 协议）
## 返回: 创建成功或目录已存在返回 true
static func mkdir(dir_path: String) -> bool:
	if DirAccess.dir_exists_absolute(dir_path):
		return true
	return DirAccess.make_dir_recursive_absolute(dir_path)

## 创建文件（如果不存在）
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 返回: 创建成功或文件已存在返回 true
static func touch(file_path: String) -> bool:
	if FileAccess.file_exists(file_path):
		return true
	var dir_path = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	file.close()
	return true

## 删除文件
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 返回: 删除成功返回 true，文件不存在也返回 true
static func remove(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		return true
	DirAccess.remove_absolute(file_path.get_base_dir())
	return true

## 读取文件全部内容为字符串
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 返回: 文件内容字符串，读取失败返回空字符串
static func read_str(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return ""
	var content = file.get_as_text()
	file.close()
	return content

## 读取文件全部内容为字节数组
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 返回: 文件内容字节数组，读取失败返回空数组
static func read_bytes(file_path: String) -> PackedByteArray:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return PackedByteArray()
	var content = file.get_buffer(file.get_length())
	file.close()
	return content

## 将字符串写入文件（覆盖模式）
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 参数 content: 要写入的字符串内容
## 返回: 写入成功返回 true
static func write_str(file_path: String, content: String) -> bool:
	var dir_path = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(content)
	file.close()
	return true

## 将字符串追加到文件末尾
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 参数 content: 要追加的字符串内容
## 返回: 追加成功返回 true
static func append_str(file_path: String, content: String) -> bool:
	var dir_path = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file = null
	if FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	file.seek_end()
	file.store_string(content)
	file.close()
	return true

## 将字节数组写入文件（覆盖模式）
## 参数 file_path: 文件路径（支持 res:// 和 user:// 协议）
## 参数 data: 要写入的字节数组
## 返回: 写入成功返回 true
static func write_bytes(file_path: String, data: PackedByteArray) -> bool:
	var dir_path = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(data)
	file.close()
	return true

## 复制文件
## 参数 src_path: 源文件路径
## 参数 dest_path: 目标文件路径
## 返回: 复制成功返回 true
static func copy(src_path: String, dest_path: String) -> bool:
	if not FileAccess.file_exists(src_path):
		return false
	var content = read_bytes(src_path)
	return write_bytes(dest_path, content)

## 移动文件（复制后删除源文件）
## 参数 src_path: 源文件路径
## 参数 dest_path: 目标文件路径
## 返回: 移动成功返回 true
static func move(src_path: String, dest_path: String) -> bool:
	DirAccess.rename_absolute(src_path,dest_path)
	return true

## 获取文件名（包含扩展名）
## 参数 file_path: 文件路径
## 返回: 文件名，例如 "test.txt"
static func get_name(file_path: String) -> String:
	return file_path.get_file()

## 获取文件名（不含扩展名）
## 参数 file_path: 文件路径
## 返回: 文件名，例如 "test"
static func get_name_without_ext(file_path: String) -> String:
	var file_name = file_path.get_file()
	var dot_idx = file_name.rfind(".")
	if dot_idx == -1:
		return file_name
	return file_name.substr(0, dot_idx)

## 获取文件扩展名
## 参数 file_path: 文件路径
## 返回: 扩展名，例如 "txt"，无扩展名返回空字符串
static func get_ext(file_path: String) -> String:
	var file_name = file_path.get_file()
	var dot_idx = file_name.rfind(".")
	if dot_idx == -1:
		return ""
	return file_name.substr(dot_idx + 1)

## 获取文件大小（字节）
## 参数 file_path: 文件路径
## 返回: 文件大小，失败返回 -1
static func size(file_path: String) -> int:
	if not FileAccess.file_exists(file_path):
		return -1
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return -1
	var file_size = file.get_length()
	file.close()
	return file_size

## 格式化文件大小为可读字符串
## 参数 bytes: 文件大小（字节）
## 返回: 格式化的大小字符串，如 "1.50 MB"
static func format_size(bytes: int) -> String:
	if bytes < 0:
		return "0 B"
	var units = ["B", "KB", "MB", "GB", "TB"]
	var unit_index = 0
	var size: float = float(bytes)
	while size >= 1024.0 and unit_index < units.size() - 1:
		size /= 1024.0
		unit_index += 1
	if unit_index == 0:
		return "%d %s" % [int(size), units[unit_index]]
	return "%.2f %s" % [size, units[unit_index]]

## 列出目录下的所有文件（不递归）
## 参数 dir_path: 目录路径
## 返回: 文件路径数组
static func list_files(dir_path: String) -> Array:
	var result = []
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not file_name.begins_with("."):
			var full_path = dir_path.ends_with("/") and (dir_path + file_name) or (dir_path + "/" + file_name)
			if FileAccess.file_exists(full_path):
				result.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result

## 列出目录下的所有文件（递归子目录）
## 参数 dir_path: 目录路径
## 返回: 文件路径数组
static func list_files_recursive(dir_path: String) -> Array:
	var result = []
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not file_name.begins_with("."):
			var full_path = dir_path.ends_with("/") and (dir_path + file_name) or (dir_path + "/" + file_name)
			if FileAccess.file_exists(full_path):
				result.append(full_path)
			elif DirAccess.dir_exists_absolute(full_path):
				var sub_files = list_files_recursive(full_path)
				for f in sub_files:
					result.append(f)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result

## 列出目录下的所有子目录（不递归）
## 参数 dir_path: 目录路径
## 返回: 目录路径数组
static func list_dirs(dir_path: String) -> Array:
	var result = []
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not file_name.begins_with("."):
			var full_path = dir_path.ends_with("/") and (dir_path + file_name) or (dir_path + "/" + file_name)
			if DirAccess.dir_exists_absolute(full_path):
				result.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result

## 清理目录（删除目录下所有文件和子目录，但保留目录本身）
## 参数 dir_path: 目录路径
## 返回: 清理成功返回 true
static func clean_dir(dir_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(dir_path):
		return false
	var sub_dirs = list_dirs(dir_path)
	for sub_dir in sub_dirs:
		delete_dir(sub_dir)
	var files = list_files(dir_path)
	for file_path in files:
		remove(file_path)
	return true

## 删除目录（递归删除所有内容和目录本身）
## 参数 dir_path: 目录路径
## 返回: 删除成功返回 true
static func delete_dir(dir_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(dir_path):
		return false
	var sub_dirs = list_dirs(dir_path)
	for sub_dir in sub_dirs:
		delete_dir(sub_dir)
	var files = list_files(dir_path)
	for file_path in files:
		remove(file_path)
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return false
	var ok = dir.remove_recursive()
	dir.close()
	return ok

## 读取配置文件（简单的 key=value 格式）
## 参数 file_path: 配置文件路径
## 返回: 配置字典 {key: value}
static func read_properties(file_path: String) -> Dictionary:
	var result = {}
	var content = read_str(file_path)
	if content == "":
		return result
	var lines = content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var eq_idx = line.find("=")
		if eq_idx > 0:
			var key = line.substr(0, eq_idx).strip_edges()
			var value = line.substr(eq_idx + 1).strip_edges()
			result[key] = value
	return result

## 写入配置文件（简单的 key=value 格式）
## 参数 file_path: 配置文件路径
## 参数 props: 配置字典 {key: value}
## 返回: 写入成功返回 true
static func write_properties(file_path: String, props: Dictionary) -> bool:
	var content = ""
	for key in props.keys():
		content += "%s=%s\n" % [key, props[key]]
	return write_str(file_path, content)
