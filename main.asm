[bits 32]

extern _lround
extern _fmod
extern _pow
extern _ceil
extern _floor
extern _trunc
extern _round
extern _sqrt
extern _cbrt
extern _sin
extern _cos
extern _tan
extern _asin
extern _acos
extern _atan
extern _atan2
extern _exp
extern _log
extern _log10
extern _time

extern _tolower

extern _sscanf
extern _printf
extern _putchar
extern _puts
extern _fgets

; `#define stdin (__acrt_iob_func(0))` at `stdio.h`
extern ___acrt_iob_func

global _main



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Globals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data

format_lf:                              db "%lf", 0
format_rpn_function:                    db "%s#%u ", 0
format_rpn_constant:                    db "%s ", 0
format_rpn_variable:                    db "$%s ", 0
format_rpn_value:                       db "%.12lg ", 0
format_ask_expression:                  db "Podaj wyrazenie: ", 0
format_print_rpn:                       db "ONP: ", 0
format_ask_variable_value:              db "Podaj %.6s: ", 0
format_continuous_mode_end:             db "(koniec)", 0
format_print_result:                    db "Wynik: %.12lg", 0xA, 0
format_error_comma_outside_bracket:     db "Error: Comma outside brackets! (offset=%u)", 0xA, 0
format_error_var_name_too_long:         db "Error: Variable name longer then 6 characters, unsupported. (offset=%u,name='%7s')", 0xA, 0
format_error_unknown_token:             db "Error: Unknown token! (offset=%u,code=%u,ascii='%c')", 0xA, 0
format_error_unmatched_bracket_begin:   db "Error: Unmatched bracket beginning! (offset=%u)", 0xA, 0
format_error_unmatched_bracket_close:   db "Error: Unmatched bracket closing! (offset=%u)", 0xA, 0


dynamic_defs_count equ 35
dynamic_defs:
		db "abs", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_abs

		db "sign", 0
		db 5 dup(0)
		db -128
		db 1
		dd apply_sign

		db "ceil", 0
		db 5 dup(0)
		db -128
		db 1
		dd apply_ceil

		db "floor", 0
		db 4 dup(0)
		db -128
		db 1
		dd apply_floor

		db "trunc", 0
		db 4 dup(0)
		db -128
		db 1
		dd apply_trunc

		db "round", 0
		db 4 dup(0)
		db -128
		db 1
		dd apply_round

		db "min", 0
		db 6 dup(0)
		db -128
		db -1
		dd apply_min

		db "max", 0
		db 6 dup(0)
		db -128
		db -1
		dd apply_max

		db "sum", 0
		db 6 dup(0)
		db -128
		db -1
		dd apply_sum

		db "product", 0
		db 2 dup(0)
		db -128
		db -1
		dd apply_product

		db "count", 0
		db 4 dup(0)
		db -128
		db -1
		dd apply_count

		db "avg", 0
		db 6 dup(0)
		db -128
		db -1
		dd apply_avg

		db "sqrt", 0
		db 5 dup(0)
		db -128
		db 1
		dd apply_sqrt

		db "cbrt", 0
		db 5 dup(0)
		db -128
		db 1
		dd apply_cbrt

		db "rad", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_rad

		db "deg", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_deg

		db "sin", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_sin

		db "cos", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_cos

		db "tan", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_tan

		db "asin", 0
		db 5 dup(0)
		db -128
		db 1
		dd apply_asin

		db "acos", 0
		db 5 dup(0)
		db -128
		db 1
		dd apply_acos

		db "atan", 0
		db 5 dup(0)
		db -128
		db 1
		dd apply_atan

		db "atan2", 0
		db 4 dup(0)
		db -128
		db 2
		dd apply_atan2

		db "exp", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_exp

		db "ln", 0
		db 7 dup(0)
		db -128
		db 1
		dd apply_ln

		db "log", 0
		db 6 dup(0)
		db -128
		db 2
		dd apply_log

		db "log10", 0
		db 4 dup(0)
		db -128
		db 1
		dd apply_log10

		db "fib", 0
		db 6 dup(0)
		db -128
		db 1
		dd apply_fib

		db "pi", 0
		db 7 dup(0)
		db -128
		db 0
		dd apply_pi

		db "euler", 0
		db 4 dup(0)
		db -128
		db 0
		dd apply_euler

		db "golden", 0
		db 3 dup(0)
		db -128
		db 0
		dd apply_golden

		db "inf", 0
		db 6 dup(0)
		db -128
		db 0
		dd apply_inf

		db "nan", 0
		db 6 dup(0)
		db -128
		db 0
		dd apply_nan

		db "unixtime", 0
		db 1 dup(0)
		db -128
		db 0
		dd apply_unixtime

		db "nr_albumu", 0
		db -128
		db 0
		dd apply_easteregg


op_def_add:
		db "+", 0
		db 8 dup(0)
		db 1
		db 2
		dd apply_add
op_def_subtract:
		db "-", 0
		db 8 dup(0)
		db 1
		db 2
		dd apply_subtract
op_def_multiply:
		db "*", 0
		db 8 dup(0)
		db 2
		db 2
		dd apply_multiply
op_def_divide:
		db "/", 0
		db 8 dup(0)
		db 2
		db 2
		dd apply_divide
op_def_modulo:
		db "%", 0
		db 8 dup(0)
		db 3
		db 2
		dd apply_modulo
op_def_power:
		db "^", 0
		db 8 dup(0)
		db 4
		db 2
		dd apply_power
op_def_factorial:
		db "!", 0
		db 8 dup(0)
		db 5
		db 1
		dd apply_factorial
op_def_neg:
		db "-", 0
		db 8 dup(0)
		db 1
		db 1
		dd apply_neg


constant_positive_infinity_f32:         dd 0b01111111100000000000000000000000
constant_negative_infinity_f32:         dd 0b11111111100000000000000000000000
constant_easteregg:                     dd 117813
constant_degrees_to_radians_multiplier: dq 0.017453292519943295
constant_radians_to_degrees_multiplier: dq 57.29577951308232
constant_near_zero_epsilon:             dq 0.000000000001



section .bss

stdin:	resd 1



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Operators

apply_add:
		mov     eax, dword [esp + 4]
		movzx   ecx, byte [eax + 2040]
		lea     edx, [ecx - 1]
		mov     byte [eax + 2040], dl
		movzx   edx, dl
		movzx   ecx, cl
		fld     qword [eax + edx * 8]
		fadd    qword [eax + ecx * 8]
		fstp    qword [eax + edx * 8]
		ret

apply_subtract:
		mov     eax, dword [esp + 4]
		movzx   ecx, byte [eax + 2040]
		lea     edx, [ecx - 1]
		mov     byte [eax + 2040], dl
		movzx   edx, dl
		movzx   ecx, cl
		fld     qword [eax + edx * 8]
		fsub    qword [eax + ecx * 8]
		fstp    qword [eax + edx * 8]
		ret

