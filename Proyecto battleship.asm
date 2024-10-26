ORG 100h 
.data

titulo db "Batalla Naval$"  
;Mensaje misiles restantes
msj_Misil1 db "Tienes $"
misiles dw 21   
misilActual dw 1
msj_Misil2 db " misiles para destruir la flota enemiga $"   
msj_enter db "Presiona ENTER para visualizar el tablero y ubicar los barcos aleatoriamente... $"
enter db 10, 13, '$'  

tablero db 49 dup('0') 
tablero_jugadas db 49 dup(177)   
columnas db 2 dup(10), 4 dup(9),"  \ A B C D E F G", 10, 13, "$" 
letras db 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'a', 'b', 'c', 'd', 'e', 'f', 'g' 
PosicionX db 0
X db 0
PosicionY db 0
Y db 0   

disparos db 20 dup(50)
auxiliar dw 0

esHorizontal db 0

;Barcos
portaaviones_T dw 5 ;el tamano del portaaviones es de 5 celdas
crucero_T dw 4 ;el tamano del crucero es de 4 celdas
submarino_T dw 3 ;el tamano del submarino es de 3 celdas 

 

;Juego
msj_ataque db "Misil $"   
msj_ataque2 db ", Ingrese la celda a atacar (Ejemplo: A1 o a1): $"
msj_opcion db " $"
salto db 10, 13, "$"  
msj_continuar db "Presiona ENTER para continuar $"

msj_colI db "Columna fuera de rango. Intenta con una columna A-G $"
msj_filaI db "Fila fuera de rango. Intenta con una fila 1-7 $"
msj_posR db "Esa celda ya ha sido atacada, intenta con otra$"

msj_impactoSi db "Impacto confirmado $"
msj_impactoNo db "Sin impacto $"

submarinoContador db 0
cruceroContador db 0
portaavionesContador db 0 
barcosHundidos db "0$"     

blanco 80 dup(32), "$"
                      

msj_subH db "Submarino hundido$"
msj_crucH db "Crucero hundido$"
msj_portH db "Portaviones hundido$"
msj_Final1 db "Usted logro hundir: $"
msj_Final2 db " barcos$" 

menu db "0$"    
playAgain db "Quieres jugar otra vez?$"   
opcionSi db "1. Si$"
opcionNo db "2. ", "No$" 
opcion db "$"
                         

msj_despedida db "Gracias por jugar!$"  
msj_ganar db "Felicidades, lograste hundir todos los navios!$"  
error db "Opcion incorrecta $"                      
.code

mov ah, 00h
mov al, 03h
int 10h

;Se muestra el titulo
mov ah, 09h
lea dx, titulo
int 21h 
lea dx, salto
int 21h 

;Se muestran los misiles restantes (Primera parte del mensaje)
lea dx, msj_Misil1
int 21h

;Descomponer el numero
mov ax, misiles
mov cx, 0
descomponer:
mov bx, 10
div bl
mov dx, ax
mov ah, 0
mov al, dh
push ax
mov ax, 0
mov al, dl
inc cx
cmp dl, 0
jnz descomponer 
jz convertir
;Convertir el numero
convertir:         
sub cx, 1
pop ax
mov ah, 02h
mov dx, ax
add dx, 30h
int 21h 
cmp cx, 0
jnz convertir

;(Segunda parte del mensaje)
mov ah, 09h
lea dx, msj_Misil2
int 21h
lea dx, salto
int 21h

jmp pulsar_enter    
           
;Ubicar el portaaviones en el tablero           
ubicar_Portaaviones:
call generar_PosRandom
call horizontal_o_vertical   

mov si, bx

mov cx, portaaviones_T

cmp esHorizontal, 1
je ubicar_portaavionesH
jne ubicar_portaavionesV 

;Se ubica el portaaviones verticalmente
ubicar_portaavionesV:
mov ax, si
mov bx, 7
div bl

mov bx, si

;Problemas al ubicar
cmp al, 2 ;El portaaviones inferiormente entra en el tablero desde la fila 3 hasta la 7
jle sumar_portaavionesY
cmp al, 4 ;El portaaviones superiormente entra en el tablero desde la fila 5 hasta la 1
jge restar_portaavionesY
jmp ubicar_Portaaviones

