package lib

import "core:math"
import r "vendor:raylib"

TILE_SIZE: i32 : 40

MAP :: [10][10]i8 {
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 1, 1, 1, 0, 0, 1},
	{1, 0, 1, 0, 1, 0, 0, 0, 0, 1},
	{1, 0, 1, 0, 1, 1, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 1, 1, 1},
	{1, 0, 0, 0, 0, 0, 1, 0, 0, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

MAP_ROW :: len(MAP)
MAP_COL :: len(MAP[0])

is_hit :: proc(point: r.Vector2, size: f32) -> bool {
	n_map := MAP
	for i: i32 = 0; i < MAP_ROW; i += 1 {
		for j: i32 = 0; j < MAP_COL; j += 1 {
			if f32(j) < point.x + size &&
			   f32(j) + size > point.x &&
			   f32(i) < point.y + size &&
			   f32(i) + size > point.y &&
			   n_map[i][j] == 1 {
				return true
			}
		}
	}
	return false
}

render_2d_map :: proc() {
	n_map := MAP
	for i: i32 = 0; i < MAP_ROW; i += 1 {
		for j: i32 = 0; j < MAP_COL; j += 1 {
			color: r.Color = r.BLACK
			if n_map[i][j] == 1 {
				color = r.BROWN
			}
			r.DrawRectangle(j * TILE_SIZE, i * TILE_SIZE, TILE_SIZE, TILE_SIZE, color)
		}
	}
}

step_ray :: proc(
	pos: r.Vector2,
	forward: r.Vector2,
	step_count: i32,
	step_len: i32,
	incr: ^i32,
	color: r.Color,
	p_hit: ^r.Vector2,
	x_offset: i32,
) {
	start := (r.Vector2){pos.x, pos.y}
	end := (r.Vector2){pos.x + (forward.x / f32(step_len)), pos.y + (forward.y / f32(step_len))}
	p_hit^.x = end.x
	p_hit^.y = end.y
	if x_offset != 0 {
		r.DrawLine(
			i32(start.x) * TILE_SIZE + TILE_SIZE / 2,
			i32(start.y) * TILE_SIZE + TILE_SIZE / 2,
			i32(end.x) * TILE_SIZE + TILE_SIZE / 2,
			i32(end.y) * TILE_SIZE + TILE_SIZE / 2,
			r.GRAY,
		)
	}
	if !is_hit(end, 0.5) && incr^ < step_count {
		incr^ += 1
		step_ray(end, forward, step_count, step_len, incr, color, p_hit, x_offset)
	} else {
		incr^ = 0
	}
}

render_3d_map :: proc(
	cam_pos: r.Vector2,
	cam_rotation: f32,
	line_thickness: i32,
	fov: i32,
	x_offset: i32,
) {
	r.DrawRectangle(x_offset, 0, r.GetScreenWidth(), 5 * TILE_SIZE, r.SKYBLUE)
	r.DrawRectangle(x_offset, 5 * TILE_SIZE, r.GetScreenWidth(), 5 * TILE_SIZE, r.GREEN)

	for i: i32 = -fov / 2; i < fov / 2; i += 1 {
		hit: r.Vector2
		incr: i32

		direction := (r.Vector2) {
			math.sin_f32((cam_rotation + f32(i)) * (math.PI / f32(180))),
			math.cos_f32((cam_rotation + f32(i)) * (math.PI / f32(180))),
		}
		step_ray(cam_pos, direction, 2000, 200, &incr, r.GRAY, &hit, x_offset)
		dist: f32 = math.pow_f32(cam_pos.x - hit.x, 2) + math.pow_f32(cam_pos.y - hit.y, 2)
		r.DrawRectangle(
			(i * line_thickness + (line_thickness * fov / 2) + x_offset),
			5 * TILE_SIZE - (1000 / i32(math.ceil_f32(dist))) / 2,
			line_thickness,
			(1000 / i32(math.ceil_f32(dist))),
			r.BROWN,
		)
	}
}

render_2d_player :: proc(pos: r.Vector2) {
	r.DrawCircle(
		i32(pos.x) * TILE_SIZE + TILE_SIZE / 2,
		i32(pos.y) * TILE_SIZE + TILE_SIZE / 2,
		6,
		r.ORANGE,
	)
}

update_2d_player :: proc(pos: ^r.Vector2, rotation: ^i32) {
	forward := (r.Vector2) {
		math.sin_f32(f32(rotation^) * (math.PI / f32(180))),
		math.cos_f32(f32(rotation^) * (math.PI / f32(180))),
	}

	velocity := (r.Vector2){}

	if r.IsKeyDown(.W) {
		velocity = (r.Vector2){0.01 * forward.x, 0.01 * forward.y}
	}

	if r.IsKeyDown(.S) {
		velocity = (r.Vector2){-0.01 * forward.x, -0.01 * forward.y}
	}

	if r.IsKeyDown(.LEFT) {
		rotation^ -= 1
	}

	if r.IsKeyDown(.RIGHT) {
		rotation^ += 1
	}

	if !is_hit((r.Vector2){pos^.x + velocity.x, pos^.y + velocity.y}, 0.5) {
		pos^.x += velocity.x
		pos^.y += velocity.y
	}
}