apply_multiply:
		mov     eax, dword [esp + 4]
		movzx   ecx, byte [eax + 2040]
		lea     edx, [ecx - 1]
		mov     byte [eax + 2040], dl
		movzx   edx, dl
		movzx   ecx, cl
		fld     qword [eax + edx * 8]
		fmul    qword [eax + ecx * 8]
		fstp    qword [eax + edx * 8]
		ret

apply_divide:
		mov     eax, dword [esp + 4]
		movzx   ecx, byte [eax + 2040]
		lea     edx, [ecx - 1]
		mov     byte [eax + 2040], dl
		movzx   edx, dl
		movzx   ecx, cl
		fld     qword [eax + edx * 8]
		fdiv    qword [eax + ecx * 8]
		fstp    qword [eax + edx * 8]
		ret

apply_modulo:
		push    esi
		push    ebx
		sub     esp, 4
		mov     ebx, dword [esp + 16]
		movzx   edx, byte [ebx + 2040]
		lea     eax, [edx - 1]
		mov     byte [ebx + 2040], al
		movzx   esi, al
		movzx   edx, dl
		push    dword [ebx + 4 + edx * 8]
		push    dword [ebx + edx * 8]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _fmod
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_power:
		push    esi
		push    ebx
		sub     esp, 4
		mov     ebx, dword [esp + 16]
		movzx   edx, byte [ebx + 2040]
		lea     eax, [edx - 1]
		mov     byte [ebx + 2040], al
		movzx   esi, al
		movzx   edx, dl
		push    dword [ebx + 4 + edx * 8]
		push    dword [ebx + edx * 8]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _pow
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_factorial:
		push    esi
		push    ebx
		sub     esp, 28
		mov     ebx, dword [esp + 40]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    round_f64_to_u32_forget_sign
		add     esp, 16
		test    eax, eax
		je      .zero
		fld1
	.next:
		movd    xmm0, eax
		movq    qword [esp + 8], xmm0
		fild    qword [esp + 8]
		fmulp   st1, st0
		sub     eax, 1
		jne     .next
	.done:
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret
	.zero:
		fld1
		jmp     .done

apply_neg:
		mov     eax, dword [esp + 4]
		movzx   edx, byte [eax + 2040]
		fld     qword [eax + edx * 8]
		fchs
		fstp    qword [eax + edx * 8]
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants

apply_pi:
		mov     edx, dword [esp + 4]
		movzx   eax, byte [edx + 2040]
		add     eax, 1
		mov     byte [edx + 2040], al
		movzx   eax, al
		mov     dword [edx + eax * 8], 1413754136
		mov     dword [edx + 4 + eax * 8], 1074340347
		ret

apply_euler:
		mov     edx, dword [esp + 4]
		movzx   eax, byte [edx + 2040]
		add     eax, 1
		mov     byte [edx + 2040], al
		movzx   eax, al
		mov     dword [edx + eax * 8], -1961601175
		mov     dword [edx + 4 + eax * 8], 1074118410
		ret

apply_golden:
		mov     edx, dword [esp + 4]
		movzx   eax, byte [edx + 2040]
		add     eax, 1
		mov     byte [edx + 2040], al
		movzx   eax, al
		mov     dword [edx + eax * 8], -1684540248
		mov     dword [edx + 4 + eax * 8], 1073341303
		ret

apply_inf:
		mov     edx, dword [esp + 4]
		movzx   eax, byte [edx + 2040]
		add     eax, 1
		mov     byte [edx + 2040], al
		movzx   eax, al
		fld1
		fldz
		fdivp   st1, st0
		fstp    qword [edx + eax * 8]
		ret

apply_nan:
		mov     edx, dword [esp + 4]
		movzx   eax, byte [edx + 2040]
		add     eax, 1
		mov     byte [edx + 2040], al
		movzx   eax, al
		fldz
		fdiv    st0, st0
		fstp    qword [edx + eax * 8]
		ret

apply_unixtime:
		push    ebx
		sub     esp, 36
		mov     ebx, dword [esp + 44]
		push    0
		call    _time
		movzx   ecx, byte [ebx + 2040]
		lea     edx, [ecx + 1]
		mov     byte [ebx + 2040], dl
		movzx   edx, dl
		mov     dword [esp + 28], eax
		fild    dword [esp + 28]
		fstp    qword [ebx + edx * 8]
		add     esp, 40
		pop     ebx
		ret

apply_easteregg:
		mov     edx, dword [esp + 4]
		movzx   eax, byte [edx + 2040]
		add     eax, 1
		mov     byte [edx + 2040], al
		movzx   eax, al
		fild    dword [constant_easteregg]
		fstp    qword [edx + eax * 8]
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

apply_abs:
		mov     eax, dword [esp + 4]
		movzx   edx, byte [eax + 2040]
		fld     qword [eax + edx * 8]
		fabs
		fstp    qword [eax + edx * 8]
		ret

apply_sign:
		push    ebx
		sub     esp, 8
		mov     eax, dword [esp + 16]
		movzx   ecx, byte [eax + 2040]
		fldz
		fld     qword [eax + ecx * 8]
		fcomi   st0, st1
		fxch    st1
		seta    dl
		movzx   edx, dl
		fcomip  st0, st1
		fstp    st0
		seta    bl
		movzx   ebx, bl
		sub     edx, ebx
		mov     dword [esp + 4], edx
		fild    dword [esp + 4]
		fstp    qword [eax + ecx * 8]
		add     esp, 8
		pop     ebx
		ret

apply_ceil:
		sub     esp, 12
		mov     edx, dword [esp + 16]
		movzx   ecx, byte [edx + 2040]
		fld     qword [edx + ecx * 8]
		fnstcw  word [esp + 6]
		movzx   eax, word [esp + 6]
		and     ah, -13
		or      ah, 8
		mov     word [esp + 4], ax
		fldcw   word [esp + 4]
		frndint
		fldcw   word [esp + 6]
		fstp    qword [edx + ecx * 8]
		add     esp, 12
		ret

apply_floor:
		sub     esp, 12
		mov     edx, dword [esp + 16]
		movzx   ecx, byte [edx + 2040]
		fld     qword [edx + ecx * 8]
		fnstcw  word [esp + 6]
		movzx   eax, word [esp + 6]
		and     ah, -13
		or      ah, 4
		mov     word [esp + 4], ax
		fldcw   word [esp + 4]
		frndint
		fldcw   word [esp + 6]
		fstp    qword [edx + ecx * 8]
		add     esp, 12
		ret

apply_trunc:
		sub     esp, 12
		mov     eax, dword [esp + 16]
		movzx   ecx, byte [eax + 2040]
		fld     qword [eax + ecx * 8]
		fnstcw  word [esp + 6]
		movzx   edx, word [esp + 6]
		or      dh, 12
		mov     word [esp + 4], dx
		fldcw   word [esp + 4]
		frndint
		fldcw   word [esp + 6]
		fstp    qword [eax + ecx * 8]
		add     esp, 12
		ret

apply_round:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _round
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

