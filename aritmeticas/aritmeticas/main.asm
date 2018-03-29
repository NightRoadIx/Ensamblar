;
; aritmeticas.asm
;
; Created: 29/03/2018 13:33:36
; Author : MaedhrosIx
;


.ORG 0x0000
RJMP main
main:
	LDI r16, 246	; Cargar un valor de 5 en r16
	LDI r17, 10		; Cargar un valor de 10 en r17
	LDI r18, 20		; Cargar un valor de 20 en r18
	LDI r19, 30		; Cargar un valor de 30 en r19

; INSTRUCCIONES ARITMÉTICAS
aritmet:
	; Sumar r16:17 mas r18:r19
	ADD r18, r16	; r18 = r18 + r16, se activa la bandera de acarreo
	ADC r19, r17	; r19 = r19 + r17 + C

	; Sumar una constante (0 a 63) a una palabra (registros X, Y Z, r24, r26, r28, r30)
	LDI ZL, 0xC8	; Cargar 0x53 a registro ZL (r30)
	LDI ZH, 0x13	; Cargar 0x13 a registro ZH (r31), registro Z 0x1353
	; Sumar la constante
	ADIW ZL, 0x3F	; Sumar a ZL el número 0x3F

	; Las restas operan de la misma forma que la suma
	; ADD  --  SUB
	; ADC  --  SBC
	; ADIW --  SBIW
	; sin embargo hay dos operaciones adicionales con constantes
	SUBI r17, 5		; r17 = r17 - 5

	; restar 0x4F23 de r17:r16
	SUBI r16, 0x23	
	SBCI r17, 0x4F	; Resta con acarreo una constante

	LDI r16, 5
	LDI r17, 10

	MUL r16, r17	; Multiplicar r1:r0 = r16 * r17
	SUBI r16, 10
	MULS r16, r17	; Multiplicación con signo (registros SREG S y N)

; INSTRUCCIONES LÓGICAS
logicas:
	LDI r16, 10
	LDI r17, 20

	; Operación AND
	AND r16, r17	; r16 = r16 & r17
	ANDI r16, 128	; r16 = r16 & k

	; Operación OR
	LDI r16, 10		
	OR r16, r17		; r16 = r16 | r17
	ORI r16, 128	; r16 = r16 | k

	; Operación XOR
	LDI r17, 15
	EOR r16, r17	; r16 = r16 xor r17

	; Enmascarar la información
	LDI r16, 8
	SBR r16, 4		; Poner en alto los bits indicados r16 = r16 or k
	CBR r16, 8		; Poner en bajo los bits indicados r16 = r16 and (0xFF - k)

; Operaciones aritméticas y lógicas unarias
otras:
	; De estas ya se conocen INC, DEC, CLR y SER
	LDI r16, 170
	COM r16			; Complemento a 1 ( r16 = 0xFF - r16 )
	LDI r16, 170
	NEG r16			; Complemento a 2 ( r16 = 0x00 - r16 )
	TST r16			; Evalua el registro para saber si es cero o negativo
					; r16 = r16 and r16 (SREG: V, N, Z)

	NOP