package main

import "core:fmt"
import "core:strconv"

titulo :: proc(texto: string) {
	fmt.printf("\n=== %s ===\n", texto)
}

main :: proc() {
	declaraciones()
	inferencia_de_tipos()
	asignacion_con_tipo_definido()
	asignacion_multiple()
	asignacion_compuesta()
	constantes()
	conversiones()
	expresiones_aritmeticas()
	expresiones_de_bits()
	comparaciones_y_logica()
	expresiones_condicionales()
	tipos_distinct()
	desbordamiento()
	tipos_compuestos()
}

// ----------------------------------------------------------------------------
// 1. DECLARACIÓN DE VARIABLES
// ----------------------------------------------------------------------------
declaraciones :: proc() {
	titulo("1. Declaración de variables")

	// Forma 1: solo el tipo. La variable queda con su VALOR CERO (nunca basura).
	a: int
	b: f64
	c: bool
	d: string
	e: ^int
	fmt.printf("valores cero -> int=%v f64=%v bool=%v string=%q puntero=%v\n", a, b, c, d, e)

	// Forma 2: tipo explícito y valor inicial.
	f: int = 10
	g: f32 = 2.5

	// Forma 3: varias variables del mismo tipo.
	h, i: int
	j, k: f32 = 1.5, 2.5

	// Forma 4: inferencia con ":=" (el tipo se deduce del valor).
	l := 99

	// Estas tres declaraciones son equivalentes:
	//     x: int = 123
	//     x:     = 123
	//     x := 123

	// Forma 5: sin inicializar. "---" evita poner la memoria en cero.
	// Hay que asignarle un valor antes de leerla.
	m: int = ---
	m = 7

	fmt.println("f, g       =", f, g)
	fmt.println("h, i       =", h, i)
	fmt.println("j, k       =", j, k)
	fmt.println("l, m       =", l, m)

	// Las declaraciones deben ser únicas dentro de un mismo ámbito:
	// l := 100            // ERROR: redeclaración de 'l' en este ámbito

	// En un bloque interno SÍ se puede declarar otra variable con el mismo
	// nombre (sombrea a la externa; con la opción -vet el compilador avisa).
	{
		l := 1000
		fmt.println("l interno  =", l)
	}
	fmt.println("l externo  =", l)
}

// ----------------------------------------------------------------------------
// 2. CÓMO INFIERE EL TIPO
// ----------------------------------------------------------------------------
cuadrado :: proc(n: int) -> int {
	return n * n
}

inferencia_de_tipos :: proc() {
	titulo("2. Inferencia de tipos (%T muestra el tipo)")

	// Los literales son "sin tipo" (untyped) y toman un tipo por defecto:
	entero := 42        // int
	real := 3.14        // f64
	letra := 'Z'        // rune
	texto := "Hola"     // string
	logico := true      // bool
	imaginario := 2i    // complex128

	fmt.printf("%v\t-> %T\n", entero, entero)
	fmt.printf("%v\t-> %T\n", real, real)
	fmt.printf("%v\t-> %T\n", letra, letra)
	fmt.printf("%q\t-> %T\n", texto, texto)
	fmt.printf("%v\t-> %T\n", logico, logico)
	fmt.printf("%v\t-> %T\n", imaginario, imaginario)

	// También infiere a partir de otras variables, expresiones y llamadas:
	copia := entero            // int
	doble_real := real * 2     // f64
	mayor_que := entero > 10   // bool
	resultado := cuadrado(4)   // int (tipo de retorno del procedimiento)
	fmt.printf("copia: %T | doble_real: %T | mayor_que: %T | resultado: %T\n",
		copia, doble_real, mayor_que, resultado)

	// Para otro tipo hay que pedirlo: con anotación o con conversión.
	a: f32 = 7         // el literal 7 se adapta a f32
	b := f32(7)        // equivalente
	c := u8(200)
	fmt.printf("a: %T | b: %T | c: %T\n", a, b, c)
}