apply_min:
		push    esi
		push    ebx
		mov     ecx, dword [esp + 12]
		mov     ebx, dword [esp + 16]
		test    bl, bl
		je      .no_args
		movzx   eax, byte [ecx + 2040]
		lea     eax, [ecx + eax * 8]
		movzx   esi, bl
		sal     esi, 3
		mov     edx, eax
		sub     edx, esi
		fld     dword [constant_positive_infinity_f32]
	.next:
		fld     qword [eax]
		fxch    st1
		fucomi  st0, st1
		fcmovnbe st0, st1
		fstp    st1
		sub     eax, 8
		cmp     eax, edx
		jne     .next
	.done:
		movzx   eax, byte [ecx+2040]
		add     eax, 1
		sub     eax, ebx
		mov     byte [ecx+2040], al
		movzx   eax, al
		fstp    qword [ecx + eax * 8]
		pop     ebx
		pop     esi
		ret
	.no_args:
		fld     dword [constant_positive_infinity_f32]
		jmp     .done

apply_max:
		push    esi
		push    ebx
		mov     ecx, dword [esp + 12]
		mov     ebx, dword [esp + 16]
		test    bl, bl
		je      .no_args
		movzx   eax, byte [ecx + 2040]
		lea     eax, [ecx + eax * 8]
		movzx   esi, bl
		sal     esi, 3
		mov     edx, eax
		sub     edx, esi
		fld     dword [constant_negative_infinity_f32]
	.next:
		fld     qword [eax]
		fucomi  st0, st1
		fcmovbe st0, st1
		fstp    st1
		sub     eax, 8
		cmp     eax, edx
		jne     .next
	.done:
		movzx   eax, byte [ecx + 2040]
		add     eax, 1
		sub     eax, ebx
		mov     byte [ecx + 2040], al
		movzx   eax, al
		fstp    qword [ecx + eax * 8]
		pop     ebx
		pop     esi
		ret
	.no_args:
		fld     dword [constant_negative_infinity_f32]
		jmp     .done

apply_sum:
		push    esi
		push    ebx
		mov     ecx, dword [esp+12]
		mov     ebx, dword [esp+16]
		test    bl, bl
		je      .no_args
		movzx   eax, byte [ecx+2040]
		lea     eax, [ecx+eax*8]
		movzx   esi, bl
		sal     esi, 3
		mov     edx, eax
		sub     edx, esi
		fldz
	.next:
		fadd    qword [eax]
		sub     eax, 8
		cmp     eax, edx
		jne     .next
	.done:
		movzx   eax, byte [ecx+2040]
		add     eax, 1
		sub     eax, ebx
		mov     byte [ecx+2040], al
		movzx   eax, al
		fstp    qword [ecx+eax*8]
		pop     ebx
		pop     esi
		ret
	.no_args:
		fldz
		jmp     .done

apply_product:
		push    esi
		push    ebx
		mov     ecx, dword [esp+12]
		mov     ebx, dword [esp+16]
		test    bl, bl
		je      .no_args
		movzx   eax, byte [ecx+2040]
		lea     eax, [ecx+eax*8]
		movzx   esi, bl
		sal     esi, 3
		mov     edx, eax
		sub     edx, esi
		fld1
	.next:
		fmul    qword [eax]
		sub     eax, 8
		cmp     eax, edx
		jne     .next
	.done:
		movzx   eax, byte [ecx+2040]
		add     eax, 1
		sub     eax, ebx
		mov     byte [ecx+2040], al
		movzx   eax, al
		fstp    qword [ecx+eax*8]
		pop     ebx
		pop     esi
		ret
	.no_args:
		fld1
		jmp     .done

apply_count:
		sub     esp, 12
		mov     ecx, dword [esp+16]
		mov     edx, dword [esp+20]
		mov     eax, 1
		sub     eax, edx
		add     al, byte [ecx+2040]
		mov     byte [ecx+2040], al
		movzx   eax, al
		movzx   edx, dl
		mov     word [esp+6], dx
		fild    word [esp+6]
		fstp    qword [ecx+eax*8]
		add     esp, 12
		ret

apply_avg:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp+24]
		mov     ecx, dword [esp+28]
		test    cl, cl
		je      .no_args
		movzx   eax, byte [ebx+2040]
		lea     eax, [ebx+eax*8]
		movzx   esi, cl
		sal     esi, 3
		mov     edx, eax
		sub     edx, esi
		fldz
	.next:
		fadd    qword [eax]
		sub     eax, 8
		cmp     eax, edx
		jne     .next
	.done:
		movzx   eax, byte [ebx+2040]
		add     eax, 1
		sub     eax, ecx
		mov     byte [ebx+2040], al
		movzx   eax, al
		movzx   ecx, cl
		mov     dword [esp+4], ecx
		fild    dword [esp+4]
		fdivp   st1, st0
		fstp    qword [ebx+eax*8]
		add     esp, 12
		pop     ebx
		pop     esi
		ret
	.no_args:
		fldz
		jmp     .done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

apply_sqrt:
		push    esi
		push    ebx
		sub     esp, 4
		mov     ebx, dword [esp + 16]
		movzx   esi, byte [ebx + 2040]
		fld     qword [ebx + esi * 8]
		fsqrt
		fstp    qword [ebx + esi * 8]
		add     esp, 4
		pop     ebx
		pop     esi
		ret

apply_cbrt:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _cbrt
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

apply_rad:
		mov     eax, dword [esp+4]
		movzx   edx, byte [eax+2040]
		fld     qword [constant_degrees_to_radians_multiplier]
		fmul    qword [eax+edx*8]
		fstp    qword [eax+edx*8]
		ret

apply_deg:
		mov     eax, dword [esp+4]
		movzx   edx, byte [eax+2040]
		fld     qword [constant_radians_to_degrees_multiplier]
		fmul    qword [eax+edx*8]
		fstp    qword [eax+edx*8]
		ret

apply_sin:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _sin
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_cos:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _cos
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_tan:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _tan
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_asin:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _asin
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_acos:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _acos
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_atan:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _atan
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_atan2:
		push    esi
		push    ebx
		sub     esp, 4
		mov     ebx, dword [esp + 16]
		movzx   edx, byte [ebx + 2040]
		lea     eax, [edx - 1]
		mov     byte [ebx + 2040], al
		movzx   esi, al
		movzx   edx, dl
		push    dword [ebx + 4 + edx * 8]
		push    dword [ebx + edx * 8]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _atan2
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_exp:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _exp
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_ln:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _log
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

apply_log:
		push    esi
		push    ebx
		sub     esp, 20
		mov     ebx, dword [esp + 32]
		cmp     byte [esp + 36], 1
		je      .no_arg_so_its_ln
		movzx   edx, byte [ebx + 2040]
		lea     eax, [edx - 1]
		mov     byte [ebx + 2040], al
		movzx   edx, dl
		fld     qword [ebx + edx * 8]
		fstp    qword [esp + 8]
		movzx   esi, al
		sub     esp, 8
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _log
		fstp    qword [esp + 16]
		add     esp, 8
		push    dword [esp + 20]
		push    dword [esp + 20]
		call    _log
		fdivr   qword [esp + 16]
		fstp    qword [ebx + esi * 8]
		add     esp, 16
	.done:
		add     esp, 20
		pop     ebx
		pop     esi
		ret
	.no_arg_so_its_ln:
		sub     esp, 8
		push    1
		push    ebx
		call    apply_ln
		add     esp, 16
		jmp     .done

