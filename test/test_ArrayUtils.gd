extends Node


func test() -> void:
	获取最后一个元素()
	pass # Replace with function body.


func 获取最后一个元素():
	var array=[1,2,3,4,5]
	assert(ArrayUtils.get_last(array)==5,"最后一个结果应该为5")
	pass
