extends Node

@onready var midi_player = $MidiReader/MidiPlayer
@onready var king_egg_song = $AudioReader/KingEggSong

@onready var midi_reactor = $"../TestMusic/MidiReactor"
@onready var beat_reactor = $"../TestMusic/BeatReactor"

var beat_time_begin
var beat_time_delay

# We'll store the last beat event's time here.
var last_beat_time: float = 0.0

# Track the last beat processed so we only trigger on a new beat.
var last_beat: int = 0

# BPM changes dictionary
var bpm_changes:Array[Dictionary] = [
	{
		"Crotchet": 0, # The beat at which BPM changes
		"BPM": 138,    # The new BPM
	},
]

# Converts seconds into the total number of crotchets (beats)
func seconds_to_crotchet(seconds: float) -> float:
	var remaining_seconds := seconds
	var last_bpm := 138.0 # Default BPM if not otherwise set
	var last_crotchet := 1.0
	var total_crotchets := 1.0
	
	for change in bpm_changes:
		var full = remaining_seconds * last_bpm / 60.0
		if full >= change["Crotchet"]:
			var diff = change["Crotchet"] - last_crotchet
			total_crotchets += diff
			remaining_seconds -= diff / last_bpm * 60.0
			last_bpm = change["BPM"]
			last_crotchet = change["Crotchet"]
		else:
			break
	total_crotchets += remaining_seconds * last_bpm / 60.0 + 1
	
	return total_crotchets

func _ready():
	beat_time_begin = Time.get_ticks_usec()
	beat_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	midi_player.play()
	king_egg_song.play()

func _process(delta):
	# Calculate the adjusted elapsed time
	var time = (Time.get_ticks_usec() - beat_time_begin) / 1000000.0
	time -= beat_time_delay
	time = max(0, time)
	
	# Calculate the current beat (crotchet) and compare with the last processed beat
	var current_beat = int(seconds_to_crotchet(time))
	if current_beat > last_beat:
		last_beat = current_beat
		# Record the beat event time for later comparison.
		last_beat_time = time
		
		#print((last_beat-2) % 4 + 1)
		
		# Toggle the beat reactor's scale as visual feedback.
		if beat_reactor.scale == Vector2(1, 1):
			beat_reactor.scale = Vector2(1.5, 1.5)
		else:
			beat_reactor.scale = Vector2(1, 1)

func _on_midi_reader_send_that_played():
	# Compute the current time for the MIDI event in the same way as for beats.
	var midi_event_time = (Time.get_ticks_usec() - beat_time_begin) / 1000000.0 - beat_time_delay
	
	# Calculate and print the time difference between the MIDI event and the last beat event.
	var time_difference = midi_event_time - last_beat_time
	print("Time difference: ", time_difference)
	
	# Toggle the midi reactor's scale as visual feedback.
	if midi_reactor.scale == Vector2(1, 1):
		midi_reactor.scale = Vector2(1.5, 1.5)
	else:
		midi_reactor.scale = Vector2(1, 1)
