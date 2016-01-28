%include "asm_io.inc"
global asm_main

section .data
str1: db "too many arguments",0
str2: db "arugment is too long",0
str3: db "must be only lower case letters",0
flag: db "char",0
Y: dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
section .bss
N resd 1
X resb 20
z resd 20
temp resd 1
k resd 1
p resd 1
section .text

asm_main:
  enter 0, 0
  pusha
 
  mov ebx, dword [ebp+8]  ; stores the number of arguments in ebx
  
  cmp dword[ebp+8], 2 ; makes sure there is two or less arguments
  jne errmsg	; go to errmsg if there is more than 2 arguments
  
  mov ebx, dword [ebp+12] 
  mov eax, dword [ebx+4]
  mov [temp], dword eax ; stored in temp is the second argument

  loop:
	mov ebx, dword[temp] ; moves the word temp to ebx

	mov al, byte[ebx]    ; puts byte version of the word into al

	cmp byte[ebx], 0     ; makes sure the pointer is pointing at something
	je checkLength
	
	cmp byte[ebx],'a'
	jb errmsg3
	cmp byte[ebx],'z'  ; these four lines check that the pointer is pointing 				at a letter between a and z
	ja errmsg3	; go to errmsg3 if the pointer isnt pointing at a letter
	
	mov ecx, dword[N] 
	mov [X+(ecx)*4],al ; inserting byte from word into the next index in the 				arry of x

	add [temp], dword 1
	add [N], dword 1

	jmp loop
	
	checkLength:  ;checks length of the word to make sure it is less than or
			; or equal to 20 else will go to errmsg2
	cmp [N], dword 20 
	ja errmsg2
	
	jmp endloop  ;jmps to the endloop method

  endloop: ; this method pushes all the variables adjusted in the main function
	   ; and displays the contents of array X then goes to method maxprep
	push X
	push N
	push flag
	call display
	add esp,12
	jmp maxprep
	popa
	leave
	ret	

  maxprep: ;creates the lydon numbers in maxlyn method and saves them in array Y
	push k
	push N
	push X

	mov ebx,dword [N]	

	call maxlyn
	add esp,12
	
	mov ecx, dword [k]
	
	mov eax, dword[p]
	
	mov [Y+ecx*4],eax
	
	add [k],dword 1
	
	cmp [k],ebx
	jb maxprep
	
	mov [flag], dword "int"
	
	push Y
	push N
	push flag	
	call display
	add esp,12

	jmp enderr

 
  errmsg:
	mov eax, str1
	call print_string
	call print_nl
 	jmp enderr

  errmsg2:
	mov eax, str2
	call print_string
	call print_nl
	jmp enderr

  errmsg3:
	mov eax,str3
	call print_string
	call print_nl
	jmp enderr

enderr:

popa
leave
ret
		 
display: ;displays the values of the array that is pushed into this method
	enter 0,0
	pusha
	mov ebx,0
	
	cmp [flag], dword "char"
	je Disp
	cmp [flag],dword "int"
	je Disp2

	Disp:
	cmp ebx,[N]
	ja endDisp

	mov al,byte[X+ebx*4]
	call print_char
	add ebx,1
	jmp Disp
	
	Disp2:
	cmp ebx, [N]
	ja endDisp
	
	mov al,byte[Y+ebx*4]
	cmp al, 0
	je endDisp	
	call print_int
	add ebx,1
	mov eax, ' '
	call print_char
	jmp Disp2	

	endDisp:
	call read_char


	popa	
	leave
	ret

  maxlyn: ;algorithm for the lydon numbers
	enter 0,0
	pusha
	
	mov ebx, dword [N]

	cmp [k] ,dword ebx
	je return1

	mov [p],dword  1
	mov ecx, dword [k]
	add ecx, dword 1

	loop1:
	
	cmp ecx, ebx
	je end
	 
	mov edx, ecx
	sub edx, dword [p] ;edx i-p	

	mov al,byte[X+edx*4]

	cmp al,byte[X+ecx*4]
	je restart	

	cmp  al,byte [X+ecx*4]
	jg return1	

	mov eax,dword [k]
	
	mov [p],ecx
	add [p],dword 1
	sub [p],eax
	
	jmp restart 
	
	return1:
	jmp end

	restart:
	add ecx, dword 1
	jmp loop1

	end:
	
	popa
	leave
	ret
