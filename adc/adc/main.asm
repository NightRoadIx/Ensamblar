;
; adc.asm
;
; Created: 14/04/2018 0:15:26
; Author : NightRoadIx
;

; Incluir definiciones para el ATMEGA328P
.INCLUDE "m328pdef.inc"

.ORG 0x0000					; Organiza todo a partir de la dirección 0x0000
RJMP setup					; Asegurar que el programa comience en la etiqueta setup

; ******************************************************************************************************
; RUTINA DE CONFIGURACIONES
setup: 
	CLR r16
	CLR r17
	CLR r18
	CLR r19

	; ***** Configuraciones de puertos *****
	; Configurar Puerto B, pines 0 a 5 como salidas
	LDI r16, 0b00111111
	OUT DDRB, r16
	; Configurar Puerto D, pines 7 y 5 como salidas
	LDI r16, 0b10100000
	OUT DDRD, r16
	; Configurar Puerto C como entradas (IMPORTANTE PARA ADC)
	CLR r16
	OUT DDRC, r16

loop:
	NOP
; Iniciar la configuración del ADC
setADC:
	CLR r16
	; Modificar el registro de control y estado del ADC
	; Iniciar en cero
	STS ADCSRA, r16

	LDI r16, 0b01000011
	; Registro de selección del multiplexor del ADC
	; Utilizar la referencia por AVcc, ajustar los datos a la izquierda, utilizar la entrada ADC3 (PORTC3)
	STS ADMUX, r16

	LDI r16, 0b11000111
	; Configurar: Habilitar el ADC, Iniciar una conversión, Preescaler para el reloj del ADC a 128
	STS ADCSRA, r16

verificar:
	LDS r16, ADCSRA
	SBRS r16, 4		; Esperar a que la conversión se complete, cuando esto sucede el bit4 de ADCSRA se coloca en 1
	JMP verificar

	LDS r17, ADCL	; Cargar la parte baja del valor de la conversión
	; Cargar la parte alta del valor de la conversión, como está ajustado a la izquierda, solo hay una precisión de 8 bits y solo es requerido leer este
	; Si ADLAR de ADCSRA no está colocado, entonces los valores se ajustan a la derecha y el valor se guarda en ADCH:ADCL
	LDS r18, ADCH

	OUT PORTB, r17		; Mandar al PORTB lo que se lee en el ADC
	BST r17, 6
	BLD r19, 7 
	BST r17, 7
	BLD r19, 5
	OUT PORTD, r19
	RCALL delay_05

	RJMP loop

; ******************************************************************************************************
; RUTINA DE RETRASO
; A partir de este punto, todo es parte del loop del delay
delay_05: 
	LDI r16, 24				; Cargar un valor de 8 en el registro 16
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