;ubica hacia abajo
sumar_portaavionesY:
mov tablero[si], 'P'  
add si, 7
loop sumar_portaavionesY 
jmp ubicar_Crucero    

;ubica hacia arriba
restar_portaavionesY:
mov tablero[si], 'P'
sub si, 7
loop restar_portaavionesY
jmp ubicar_Crucero

;se ubica el portaaviones horizontalmente
ubicar_portaavionesH:
mov ax, si
mov bx, 7
div bl

mov bx, si

;Problemas al ubicar
cmp ah, 2  ;El portaaviones entra en las columnas C-G ->
jle sumar_portaavionesX
cmp ah, 4  ;El portaaviones entra en las columnas A-E <-
jge restar_portaavionesX
jmp ubicar_Portaaviones

;ubicar hacia la izquierda
sumar_portaavionesX:
mov tablero[si], 'P'
inc si
loop sumar_portaavionesX
jmp ubicar_Crucero

;ubicar hacia la derecha
restar_portaavionesX:
mov tablero[si], 'P'
dec si
loop restar_portaavionesX
jmp ubicar_Crucero


;se ubica el crucero
ubicar_Crucero:
call generar_PosRandom
call horizontal_o_vertical

mov si, bx

mov cx, crucero_T

cmp esHorizontal, 1
je ubicar_cruceroH
jne ubicar_cruceroV


;Se ubica el crucero horizontalmente
ubicar_cruceroH:
mov ax, si
mov bx, 7
div bl

mov bx, si

;Problemas al ubicar
cmp ah, 3  ;El crucero entra en las columnas D-G ->
jle verificar_derecha
cmp ah, 3  ;El crucero entra en las columnas A-D <-
jge verificar_izquierda
jmp ubicar_Crucero  

verificar_derecha:
cmp tablero[bx], '0'
jne ubicar_Crucero
inc bx
loop verificar_derecha

mov cx, crucero_T

;se ubica hacia la derecha
sumar_cruceroX:
mov tablero[si], 'C'
inc si
loop sumar_cruceroX
jmp ubicar_Submarino


verificar_izquierda:
cmp tablero[bx], '0'
jne ubicar_Crucero
dec bx
loop verificar_izquierda 

mov cx, crucero_T   

;se ubica hacia la izquierda
restar_cruceroX:
mov tablero[si], 'C'
dec si
loop restar_cruceroX
jmp ubicar_Submarino   


;Se ubica el crucero verticalmente
ubicar_cruceroV:
mov ax, si
mov bx, 7
div bl

mov bx, si

cmp al, 3 ;El crucero inferiormente entra en el tablero desde la fila 4 hasta la 7
jle verificar_abajo
cmp al, 3 ;El crucero superiormente entra en el tablero desde la fila 4 hasta la 1
jge verificar_arriba
jmp ubicar_Crucero

verificar_abajo:
cmp tablero[bx], '0'
jne ubicar_Crucero
add bx, 7
loop verificar_abajo

mov cx, crucero_T

;Se ubica hacia abajo
sumar_cruceroY:
mov tablero[si], 'C'
add si, 7
loop sumar_cruceroY
jmp ubicar_Submarino

verificar_arriba:
cmp tablero[bx], '0'
jne ubicar_Crucero
sub bx, 7 
loop verificar_arriba

mov cx, crucero_T

;Se ubica hacia arriba
restar_cruceroY:
mov tablero[si], 'C'
sub si, 7
loop restar_cruceroY
jmp ubicar_Submarino

;Se ubica el submarino
ubicar_Submarino:
call generar_PosRandom
call horizontal_o_vertical

mov si, bx
mov cx, submarino_T

cmp esHorizontal, 1
je ubicar_submarinoH
jne ubicar_submarinoV

;Se ubica el submarino verticalmente
ubicar_submarinoV:
mov ax, bx
mov bx, 7
div bl

mov bx, si

