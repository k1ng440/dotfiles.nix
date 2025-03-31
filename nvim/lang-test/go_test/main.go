package main

import (
    "fmt"
    "time"
    "errors"
)

const (
    SimpleConst = 1 << iota
)

type Person struct {
    Name string
    Age  int
}

type Greeter interface {
    Greet() string
}

func (p Person) Greet() string {
    return fmt.Sprintf("Hello, my name is %s and I am %d years old.", p.Name, p.Age)
}

func add(a int, b int) int {
    return a + b
}

func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}

func sum(nums ...int) int {
    total := 0
    for _, num := range nums {
        total += num
    }
    return total
}

func double(x *int) {
    *x *= 2
}

func sayHello(c chan string) {
    time.Sleep(1 * time.Second)
    c <- "Hello from goroutine!"
}

func main() {
    var a int = 10
    b := 20
    const pi = 3.1415
    fmt.Println("a + b =", add(a, b))
    fmt.Println("pi =", pi)

    if a < b {
        fmt.Println("a is less than b")
    } else {
        fmt.Println("a is greater or equal to b")
    }

    for i := 0; i < 3; i++ {
        fmt.Println("Loop i =", i)
    }

    switch a {
    case 10:
        fmt.Println("a is 10")
    default:
        fmt.Println("a is something else")
    }

    arr := [3]int{1, 2, 3}
    slice := []int{4, 5, 6}
    fmt.Println("Array:", arr)
    fmt.Println("Slice:", slice)

    m := map[string]int{"foo": 1, "bar": 2}
    m["baz"] = 3
    fmt.Println("Map:", m)

    p := Person{Name: "Alice", Age: 30}
    fmt.Println(p.Greet())

    var g Greeter = p
    fmt.Println("Interface call:", g.Greet())

    result, err := divide(10, 0)
    if err != nil {
        fmt.Println("Error:", err)
    } else {
        fmt.Println("10 / 2 =", result)
    }

    fmt.Println("Sum:", sum(1, 2, 3, 4))

    n := 5
    double(&n)
    fmt.Println("Doubled value:", n)

    ch := make(chan string)
    go sayHello(ch)
    msg := <-ch
    fmt.Println(msg)

    func(msg string) {
        fmt.Println("Anonymous says:", msg)
    }("Hi there!")

    defer fmt.Println("This is deferred and runs last.")
}