apply_log10:
		push    esi
		push    ebx
		sub     esp, 12
		mov     ebx, dword [esp + 24]
		movzx   esi, byte [ebx + 2040]
		push    dword [ebx + 4 + esi * 8]
		push    dword [ebx + esi * 8]
		call    _log10
		fstp    qword [ebx + esi * 8]
		add     esp, 20
		pop     ebx
		pop     esi
		ret

round_f64_to_u32_forget_sign:
		sub     esp, 28
		fld     qword [esp + 32]
		fabs
		fstp    qword [esp]
		call    _lround
		add     esp, 28
		ret

apply_nop:
		ret

fib:
		push    ebx
		mov     ecx, dword [esp + 8]
		cmp     ecx, 1
		jbe     .fib_eq0or1
		cmp     ecx, 4
		jbe     .fib_be4
	.fib_4plus:
		mov     edx, 2
		mov     eax, 3
		sub     ecx, 4
	.fib_next:
		xadd    eax, edx
		loop    .fib_next
		pop     ebx
		ret
	.fib_eq0or1:
		mov     eax, ecx
		pop     ebx
		ret
	.fib_be4:
		mov     eax, ecx
		sub     eax, 1
		pop     ebx
		ret 

apply_fib:
		push    edi
		push    esi
		push    ebx
		sub     esp, 32
		mov     ebx, dword [esp + 48]
		movzx   esi, byte [ebx + 2040]
		fld     qword [ebx + esi * 8]
		fst     qword [esp + 16]
		fstp    qword [esp]
		call    round_f64_to_u32_forget_sign
		fld     qword [esp + 16]
		fldz
		fcomip  st0, st1
		fstp    st0
		mov     edi, -1
		mov     edx, 1
		cmovbe  edi, edx
		mov     dword [esp], eax
		call    fib
		imul    eax, edi
		movd    xmm0, eax
		movq    qword [esp + 24], xmm0
		fild    qword [esp + 24]
		fstp    qword [ebx + esi * 8]
		add     esp, 32
		pop     ebx
		pop     esi
		pop     edi
		ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Parsing to RPN

