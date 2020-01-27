global findPattern

section .text
;Point* findPattern(imgInfo* pImg, int pSize, int* ptrn, Point* pDst, int* fCnt);

;[ebp + 8] - imgInfo* pImg, next start bmp							
;[ebp + 12] - int pSize
;[ebp + 16] - int* ptrn
;[ebp + 20] - Point* pDst
;[ebp + 24] - int* fCnt

;[ebp - 2] - pattern
;[ebp - 4] - pattern
;[ebp - 6] - patter
;[ebp - 8] - pattern
;[ebp - 10] - pattern
;[ebp - 12] - pattern
;[ebp - 14] - pattern
;[ebp - 16] - pattern								[ebp + 2*ecx - 16]

;[ebp - 18] - analyze_data
;[ebp - 20] - analyze_data
;[ebp - 22] - analyze_data
;[ebp - 24] - analyze_data
;[ebp - 26] - analyze_data
;[ebp - 28] - analyze_data
;[ebp - 30] - analyze_data
;[ebp - 32] - analyze_data							[ebp + 2*ecx - 32]



;[ebp - 36] - wysokosc wzorca
;[ebp - 40] - szerokosc wzorca

;[ebp - 44] - adres poczatku tablicy punktow
;[ebp - 48] - szerokosc obrazka byte

;[ebp - 52] - startBMP

;[ebp - 56] - szerokosc okna analizy
;[ebp - 60] - wysokosc okna analizy



;word [ebp - 62] - maska


findPattern:


	push	ebp
	mov		ebp, esp
	sub		esp, 64
	
	push	ebx
	push	edx
	push	edi
	push	esi
	
	;zapamietanie adresu poczatku tablicy punktow na pozniej
	mov		eax, [ebp + 20]
	mov		[ebp - 44], eax
	
	mov		ebx, [ebp + 8]						;zaladowanie adresu obrazka
	
	mov		eax, [ebx + 8]						;poczatek bitmapy
	mov		[ebp - 52], eax
	
	mov		eax, [ebx + 4]						;wczytanie wysokosci obrazka w pixelach
	mov		edi, eax							;edi - wysokosc obrazka w pikselach
	
	mov		eax, [ebx]						;wczytanie szerokosci obrazka w pixelach
	mov		esi, eax

	
	;lineBytes = ((pInfo->width + 31) >> 5) << 2; // line size in bytes

	add		eax, 31
	shr		eax, 5
	shl		eax, 2
	
	mov		[ebp - 48], eax						;zapis szerokosci obrazka w bajtach
	
	mov 	ecx, 0x0000FFFF
	mov		eax, [ebp + 12]
	mov 	ebx, eax
	and		ebx, ecx							;int ry = pSize & 0x0000FFFF;
	mov		[ebp - 36], ebx						;ebx - wysokosc wzorca
	
	sub		edi, ebx
	inc		edi									;edi - wysokosc okna analizy
	mov		[ebp - 60], edi					
	

	shr		eax, 16								;int rx = pSize >> 16;
	and 	eax, ecx
	mov 	[ebp - 40], eax	
	
	sub		esi, eax
	inc		esi
	mov		[ebp - 56], esi

	
;create mask
	mov		esi, eax							;licznik = rx
	xor		edi, edi
	inc		edi									;edi = 1
	shl		edi, 15
	
	xor		ecx, ecx							;ecx = 0
	

create_mask_loop:
	or		ecx, edi
	shr		edi, 1
	dec		esi
	jnz		create_mask_loop
	
	mov		word [ebp - 62], cx						;save mask
	
;save patterns
	mov		edx, 16
	sub		edx, eax							;edx o ile przesunac w lewo aby wzorzec dosunac do lewej strony drugiego bajtu [ 4 | 3 | 2 | 1]
	
	mov		edi, ebx							;edi == ry
	mov		esi, [ebp + 16]
	
	
save_patterns_loop:	
	mov		ecx, [esi]
	mov		eax, edx
	
shift_mask:	
	shl		cx, 1
	dec		eax
 	jnz		shift_mask
	
	mov		word [ebp + 2 * edi - 16 - 2], cx
	
	add		esi, 4								;przesuniecie na kolejny wzorzec
	dec		edi
	jnz		save_patterns_loop
	
;GLOWNA PETLA
	
	xor		edx, edx							;edx - y
		
	mov		edi, [ebp + 24]
	mov		[edi], edx						;wyzerowanie licznika znalezionych wzorcow
	
	
	
kolejna_linia:
	
	
	mov		esi, [ebp - 52];					;esi - start BMP
	xor		ecx, ecx							;ecx - 
	mov		edi, [ebp - 36]						;edi - dekrementowana wysokosc wzorca
	xor		ebx, ebx							;ebx - licznik pikseli w prawo
	;edx
		
	
store_data:
	xor		ax, ax							;eax = 0
	mov		al, byte[esi + ecx]
	shl		ax, 8
	mov		word[ebp + 2 * edi - 32 - 2], ax
	
	
	;xor		eax, eax
	;mov		byte[esi + ecx], al
	add		ecx, [ebp - 48]
	
	dec		edi
	jnz		store_data
	
	;[ebp + 2*ecx - 32 - 2]
	


	;;;xor		edx, edx
	