;Problemas
cmp al, 4  ;El submarino inferiormente entra en el tablero desde la fila 5 hasta la 7
jle verificar_inferior
cmp al, 2  ;El submarino superiormente entra en el tablero desde la fila 3 hasta la 1
jge verificar_superior
jmp ubicar_Submarino

verificar_inferior:
cmp tablero[bx], '0'
jne ubicar_Submarino
add bx, 7
loop verificar_inferior

mov cx, submarino_T

;Se ubica hacia abajo
sumar_submarinoY:
mov tablero[si], 'S'
add si, 7
loop sumar_submarinoY
jmp juego

verificar_superior:
cmp tablero[bx], '0'
jne ubicar_Submarino
sub bx, 7
loop verificar_superior

mov cx, submarino_T

;se ubica hacia arriba
restar_submarinoY:
mov tablero[si], 'S'
sub si, 7
loop restar_submarinoY
jmp juego

;Se ubica el submarino horizontalmente
ubicar_submarinoH:
mov ax, bx
mov bx, 7
div bl

mov bx, si

;Problemas
cmp ah, 4   ;El submarino entra en las columnas E-G ->
jle verificar_derechaS
cmp ah, 2   ;El submarino entra en las columnas A-C <-
jge verificar_izquierdaS
jmp ubicar_Submarino

verificar_derechaS:
cmp tablero[bx], '0'
jne ubicar_Submarino
inc bx
loop verificar_derechaS

mov cx, submarino_T

;se ubica hacia la derecha
sumar_submarinoX:
mov tablero[si], 'S'
inc si
loop sumar_SubmarinoX
jmp juego

verificar_izquierdaS:
cmp tablero[bx], '0'
jne ubicar_Submarino
dec bx
loop verificar_izquierdaS

mov cx, submarino_T

;Se ubica hacia la derecha
restar_submarinoX:
mov tablero[si], 'S'
dec si
loop restar_submarinoX
jmp juego
                               
                               
;Empieza el juego                               
juego:
je mostrar_tablero
jne iniciar_tablero


;Sirve para mostrar el tablero con las celdas resaltadas
mostrar_tablero:
mov ah, 00h
mov al, 03h
int 10h

mov ah, 09h 
lea dx, salto
int 21h
lea dx, columnas
int 21h 

mov di, 0
mov si, 0

mov bl, '1'

filaTablero:
mov ah, 02h
mov dx, 9
int 21h
int 21h
int 21h
int 21h

mov dx, 32
int 21h
int 21h  

mov dl, bl
int 21h

mov cx, 7

contenidoFila:
mov dx, 32
int 21h
mov dl, tablero[si]
int 21h 

inc si
loop contenidoFila

mov dx, 10
int 21h
mov dx, 13
int 21h

inc bl
inc di
cmp di, 7
jl filaTablero

cmp misiles, 0
je fin_juego
jmp partida ;;;;;



;se prepara el tablero
iniciar_tablero:
mov si, 0
mov cx, 49
reiniciar_tablero:
mov tablero_jugadas[si], 177 ;177 es el caracter ASCII con el que se llena el tablero
inc si
loop reiniciar_tablero

mov si, 0

;se muestra el tablero, con el cual el usuario puede interactuar
mostrar_tablero_jugadas:
;Limpiar
mov ah, 00h
mov al, 03h
int 10h     

;Mostrar las columnas
mov ah, 09h
lea dx, columnas
int 21h

mov di, 0
mov si, 0

mov bl, '1'
numeroF:
mov ah, 02h
mov dx, 9
int 21h
int 21h
int 21h
int 21h

mov dx, 32
int 21h
int 21h

mov dl, bl
int 21h  

mov cx, 7

contenidoF:
mov dx, 32
int 21h 

mov dl, tablero_jugadas[si]
int 21h

inc si
loop contenidoF

mov dx, 10
int 21h
mov dx, 13
int 21h

inc bl
inc di   
cmp di, 7
jl numeroF


;muestra mensajes de misiles
partida: ;;;;;
mov ah, 02h
mov dh, 13
mov dl, 38
int 10h
mov dx, 32
int 21h
int 21h
mov dh, 09h
int 10h
mov ah, 09h 
lea dx, salto
int 21h
lea dx, salto
int 21h
;Se muestran los misiles restantes (Primera parte del mensaje)
lea dx, msj_Misil1
int 21h

