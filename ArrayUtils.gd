extends RefCounted
class_name ArrayUtils


static func is_empty(array:Array)->bool:
	if array==null:
		return true;
	if array.is_empty():
		return true
	return false;

static func get_last(array:Array):
	if is_empty(array):
		return null;
	return array.get(array.size()-1)
