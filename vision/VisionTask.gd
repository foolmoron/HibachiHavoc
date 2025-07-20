class_name VisionTask
extends Node

var model_assets_dir := "user://GDMP/vision"
var request: HTTPRequest
var delegate := MediaPipeTaskBaseOptions.DELEGATE_CPU
var camera_helper: MediaPipeCameraHelper = MediaPipeCameraHelper.new()
var camera_extension := CameraServerExtension.new()
var camera_feed: CameraFeed
var camera_texture := CameraTexture.new()
var use_camera_extension := true
var image_file_web: FileAccessWeb
var video_file_web: FileAccessWeb

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var image_view: TextureRect = $Image

func _exit_tree() -> void:
	camera_extension = null

func _ready():
	progress_bar.hide()
	camera_helper.new_frame.connect(self._camera_frame)

	for feed in CameraServer.feeds():
		camera_feed = feed
		var formats := camera_feed.get_formats()
		for i in range(formats.size()):
			var format: Dictionary = formats[i]
			if format.has("frame_numerator") and format.has("frame_denominator"):
				format["fps"] = round(format["frame_denominator"] / format["frame_numerator"])
			if format.has("framerate_numerator") and format.has("framerate_denominator"):
				format["fps"] = round(format["framerate_numerator"] / format["framerate_denominator"])
			if format["fps"] == 15:
				camera_feed.set_format(i, {})
				break

	_init_task()
	_open_camera()

func _process(_delta: float) -> void:
	if request:
		progress_bar.show()
		var max_size := request.get_body_size()
		var cur_size := request.get_downloaded_bytes()
		progress_bar.value = round(float(cur_size) / float(max_size) * 100)

func _reset() -> void:
	if camera_feed:
		camera_feed.feed_is_active = false
		if camera_feed.frame_changed.is_connected(self._camera_feed_frame):
			camera_feed.frame_changed.disconnect(self._camera_feed_frame)
	camera_helper.close()

func _get_model_asset(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, path: String) -> void:
	progress_bar.hide()
	image_view.show()
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	if response_code != HTTPClient.RESPONSE_OK:
		return
	if body.is_empty():
		return
	if DirAccess.make_dir_recursive_absolute(model_assets_dir) != OK:
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_buffer(body)
	file.close()
	request = null
	_init_task()

func _init_task() -> void:
	pass

func _open_camera() -> void:
	_reset()
	if not camera_helper.permission_granted():
		camera_helper.request_permission()
	_start_camera()

func _start_camera() -> void:
	if use_camera_extension:
		camera_texture.camera_feed_id = camera_feed.get_id()
		camera_feed.frame_changed.connect(self._camera_feed_frame)
		camera_feed.feed_is_active = true
	else:
		camera_helper.set_mirrored(true)
		camera_helper.start(MediaPipeCameraHelper.FACING_FRONT, Vector2(640, 480))

func _camera_feed_frame() -> void:
	if camera_texture == null:
		return
	var image := camera_texture.get_image()
	if image == null or image.is_empty():
		return
	var img := MediaPipeImage.new()
	img.set_image(image)
	_camera_frame(img)

func _camera_frame(image: MediaPipeImage) -> void:
	if delegate == MediaPipeTaskBaseOptions.DELEGATE_CPU and image.is_gpu_image():
		image.convert_to_cpu()
	_process_camera(image, Time.get_ticks_msec())

func _process_image(_image: Image) -> void:
	pass

func _process_video(_image: Image, _timestamp_ms: int) -> void:
	pass

func _process_camera(_image: MediaPipeImage, _timestamp_ms: int) -> void:
	pass

func get_model_asset(filename: String, generation: int = -1) -> FileAccess:
	var path := model_assets_dir.path_join(filename)
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		return file
	request = MediaPipeExternalFiles.get_asset(filename, generation)
	if request != null:
		image_view.hide()
		progress_bar.show()
		var callback := _get_model_asset.bind(path)
		request.request_completed.connect(callback)
	return null

func update_image(image: Image) -> void:
	if image == null or image.is_empty():
		return
	if Vector2i(image_view.texture.get_size()) == image.get_size():
		image_view.texture.call_deferred("update", image)
	else:
		image_view.texture.call_deferred("set_image", image)