;Descomponer el numero
mov ax, misiles
mov cx, 0
descomponer2:
mov bx, 10
div bl
mov dx, ax
mov ah, 0
mov al, dh
push ax
mov ax, 0
mov al, dl
inc cx
cmp dl, 0
jnz descomponer2 
jz convertir2
;Convertir el numero
convertir2:         
sub cx, 1
pop ax
mov ah, 02h
mov dx, ax
add dx, 30h
int 21h 
cmp cx, 0
jnz convertir2

;(Segunda parte del mensaje)
mov ah, 09h
lea dx, msj_Misil2
int 21h

cmp [barcosHundidos], '3'
je gana
cmp misiles, 0  
je resaltar_celdas

;(Primera parte del mensaje)
mov ah, 09h                  
lea dx, salto
int 21h
lea dx, msj_ataque
int 21h 

;Descomponer el numero
mov ax, misilActual
mov cx, 0
descomponer3:
mov bx, 10
div bl
mov dx, ax
mov ah, 0
mov al, dh
push ax
mov ax, 0
mov al, dl
inc cx
cmp dl, 0
jnz descomponer3 
jz convertir3
;Convertir el numero
convertir3:         
sub cx, 1
pop ax
mov ah, 02h
mov dx, ax
add dx, 30h
int 21h 
cmp cx, 0
jnz convertir3

;(Segunda parte del mensaje)
mov ah, 09h
lea dx, msj_ataque2
int 21h
mov ah, 09h
lea dx, msj_opcion 
int 21h
jmp pedir_columnaL



resaltar_celdas:
    call limpiar_final
    
    jmp mostrar_tablero


;Se piden las celdas al usuario
pedir_columnaL:

mov ax, 00h
mov ah, 01h
int 21h

mov si, 0
mov cx, 14

cmp al, "a"
jge minuscula

mayuscula:
cmp al, 'A'
jl colFuera

cmp al, 'G'
jg colFuera ;jugada_ilegal

jmp indice_col

minuscula:
cmp al, 'a'
jl colFuera

cmp al, 'g'
jg colFuera

indice_col: 
cmp al, letras[si]
je pedir_fila
inc si
loop indice_col

corregirX:
sub si, 7

pedir_fila:
cmp si, 7
jge corregirX 

mov ax, si
mov [PosicionX], al
inc al
add al, al
mov X, al   

mov ax, 00h
mov ah, 01h
int 21h

cmp al, '1'
jl  filaFuera

cmp al, '7'
jg filaFuera

sub al, 30h     

mov [PosicionY], al
dec PosicionY
mov Y, al  

mov al, 7
mul [PosicionY]
mov [PosicionY], al  

mov ax, 0
mov al, [PosicionY]
add al, [PosicionX]
mov bx, ax

mov si, 0
mov cx, 20


;se actualiza el tablero con la celda atacada
disparo:
cmp bl, disparos[si]
je celdaRepetida ;repetido
inc si
loop disparo

mov si, auxiliar 

mov disparos[si], bl

inc auxiliar
dec misiles  
inc misilActual

cmp tablero[bx], '0'
je fallar
jne acertar

colFuera:
mov ah, 09h
lea dx, salto
int 21h
;ret
mov ah, 09h
lea dx, msj_colI
int 21h
jmp posFuera

filaFuera:
mov ah, 09h
lea dx, salto
int 21h
;ret
mov ah, 09h
lea dx, msj_filaI
int 21h
jmp posFuera

celdaRepetida:
mov ah, 09h
lea dx, salto
int 21h
;ret
mov ah, 09h
lea dx, msj_posR
int 21h

posFuera:
;Mensaje ENTER 
lea dx, salto
int 21h
lea dx, msj_continuar
int 21h

; Esperar a que el usuario pulse ENTER
mov ah, 0Ah
mov dx, offset enter
int 21h  

call limpiar_seccion  
jmp partida


