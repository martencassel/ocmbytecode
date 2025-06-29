
The document refers to **positions on the stack from the top** in two main ways:

---

### 1. **In Syntax (Instruction Descriptions)**

- **"Top of stack"** or **"at top of stack"** always means the value at the very top (the most recently pushed value).
- **"Next to top"** means the value just below the top.
- **"Second to top"**, **"third to top"**, etc., refer to values further down, counting from the top.

**Examples from the document:**

- **Opcode 0x05 (dup):**
  > stack input: one value of any type
  *(operates on the top of stack)*

- **Opcode 0x09 (exch):**
  > effect: exchanges top of stack with next-to-top-of-stack

- **Opcode 0x0A (index):**
  > effect: pushes a copy of the next-to-top value.

- **Opcode 0x47 (index.1):**
  > effect: pushes a copy of the second-to-top (the third value if you call top-of-stack the first one) to the standard stack.

---

### 2. **In Text (Explanatory Notes)**

- The document sometimes clarifies with phrases like:
  > "the third value if you call top-of-stack the first one"
- Or uses **"n-th operand below the input operand"** for more general stack indexing.

---

### 3. **General Pattern**

- **Top of stack** = stack[-1] (last pushed)
- **Next to top** = stack[-2]
- **Third to top** = stack[-3]
- etc.

---

### 4. **Summary Table**

| Phrase in Document         | Stack Index (from top) | Example Syntax/Usage                |
|---------------------------|------------------------|-------------------------------------|
| top of stack              | 0                      | "at top of stack"                   |
| next to top               | 1                      | "next-to-top-of-stack"              |
| second to top             | 2                      | "second-to-top (the third value...)"|
| n-th to top               | n                      | "n-th operand below the input"      |

---

**In summary:**
The document uses phrases like "top of stack", "next to top", "second to top", and "n-th to top" to refer to stack positions, always counting from the top (most recent) downward. In syntax, this is reflected in both the stack input/output descriptions and explanatory text.

--


Yes, there are other common ways to refer to stack positions, especially in programming and documentation:

---

### 1. **Negative Integer Indexing**

- Many languages (like Python) use negative indices to refer to stack positions from the top:
  - `stack[-1]` = top of stack
  - `stack[-2]` = next to top
  - `stack[-n]` = n-th to top

This is concise and unambiguous, especially in pseudocode or when describing stack operations programmatically.

---

### 2. **Slice Notation**

- You can use slice notation to describe a range of stack elements:
  - `stack[-3:]` = top 3 elements (from third-to-top up to top)
  - `stack[-n:]` = top n elements
  - `stack[m:n]` = elements from position m to n (if using 0-based indexing from the bottom)

This is useful for describing stack effects of instructions that operate on multiple elements at once.

---

### 3. **Explicit Stack Diagrams**

- Some documentation uses diagrams or lists to show the stack before and after an operation, labeling each position.

---

### 4. **Summary Table**

| Notation         | Meaning                  | Example         |
|------------------|-------------------------|-----------------|
| `stack[-1]`      | Top of stack            | `stack[-1]`     |
| `stack[-2]`      | Next to top             | `stack[-2]`     |
| `stack[-n]`      | n-th to top             | `stack[-3]`     |
| `stack[-3:]`     | Top 3 elements (slice)  | `stack[-3:]`    |

---

**In summary:**
Negative integer indexing and slice notation are widely used, especially in code and technical writing, to refer to stack positions and ranges from the top. This complements the natural language descriptions found in your document.
