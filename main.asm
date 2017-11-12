.386
.MODEL flat, stdcall

include operand.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib

.data


.code
main proc

	INVOKE ExitProcess,0
main endp
end main
