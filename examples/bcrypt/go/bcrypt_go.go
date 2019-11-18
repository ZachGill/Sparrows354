package main

import (
	"fmt"
	"time"

	"golang.org/x/crypto/bcrypt"
)

func main() {
	count := 100
	tStart := time.Now()
	for i := 0; i < count; i++ {
		hashPass, _ := bcrypt.GenerateFromPassword([]byte("password"), 11)
		bcrypt.CompareHashAndPassword(hashPass, []byte("password"))
	}
	tEnd := time.Now()
	tElapsed := int64(tEnd.Sub(tStart))
	tAverage := tElapsed / int64(count)
	fmt.Println(time.Duration(tAverage))
}