// ----------------------------------------------------------------------------
// 3. ASIGNAR CUANDO EL TIPO YA ESTÁ DEFINIDO
// ----------------------------------------------------------------------------
asignacion_con_tipo_definido :: proc() {
	titulo("3. Asignación con tipo ya definido")

	n: int = 5
	n = 10            // OK: mismo tipo
	n = 3.0           // OK: 3.0 es una constante sin tipo y cabe en int sin perder precisión
	fmt.println("n =", n)

	// Todo lo siguiente es ERROR DE COMPILACIÓN:
	// n = 3.5          // ERROR: 3.5 no se puede representar como int
	// n = "hola"       // ERROR: un string no es un int
	// n = true         // ERROR: un bool no es un int

	f: f32 = 2.5
	// n = f            // ERROR: f es f32 (variable tipada); no hay conversión implícita
	n = int(f)         // OK: conversión explícita (trunca a 2)
	fmt.println("n = int(f) =", n)

	// Tampoco hay conversión implícita entre enteros de distinto tamaño:
	pequeno: i32 = 5
	// grande: i64 = pequeno      // ERROR
	grande: i64 = i64(pequeno)   // OK
	fmt.println("grande =", grande)
}

// ----------------------------------------------------------------------------
// 4. ASIGNACIÓN MÚLTIPLE
// ----------------------------------------------------------------------------
dividir :: proc(a, b: int) -> (int, int) {
	return a / b, a % b
}

asignacion_multiple :: proc() {
	titulo("4. Asignación múltiple")

	// Declaración múltiple con tipos distintos (cada uno se infiere):
	edad, nombre := 25, "Ana"
	fmt.printf("%v (%T), %v (%T)\n", edad, edad, nombre, nombre)

	// Intercambio sin variable auxiliar (se evalúa todo el lado derecho primero):
	p, q := 10, 20
	p, q = q, p
	fmt.println("después del intercambio: p =", p, " q =", q)

	// Declarar varias y asignar después:
	x, y, z: int
	x, y, z = 1, 2, 3
	fmt.println("x, y, z =", x, y, z)

	// Un procedimiento puede devolver varios valores:
	cociente, resto := dividir(17, 5)
	fmt.println("17 / 5 -> cociente:", cociente, " resto:", resto)

	// "_" descarta un valor que no interesa:
	solo_cociente, _ := dividir(17, 5)
	fmt.println("solo el cociente:", solo_cociente)

	// Redeclarar al menos UNA variable nueva con ":=" es lo que se permite;
	// reusar las dos ya existentes con ":=" es un error:
	// cociente, resto := dividir(9, 2)   // ERROR: ninguna variable nueva
	cociente, resto = dividir(9, 2)        // OK: es una asignación
	fmt.println("9 / 2 -> cociente:", cociente, " resto:", resto)
}

// ----------------------------------------------------------------------------
// 5. ASIGNACIÓN COMPUESTA
// ----------------------------------------------------------------------------
asignacion_compuesta :: proc() {
	titulo("5. Asignación compuesta (no existen ++ ni --)")

	v := 10
	v += 5;  fmt.println("v += 5      ->", v)   // 15
	v -= 3;  fmt.println("v -= 3      ->", v)   // 12
	v *= 2;  fmt.println("v *= 2      ->", v)   // 24
	v /= 5;  fmt.println("v /= 5      ->", v)   // 4  (división entera)
	v %= 3;  fmt.println("v %= 3      ->", v)   // 1
	v += 1;  fmt.println("v += 1      ->", v)   // 2  (en lugar de v++)

	v = 20
	v <<= 2; fmt.println("v <<= 2     ->", v)   // 80
	v >>= 1; fmt.println("v >>= 1     ->", v)   // 40
	v &= 0b001100; fmt.println("v &= 0b1100 ->", v)  // 8
	v |= 0b000011; fmt.println("v |= 0b0011 ->", v)  // 11
	v ~= 0b001111; fmt.println("v ~= 0b1111 ->", v)  // 4  (XOR)
	v &~= 0b000100; fmt.println("v &~= 0b0100 ->", v) // 0  (AND-NOT)

	activo := true
	activo &&= false
	fmt.println("activo &&= false ->", activo)
	activo ||= true
	fmt.println("activo ||= true  ->", activo)
}

