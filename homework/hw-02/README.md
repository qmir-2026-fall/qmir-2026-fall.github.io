# Homework 02
## Practicing the Reproducible Workflow

> **A note on AI tools:** Yes, ChatGPT, Claude, and similar tools can solve every exercise in this homework in seconds. Please don't let them. The point of this assignment is not the output -- it is the practice. Use AI the smart way: to understand what a function does, to explain an error message, or to check your reasoning. Don't use it to generate answers you then copy in. That helps no one, least of all you.

### Goal

Practice the complete workflow independently:

> Clone → Edit → Render → Stage → Commit → Push

This assignment is about learning the **process**, not producing sophisticated analysis.

---

## 🔁 Important: Git + Render Workflow Throughout the Assignment

You should practice both **version control** *and* **rendering** continuously while working.

### Render frequently

- Render your document whenever you make changes.
- Check whether:
  - The document compiles without errors.
  - The output looks as expected.
  - Code results update correctly.
- Treat rendering as a way to **test your analysis**.

Do **not** wait until the end to render.

---

### Version Control Requirements

- Do **not** complete everything and commit once at the end.
- Commit regularly as you make progress.
- Write short, informative commit messages.

You must make **at least three commits** with meaningful messages, for example:

1. Added YAML metadata  
2. Added markdown text  
3. Added code and figure  
4. Minor revision / formatting improvement  

(Three is the minimum -- more is fine.)

---

# Exercise 1: Clone and Open the Project

1. Clone this repository to your computer.
2. Open the folder in **Positron**.
3. Confirm:
   - The file `hw02.qmd` is present.
   - Git is active (you can see changes in the Source Control panel).

✔️ When finished: You have the project open locally and Git is tracking changes.

---

# Exercise 2: Add Metadata (YAML)

Edit the YAML header of `hw02.qmd`.

Your YAML should include:

- An output format (`pdf`)
- A title  
- Your name  
- A date    
- A table of contents

Keep it simple.

🔁 Render after editing the YAML to confirm it works.  
💡 Commit after completing this step.

---

# Exercise 3: Writing in Markdown

Write one short paragraph, in your own words, explaining:

- What is Quarto?  
- What is Git?  
- What is GitHub?  

Include some basic markdown formatting (e.g., bold text, italics, or a list).

🔁 Render to see how your markdown appears in the output.  
💡 Commit after completing this step.

# Exercise 4: Advanced Quarto

Enhance your document by adding an image and a table.

1. Include an image in your document.
2. Add an informative caption to the image.
3. Write one sentence in your text that refers to the image using a cross-reference.
4. Add a table of your choice.
5. Give the table an informative caption and refer to it in your text using a cross-reference.

🔁 Render your document to check that the image, table, captions, and cross-references appear correctly.

💡 Commit after completing this step.

# Exercise 5: Reflection

At the end of your document, add a section titled:

## Reflection

Briefly answer:

> What did you find confusing or difficult while working with Quarto, Git/GitHub, or Positron? Was there anything about the workflow that you are still unsure about?

Be honest -- this helps improve the course.

🔁 Render one final time to confirm everything compiles cleanly.  
💡 Make a final commit.

---

# Final Step: Push to GitHub

Push all commits to GitHub before the deadline.

Your repository must contain:

- `hw02.qmd`
- The rendered file (`.pdf`)
- At least three commits visible in the commit history

---

## Submission

No separate submission is required.

Your work is considered submitted if:

- All commits are pushed to GitHub  
- The repository is updated before the deadline 


## Feedback policy

> **A sample solution will be published after the due date and will be available to everyone, regardless of whether you opt in to AI feedback.**
> **Optional AI feedback:** If you would like to receive automated AI feedback on your submission, you can voluntarily opt in by adding a file named `license.md` to your repository. The file must contain the MIT License text provided below.
> If `license.md` is present, your submission may be processed by an AI system, which will compare your work with the sample solution and add a `FEEDBACK.pdf` to your repository.

> **This is completely optional.** If you do not add `license.md`, your submission will not be processed for AI feedback. You will still have access to the sample solution after the due date.

### `license.md`

To opt in to AI feedback, create a file named `license.md` in the root of your repository and add the following text:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.