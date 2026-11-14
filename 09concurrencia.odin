package main

import "core:fmt"
import "core:sync"
import "core:thread"
import "core:time"

// Ejecucion: odin run 09concurrencia.odin -file -o:speed

// Estructura para pasar datos a cada tarea
Datos_Tarea :: struct {
	id:           int,
	iteraciones:  int,
	suma_global:  ^int, // Puntero a memoria compartida
}

// Función que ejecutará cada hilo en paralelo
tarea_pesada :: proc(t: thread.Task) {
	datos := cast(^Datos_Tarea)t.data
	
	fmt.printf("[Hilo %d] Iniciando procesamiento en paralelo...\n", datos.id)
	
	// Simulamos carga de trabajo intensiva en CPU
	acumulador_local := 0
	for i in 0..<datos.iteraciones {
		//datos.suma_global^ += 1
		acumulador_local += 1
	}

	// Simulamos una pequeña latencia variable según el ID
	time.sleep(time.Duration(datos.id * 50) * time.Millisecond)

	// Concurrencia segura: Sumamos al total global de forma atómica
	// para evitar condiciones de carrera (Race Conditions)
	sync.atomic_add(datos.suma_global, acumulador_local)

	fmt.printf("[Hilo %d] Finalizado. Aportó: %d\n", datos.id, acumulador_local)
}

main :: proc() {
	NUM_HILOS := 4
	NUM_TAREAS :: 8
	ITERACIONES_POR_TAREA :: 10_000_000

	fmt.printf("Iniciando prueba con %d hilos y %d tareas...\n\n", NUM_HILOS, NUM_TAREAS)
	inicio := time.now()

	// 1. Inicializar el Pool de Hilos
	pool: thread.Pool
	thread.pool_init(&pool, allocator = context.allocator, thread_count = NUM_HILOS)
	defer thread.pool_destroy(&pool)

	// 2. Arrancar los hilos trabajadores
	thread.pool_start(&pool)

	// Variable compartida por todos los hilos
	suma_total := 0
	lista_datos: [NUM_TAREAS]Datos_Tarea

	// 3. Encolar las tareas para ejecución paralela
	for i in 0..<NUM_TAREAS {
		lista_datos[i] = Datos_Tarea{
			id          = i + 1,
			iteraciones = ITERACIONES_POR_TAREA,
			suma_global = &suma_total,
		}
		
		thread.pool_add_task(&pool, allocator = context.allocator, procedure = tarea_pesada, data = &lista_datos[i], user_index = i)
	}

	// 4. Esperar a que todas las tareas terminen (Sincronización)
	thread.pool_finish(&pool)

	duracion := time.since(inicio)

	fmt.println("\n--- Resultados ---")
	fmt.printf("Suma total esperada: %d\n", NUM_TAREAS * ITERACIONES_POR_TAREA)
	fmt.printf("Suma total obtenida: %d\n", suma_total)
	fmt.printf("Tiempo total:        %v\n", duracion)
}