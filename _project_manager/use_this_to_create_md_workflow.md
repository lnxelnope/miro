Act as a **Senior Technical Architect**. I want you to create a detailed **Implementation Plan** (Markdown file) for the task: "[ชื่อ Task/Feature]".

Your goal is to guide a Junior Developer. The output must be **Visual, Educational, and Implementation-Ready**.

Structure:

1.  **System Visualization:**
    *   Create an **ASCII Art Diagram** showing the UI Layout or System Flow.
    *   Explain the concept simply.

2.  **File Structure:** List all files to be Created or Edited.

3.  **Step-by-Step Implementation:**
    *   **Rule:** Break down complex UI into smaller components (e.g., separate ListItem from List).
    *   For EACH step, format as:
        *   **Step X:** [Clear Title]
        *   **File:** `path/to/file`
        *   **Action:** CREATE / EDIT
        *   **Explanation:** One sentence explaining *why* we are doing this.
        *   **Code:** Provide *COMPLETE* code with helpful comments for complex logic.

4.  **Order of Operations:**
    *   Types/Interfaces (Define the data structure first)
    *   Library/Helper Functions (Business logic & calculations)
    *   Small UI Components (Badges, Items)
    *   Main Containers/Modals (Assemble the pieces)
    *   Screens/Pages (Final integration)

5.  **Quality Checklist:**
    *   Handle Edge Cases (Loading, Empty states, Errors).
    *   Use explicit types.
    *   Verify User Experience (UX).