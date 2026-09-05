# Homework 03
## Practicing the Reproducible Workflow

> **A note on AI tools:** Yes, ChatGPT, Claude, and similar tools can solve every exercise in this homework in seconds. Please don't let them. The point of this assignment is not the output — it is the practice. Use AI the smart way: to understand what a function does, to explain an error message, or to check your reasoning. Don't use it to generate answers you then copy in. That helps no one, least of all you.

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

(Three is the minimum — more is fine.)

---

# Exercise 1 – Clone and Open the Project

1. Clone this repository to your computer.
2. Open the folder in **Positron**.
3. Confirm:
   - The file `hw02.qmd` is present.
   - Git is active (you can see changes in the Source Control panel).

✔️ When finished: You have the project open locally and Git is tracking changes.

---

# Exercise 2 – Add Metadata (YAML)

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

# Exercise 3 – Writing in Markdown

Write one short paragraph, in your own words, explaining:

- What is Quarto?  
- What is R?  
- What is Git?  
- What is GitHub?  

Include some basic markdown formatting (e.g., bold text, italics, or a list).

🔁 Render to see how your markdown appears in the output.  
💡 Commit after completing this step.

---

# Exercise 4 — Practicing R: Data Types, Structures, and Subsetting

This exercise gives you hands-on practice with the core concepts from Week 3. Add a clearly labeled section to your `hw02.qmd` for each sub-task below. Write **at least one sentence of prose** below each code cell explaining what you did and what the output shows — this is the literate programming habit we are building.

---

## 4.1 — Vectors and Data Types

Create three vectors of **different types** that relate to a political science topic of your choice (e.g., countries, election results, party membership). Your vectors should include at least one `character`, one `numeric`, and one `logical` vector.

For each vector:
- Print it
- Check its type using `class()`

Then: try mixing types in a single vector and report in prose what happens and why.

🔁 Render after completing this section.

---

## 4.2 — Building a Data Frame

Using your vectors from 4.1 (or new ones), build a small **data frame** with at least 4 rows and 3 columns.

Then:
- Check the number of rows and columns using `nrow()` and `ncol()`
- Inspect the structure using `str()`
- Print the first few rows using `head()`

🔁 Render to check output.

---

## 4.3 — Accessing and Subsetting Data

Using the data frame you created:

1. Extract a single column using `$`
2. Access one specific cell using `[row, column]` notation
3. Filter rows using a logical condition (e.g., return only rows where population exceeds a threshold, or where a country is an EU member)

🔁 Render after completing this section.  
💡 Commit after completing Exercise 4.

---

# Exercise 5 — Reflection

At the end of your document, add a section titled:

## Reflection

Briefly answer:

> What did you find confusing or difficult — either about the reproducible workflow or about working with R data types and structures?

Be honest — this helps improve the course.

🔁 Render one final time to confirm everything compiles cleanly.  
💡 Make a final commit.

---

# Final Step – Push to GitHub

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

> **A sample solution is published for this homework after the due date. Individual feedback is
> NOT provided by default.** The only individual feedback available is **optional AI feedback**:
> add an open-source `license.md` to this repo to opt in, and an AI will read your submission
> alongside the sample solution and write a `FEEDBACK.pdf` back into your repo. No `license.md`,
> no processing.
