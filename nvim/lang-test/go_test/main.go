package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println("Hello, world")
	_ = os.Environ()
}

