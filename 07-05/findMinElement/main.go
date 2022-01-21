package main

import "fmt"
import "errors"

func main() {
	slice := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}

	printMinElement(slice)
	printMinElement([]int{})
}

func printMinElement(slice []int) {
	min, err := minElement(slice)
	if err != nil {
		fmt.Println("No minimal element")
		return
	}

	fmt.Println(min)
}

func minElement(slice []int) (min int, err error) {
	if len(slice) == 0 {
		return 0, errors.New("Empty slice")
	}

	min = slice[0]
	for _, v := range slice {
		if v < min {
			min = v
		}
	}

	return min, nil
}
