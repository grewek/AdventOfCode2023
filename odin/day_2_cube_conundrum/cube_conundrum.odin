package cube_conundrum

import "core:os";
import "core:fmt";
import "core:strings";
import "core:strconv";

advance :: proc(length: int, current_position: ^int) {
    current_position^ += length
}

BallContainer :: struct {
    red: int,
    blue: int,
    green: int,
}

main :: proc() {
    input, err := os.read_entire_file_from_filename("day02_input.txt");
    //color_groups: [dynamic]ColorGroup;
    colors: [dynamic]Colors;

    if !err {
        fmt.printf("error: %v\n", err);
        return;
    }

    current_position := 0;
    for {
        advance(5, &current_position); //Skip the GAME Token !

        if input[current_position] == ' ' {
            advance(1, &current_position);
        }
        //Do we need this ?
        game_id := parse_integer(input, &current_position);

        advance(2, &current_position); //Skip ': '
        game_colors := parse_colorset(input, &current_position, game_id);
        game_colors.game_id = game_id;
        append(&colors, game_colors);

        if(current_position >= len(input) - 5) {
            break;
        }
    }

    sum := 0;
    cubes := 0;
    for round in colors {
        fmt.printf("%v\n", round.game_id);
        fmt.printf("%v\n", round.rounds);
        red_balls : int : 12
        green_balls : int: 13
        blue_balls : int : 14

        if round.max_red <= red_balls && round.max_blue <= blue_balls && round.max_green <= green_balls {
            sum += round.game_id
        }

        cubes += round.max_red * round.max_blue * round.max_green;
    }

    fmt.printf("The sum of all possible games is: %d\n", sum);
    fmt.printf("The sum of all min cubes is: %d\n", cubes);
}

is_digit :: proc(data: []byte, position: ^int) -> bool {
    switch data[position^] {
        case '0'..='9': return true;
        case: return false;
    }
}
parse_integer :: proc(data: []byte, position: ^int) -> int {
    start := position^;
    for ; is_digit(data, position) ; {
        position^ += 1;
    }

    end := position^;

    bytes: [128]byte;
    builder := strings.builder_from_slice(bytes[:]);

    strings.write_bytes(&builder, data[start:end]);
    raw_value := strings.to_string(builder);
    converted_value, err := strconv.parse_int(raw_value);

    if !err {
        //TODO: Error
    }

    return converted_value;
}

is_alpha :: proc(data: []byte, position: ^int) -> bool {
    switch data[position^] {
        case 'A'..='Z', 'a'..='z': return true;
        case: return false;
    }
}

Color :: enum {
    Red,
    Green,
    Blue,
    Error,
}

parse_color :: proc(data: []byte, position: ^int) -> Color {
    start := position^;

    for ; is_alpha(data, position) ; {
        position^ += 1;
    }
    end := position^;

    bytes: [128]byte;
    builder := strings.builder_from_slice(bytes[:]);
    strings.write_bytes(&builder, data[start:end]);
    value := strings.to_string(builder);

    switch value {
        case "red": return Color.Red;
        case "green": return Color.Green;
        case "blue": return Color.Blue;
    }

    return Color.Error
}

ColorObject :: struct {
    count: int,
    color: Color,
}


Colors :: struct {
    game_id: int, 
    rounds: int,
    max_red: int,
    max_green: int,
    max_blue: int,
}

parse_colorset :: proc(data: []byte, current_position: ^int, game_id: int) -> Colors {
    //sets :[dynamic]ColorGroup;
    game_color_count: Colors;

    //Skip the comma if there is any
    if data[current_position^] == ',' {
        advance(2, current_position);
    }
    if data[current_position^] == ' ' {
        //We only need to skip the space !
        advance(1, current_position);
    }


    //group := ColorGroup {};
    colors := Colors {};
    round_index := 0;
    fmt.printf("GAME ID: %d\n", game_id);
    for {
        count := parse_integer(data, current_position);
        advance(1, current_position);
        color := parse_color(data, current_position);

        fmt.printf("\t->COUNT: %d\n", count);
        fmt.printf("\t->COLOR: %v\n", color);

        switch color {
            case Color.Red: {
                if colors.max_red < count { colors.max_red = count }
            }
            case Color.Blue: {
                if colors.max_blue < count { colors.max_blue = count }
            }
            case Color.Green: {
                if colors.max_green < count { colors.max_green = count }
            }
            case Color.Error: continue;
        }

        if data[current_position^] == '\n' {
            fmt.printf("%v\n", colors);
            break;
        }

        if data[current_position^] == ',' {
            advance(2, current_position);
        }

        if data[current_position^] == ';' {
            round_index += 1;
            advance(2, current_position);
        }
    }

    colors.rounds = round_index;
    return colors;
}
