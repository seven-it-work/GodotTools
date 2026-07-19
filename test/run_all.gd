extends Control



func _ready():
	var script_folder = get_script().resource_path.get_base_dir()
	print("开始测试：",script_folder)
	var list=FileUtil.list_files_recursive(script_folder, _file_filter.bind())
	for i in list:
		execute_single_script(i)

func _file_filter(filePath:String)->bool:
	var fileName=ArrayUtils.get_last(filePath.split("/"))
	return fileName.begins_with("test_") and fileName.ends_with(".gd")

# 加载并执行单个脚本
func execute_single_script(gd_path: String):
	print("\n===== 开始执行脚本: ", gd_path, " =====")
	# 加载脚本资源
	var script: GDScript = load(gd_path)
	if not script:
		print("加载失败: ", gd_path)
		return
	
	# 创建临时节点承载脚本
	var temp_node = Node.new()
	temp_node.set_script(script)
	add_child(temp_node)

	# 调用统一入口 test()
	if temp_node.has_method("test"):
		temp_node.test()
	else:
		print(gd_path, " 缺少 run() 入口函数")

	# 执行完成后销毁临时节点
	temp_node.queue_free()
	print("===== 脚本 ", gd_path, " 执行完毕 =====\n")
