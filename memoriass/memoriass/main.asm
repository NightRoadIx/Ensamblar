; Tabla de constantes
.EQU diez = 0x0A		; Se define una constante que se llama diez con un valor de 0x0A

; Segmento de definición de datos
.DSEG
.ORG 0X0100				; Con esto se le indica que se reservará espacio en memoria a partir de 0x0100 en SRAM
	var1:	.BYTE	1	; Variable de 1 byte en SRAM

; Segmento de código
.CSEG
.ORG 0x0000
RJMP main
main:
	LDI r16, 5		; Cargar un valor de 5 en r16
	LDI r17, 10		; Cargar un valor de 10 en r17
	LDI r18, 20		; Cargar un valor de 20 en r18
	LDI r19, 30		; Cargar un valor de 30 en r19
	CLR r20			; Limpiar el registro r20

; Instrucciones de carga en memoria
cargamem:
	; Direccionamiento directo a la memoria de datos
	; Recordar que hay un espacio de 2048 bytes para la memoria SRAM de propósito general
	; Comienza en la dirección 0x0100 y termina en la 0x08FF (donde comienza la pila)

	; Direccionamiento directo a memoria de datos
	; Guardar los registros en las direcciones de memoria
	STS 0x0110, r16
	; Sumar r16 y r17
	ADD r16, r17
	; Guardar el valor de la suma en la dirección 0x0101
	STS 0x0111, r16
	; Reingresar el valor que tenía anterior  la suma r16 (y que por fortuna se guardo en 0x0100)
	LDS r16, 0x0110

	; Ingresar datos a partir de lo reservado
	STS var1, r18

	; Hacer uso de las constantes, cargar a un registro
	LDI r20, diez

	; O entrar con direccionamiento indirecto haciendo uso de los registros
	; X (r26:r27), Y (r28:r29), Z (r30:r31)	
	LDI XH, 0x01
	LDI XL, 0x12		; Esto carga la dirección de memoria 0x0112
	; Almacenar en la dirección apuntada por X, el registro r20
	ST X, r20

	NOP

; Uso de la pila
cargastack:
	; Se puede usar la pila para almacenar datos de manera "ordenada"
	; Almacenar los valores de los registros en la pila ordenados r20:r19:r18:r17:r16
	PUSH r16
	PUSH r17
	PUSH r18
	PUSH r19
	PUSH r20

	; Para sacar de la pila y obtener de nuevo el valor del r16, hay que recorrer toda la pila
	POP r16			; Valor r20
	POP r16			; Valor r19
	POP r16			; Valor r18
	POP r16			; Valor r17
	POP r16			; Valor r16

	; Se puede obtener el tope de la RAM o el inicio de la pila con la instrucción RAMEND
	; Guardar los valores de la dirección del fin de la RAM en los registros r21 y r22
	LDI r21, low(RAMEND)
	LDI r22, high(RAMEND)

	NOP