poziomo_z_wczytywaniem:							;#przesuniecie okna porownania w prawo o 1 piksel plus wczytywanie
	mov		edi, [ebp - 36]						;edi - dekrementowana wysokosc wzorca
	inc		esi
	xor		ecx, ecx							;ecx - licznik wierszach

pionowo_z_wczytywaniem:
	;mov		eax, [ebp + 4 * edi - 64 - 4]
	mov		ax, word[ebp + 2 * edi - 32 - 2]
	mov		al, byte[esi + ecx]
	
	
	
;	push	edx
;	xor		dl, dl
;	mov		byte[esi + ecx], dl
;	pop		edx
	
	
	add		ecx, [ebp - 48]
	
	
	
	shl		eax, 1
	mov		word[ebp + 2 * edi - 32 - 2], ax
	shr		eax, 1
	
;eax - do analizy

	and		ax, word [ebp - 62]					;maskowanie danych
	cmp		ax, word[ebp + 2 * edi - 16 - 2]
	jne		test_niemaskowanie_z_wczytywaniem
	dec		edi
	jnz		pionowo_z_wczytywaniem
	

;zapisanie x, y znalezionego wzorca
;edi - adres punktow
	mov		edi, [ebp + 20]
	mov		[edi], ebx
	add		edi, 4
	mov		[edi], edx
	add		edi, 4
	mov		[ebp + 20], edi

;zwiekszenie licznika znalezionych punktow	
	mov		edi, [ebp + 24]
	mov		eax, [edi]
	inc		eax
	mov		[edi], eax
	
	inc		ebx									;x += 1
	cmp		ebx, [ebp - 56]
	je		test_koniec
	
	jmp		poziomo_bez_wczytywania

	
	
niemaskowanie_z_wczytywaniem:								
	mov		ax, word[ebp + 2 * edi - 32 - 2]
	mov		al, byte[esi + ecx]
	
	
	
;	push	edx
;	xor		dl, dl
;	mov		byte[esi + ecx], dl
;	pop		edx
	
	add		ecx, [ebp - 48]
	
	
	shl		eax, 1
	mov		word[ebp + 2 * edi - 32 - 2], ax
	shr		eax, 1
	
test_niemaskowanie_z_wczytywaniem:
	dec		edi
	jnz		niemaskowanie_z_wczytywaniem
	
	inc		ebx									;x += 1
	cmp		ebx, [ebp - 56]
	je		test_koniec

	
poziomo_bez_wczytywania:						;gdy numer piksela nie jest wielokrotnoscia 8
	mov		edi, [ebp - 36]						;edi - dekrementowana wysokosc wzorca
	
	
	
pionowo_bez_wczytywania:
	mov		ax, word[ebp + 2 * edi - 32 - 2]
	shl		eax, 1
	mov		word[ebp + 2 * edi - 32 - 2], ax
	shr		eax, 1
	
	and		ax, word [ebp - 62]					;maskowanie danych
	cmp		ax, [ebp + 2 * edi - 16 - 2]
	jne		test_niemaskowanie_bez_wczytywania
	dec		edi
	jnz		pionowo_bez_wczytywania
	
		

;zapisanie x, y znalezionego wzorca
;edi - adres punktow
	mov		edi, [ebp + 20]
	mov		[edi], ebx
	add		edi, 4
	mov		[edi], edx
	add		edi, 4
	mov		[ebp + 20], edi

;zwiekszenie licznika znalezionych punktow	
	mov		edi, [ebp + 24]
	mov		eax, [edi]
	inc		eax
	mov		[edi], eax
	
	inc		ebx									;x += 1
	cmp		ebx, [ebp - 56]
	je		test_koniec
	
	
	;sprawdzic podzielnosc przez 8
	
	mov		eax, ebx
	shr		eax, 3
	shl		eax, 3
	cmp		eax, ebx
	jz		poziomo_z_wczytywaniem
	jmp		poziomo_bez_wczytywania
	
	
niemaskowanie_bez_wczytywania:								
	mov		ax, word [ebp + 2 * edi - 32 - 2]
	shl		ax, 1
	mov		word [ebp + 2 * edi - 32 - 2], ax
	
test_niemaskowanie_bez_wczytywania:
	dec		edi
	jnz		niemaskowanie_bez_wczytywania
	
	inc		ebx									;x += 1
	cmp		ebx, [ebp - 56]
	je		test_koniec
	
	
	mov		eax, ebx
	shr		eax, 3
	shl		eax, 3
	cmp		eax, ebx
	jz		poziomo_z_wczytywaniem
	jmp		poziomo_bez_wczytywania
	
test_koniec:
	mov		eax, [ebp - 52]
	add		eax, [ebp - 48]
	mov		[ebp - 52], eax
	
	inc		edx
	cmp		edx, [ebp - 60]
	jl		kolejna_linia
	
	
	
	;funkcja zwraca adres poczatku tablicy punktow
	mov		eax, [ebp - 44]
	

	
end:
	pop		esi
	pop		edi
	pop		edx
	pop		ebx
	
	
	mov 	esp, ebp
	pop 	ebp
	ret
	
	
	