;se actualiza el tablero con 1, cuando se ataca el barco
acertar:
mov si, bx

mov ah, 02h
mov dl, 34
add dl, X
mov dh, 2
add dh, Y
int 10h
mov dx, '1'
int 21h
mov dh, 13;;;;;;
int 10h

mov ah, 09h  
lea dx, salto
int 21h
lea dx, msj_impactoSi
int 21h

mov tablero_jugadas[si], '1'

cmp tablero[si], 'S'
je submarinoImpactado

cmp tablero[si], 'C'
je  cruceroImpactado

cmp tablero[si], 'P'
je portaavionesImpactado

;incrementa el contador de submarino
submarinoImpactado:
inc submarinoContador
mov dx, submarino_T
cmp submarinoContador, dl
je submarinoHundido 
;continuar mensaje  
mov ah, 09h 
lea dx, salto
int 21h
lea dx, msj_continuar
int 21h

; Esperar a que el usuario pulse ENTER
mov ah, 0Ah
mov dx, offset enter
int 21h  

;limpiar 
call limpiar_seccion 
jmp partida


;incrementa el contador de crucero
cruceroImpactado:
inc cruceroContador
mov dx, crucero_T
cmp cruceroContador, dl 

je cruceroHundido  

;continuar mensaje  
mov ah, 09h  
lea dx, salto
int 21h
lea dx, msj_continuar
int 21h

; Esperar a que el usuario pulse ENTER
mov ah, 0Ah
mov dx, offset enter
int 21h  


;limpiar
call limpiar_seccion
jmp partida


;incrementa el contador de portaaviones
portaavionesImpactado:
inc portaavionesContador
mov dx, portaaviones_T
cmp portaavionesContador, dl
je portaavionesHundido  
;continuar mensaje  
mov ah, 09h 
lea dx, salto
int 21h
lea dx, msj_continuar
int 21h

; Esperar a que el usuario pulse ENTER
mov ah, 0Ah
mov dx, offset enter
int 21h  

;limpiar
call limpiar_seccion
jmp partida 


;incrementa el numero de barcos hundidos
submarinoHundido:
inc [barcosHundidos]

mov ah, 09h 
lea dx, salto
int 21h
lea dx, msj_subH
int 21h   
lea dx, salto
int 21h
jmp cont

;incrementa el numero de barcos hundidos
cruceroHundido:
inc [barcosHundidos]

mov ah, 09h 
lea dx, salto
int 21h
lea dx, msj_crucH
int 21h 
lea dx, salto
int 21h 
jmp cont

;incrementa el numero de barcos hundidos
portaavionesHundido:
inc [barcosHundidos]

mov ah, 09h  
lea dx, salto
int 21h
lea dx, msj_portH
int 21h
lea dx, salto
int 21h  
jmp cont

;continuar
cont:
mov ah, 09h
lea dx, msj_continuar
int 21h

mov ah, 0Ah
mov dx, offset enter
int 21h 

call limpiar_seccion   
jmp partida ;;;;;;;;;;;


;se muestra mensaje de ganar
gana:

mov ah, 00h
mov al, 03h
int 10h

mov ah, 09h
lea dx, msj_ganar
int 21h    
lea dx, salto
int 21h


jmp reiniciar_variables 


;se actualiza el tablero con 0, cuando en la celda atacada no hay un barco
fallar:
mov si, bx

mov ah, 02h
mov dl, 34
add dl, X
mov dh, 2
add dh, Y
int 10h 
mov dx, '0'
int 21h
mov dh, 13
int 10h

mov ah, 09h   
lea dx, salto
int 21h
lea dx, msj_impactoNo
int 21h

mov tablero_jugadas[si], '0' 


mov ah, 09h  
lea dx, salto
int 21h
lea dx, msj_continuar
int 21h

mov ah, 0Ah
mov dx, offset enter
int 21h 

call limpiar_seccion
jmp partida ;;;;;;;;;;;;;;;


;Resultados del jugador 
fin_juego:
mov ah, 09h 
lea dx, salto
int 21h
lea dx, msj_Final1
int 21h
lea dx, barcosHundidos
int 21h
lea dx, msj_Final2
int 21h  
lea dx, salto
int 21h


