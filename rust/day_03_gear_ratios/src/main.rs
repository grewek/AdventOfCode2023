use std::collections::HashMap;
fn main() {
    println!("Hello, world!");
}


#[derive(Debug)]
struct Map {
    width: usize,
    height: usize,
    repr: HashMap<(usize, usize), char>,
}

impl Map {
    fn scan_line(&self, y: usize) -> (Vec<usize>, usize) {
        let mut result: Vec<usize> = vec![];
        let mut current_value = "".to_string();

        let mut sum = 0;
        for x in 0..=self.width {
            if let Some(value) = self.repr.get(&(x,y)) {
                if value.is_ascii_digit() {
                    current_value.push(*value);
                    continue;
                }
            }
            
            if current_value.len() > 0 {
                let validated = self.check_neighbours(current_value.len(), x, y);
                result.push(current_value.parse().unwrap());

                if validated {
                    println!("addding sum to {}",sum);
                    sum += result.last().unwrap();
                }
            }

            current_value = "".to_string();
        }

        println!("The sum is: {}", sum);
        (result, sum)
    }

    fn check_operator(&self, cell: char) -> bool {
        if cell != '.' && cell.is_ascii_punctuation() {
            return true;
        }

        false
    }
    fn check_neighbours(&self, value_len: usize, x: usize, y: usize) -> bool {
        let mut value_len = value_len;
        let mut validated = false;
        while value_len > 0 {
            let x_pos = x - value_len;

            if let Some(neighbour_cell) = self.repr.get(&(x_pos, y + 1)) {
                if !validated {
                    validated = self.check_operator(*neighbour_cell);
                }
            }

            if let Some(neighbour_cell) = self.repr.get(&(x_pos, y.saturating_sub(1))) {
                if !validated {
                    validated = self.check_operator(*neighbour_cell);
                }
            }

            if let Some(neighbour_cell) = self.repr.get(&(x_pos + 1, y)) {
                if !validated {
                    validated = self.check_operator(*neighbour_cell);
                }
            }

            if let Some(neighbour_cell) = self.repr.get(&(x_pos.saturating_sub(1), y)) {
                if !validated {
                    validated = self.check_operator(*neighbour_cell);
                }
            }

            if let Some(neighbour_cell) = self.repr.get(&(x_pos + 1, y + 1)) {
                if !validated {
                    validated = self.check_operator(*neighbour_cell);
                }
            }

            if let Some(neighbour_cell) = self.repr.get(&(x_pos.saturating_sub(1), y.saturating_sub(1))) {
                if !validated {
                    validated = self.check_operator(*neighbour_cell);
                }
            }
            value_len -= 1;
        }

        validated
    }
}

fn part_a(input: &str) -> usize {
    let height = input.lines().count();
    let width = input.lines().next().unwrap().len();

    let mut map = Map { width, height, repr: HashMap::new() };

    for (y, line) in input.lines().enumerate() {
        for(x, character) in line.chars().enumerate() {
            map.repr.insert((x,y), character);
        }
    }

    let mut sum = 0;
    for y in 0..=map.height {
        let (values, to_add) = map.scan_line(y);
        sum += to_add;
        println!("{:?}", to_add);
    }

    println!("sum: {}", sum);
    todo!()
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn test_example_a() {
        let input = include_str!("../day03_example.txt");

        let result = part_a(input);
        assert_eq!(result, 4361);
    }
}