is_char_allowed_in_name:
		mov     edx, dword [esp + 4]
		mov     eax, edx
		and     eax, 0xDF
		sub     eax, 65
		cmp     al, 25
		setbe   al
		cmp     dl, 95
		sete    cl
		or      al, cl
		je      .case2
		ret
	.case2:
		sub     edx, 48
		cmp     dl, 9
		setbe   al
		ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parse_to_rpn:
		; frame
		push    ebp
		push    edi
		push    esi
		push    ebx
		sub     esp, 2188
		lea     eax, [esp + 56]
		lea     edx, [esp + 2096]
	.initializing_f64_stack_for_operators:
		fldz
		fstp    qword [eax]
		add     eax, 8
		cmp     eax, edx
		jne     .initializing_f64_stack_for_operators
		mov     ebx, -1
		mov     dword [esp], 0 ; input index
		mov     byte [esp + 31], 1 ; looseMinus
		mov     byte [esp + 29], 0 ; previousWasValue
		jmp     .main_loop

	.whitespace_omit_next_char:
		add     dword [esp], 1 ; input index

	.main_loop:
		; check whitespace
		mov     esi, dword [esp] ; input index
		add     esi, dword [esp + 2212] ; input
		movzx   eax, byte [esi]
		cmp     al, 32
		sete    cl
		cmp     al, 9
		sete    dl
		or      cl, dl
		mov     edi, ecx
		jne     .whitespace_omit_next_char

		; check if number
		lea     edx, [eax - 43]
		test    dl, -3
		jne     .not_minus_nor_plus
		cmp     byte [esp + 29], 0 ; previousWasValue
		jne     .not_a_number_and_previous_was_value
		mov     eax, dword [esp + 2212] ; input
		mov     ecx, dword [esp] ; input index
		movzx   eax, byte [eax + 1 + ecx]
	.not_minus_nor_plus:
		movsx   eax, al
		sub     eax, 48
		cmp     eax, 9
		jbe     .number_parsing
	.couldnt_parse_as_number:
		movzx   eax, byte [esi]
		mov     byte [esp + 8], al
		cmp     al, 40
		je      .handle_bracket_opening
	.not_a_bracket_opening:
		cmp     byte [esp + 8], 41
		je      .handle_bracket_closing
		movzx   eax, byte [esp + 8]
		cmp     al, 44
		sete    dl
		cmp     al, 59
		sete    al
		or      dl, al
		jne     .handle_comma
		cmp     byte [esp + 29], 0 ; previousWasValue
		je      .right_side_operators
		movzx   eax, byte [esp + 8]
		cmp     al, 47
		jg      .operator_power
		cmp     al, 32
		jle     .operator_not_found
		sub     eax, 33
		cmp     al, 14
		ja      .operator_not_found
		movzx   eax, al
		jmp     dword .operators_jump_table[0 + eax * 4]
	.operators_jump_table:
		dd .operator_factorial
		dd .operator_not_found
		dd .operator_not_found
		dd .operator_not_found
		dd .operator_modulo
		dd .operator_not_found
		dd .operator_not_found
		dd .operator_not_found
		dd .operator_not_found
		dd .operator_multiply
		dd .operator_add
		dd .operator_not_found
		dd .operator_subtract
		dd .operator_not_found
		dd .operator_divide

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.operator_multiply:
		mov     eax, op_def_multiply
		jmp     .handle_operator_with_allowed_loose_minus
	.operator_divide:
		mov     eax, op_def_divide
		jmp     .handle_operator_with_allowed_loose_minus
	.operator_modulo:
		mov     eax, op_def_modulo
		jmp     .handle_operator_with_allowed_loose_minus
	.operator_factorial:
		mov     eax, op_def_factorial
		jmp     .handle_operator_with_allowed_loose_minus
	.operator_power:
		mov     eax, op_def_power
		cmp     byte [esp + 8], 94
		jne     .try_finding_functions_or_constants
	.handle_operator_with_allowed_loose_minus:
		movzx   edi, byte [eax + 10]
		mov     ecx, edi
		cmp     cl, 1
		jbe     .handle_operator_priority_dancing
		cmp     byte [esp + 31], 0 ; looseMinus
		je      .handle_operator_priority_dancing
		; handle loose minuses operation order
		mov     esi, dword [esp + 2208]
		movzx   ecx, byte [esi + 2040]
		movzx   esi, cl
		mov     ebp, dword [esp + 2208]
		fld     qword [ebp + 0 + esi * 8]
		fldz
		fcomi   st0, st1
		jbe     .handle_operator_priority_dancing_but_first_clean_fpu
		fstp    qword [ebp + 0 + esi * 8]
		add     ecx, 1
		mov     byte [ebp + 2040], cl
		movzx   ecx, cl
		fabs
		fstp    qword [ebp + 0 + ecx * 8]
		mov     dword [esp + 2120], op_def_subtract
		mov     byte [esp + 2124], 2
		mov     byte [esp + 2125], 0
		mov     word [esp + 2126], 32762
		add     ebx, 1
		movzx   ecx, bl
		movsd   xmm5, qword [esp + 2120]
		movsd   qword [esp + 56 + ecx * 8], xmm5
		jmp     .handle_operator_priority_dancing

	.operator_subtract:
		mov     eax, op_def_subtract
		jmp     .prepare_priority_for_substract_or_add_then_go_dance
	.operator_add:
		mov     eax, op_def_add
	.prepare_priority_for_substract_or_add_then_go_dance:
		movzx   edi, byte [eax + 10]
		jmp     .handle_operator_priority_dancing

	.handle_operator_priority_dancing_but_first_clean_fpu: ; after handling potential loose minus
		fstp    st0
		fstp    st0
	.handle_operator_priority_dancing:
		cmp     bl, -1
		je      .handle_operator_almost_done
		mov     esi, eax
	.handle_operator_priority_dancing_continue:
		movzx   ecx, bl
		fld     qword [esp + 56 + ecx * 8]
		fstp    qword [esp + 8]
		mov     ecx, dword [esp + 12]
		shr     ecx, 16
		cmp     cx, 32763
		je      .handle_operator_priority_dancing_bracket
		mov     ecx, dword [esp + 8]
		mov     eax, edi
		cmp     byte [ecx + 10], al
		jnb     .handle_operator_priority_dancing_push_next
		mov     eax, esi
	.handle_operator_almost_done:
		movzx   ecx, byte [eax + 11]
		mov     dword [esp + 2128], eax
		mov     byte [esp + 2132], cl
		mov     byte [esp + 2133], 0
		mov     word [esp + 2134], 32762
		add     ebx, 1
		movzx   eax, bl
		movsd   xmm3, qword [esp + 2128]
		movsd   qword [esp + 56 + eax * 8], xmm3
		add     dword [esp], 1 ; input index
		mov     byte [esp + 29], dl ; previousWasValue
		jmp     .main_loop

	.handle_operator_priority_dancing_push_next:
		mov     eax, dword [esp + 2208]
		movzx   eax, byte [eax + 2040]
		mov     byte [esp + 16], al
		lea     ecx, [eax + 1]
		mov     eax, dword [esp + 2208]
		mov     byte [eax + 2040], cl
		movzx   ecx, cl
		movsd   xmm5, qword [esp + 8]
		movsd   qword [eax + ecx * 8], xmm5
		sub     ebx, 1
		cmp     bl, -1
		jne     .handle_operator_priority_dancing_continue
	.handle_operator_priority_dancing_bracket:
		mov     eax, esi
		jmp     .handle_operator_almost_done

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.number_parsing:
		; try sscanf as number
		sub     esp, 4
		lea     eax, [esp + 52]
		push    eax
		push    format_lf
		push    esi
		call    _sscanf
		add     esp, 16
		test    eax, eax
		jle     .couldnt_parse_as_number
		mov     eax, dword [esp + 2208]
		movzx   eax, byte [eax + 2040]
		mov     byte [esp + 8], al
		add     eax, 1
		mov     edi, dword [esp + 2208]
		mov     byte [edi + 2040], al
		movzx   eax, al
		movsd   xmm6, qword [esp + 48]
		movsd   qword [edi + eax * 8], xmm6
		cmp     byte [esi], 45
		sete    al
		movzx   eax, al
		add     dword [esp], eax ; input index
		mov     edx, dword [esp] ; input index
	.omitting_number:
		add     edx, 1
		mov     eax, dword [esp + 2212] ; input
		movzx   ecx, byte [eax + edx]
		movsx   eax, cl
		sub     eax, 48
		cmp     eax, 9
		jbe     .omitting_number
		cmp     cl, 46
		je      .omitting_number
		mov     dword [esp], edx ; input index
		mov     byte [esp + 29], 1 ; previousWasValue
		jmp     .main_loop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.not_a_number_and_previous_was_value:
		movzx   eax, byte [esi]
		mov     byte [esp + 8], al
		cmp     al, 40
		jne     .not_a_bracket_opening
	.handle_bracket_glue_by_multiply_op_unless_function:
		movzx   eax, bl
		cmp     word [esp + 62 + eax * 8], 32762
		je      .handle_bracket_opening_after_conditional_multiply
		mov     dword [esp + 2104], op_def_multiply
		mov     byte [esp + 2108], 2
		mov     byte [esp + 2109], 0
		mov     word [esp + 2110], 32762
		add     ebx, 1
		movzx   eax, bl
		movsd   xmm7, qword [esp + 2104]
		movsd   qword [esp + 56 + eax * 8], xmm7
		jmp     .handle_bracket_opening_after_conditional_multiply

	.handle_bracket_opening:
		cmp     byte [esp + 29], 0 ; previousWasValue
		jne     .handle_bracket_glue_by_multiply_op_unless_function
	.handle_bracket_opening_after_conditional_multiply:
		mov     dword [esp + 2116], 0
		mov     esi, dword [esp] ; input index
		mov     dword [esp + 2112], esi
		mov     word [esp + 2118], 32763
		add     ebx, 1
		movzx   eax, bl
		movsd   xmm4, qword [esp + 2112]
		movsd   qword [esp + 56 + eax * 8], xmm4
		add     esi, 1
		mov     dword [esp], esi ; input index
		mov     eax, edi
		mov     byte [esp + 29], al ; previousWasValue
		mov     byte [esp + 31], 1 ; looseMinus
		jmp     .main_loop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.handle_bracket_closing:
		cmp     bl, -1
		je      .closing_bracket_not_found
		mov     ecx, dword [esp + 2208]
	.handle_bracket_closing_next_operator:
		mov     edx, ebx
		sub     ebx, 1
		movzx   eax, dl
		fld     qword [esp + 56 + eax * 8]
		fstp    qword [esp + 8]
		mov     eax, dword [esp + 12]
		shr     eax, 16
		cmp     ax, 32763
		je      .related_bracket_found
		movzx   eax, byte [ecx + 2040]
		add     eax, 1
		mov     byte [ecx + 2040], al
		movzx   eax, al
		movsd   xmm0, qword [esp + 8]
		movsd   qword [ecx + eax * 8], xmm0
		cmp     bl, -1
		jne     .handle_bracket_closing_next_operator
	.closing_bracket_not_found:
		sub     esp, 8
		push    dword [esp + 8]
		push    format_error_unmatched_bracket_close
		call    _printf
		add     esp, 16
		mov     eax, 1
		jmp     .return

	.related_bracket_found:
		movsd   xmm4, qword [esp + 8]
		movsd   qword [esp + 40], xmm4
		movzx   eax, bl
		fld     qword [esp + 56 + eax * 8]
		fstp    qword [esp + 8]
		movsd   xmm7, qword [esp + 8]
		movsd   qword [esp + 48], xmm7
		mov     eax, dword [esp + 12]
		shr     eax, 16
		cmp     ax, 32762
		je      .function_remaining_found_and_is_function_or_operator
	.handle_bracket_closing_next_token:
		add     dword [esp], 1 ; input index
		mov     eax, edi
		mov     byte [esp + 31], al ; looseMinus
		mov     byte [esp + 29], 1 ; previousWasValue
		jmp     .main_loop

	.function_remaining_found_and_is_function_or_operator:
		mov     eax, dword [esp + 8]
		cmp     byte [eax + 10], 0
		jns     .handle_bracket_closing_next_token ; priority < 128 are opearators
		lea     ebx, [edx - 2]
		cmp     byte [esp + 29], 0 ; previousWasValue
		je      .patryk_ludwikowski
		add     byte [esp + 44], 1
	.patryk_ludwikowski:
		movzx   eax, byte [esp + 44]
		mov     byte [esp + 52], al
		mov     eax, dword [esp + 2208]
		movzx   eax, byte [eax + 2040]
		mov     byte [esp + 8], al
		add     eax, 1
		mov     esi, dword [esp + 2208]
		mov     byte [esi + 2040], al
		movzx   eax, al
		movsd   xmm6, qword [esp + 48]
		movsd   qword [esi + eax * 8], xmm6
		jmp     .handle_bracket_closing_next_token

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.handle_comma:
		cmp     bl, -1
		je      .comma_outside_brackets
		mov     ecx, dword [esp + 2208]
	.handle_comma_next_operator:
		movzx   edx, bl
		fld     qword [esp + 56 + edx * 8]
		fstp    qword [esp + 8]
		movsd   xmm1, qword [esp + 8]
		movsd   qword [esp + 48], xmm1
		mov     eax, dword [esp + 12]
		shr     eax, 16
		cmp     ax, 32763
		je      .comma_bracket_found
		movzx   eax, byte [ecx + 2040]
		add     eax, 1
		mov     byte [ecx + 2040], al
		movzx   eax, al
		movsd   xmm2, qword [esp + 8]
		movsd   qword [ecx + eax * 8], xmm2
		sub     ebx, 1
		cmp     bl, -1
		jne     .handle_comma_next_operator
	.comma_outside_brackets:
		sub     esp, 8
		push    dword [esp + 8]
		push    format_error_comma_outside_bracket
		call    _printf
		add     esp, 16
		mov     eax, 1
		jmp     .return

	.comma_bracket_found:
		mov     eax, dword [esp + 12]
		add     eax, 1
		mov     byte [esp + 52], al
		movsd   xmm5, qword [esp + 48]
		movsd   qword [esp + 56 + edx * 8], xmm5
		add     dword [esp], 1 ; input index
		mov     eax, edi
		mov     byte [esp + 29], al ; previousWasValue
		jmp     .main_loop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.right_side_operators:
		cmp     byte [esp + 8], 45
		jne     .try_finding_functions_or_constants

	.right_side_operator_negation:
		mov     dword [esp + 2136], op_def_neg
		mov     byte [esp + 2140], 1
		mov     byte [esp + 2141], 0
		mov     word [esp + 2142], 32762
		add     ebx, 1
		movzx   eax, bl
		movsd   xmm7, qword [esp + 2136]
		movsd   qword [esp + 56 + eax * 8], xmm7
		add     dword [esp], 1 ; input index
		jmp     .main_loop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.operator_not_found:
	.try_finding_functions_or_constants:
		mov     edi, 0 ; fi
		movzx   eax, byte [esp + 8]
		mov     byte [esp + 30], al ; save input[i]
		mov     dword [esp + 24], esi ; save esi
		mov     esi, ebx ; save ebx
	.next_possible_function_name:
		mov     ebp, edi
		sal     ebp, 4
		movzx   eax, byte dynamic_defs[ebp]
		test    al, al
		je      .function_name_loop
		movzx   ebx, byte [esp + 30]
		mov     dword [esp + 20], 0 ; ini
	.compare_names_char:
		;movsx   eax, al
		sub     esp, 12
		push    eax
		call    _tolower
		mov     dword [esp + 32], eax
		;movsx   ebx, bl
		mov     dword [esp], ebx
		call    _tolower
		add     esp, 16
		cmp     dword [esp + 16], eax
		je      .next_function_name_char
	.next_function_def:
		add     edi, 1 ; fni += 1
		cmp     edi, dynamic_defs_count
		jne     .next_possible_function_name
	.handle_possible_variable:
		mov     ebx, esi ; restore ebx
		mov     esi, dword [esp + 24] ; restore esi
		mov     edi, dword [esp] ; input index
		mov     eax, edi
		mov     byte [esp + 16], al ; save possible variable start index
		mov     edi, ebx
		mov     ebx, eax
	.next_variable_name_char:
		movzx   ebp, bl
		sub     esp, 12
		mov     eax, dword [esp + 2224]
		movsx   eax, byte [eax + ebp]
		push    eax
		call    is_char_allowed_in_name
		add     esp, 16
		test    al, al
		je      .variable_no_more_chars
		add     ebx, 1 ; j += 1
		movzx   eax, bl
		mov     ecx, dword [esp] ; input index
		sub     eax, ecx
		cmp     eax, 6
		jbe     .next_variable_name_char
		sub     esp, 4
		push    esi
		push    dword [esp + 8]
		push    format_error_var_name_too_long
		call    _printf
		add     esp, 16
		mov     eax, 1
		jmp     .return

	.function_name_loop:
		movzx   ebx, byte [esp + 8]
		mov     dword [esp + 20], 0 ; ini
	.function_name_end:
		sub     esp, 12
		movsx   ebx, bl
		push    ebx
		call    is_char_allowed_in_name
		add     esp, 16
		test    al, al
		jne     .next_function_def
		; found match!
		mov     ebx, esi
		sal     edi, 4
		lea     eax, dynamic_defs[edi]
		cmp     byte [esp + 29], 0 ; previousWasValue
		je      .function_found_after_conditional_multiply
		mov     dword [esp + 2144], op_def_multiply
		mov     byte [esp + 2148], 2
		mov     byte [esp + 2149], 0
		mov     word [esp + 2150], 32762
		add     ebx, 1
		movzx   ecx, bl
		movsd   xmm3, qword [esp + 2144]
		movsd   qword [esp + 56 + ecx * 8], xmm3
	.function_found_after_conditional_multiply:
		mov     dword [esp + 2152], eax
		mov     byte [esp + 2156], 0
		mov     byte [esp + 2157], 0
		mov     word [esp + 2158], 32762
		add     ebx, 1
		movzx   eax, bl
		movsd   xmm6, qword [esp + 2152]
		movsd   qword [esp + 56 + eax * 8], xmm6
		movzx   eax, byte [esp + 20] ; ini
		add     dword [esp], eax ; input index
		mov     byte [esp + 29], 1 ; previousWasValue
		jmp     .main_loop

	.next_function_name_char:
		add     dword [esp + 20], 1 ; ini
		mov     eax, dword [esp + 20] ; ini
		mov     ebx, dword [esp + 24]
		movzx   ebx, byte [ebx + eax]
		movzx   eax, byte dynamic_defs[ebp + eax]
		test    al, al
		jne     .compare_names_char
		jmp     .function_name_end

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.variable_no_more_chars:
		mov     eax, ebx
		mov     ebx, edi
		mov     edi, eax
		cmp     dword [esp], ebp ; input index (i < j)
		jb      .variable_name_captured
		movzx   ebp, byte [esp + 8]
		mov     eax, ebp
		cmp     al, 13
		ja      .unknown_token
		mov     eax, 9217
		bt      eax, ebp
		jc      .end_of_input
	.unknown_token:
		mov     eax, ebp
		movsx   eax, al
		push    eax
		push    eax
		push    dword [esp + 8]
		push    format_error_unknown_token
		call    _printf
		add     esp, 16
		mov     eax, 1
		jmp     .return

	.variable_name_captured:
		cmp     byte [esp + 29], 0 ; previousWasValue
		je      .variable_name_captured_after_conditional_multiply
		mov     dword [esp + 2160], op_def_multiply
		mov     byte [esp + 2164], 2
		mov     byte [esp + 2165], 0
		mov     word [esp + 2166], 32762
		add     ebx, 1
		movzx   eax, bl
		movsd   xmm6, qword [esp + 2160]
		movsd   qword [esp + 56 + eax * 8], xmm6
	.variable_name_captured_after_conditional_multiply:
		mov     eax, edi ; j
		sub     al, byte [esp + 16] ; length = j - possible variable start index
		mov     edx, 0
	.put_next_variable_name_char:
		movzx   ecx, byte [esi + edx]
		mov     byte [esp + 2168 + edx], cl
		add     edx, 1
		cmp     dl, al
		jb      .put_next_variable_name_char
		test    al, al
		mov     edx, 1
		cmove   eax, edx
		cmp     al, 5
		ja      .variable_name_completed
		movzx   edx, al
		lea     ecx, [esp + 2168 + edx]
		lea     esi, [esp + 2169 + edx]
		mov     edx, 5
		sub     edx, eax
		movzx   edx, dl
		add     esi, edx
	.fill_next_variable_name_char_zero:
		mov     byte [ecx], 0
		add     ecx, 1
		cmp     ecx, esi
		jne     .fill_next_variable_name_char_zero
	.variable_name_completed:
		mov     word [esp + 2174], 32761
		mov     eax, dword [esp + 2208]
		movzx   eax, byte [eax + 2040]
		add     eax, 1
		mov     edi, dword [esp + 2208]
		mov     byte [edi + 2040], al
		movzx   eax, al
		movsd   xmm5, qword [esp + 2168]
		movsd   qword [edi + eax * 8], xmm5
		mov     dword [esp], ebp ; input index
		mov     byte [esp + 29], 1 ; previousWasValue
		jmp     .main_loop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.end_of_input:
		cmp     bl, -1
		je      .return_zero
		mov     edx, ebx
		mov     ecx, dword [esp + 2208]
	.moving_remaining_operators:
		movzx   eax, dl
		fld     qword [esp + 56 + eax * 8]
		fstp    qword [esp]
		mov     eax, dword [esp + 4]
		shr     eax, 16
		cmp     ax, 32763
		je      .unmatched_bracket_begin
		movzx   eax, byte [ecx + 2040]
		add     eax, 1
		mov     byte [ecx + 2040], al
		movzx   eax, al
		movsd   xmm6, qword [esp]
		movsd   qword [ecx + eax * 8], xmm6
		sub     edx, 1
		cmp     dl, -1
		jne     .moving_remaining_operators
	.return_zero:
		mov     eax, 0
		jmp     .return
	.return:
		add     esp, 2188
		pop     ebx
		pop     esi
		pop     edi
		pop     ebp
		ret

	.unmatched_bracket_begin:
		sub     esp, 8
		mov     eax, dword [esp + 8]
		push    eax
		push    format_error_unmatched_bracket_begin
		call    _printf
		add     esp, 16
		mov     eax, 1
		jmp     .return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Executing RPN