// ----------------------------------------------------------------------------
// 6. CONSTANTES (se declaran con "::")
// ----------------------------------------------------------------------------
constantes :: proc() {
	titulo("6. Constantes")

	PI :: 3.14159              // constante SIN tipo
	MAX_VIDAS : int : 3        // constante CON tipo
	SALUDO :: "Hola"
	DOBLE_PI :: PI * 2         // se calcula en tiempo de compilación

	// PI = 3.0                 // ERROR: no se puede asignar a una constante

	// Una constante sin tipo se adapta a quien la reciba:
	como_f32: f32 = PI
	como_f64: f64 = PI
	fmt.printf("PI como f32: %v (%T) | como f64: %v (%T)\n", como_f32, como_f32, como_f64, como_f64)

	radio := 2.0
	area := PI * radio * radio
	fmt.println("área =", area, "| DOBLE_PI =", DOBLE_PI)
	fmt.println("MAX_VIDAS * 2 =", MAX_VIDAS * 2, "|", SALUDO)
}

// ----------------------------------------------------------------------------
// 7. CONVERSIONES EXPLÍCITAS
// ----------------------------------------------------------------------------
conversiones :: proc() {
	titulo("7. Conversiones de tipo")

	i := 123
	f := f64(i)             // T(valor): sintaxis de llamada
	u := u32(f)
	c := cast(f64)i         // cast(T) valor: equivalente
	fmt.printf("int %v -> f64 %v -> u32 %v | cast: %v\n", i, f, u, c)

	// Los float se TRUNCAN al pasar a entero (no se redondean):
	t := 3.99
	fmt.println("int(3.99) =", int(t))               // 3

	// Entero grande a tipo más chico: se descartan los bits altos.
	grande := 300
	fmt.println("u8(300)   =", u8(grande))            // 44
	negativo := -1
	fmt.println("u32(-1)   =", u32(negativo))         // 4294967295

	// transmute: reinterpreta los BITS (mismo tamaño), no el valor.
	uno: f32 = 1.0
	bits := transmute(u32)uno
	fmt.printf("transmute(u32) de 1.0 = 0x%08x\n", bits)   // 0x3f800000

	// auto_cast: convierte al tipo que espera el destino (solo para pruebas).
	origen: f32 = 2.5
	destino: int = auto_cast origen
	fmt.println("auto_cast 2.5 a int =", destino)

	// Caracteres: rune <-> entero
	letra := 'A'
	codigo := int(letra)
	siguiente := letra + 1                 // sigue siendo rune
	fmt.printf("'A' = %v | siguiente = %c | rune(%v) = %c\n", codigo, siguiente, codigo + 2, rune(codigo + 2))

	// Número <-> texto
	texto := fmt.tprintf("%d", 456)        // int -> string
	numero := strconv.atoi(texto)          // string -> int
	fmt.printf("texto=%q numero+1=%v\n", texto, numero + 1)
}

