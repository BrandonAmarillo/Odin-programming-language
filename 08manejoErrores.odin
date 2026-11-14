package main

import "core:fmt"

ValueError :: struct {}
BarError :: struct {}
BazError :: struct {}
PlopError :: struct {}

Error :: union {
    ValueError,
    BarError,
    BazError,
    PlopError,
}

foo :: proc() -> (int, Error) {
    return 0, ValueError{}
}

main :: proc() {
    x, err := foo()

    switch e in err {
    case ValueError:
        fmt.println("Error de valor")
    case BarError:
        fmt.println("Error de barra")
    case BazError:
        fmt.println("Error de baz")
    case PlopError:
        fmt.println("Error de plop")
    case:
        fmt.println("Sin error")
    }

    fmt.println("x =", x)
}