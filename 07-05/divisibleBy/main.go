package main

import "fmt"
import "strconv"
import "strings"

func main() {
	const divisibleBy = 3

	var divisible []string
	for i := 1; i <= 100; i++ {
		if i%divisibleBy == 0 {
			divisible = append(divisible, strconv.Itoa(i))
		}
	}

	fmt.Println("(" + strings.Join(divisible, ", ") + ")")
}