// ----------------------------------------------------------------------------
// 8. EXPRESIONES ARITMÉTICAS
// ----------------------------------------------------------------------------
expresiones_aritmeticas :: proc() {
	titulo("8. Expresiones aritméticas")

	a, b := 17, 5
	fmt.println("a + b   =", a + b)     // 22
	fmt.println("a - b   =", a - b)     // 12
	fmt.println("a * b   =", a * b)     // 85
	fmt.println("a / b   =", a / b)     // 3   (división entera, trunca)
	fmt.println("a % b   =", a % b)     // 2   (resto truncado)

	// % (truncado) vs %% (con piso) se diferencian con negativos:
	n := -17
	fmt.println("-17 % 5  =", n % 5)    // -2
	fmt.println("-17 %% 5 =", n %% 5)   // 3

	// Con constantes: división entera vs real
	fmt.println("7 / 2   =", 7 / 2, "| 7.0 / 2 =", 7.0 / 2)   // 3 y 3.5

	// Expresiones mixtas: no se pueden mezclar tipos distintos.
	x := 2.5
	// fmt.println(a + x)             // ERROR: int + f64
	fmt.println("f64(a) + x =", f64(a) + x)

	// Precedencia: "<<" pesa igual que "*", más que "+".
	fmt.println("2 + 3 * 4    =", 2 + 3 * 4)       // 14
	fmt.println("(2 + 3) * 4  =", (2 + 3) * 4)     // 20
	fmt.println("1 + 2 << 3   =", 1 + 2 << 3)      // 17  = 1 + (2 << 3)
	fmt.println("100 / 10 / 5 =", 100 / 10 / 5)    // 2   (asocia a izquierda)

	// Funciones incorporadas útiles en expresiones:
	valor := 15
	fmt.println("min(3, 7, 1) =", min(3, 7, 1), "| max(3, 7, 1) =", max(3, 7, 1))
	fmt.println("clamp(15, 0, 10) =", clamp(valor, 0, 10), "| abs(-5) =", abs(-5))
}

// ----------------------------------------------------------------------------
// 9. EXPRESIONES A NIVEL DE BITS
// ----------------------------------------------------------------------------
expresiones_de_bits :: proc() {
	titulo("9. Operadores de bits")

	p: u8 = 0b1100_1010
	q: u8 = 0b1010_1100
	fmt.printf("p        = %08b\n", p)
	fmt.printf("q        = %08b\n", q)
	fmt.printf("p & q    = %08b  (AND)\n", p & q)
	fmt.printf("p | q    = %08b  (OR)\n", p | q)
	fmt.printf("p ~ q    = %08b  (XOR)\n", p ~ q)
	fmt.printf("p &~ q   = %08b  (AND-NOT)\n", p &~ q)
	fmt.printf("~p       = %08b  (complemento)\n", ~p)
	fmt.printf("p << 1   = %08b  (se pierde el bit alto en u8)\n", p << 1)
	fmt.printf("p >> 2   = %08b\n", p >> 2)
}

// ----------------------------------------------------------------------------
// 10. COMPARACIONES Y LÓGICA
// ----------------------------------------------------------------------------
con_efecto :: proc() -> bool {
	fmt.println("   (se evaluó con_efecto())")
	return true
}

comparaciones_y_logica :: proc() {
	titulo("10. Comparaciones, lógica y cortocircuito")

	n := 7
	fmt.println("n == 7 :", n == 7, "| n != 7 :", n != 7)
	fmt.println("n < 10 :", n < 10, "| n >= 8 :", n >= 8)
	fmt.println("n > 3 && n < 10 :", n > 3 && n < 10)
	fmt.println("n < 3 || n > 5  :", n < 3 || n > 5)
	fmt.println("!(n > 3)        :", !(n > 3))

	// && y || se evalúan en cortocircuito:
	falso := false
	verdadero := true
	fmt.println("falso && con_efecto():")
	r1 := falso && con_efecto()       // NO llama a con_efecto
	fmt.println("  ->", r1)
	fmt.println("verdadero && con_efecto():")
	r2 := verdadero && con_efecto()   // SÍ la llama
	fmt.println("  ->", r2)

	// Pertenencia con "in" / "not_in" (bit_set y map)
	Dia :: enum {Lun, Mar, Mie, Jue, Vie}
	Dias :: bit_set[Dia]
	laborables := Dias{.Lun, .Mar, .Mie}
	fmt.println("Mar in laborables     :", Dia.Mar in laborables)
	fmt.println("Vie not_in laborables :", Dia.Vie not_in laborables)
}

