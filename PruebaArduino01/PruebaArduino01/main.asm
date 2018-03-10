;
; PruebaArduino01.asm

.ORG 0x0000			// Organiza todo a partir de la dirección 0x0000
RJMP main			// Asegurar que el programa comience en la etiqueta main
main: 
	LDI r16, 0xFF	// Cargar el valor inmediato 0xFF (todos los bits en 1) en el registro 16
	OUT DDRB, r16	// Colocar el registro de Dirección de Datos (DDR) del puerto B como salidas para todos los pines

loop: 
	SBI PortB, 5	// Colocar el 5° bit del PortB (i.e. encender el LED) 
	RCALL delay_05	// Llama al retraso de 5 segundos
	CBI PortB, 5	// Limpia el 5° bit del PortB (i.e. apaga el LED) 
	RCALL delay_05	// De nuevo mandar a llamar el retraso de 5 segundos
	RJMP loop		// Entrar dentro de un loop infinito (salta a la etiqueta loop)

// A partir de este punto, todo es parte del loop del delay
delay_05: 
	LDI r16, 8		// Cargar un valor de 8 en el registro 16

// Valores iniciales calculados para el retraso
outer_loop: 
	LDI r24, low(3037)	// Cargar low(3037) en el registro 24
	LDI r25, high(3037)	// Cargar high(3037) en el registro 25

delay_loop: 
	ADIW r24, 1			// Añadir inmediatamente a la palabra, r24:r25 se incrementan
	BRNE delay_loop		// si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
	DEC r16				// disminuir r16
	BRNE outer_loop		// si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
	RET					// regresar de la subrutina
