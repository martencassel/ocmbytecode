# Example: Nested Program Blocks

```c
if (cond) {
    // block1
} else {
    // block2
}
```

**In bytecode:**
```
[cond]
[block1_blob]
[block2_blob]
IFELSE
```

---

## Example: Loops

```c
while (cond) {
    // body
}
```

**In bytecode:**
```
[cond_blob]         ; Evaluates the loop condition
[body_blob]         ; Contains loop body
WHILE
```

---

## Example: Recursion

```c
function fact(n) {
    if (n <= 1) return 1;
    else return n * fact(n - 1);
}
```

**In bytecode:**

```ocm
fact_blob = {
    PUSH 1         ; Push constant 1
    CMP.LT         ; Compare n < 1 (assumes n is on stack)
    IFELSE {
        PUSH 1     ; True branch: base case, push 1
    } {
        DUP        ; False branch: duplicate n
        PUSH 1
        SUB        ; Compute n - 1
        fact_blob
        EXEC       ; Recursive call: fact(n-1)
        MUL        ; Multiply n * fact(n-1)
    }
}

; To call factorial:
PUSH n
fact_blob
EXEC
```

### Example Trace for `fact(3)`

Let's walk through the execution step by step:

1. **Call:**
   `[3] [if_blob] EXEC`
   - Stack: `[3]`
   - `if_blob` is executed with `n = 3`.

2. **Evaluate Base Case:**
   - `PUSH 1` → Stack: `[3, 1]`
   - `CMP.LT` → Stack: `[0]` (since `3 < 1` is false)
   - `IFELSE` chooses the false branch (`[n, n-1, fact_blob, MUL]`).

3. **False Branch Execution:**
   - Push `3` (already on stack), push `2` (`3-1`), push `fact_blob`, then `EXEC`.
   - `[3, 2, fact_blob, MUL]`
   - Call: `[2] [if_blob] EXEC`

4. **Repeat for `n = 2`:**
   - `2 < 1`? No → execute `[2, 1, fact_blob, MUL]`
   - Call: `[1] [if_blob] EXEC`

5. **Repeat for `n = 1`:**
   - `1 < 1`? No → execute `[1, 0, fact_blob, MUL]`
   - Call: `[0] [if_blob] EXEC`

6. **Base Case for `n = 0`:**
   - `0 < 1`? Yes → execute `PUSH1` → Stack: `[1]`

7. **Unwinding the Recursion:**
   - Return: `[1]`
   - Multiply: `1 * 1 = 1`
   - Return: `[1]`
   - Multiply: `2 * 1 = 2`
   - Return: `[2]`
   - Multiply: `3 * 2 = 6`
   - Return: `[6]`

**Result:**
The final result on the stack is `6`, which is `fact(3)`.

---

**This step-by-step symbolic execution demonstrates that the OCM bytecode correctly implements the recursive factorial function.**


---

## Passing Code as Data (callbacks)

```c
function applyTwice(f, x) {
    return f(f(x));
}
```

**In bytecode:**
```
[f_blob] [x]
DUP
EXEC ; f(x)
EXEC ; f(f(x))
```

---

## Conditional Assignment

```c
x = cond ? a : b;
```

**In bytecode:**
```
[cond]
[a_blob]
[b_blob]
IFELSE
; result on stack, assign to x as needed
```

---

## 5. Dynamic Code Generation

You can construct blobs (program blocks) at runtime, store them in variables or arrays, and execute them later. This enables metaprogramming, dynamic behavior, or even simple interpreters.

### High-level example:
```c
// Create a code block that adds 10 to its input, then execute it
var add10 = makeAdder(10);
add10(5); // returns 15

function makeAdder(n) {
    return function(x) {
        return x + n;
    };
}
```

### OCM Bytecode style (pseudo):

```
; Construct a blob that adds n to its input x
[n]                ; Push n (could be dynamic)
[ADD_BLOB]         ; Blob: [x] [n] ADD
STORE              ; Store in variable (e.g., add_n_blob)

; Later, to use the blob:
[x]                ; Push argument
[add_n_blob]       ; Push the dynamically created blob
EXEC               ; Execute: computes x + n

; Example construction of ADD_BLOB at runtime:
; Suppose n is on the stack, we build a blob that does:
;   [x] [n] ADD
; This can be achieved by assembling the bytecode for [PUSH_ARG] [PUSH_N] ADD
```

### Use case: Generating a sequence of operations

Suppose you want to build a pipeline of operations at runtime:

```
; Build an array of blobs
[blob1] [blob2] [blob3] 3 ARRAY

; For each blob in the array, execute with input x
[x]
[blobs_array]
LENGTH.ARR         ; Get number of blobs
ALOAD.LENGTH       ; Unpack blobs
; For each blob:
EXEC               ; Apply blob to x, can be done in a loop
```

---

**Summary:**
Dynamic code generation in OCM means you can build, store, and execute new program blocks at runtime, enabling flexible and powerful programming patterns.

---

## Example: Exported Procedures and External Loader Call

You can implement an export mechanism in OCM bytecode to allow an external loader to call one of several exported procedures by index.

### High-level example:

```c
export function main(x) {
    return fact(x);
}

export function add(a, b) {
    return a + b;
}
```

### OCM Bytecode Implementation

```
[main_blob]         ; Push the main procedure blob
[add_blob]          ; Push the add procedure blob
2 ARRAY             ; Create an array of exported procedures: [main_blob, add_blob]

; The loader pushes the index of the procedure to call, followed by any arguments.
; For example, to call add(2, 3):
PUSH 1              ; Index 1 for 'add'
PUSH 2
PUSH 3

; Now call the export dispatcher:
[exports_array]     ; Push the array of exported procedures
EXCH                ; Swap to get [exports_array] [index]
GET                 ; Get the procedure blob at the given index
EXEC                ; Execute the selected procedure blob
```

**How it works:**
- The exported procedures are packed into an array in a known order.
- The loader pushes the index and arguments, then the array, and the dispatcher selects and executes the correct procedure.
- The result is left on the stack.

---

**This pattern enables modular OCM programs to be called from external code, supporting multiple entry points.**