// ----------------------------------------------------------------------------
// 11. EXPRESIONES CONDICIONALES (ternario) Y or_else
// ----------------------------------------------------------------------------
expresiones_condicionales :: proc() {
	titulo("11. Ternario y or_else")

	edad := 20
	e1 := "mayor" if edad >= 18 else "menor"    // forma "x if cond else y"
	e2 := edad >= 18 ? "mayor" : "menor"        // forma "cond ? x : y"
	fmt.println(e1, "|", e2)

	// Versión de COMPILACIÓN: la condición debe ser constante.
	ES_DEBUG :: true
	modo := "debug" when ES_DEBUG else "release"
	fmt.println("modo:", modo)

	// or_else: valor alternativo si la expresión "falla" (clave inexistente).
	edades := make(map[string]int)
	defer delete(edades)
	edades["ana"] = 30

	ana := edades["ana"] or_else -1
	luis := edades["luis"] or_else -1
	fmt.println("ana:", ana, "| luis:", luis)

	// Alternativa con "coma ok":
	valor, existe := edades["luis"]
	fmt.println("luis -> valor:", valor, "existe:", existe)
}

// ----------------------------------------------------------------------------
// 12. TIPOS distinct: mismo contenido, tipos incompatibles
// ----------------------------------------------------------------------------
tipos_distinct :: proc() {
	titulo("12. Tipos distinct")

	Metros :: distinct f32
	Segundos :: distinct f32

	dist: Metros = 100          // OK: constante sin tipo
	tiempo: Segundos = 9.58
	fmt.printf("dist: %v (%T) | tiempo: %v (%T)\n", dist, dist, tiempo, tiempo)

	// velocidad := dist / tiempo        // ERROR: Metros / Segundos no es válido
	velocidad := f32(dist) / f32(tiempo) // OK: se pasa por el tipo base
	doble := dist * 2                    // OK: sigue siendo Metros
	fmt.println("velocidad =", velocidad, "| doble =", doble)

	// dist = tiempo                     // ERROR: tipos distintos
	dist = Metros(tiempo)                // OK: conversión explícita
	fmt.println("dist convertida =", dist)
}

// ----------------------------------------------------------------------------
// 13. DESBORDAMIENTO Y LÍMITES
// ----------------------------------------------------------------------------
desbordamiento :: proc() {
	titulo("13. Límites y desbordamiento")

	chico: u8 = 255
	chico += 1
	fmt.println("u8: 255 + 1 =", chico)            // 0   (da la vuelta)

	con_signo: i8 = 127
	con_signo += 1
	fmt.println("i8: 127 + 1 =", con_signo)        // -128

	fmt.println("rango de i32:", min(i32), "a", max(i32))
	fmt.println("tamaño de int:", size_of(int), "bytes")

	// División por cero con un divisor variable: PANIC en ejecución
	// (con un divisor constante 0 ni siquiera compila).
	// cero := 0
	// fmt.println(10 / cero)
}

// ----------------------------------------------------------------------------
// 14. ASIGNACIÓN DE TIPOS COMPUESTOS Y PUNTEROS
// ----------------------------------------------------------------------------
tipos_compuestos :: proc() {
	titulo("14. Asignación de structs, arreglos y punteros")

	Punto :: struct {
		x, y: int,
	}

	// Asignar un struct o un arreglo COPIA todo el valor:
	p1 := Punto{1, 2}
	p2 := p1
	p2.x = 99
	fmt.println("p1 =", p1, "| p2 =", p2)

	arr := [3]int{1, 2, 3}
	copia := arr
	copia[0] = 100
	fmt.println("arr =", arr, "| copia =", copia)

	// Programación con arreglos: la operación se aplica elemento a elemento.
	v1 := [3]f32{1, 2, 3}
	v2 := [3]f32{4, 5, 6}
	fmt.println("v1 + v2 =", v1 + v2, "| v1 * v2 =", v1 * v2)

	// Con un puntero se modifica el original:
	valor := 10
	ptr := &valor          // ^int
	ptr^ = 25              // asigna a través del puntero
	fmt.println("valor =", valor)
}