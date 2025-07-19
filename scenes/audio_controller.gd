class_name AudioControl extends AudioStreamPlayer

@onready var eatSFX := $EatSFX

func switchMusic(song : AudioStream):
	stream = song
	play()

func eat():
	if(eatSFX.playing):
		eatSFX.stop()
	eatSFX.play()
