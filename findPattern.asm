;Alexander Wrzosek

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



;[ebp - 36] - pattern height
;[ebp - 40] - pattern width

;[ebp - 44] - address of table of coordinates
;[ebp - 48] - image width in bytes

;[ebp - 52] - startBMP

;[ebp - 56] - analyse window width
;[ebp - 60] - analyse window height



;word [ebp - 62] - mask


findPattern:


	push	ebp
	mov		ebp, esp
	sub		esp, 64
	
	push	ebx
	push	edx
	push	edi
	push	esi
	
	;remember address of table of cords for later
	mov		eax, [ebp + 20]
	mov		[ebp - 44], eax
	
	mov		ebx, [ebp + 8]						;load image address
	
	mov		eax, [ebx + 8]						;start of bitmap
	mov		[ebp - 52], eax
	
	mov		eax, [ebx + 4]						;load image height in pixels
	mov		edi, eax							;edi - image height in pixels
	
	mov		eax, [ebx]						;load image width in pixels
	mov		esi, eax

	
	;lineBytes = ((pInfo->width + 31) >> 5) << 2; // line size in bytes

	add		eax, 31
	shr		eax, 5
	shl		eax, 2
	
	mov		[ebp - 48], eax						;image width in bytes
	
	mov 	ecx, 0x0000FFFF
	mov		eax, [ebp + 12]
	mov 	ebx, eax
	and		ebx, ecx							;int ry = pSize & 0x0000FFFF;
	mov		[ebp - 36], ebx						;ebx - pattern height
	
	sub		edi, ebx
	inc		edi									;edi - analyse window height
	mov		[ebp - 60], edi					
	

	shr		eax, 16								;int rx = pSize >> 16;
	and 	eax, ecx
	mov 	[ebp - 40], eax	
	
	sub		esi, eax
	inc		esi
	mov		[ebp - 56], esi

	
;create mask
	mov		esi, eax							;counter = rx
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
	sub		edx, eax							;edx shift left to move to 2nd byte [ 4 | 3 | 2 | 1]
	
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
	
	add		esi, 4								;next part of pattern
	dec		edi
	jnz		save_patterns_loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MAIN LOOP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	xor		edx, edx							;edx - y
		
	mov		edi, [ebp + 24]
	mov		[edi], edx						;zero occurences counter
	
	
	
next_line:
	
	
	mov		esi, [ebp - 52];					;esi - start BMP
	xor		ecx, ecx							
	mov		edi, [ebp - 36]						;edi -dec pattern height
	xor		ebx, ebx							;ebx -counter pixels right
	;edx
		
	
store_data:
	xor		ax, ax							;eax = 0
	mov		al, byte[esi + ecx]
	shl		ax, 8
	mov		word[ebp + 2 * edi - 32 - 2], ax
	
	
	
	add		ecx, [ebp - 48]
	
	dec		edi
	jnz		store_data

	
horizontal_with_load:							;move analyse window 1 pixel right & load
	mov		edi, [ebp - 36]						;edi - dec pattern height
	inc		esi
	xor		ecx, ecx							;ecx - line counter

vertical_with_load:
	mov		ax, word[ebp + 2 * edi - 32 - 2]
	mov		al, byte[esi + ecx]
	
	
	add		ecx, [ebp - 48]

	shl		eax, 1
	mov		word[ebp + 2 * edi - 32 - 2], ax
	shr		eax, 1
	

	and		ax, word [ebp - 62]					;masking
	cmp		ax, word[ebp + 2 * edi - 16 - 2]
	jne		test_nomask_with_load
	dec		edi
	jnz		vertical_with_load
	

;save x, y of found pattern
;edi - adress of points
	mov		edi, [ebp + 20]
	mov		[edi], ebx
	add		edi, 4
	mov		[edi], edx
	add		edi, 4
	mov		[ebp + 20], edi

;increase number of occurences	
	mov		edi, [ebp + 24]
	mov		eax, [edi]
	inc		eax
	mov		[edi], eax
	
	inc		ebx									;x++
	cmp		ebx, [ebp - 56]
	je		test_end
	
	jmp		horizontal_no_load

	
	
nomask_with_load:								
	mov		ax, word[ebp + 2 * edi - 32 - 2]
	mov		al, byte[esi + ecx]
	
	
	add		ecx, [ebp - 48]
	
	
	shl		eax, 1
	mov		word[ebp + 2 * edi - 32 - 2], ax
	shr		eax, 1
	
test_nomask_with_load:
	dec		edi
	jnz		nomask_with_load
	
	inc		ebx									;x++
	cmp		ebx, [ebp - 56]
	je		test_end

	
horizontal_no_load:						;when number of pixels is not divisible by 8
	mov		edi, [ebp - 36]						;edi - decremented pattern height
	
	
	
vertical_no_load:
	mov		ax, word[ebp + 2 * edi - 32 - 2]
	shl		eax, 1
	mov		word[ebp + 2 * edi - 32 - 2], ax
	shr		eax, 1
	
	and		ax, word [ebp - 62]					;mask
	cmp		ax, [ebp + 2 * edi - 16 - 2]
	jne		test_nomask_no_load
	dec		edi
	jnz		vertical_no_load
	
		

;save x, y of found occurence
;edi - address of points
	mov		edi, [ebp + 20]
	mov		[edi], ebx
	add		edi, 4
	mov		[edi], edx
	add		edi, 4
	mov		[ebp + 20], edi

;increase number of occurences	
	mov		edi, [ebp + 24]
	mov		eax, [edi]
	inc		eax
	mov		[edi], eax
	
	inc		ebx									;x++
	cmp		ebx, [ebp - 56]
	je		test_end
	
	
	;check / 8
	
	mov		eax, ebx
	shr		eax, 3
	shl		eax, 3
	cmp		eax, ebx
	jz		horizontal_with_load
	jmp		horizontal_no_load
	
	
nomask_no_load:								
	mov		ax, word [ebp + 2 * edi - 32 - 2]
	shl		ax, 1
	mov		word [ebp + 2 * edi - 32 - 2], ax
	
test_nomask_no_load:
	dec		edi
	jnz		nomask_no_load
	
	inc		ebx									;x++
	cmp		ebx, [ebp - 56]
	je		test_end
	
	
	mov		eax, ebx
	shr		eax, 3
	shl		eax, 3
	cmp		eax, ebx
	jz		horizontal_with_load
	jmp		horizontal_no_load
	
test_end:
	mov		eax, [ebp - 52]
	add		eax, [ebp - 48]
	mov		[ebp - 52], eax
	
	inc		edx
	cmp		edx, [ebp - 60]
	jl		next_line
	
	
	
	;return address of table of coordinates
	mov		eax, [ebp - 44]
	

	
end:
	pop		esi
	pop		edi
	pop		edx
	pop		ebx
	
	
	mov 	esp, ebp
	pop 	ebp
	ret
	
	
	
