package main

import "fmt"

const feetInMeter float64 = 3.28084

func main() {
	fmt.Print("Enter the lentgh in meters: ")
	var meters float64
	fmt.Scanf("%f", &meters)

	feet := meters * feetInMeter

	fmt.Printf("%g meters = %g feet\n", meters, feet)
}