;se reinician las variables
reiniciar_variables:
mov misiles, 21 
mov misilActual, 1 
mov [barcosHundidos], '0'
mov auxiliar, 0
mov submarinoContador, 0
mov cruceroContador, 0
mov portaavionesContador, 0

mov si, 0
mov cx, 49

;se reinicia el tablero
reiniciar_tab:
mov tablero[si], '0'
inc si
loop reiniciar_tab

mov si, 0
mov cx, 20

;se reinician los disparon
reiniciar_disparos:
mov disparos[si],50  
inc si
loop reiniciar_disparos


;se pregunta si quiere jugar otra vez
play_again:
mov menu, '1'

mov ah, 09h
lea dx, playAgain 
int 21h  
lea dx, salto
int 21h
lea dx, opcionSi
int 21h
lea dx, salto
int 21h
lea dx, opcionNo
int 21h 
lea dx, salto
int 21h 
lea dx, opcion
int 21h


;se escoge la opcion
escoger_opcion: 
mov ah, 01h
int 21h

cmp al, '1'
je ubicar_Portaaviones
cmp al, '2'
je salir
jmp incorrecto


;opcion incorrecta
incorrecto:
mov ah, 09h 
lea dx, salto
int 21h
lea dx, error 
int 21h

;Mensaje ENTER   
lea dx, salto
int 21h
lea dx, msj_continuar
int 21h

; Esperar a que el usuario pulse ENTER
mov ah, 0Ah
mov dx, offset enter
int 21h  

call limpiar_seccion

cmp menu, '1'
je play_again


;salir del juego
salir:
mov ah, 00h
mov al, 03h
int 10h

mov ah, 09h
lea dx, msj_despedida
int 21h 

mov ah, 4Ch
int 21h


pulsar_enter:
;Mensaje ENTER
lea dx, msj_enter
int 21h

; Esperar a que el usuario pulse ENTER
mov ah, 0Ah
mov dx, offset enter
int 21h  
jmp ubicar_Portaaviones


;Se genera una ubicacion random para ubicar en el tablero
generar_PosRandom proc
    mov dx, 00h
    mov ah, 2Ch
    int 21h

    mov dh, 0
    add dx, 32h ;50 en hexadecimal
    mov ax, dx
    mov dl, 3
    div dl   

    ;Se ubica la posicion en el tablero
    mov ah, 0
    mov bx, ax
    ret
generar_PosRandom endp


;Se decide si el barco va a ser ubicado horizontal o verticalmente
horizontal_o_vertical proc
    mov dx, 00h 
    mov ah, 2Ch 
    int 21h
    
    mov al, dl
    mov ah, 0
    mov dx, 2
    div bl
    cmp ah, 1 
    je horizontal
    jne vertical
    
    horizontal:
    mov esHorizontal, 1
    jmp retornar      
    
    vertical:
    mov esHorizontal, 0
    
    retornar:
    ret
horizontal_o_vertical endp   

 
;Se limpia la seccion de mensajes mostrados 
limpiar_seccion proc
    ;Limpia la posicion ingresada
    mov ah, 02h
    mov dh, 16
    mov dl, 10
    int 10h
    mov dx, 32
    int 21h
    int 21h
    ;Ubica el cursor al inicio de la linea 17 para limpiar mensajes previos
    mov dh, 10
    mov dl, 0
    int 10h
    ;Imprime en consola espacios en blanco para limpiar mensajes previos
    mov ah, 09h
    lea dx, blanco
    mov cx, 7
    limpiar2:
        int 21h
        loop limpiar2
    
    ret
limpiar_seccion endp       

limpiar_final proc
    
    mov ah, 09h
    lea dx, salto
    int 21h
    lea dx, blanco
    int 21h
    int 21h
    int 21h
    
    mov ah, 02h
    mov dh, 13
    int 10h
    
    mov ah, 09h
    lea dx, salto
    int 21h 
    
    lea dx, msj_continuar
    int 21h

    mov ah, 0Ah
    mov dx, offset enter
    int 21h   
    ret
limpiar_final endp 