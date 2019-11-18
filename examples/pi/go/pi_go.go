package main

import (
	"fmt"
)

func main() {
	count := 65535
	divisor := 1.0
	pi := 0.0
	sign := 1.0
	for i := 0; i < count; i++ {
		pi += (1.0 / divisor) * sign
		divisor += 2.0
		sign = sign * -1.0
	}
	fmt.Println(pi * 4)
}
