extends VisionTask

var task: MediaPipeFaceLandmarker
var task_file := "face_landmarker_v2_with_blendshapes.task"
var task_file_generation := 1681322467931433

var dir_latest := Vector2(0.0, 0.0)
var mouth_open_latest := false
var player_detected_latest := false

var current_rot := Vector3(0.0, 0.0, 0.0)
var current_mouth := 0.0

func _result_callback(result: MediaPipeFaceLandmarkerResult, image: MediaPipeImage, timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

func _init_task() -> void:
	var file := get_model_asset(task_file, task_file_generation)
	if file == null:
		return
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	task = MediaPipeFaceLandmarker.new()
	task.initialize(base_options, MediaPipeTask.VisionRunningMode.RUNNING_MODE_LIVE_STREAM, 1, 0.5, 0.5, 0.5, true)
	task.result_callback.connect(self._result_callback)
	super()

func _process_camera(image: MediaPipeImage, timestamp_ms: int) -> void:
	if task:
		task.detect_async(image, timestamp_ms)

func show_result(image: Image, result: MediaPipeFaceLandmarkerResult) -> void:
	player_detected_latest = result.face_landmarks.size() > 0
	for landmarks in result.face_landmarks:
		# draw_landmarks(image, landmarks)
		do_mesh_stuff(landmarks, result.face_blendshapes)
	if result.has_face_blendshapes():
		for blendshape in result.face_blendshapes:
			pass # HANDLE BLENDSHAPES

func draw_landmarks(image: Image, landmarks: MediaPipeNormalizedLandmarks) -> void:
	var color := Color.GREEN
	var rect := Image.create(12, 12, false, image.get_format())
	var image_size := Vector2(image.get_size())
	rect.fill(color)
	# var landmark := landmarks.landmarks[i]
	# var pos := Vector2(landmark.x, landmark.y)
	# rect.fill(lerp(Color.GREEN, Color.RED, landmark.z*20.0))
	# image.blit_rect(rect, rect.get_used_rect(), Vector2i(image_size * pos) - rect.get_size() / 2)

func do_mesh_stuff(landmarks: MediaPipeNormalizedLandmarks, blendshapes: Array[MediaPipeClassifications]) -> void:
	var diffH = landmarks.landmarks[356].z - (landmarks.landmarks[34].z + 0.030)
	dir_latest.x = clamp(inverse_lerp(0.08, -0.08, diffH), 0.0, 1.0)
	current_rot.y = lerp(-45, 45, dir_latest.x)
	var diffV = landmarks.landmarks[10].z - (landmarks.landmarks[18].z + 0.035)
	dir_latest.y = clamp(inverse_lerp(0.08, -0.08, diffV), 0.0, 1.0)
	current_rot.x = 90.0 + lerp(-45, 45, dir_latest.y)

	current_mouth = 0.0
	for blendshape in blendshapes:
		for category in blendshape.categories:
			if category.has_category_name() and (category.category_name == "jawOpen" or category.category_name == "jawLeft" or category.category_name == "jawRight"):
				current_mouth = max(current_mouth, category.score)
	mouth_open_latest = current_mouth > 0.05