execute_rpn:
		push    edi
		push    esi
		push    ebx
		sub     esp, 2064 ; 2048 + 16
		mov     ebx, dword [esp + 2080]
		lea     eax, [esp + 16]
		lea     edx, [esp + 2056]
	
	.initializing_f64_stack_for_execution:
		fldz
		fstp    qword [eax]
		add     eax, 8
		cmp     eax, edx
		jne     .initializing_f64_stack_for_execution
		mov     byte [esp + 2056], -1

		mov     esi, 0
		lea     edi, [esp + 16]
		jmp     .start

	.push_value:
		movzx   eax, byte [esp + 2056]
		add     eax, 1
		mov     byte [esp + 2056], al
		movzx   eax, al
		movsd   xmm0, qword [esp + 8]
		movsd   qword [esp + 16 + eax * 8], xmm0
	.next:
		add     esi, 1
		mov     eax, esi
		cmp     byte [ebx + 2040], al
		jb      .return
	.start:
		mov     eax, esi
		movzx   eax, al
		fld     qword [ebx + eax * 8]
		fstp    qword [esp + 8]
		mov     eax, dword [esp + 12]
		shr     eax, 16
		cmp     ax, 32762
		jne     .push_value
		; or execute function
		sub     esp, 8
		mov     edx, dword [esp + 16]
		mov     eax, dword [esp + 20]
		movzx   eax, al
		push    eax
		push    edi
		call    dword [edx + 12]
		add     esp, 16
		jmp     .next
	.return:
		movzx   eax, byte [esp + 2056]
		fld     qword [esp + 16 + eax * 8]
		add     esp, 2064
		pop     ebx
		pop     esi
		pop     edi
		ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Printing RPN

