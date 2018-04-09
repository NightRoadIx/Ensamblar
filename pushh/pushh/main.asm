;
; pushh.asm
;
; Created: 06/04/2018 16:41:54
; Author : MaedhrosIx
;

; DDRx
; 0 -> entrada
; 1 -> salida

.ORG 0x0000
RJMP config
config:
	; Configurar Puerto B, Pin5 como salida
	LDI r16, 0b00111111
	OUT DDRB, r16
	NOP
	; Configurar Puerto C como salidas
	SER r16
	OUT DDRC, r16
	NOP
	; Configurar Puerto D, Pin2 como entrada
	LDI r16, 0b11111011
	OUT DDRC, r16
	NOP
	; Apagar los LEDs
	SER r16
	OUT PORTC, r16
	NOP
	LDI r16, 0b11011111
	OUT PORTB, r16
	SBI PORTB, 5
	NOP
	SER r17

main:
	; Apagar todos los LEDs conectados al PORTC
	OUT PORTC, r17
	; Obtener el estado de los pines del puertoD
	IN r16, PIND
	; Skip if Bit in Register is Set SBRS Reg, bit
	; Hace un salto a la siguiente instrucción (PC+2) si el bit solicitado está en 1
	; La instrucción para cuando se quiere que el bit está en cero es SBRC	
	SBRS r16, 2
	RJMP prende		; Cuando el bit 2 del r16 no está en 1, el flujo del programa llega aquí
	RJMP main		; Esto quiere decir que cuando el bit 2 del r16 está en 1, llega aquí

prende:
	LDI r16, 0
	OUT PORTC, r16

; A partir de este punto, todo es parte del loop del delay
delay_05: 
	LDI r16, 64		; Cargar un valor de 8 en el registro 16

; Valores iniciales calculados para el retraso
outer_loop: 
	LDI r24, low(3037)	; Cargar low(3037) en el registro 24
	LDI r25, high(3037)	; Cargar high(3037) en el registro 25

delay_loop: 
	ADIW r24, 1			; Añadir inmediatamente a la palabra, r24:r25 se incrementan
	BRNE delay_loop		; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
	DEC r16				; disminuir r16
	BRNE outer_loop		; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
	RET					; regresar de la subrutina