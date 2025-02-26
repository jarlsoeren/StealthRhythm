extends Node

signal sendThatPlayed

func _on_midi_player_midi_event(channel, event):
	match event.type:
		SMF.MIDIEventType.note_on:
			#print("Note On:  @\t", event.note, " | Velocity:", event.velocity, "\ton midiChannel:", channel.number)
			sendThatPlayed.emit()
		#SMF.MIDIEventType.note_off:
			#print("Note Off: @\t", event.note, "\t\t\t\t\ton midiChannel:", channel.number)
		_:
			pass

# reads the MIDI CHANNEL NAME
func _on_midi_player_appeared_track_name(channel_number, name):
	print("channel NR: ", channel_number, " | named :", name)


func _on_midi_player_finished():
	print("MIDI has finished playing.")