print_rpn:
		push    edi
		push    esi
		push    ebx
		sub     esp, 32
		mov     esi, dword [esp + 48]
		mov     ebx, 0
		lea     edi, [esp + 24]
		jmp     .start

	.print_as_function_or_constant:
		mov     eax, dword [esp + 8]
		cmp     byte [eax + 10], 0
		js      .print_as_function
		sub     esp, 8
		push    eax
		push    format_rpn_constant
		call    _printf
		add     esp, 16
		jmp     .next

	.print_as_function:
		sub     esp, 4
		mov     edx, dword [esp + 16]
		movzx   edx, dl
		push    edx
		push    eax
		push    format_rpn_function
		call    _printf
		add     esp, 16
		jmp     .next

	.print_as_variable:
		sub     esp, 8
		push    edi
		push    format_rpn_variable
		call    _printf
		add     esp, 16
	.next:
		add     ebx, 1
		cmp     byte [esi + 2040], bl
		jb      .return
	.start:
		movzx   eax, bl
		fld     qword [esi + eax * 8]
		fstp    qword [esp + 8]
		movsd   xmm0, qword [esp + 8]
		movsd   qword [esp + 24], xmm0
		mov     eax, dword [esp + 12]
		shr     eax, 16
		cmp     ax, 32762
		je      .print_as_function_or_constant
		cmp     ax, 32761
		je      .print_as_variable
	.print_as_number:
		sub     esp, 4
		push    dword [esp + 16]
		push    dword [esp + 16]
		push    format_rpn_value
		call    _printf
		add     esp, 16
		jmp     .next

	.return:
		add     esp, 32
		pop     ebx
		pop     esi
		pop     edi
		ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main

