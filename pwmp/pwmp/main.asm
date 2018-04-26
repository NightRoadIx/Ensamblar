.include "m328pdef.inc"

.ORG 0x0000					; Organiza todo a partir de la dirección 0x0000
RJMP setup					; Asegurar que el programa comience en la etiqueta setup

; ******************************************************************************************************
; RUTINA DE CONFIGURACIONES
setup: 
	SER r16					; Cargar el valor inmediato 0xFF (todos los bits en 1) en el registro 16
	CLR r17
	CLR r18
	CLR r19
	CLR r20
	CLR r21
	; ***** Configuraciones de puertos *****
	; Configurar Puerto B como salidas pines 0 a 5
	LDI r16, 0b00111111
	OUT DDRB, r16
	; Configurar Puerto D, Pin5 como salida
	LDI r16, 0b10100000
	OUT DDRD, r16

	SER r16			; TMP
	OUT PORTB, r16
	SBI PORTD, 7

	CLR r20

configpwm:

	; Registro de control A de TC0
	LDI r16, 0b00100011
	; Operación normal del puerto donde está OC0A (PORTD6)
	; Se selecciona el modo de PWM-fast, y se acomoda el OC0B (PORTD5) en comparación en modo no inversor
	OUT TCCR0A, r16

	; No se coloca preescaler, máximo del PWM 0xFF
	LDI r16, 0b00000100
	; Se termina de seleccionar el modo PWM-fast, el modo de reloj en preescaler de clk/256
	; El modo de PWM-Rápido permite generar una señal PWM de alta frecuencia con una operación de pendiente simple
	; La frecuencia del PWM se puede calcular mediante:
	; fPWM =  fCLK / (256 * N)
	; Donde N es el divisor del preescaler
	OUT TCCR0B, r16

	; TCNT0 no se modifica, ya que modificarlo mientras se esta ejecutandoproduce un riesgo de perder la comparación entre los registros
	; TCNT0 y OCR0x
	CLR r16					; Aunque para este caso PWM se requiere que sea 0
	OUT TCNT0, r16

	; Enviar el valor del registro al OCR0B, el cual es el que se compara con el valor del contador TCNT0
	; La comparación cuando sean iguales es utilizada para generar una interrupción de Comparación de Salida o
	; para generar una forma de onda
	OUT OCR0B, r20
	INC r20					; Incrementar el valor del registro
	RCALL delay_05

	RJMP configpwm

; ******************************************************************************************************
; RUTINA DE RETRASO
; A partir de este punto, todo es parte del loop del delay
delay_05: 
	LDI r16, 6				; Cargar un valor de 8 en el registro 16
; Valores iniciales calculados para el retraso
outer_loop: 
	LDI r24, low(3037)		; Cargar low(3037) en el registro 24
	LDI r25, high(3037)		; Cargar high(3037) en el registro 25
	delay_loop: 
		ADIW r24, 1				; Añadir inmediatamente a la palabra, r24:r25 se incrementan
		BRNE delay_loop			; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
		DEC r16					; disminuir r16
		BRNE outer_loop			; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
		RET						; regresar de la subrutina
