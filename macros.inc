.macro FUNC name
.text
.code 32
.global \name
.type \name %function
\name:
.endm