_main:
		; prepare frame (remember clean)
		lea     ecx, [esp + 4]
		and     esp, -16
		push    dword [ecx - 4]
		push    ebp
		mov     ebp, esp
		push    edi
		push    esi
		push    ebx
		push    ecx

		; prepaare stdin FILE pointer
		push    dword 0
		call    ___acrt_iob_func
		add     esp, 4
		mov     [stdin], eax

		; prepare frame (local vars)
		sub     esp, 4168
		lea     eax, [ebp - 2072]
		lea     edx, [ebp - 32]

		; initialize FPU and f64_stack for RPN
		finit
	.initializing_f64_stack:
		fldz
		fstp    qword [eax]
		add     eax, 8
		cmp     edx, eax
		jne     .initializing_f64_stack
		mov     byte [ebp - 32], -1

		push    format_ask_expression
		call    _printf

		push    dword [stdin]
		push    256
		lea     ebx, [ebp - 4120]
		push    ebx
		call    _fgets
		add     esp, 8

		push    ebx
		lea     eax, [ebp - 2072]
		push    eax
		call    parse_to_rpn
		mov     esi, eax
		add     esp, 16
		test    eax, eax
		je      .parsed_successfully

	.return:
		; exit gracefully
		mov     eax, esi
		lea     esp, [ebp - 16]
		pop     ecx
		pop     ebx
		pop     esi
		pop     edi
		pop     ebp
		lea     esp, [ecx - 4]
		ret

	.parsed_successfully:
		; print RPN
		sub     esp, 12
		push    format_print_rpn
		call    _printf
		lea     eax, [ebp - 2072]
		mov     dword [esp], eax
		call    print_rpn
		mov     dword [esp], 10
		call    _putchar
		movzx   edi, byte [ebp - 32]
		add     esp, 16
		mov     eax, 0
		mov     ecx, edi

	.checking_for_variables:
		movzx   edx, al
		cmp     word [ebp - 2066 + edx * 8], 32761
		je      .has_variables
		add     eax, 1
		cmp     cl, al
		jnb     .checking_for_variables

		; if no variables, execute once and exit
		sub     esp, 12
		lea     eax, [ebp - 2072]
		push    eax
		call    execute_rpn
		fld     st0
		fabs    
		fld     qword [constant_near_zero_epsilon]
		fcomip  st0, st1
		fstp    st0
		jbe     .print_result_once_non_zero
		; or print as zero, if near enough
		fstp    st0
		fldz
	.print_result_once_non_zero:
		fstp    qword [esp + 4]
		mov     dword [esp], format_print_result
		call    _printf
		add     esp, 16
		jmp     .return

	.has_variables:
		mov     edi, ecx
		mov     dword [ebp - 4184], esi
		jmp     .initialize_live_f64_stack

	.next_live_rpn_index:
		add     ebx, 1
		mov     eax, edi
		cmp     al, bl
		jb      .next_variable
	.start_replacing_variables_with_values:
		movzx   ecx, bl
		mov     eax, esi
		mov     edx, dword [ebp - 4176]
		xor     eax, dword [ebp - 4120 + ecx * 8]
		xor     edx, dword [ebp - 4116 + ecx * 8]
		or      eax, edx
		jne     .next_live_rpn_index
		fst     qword [ebp - 4120 + ecx * 8]
		jmp     .next_live_rpn_index

	.next_variable:
		fstp    st0
		movzx   ebx, byte [ebp - 4177]
	.loop_filling_variables:
		add     ebx, 1
		mov     eax, edi
		cmp     al, bl
		jb      .all_variables_filled
	.start_filliing_variables:
		movzx   eax, bl
		fld     qword [ebp - 4120 + eax * 8]
		fstp    qword [ebp - 4176]
		movsd   xmm1, qword [ebp - 4176]
		movsd   qword [ebp - 4148], xmm1
		mov     eax, dword [ebp - 4172]
		shr     eax, 16
		cmp     ax, 32761
		jne     .loop_filling_variables
		sub     esp, 8

		lea     eax, [ebp - 4148]
		push    eax
		push    format_ask_variable_value
		call    _printf
		add     esp, 12
		
		push    dword [stdin]
		push    20
		lea     eax, [ebp - 4140]
		push    eax
		call    _fgets
		add     esp, 16
		test    eax, eax
		je      .no_more_input_so_about_to_exit
		sub     esp, 4
		lea     eax, [ebp - 4160]
		push    eax
		push    format_lf
		lea     eax, [ebp - 4140]
		push    eax
		call    _sscanf
		add     esp, 16
		test    eax, eax
		jle     .no_more_input_so_about_to_exit
		mov     eax, edi
		cmp     al, bl
		jb      .loop_filling_variables
		mov     eax, dword [ebp - 4148]
		mov     esi, dword [ebp - 4144]
		mov     dword [ebp - 4176], esi
		fld     qword [ebp - 4160]
		mov     byte [ebp - 4177], bl
		mov     esi, eax
		jmp     .start_replacing_variables_with_values

	.no_more_input_so_about_to_exit:
		mov     esi, dword [ebp - 4184]
		sub     esp, 12
		push    format_continuous_mode_end
		call    _puts
		add     esp, 16
		jmp     .return

	.all_variables_filled:
		sub     esp, 12
		lea     eax, [ebp - 4120]
		push    eax
		call    execute_rpn
		fld     st0
		fabs    
		fld     qword [constant_near_zero_epsilon]
		fcomip  st0, st1
		fstp    st0
		jbe     .print_result_continous_non_zero
		; or print as zero, if near enough
		fstp    st0
		fldz
	.print_result_continous_non_zero:
		fstp    qword [esp + 4]
		mov     dword [esp], format_print_result
		call    _printf
		add     esp, 16
	.initialize_live_f64_stack:
		mov     eax, 0
	.initializing_live_64_stack:
		; copying the original parsed RPN
		movsd   xmm0, qword [ebp - 2072 + eax]
		movsd   qword [ebp - 4120 + eax], xmm0
		add     eax, 8
		cmp     eax, 2040
		jne     .initializing_live_64_stack
		mov     eax, edi
		mov     byte [ebp - 2080], al
		sub     esp, 12
		push    10
		call    _putchar
		add     esp, 16
		mov     esi, 0
		mov     ebx, esi
		jmp     .start_filliing_variables


