package main

import rc "../lib"
import "core:fmt"
import "core:os"
import r "vendor:raylib"


main :: proc() {
	args := os.args[1:]
	dbg: bool
	if len(args) != 1 {
		fmt.eprintln("Usage: ./main -fdbg or ./main -fnodbg")
		os.exit(1)
	}

	if args[0] == "-fdbg" {
		dbg = true
	} else if args[0] == "-fnodbg" {
		dbg = false
	} else {
		fmt.eprintln(
			"Only two args are accepted:\n-fdbg (to see 2d view).\n-fnodbg (to only see 3d view).",
		)
		os.exit(2)
	}
	line_width: i32 = 10
	screen_width: i32
	screen_height: i32 = 10 * rc.TILE_SIZE
	if dbg {
		screen_width = (10 * rc.TILE_SIZE) + (line_width * 60)
	} else {
		screen_width = line_width * 60
	}
	r.InitWindow(screen_width, screen_height, "Odin Raycasting")
	defer r.CloseWindow()

	player_pos := (r.Vector2){1, 1}
	player_rotation: i32 = 0
	x_offset: i32 = 0

	if dbg {x_offset = screen_height}

	last_time := r.GetTime()
	for !r.WindowShouldClose() {
		curr_time := r.GetTime()
		if curr_time - last_time > 1.0 / 150.0 {
			last_time = curr_time
			rc.update_2d_player(&player_pos, &player_rotation)
		}
		r.BeginDrawing()
		r.ClearBackground(r.BLACK)

		if dbg {
			rc.render_2d_map()
			rc.render_2d_player(player_pos)
		}
		rc.render_3d_map(player_pos, f32(player_rotation), line_width, 60, x_offset)
		r.EndDrawing()
	}
}
