To support C code interoperating with your high-level language (HLL) in OCM, you need to define a **calling convention** and a **type mapping** between the HLL and C. Here’s how you can approach this:

---

## 1. **Stack-Based Calling Convention**

- **Arguments:**
  The HLL compiler pushes arguments onto the OCM stack (in a defined order, e.g., right-to-left).
- **C Function:**
  The C function is compiled to expect arguments on the stack (or receives a pointer to the stack).
- **Return Value:**
  The C function pushes its result back onto the stack.

**Example:**
- HLL: `fastmul(2, 3);`
- OCM stack before call: `[2, 3, fastmul_handle]`
- OCM: `CALLNATMOD`
- C function pops `a` and `b` from the stack, computes, pushes result.

---

## 2. **Type Mapping**

- **Simple types** (int, float, etc.): Map directly to OCM stack values (smallint, bigint, etc.).
- **Complex types** (arrays, blobs): Pass as pointers/handles, which C code can interpret using OCM’s data structures.
- **Return types:** C code must return values in a format the HLL expects (e.g., push a smallint for integer results).

---

## 3. **Glue Code / Wrapper Functions**

- The compiler can generate C wrapper functions that:
  - Unpack OCM stack arguments into C variables.
  - Call the user’s C code.
  - Pack the result back onto the OCM stack.
- This ensures type safety and correct stack discipline.

**Example wrapper:**
```c
int fastmul_ocm(stack_t *stack) {
    int b = stack_pop(stack);
    int a = stack_pop(stack);
    int result = a * b;
    stack_push(stack, result);
    return 0;
}
```

---

## 4. **Type Declarations in HLL**

Allow the HLL to declare argument and return types for inline C functions, e.g.:
```c
inline_c function fastmul(int a, int b) -> int { ... }
```
This helps the compiler generate correct wrappers and type conversions.

---

## 5. **Error Handling**

- C code should signal errors in a way the HLL can handle (e.g., by pushing an error code or raising an exception blob).

---

## 6. **Documentation and ABI**

- Clearly document the ABI (Application Binary Interface) for native modules: argument order, type encoding, stack usage, ownership of handles, etc.

---

**Summary:**
- Define a stack-based calling convention and type mapping.
- Generate glue code to marshal data between HLL and C.
- Use explicit type annotations for safety.
- Ensure C code interacts with the OCM stack and types as expected.

This approach enables robust, safe, and efficient interop between C and your high-level language in OCM.
