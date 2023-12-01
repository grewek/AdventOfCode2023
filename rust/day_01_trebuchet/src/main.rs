
const ASCII_TABLE_INDEX_LETTER_ZERO: u8 = 0x30;

//MODERATOR(Jon): Okay our next candidate can choose a topic for the evening
//ME: Yes thank you Jon i take dumb ideas in the evening for 5000 please...
const WORD_VALUE_TABLE: [u64; 9] = [
    (0x6f as u64) << 56 | (0x6e << 48) | (0x65 << 40), 
    (0x74 as u64) << 56 | (0x77 << 48) | (0x6f << 40), 
    (0x74 as u64) << 56 | (0x68 << 48) | (0x72 << 40) | (0x65 << 32) | (0x65 << 24), 
    (0x66 as u64) << 56 | (0x6f << 48) | (0x75 << 40) | (0x72 << 32), 
    (0x66 as u64) << 56 | (0x69 << 48) | (0x76 << 40) | (0x65 << 32), 
    (0x73 as u64) << 56 | (0x69 << 48) | (0x78 << 40), 
    (0x73 as u64) << 56 | (0x65 << 48) | (0x76 << 40) | (0x65 << 32) | (0x6e << 24), 
    (0x65 as u64) << 56 | (0x69 << 48) | (0x67 << 40) | (0x68 << 32) | (0x74 << 24), 
    (0x6e as u64) << 56 | (0x69 << 48) | (0x6e << 40) | (0x65 << 32)
];
fn main() {
    let input = include_str!("../day01_input.txt");
    println!("The result of day_01 part a is: {}", part_a(input));
    println!("The result of day_01 part b is: {}", part_b(input));
}

fn atoi(letter: u8) -> usize {
    //NOTE: Assuming we are a valid ascii value !
    (letter - ASCII_TABLE_INDEX_LETTER_ZERO) as usize
}

fn combine(value_a: usize, value_b: usize) -> usize {
    (value_a * 10 + value_b) as usize
}
fn part_a(input: &str) -> usize {
    let mut numbers = vec![];
    let mut counter = 0;
    for letter in input.chars() {
        if letter.is_ascii_whitespace() {
            if numbers.len() > 1 {
                let value_a = numbers[0];
                let value_b = numbers[numbers.len() - 1];
                let value = combine(value_a, value_b);
                counter += value;
            } else {
                let value_a = numbers[0];
                let value = combine(value_a, value_a);
                counter += value;
            }
            numbers.clear();
        }

        if letter.is_ascii_digit() {
            let result: usize =  atoi(letter as u8);
            numbers.push(result);
        }
    }

    counter
}

fn into_u64_value(bytes: &[u8]) -> (u64, u64, u64) {
    //NOTE: Things got out of hand quite quickly this year ~_~
    //
    match bytes.len() {
        5 => {
            let tlv = (bytes[0] as u64) << 56 | (bytes[1] as u64) << 48 | (bytes[2] as u64) << 40;
            let folv = tlv | (bytes[3] as u64) << 32;
            let filv = folv | (bytes[4] as u64) << 24;
            (tlv, folv, filv)
        }
        4 => {
            let tlv = (bytes[0] as u64) << 56 | (bytes[1] as u64) << 48 | (bytes[2] as u64) << 40;
            let folv = tlv | (bytes[3] as u64) << 32;
            (tlv, folv, 0)
        }
        3 => {
            let tlv = (bytes[0] as u64) << 56 | (bytes[1] as u64) << 48 | (bytes[2] as u64) << 40;
            (tlv, 0, 0)
        },
        _ => (0, 0, 0)
    }
    //let tlv = (bytes[0] as u64) << 56 | (bytes[1] as u64) << 48 | (bytes[2] as u64) << 40;
    //let folv = tlv | (bytes[3] as u64) << 32;
    //let filv = folv | (bytes[4] as u64) << 24;
    //(tlv, folv, filv )//folv, filv)
}

fn match_written_value(converted: (u64, u64, u64)) -> Option<usize> {
    let (tlv, folv, filv) = converted;
    for (index, value) in WORD_VALUE_TABLE.iter().enumerate() {
        if tlv == *value || folv == *value || filv == *value {
            return Some(index + 1)
        }
    }

    None
}
fn part_b(input: &str) -> usize {
    let mut numbers = vec![];
    let mut counter = 0;
    for (index, letter) in input.chars().enumerate() {
        if letter.is_ascii_whitespace() {
            if numbers.len() > 1 {
                let value_a = numbers[0];
                let value_b = numbers[numbers.len() - 1];
                let value = combine(value_a, value_b);
                counter += value;
            } else {
                let value_a = numbers[0];
                let value = combine(value_a, value_a);
                counter += value;
            }
            numbers.clear();
        }

        if letter.is_alphanumeric() {
            //TODO: Try to parse a number from the given string
            let max_slice = std::cmp::min(input.len(), index + 5);
            println!("OVERFLOW {}", max_slice);
            let pv = &input[index..max_slice];//.as_bytes();
            println!("{:?}, {:?}", pv, pv.as_bytes());
            if let Some(value) = match_written_value(into_u64_value(pv.as_bytes())) {
                numbers.push(value);
            }
            
        }
        if letter.is_ascii_digit() {
            let result: usize =  atoi(letter as u8);
            numbers.push(result);
        }
    }

    counter
}
#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn example_part_a_input() {
        let input = include_str!("../day01_example.txt");

        let result = part_a(input);

        assert_eq!(result, 142);
    }

    #[test]
    fn example_part_b_input() {
        let input = include_str!("../day01_example_b.txt");
        let result = part_b(input);

        assert_eq!(result, 281)
    }
}
