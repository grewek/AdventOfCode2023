package cube_conundrum

import "core:os";
import "core:fmt";
import "core:strings";
import "core:strconv";

advance :: proc(length: int, current_position: ^int) {
    current_position^ += length
}

main :: proc() {
    input, err := os.read_entire_file_from_filename("day02ex_a.txt");

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
        game_id := parse_integer(input, &current_position);

        fmt.printf("\t GAME ID: %d\n", game_id);
        advance(2, &current_position); //Skip ': '
        color_groups := parse_colorset(input, &current_position);
        fmt.printf("color_groups: %v\n", color_groups);

        //NOTE: We cannot parse another game at this point because we are missing the game token !
        if(current_position >= len(input) - 5) {
            break;
        }
        //fmt.printf("%s\n", input[current_position:]);

        //current_position += 1; //Skip the new line

    }
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

ColorGroup :: struct {
    groups: [dynamic]ColorObject,
}
parse_colorset :: proc(data: []byte, current_position: ^int) -> [dynamic]ColorGroup {
    sets :[dynamic]ColorGroup;

    //Skip the comma if there is any
    if data[current_position^] == ',' {
        advance(2, current_position);
    }
    if data[current_position^] == ' ' {
        //We only need to skip the space !
        advance(1, current_position);
    }


    group := ColorGroup {};
    for {
        count := parse_integer(data, current_position);
        advance(1, current_position);
        color := parse_color(data, current_position);

        color_object := ColorObject { count, color };
        append(&group.groups, color_object);

        if data[current_position^] == '\n' {
            //Found all data sets for this Game
            break;
        }

        if data[current_position^] == ',' {
            append(&sets, group);
            advance(2, current_position);
        }

        if data[current_position^] == ';' {
            append(&sets, group);
            group := ColorGroup{};
            advance(2, current_position);
        }
    }

    return sets;
}

