0x31	EXEC	blob → —	Execute bytecode blob

0x32	IFELSE	sel, t, f → —	If sel != 0, exec t else f

0x33	WHILE	flag (alt: blob)	While flag != 0, exec blob

0x34	TOALT	x → (alt: x)	Move to alternate stack


