
const ASCII_TABLE_INDEX_LETTER_ZERO: u8 = 0x30;

fn main() {
    let input = include_str!("../day01_input.txt");
    println!("The result of day_01 part a is: {}", part_a(input));
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

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn example_input() {
        let input = include_str!("../day01_example.txt");

        let result = part_a(input);

        assert_eq!(result, 142);
    }
}
