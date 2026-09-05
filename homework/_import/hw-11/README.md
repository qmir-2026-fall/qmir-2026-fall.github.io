# Homework Week 11 — Brexit, Identity, and the Binary Vote

## Introduction

This assignment analyses individual-level vote choices in the 2016 UK Brexit referendum using the Hobolt (2016) survey dataset.
The outcome variable, `LeaveVote`, is binary: respondents either voted Leave (1) or Remain (0).
You will fit two Bayesian probit models to examine how British national identity is associated with the probability of voting Leave, and whether this association differs by gender.
Your task is to carry out the full eight-step Bayesian workflow — from specifying the model to critically evaluating your conclusions.

---

## Dataset

**Hobolt, S. B. (2016). Brexit survey data.**

| Variable | Description | Scale |
|---|---|---|
| `LeaveVote` | Voted in favour of Brexit | 1 = Leave; 0 = Remain |
| `edlevel` | Level of education | 0 = none to 5 = PhD |
| `age` | Age of respondent | Years |
| `hhincome` | Household income per year | 1 = <£10,000 to 8 = >£1,000,000 |
| `EuropeanIdentity` | Attachment to the EU | 1 = No attachment to 7 = Strong |
| `BritishIdentity` | Attachment to Great Britain | 1 = No attachment to 7 = Strong |
| `female` | Female respondent | 1 = yes; 0 = no |

---

## Theoretical Background and Hypotheses

The 2016 Brexit referendum was as much a vote about national identity as it was about trade or sovereignty.
Voters with a strong sense of British identity may have experienced EU membership as a constraint on national self-determination, making Leave the more emotionally and politically consistent choice.

**H1:** Stronger British identity is associated with a higher probability of voting Leave.

A large body of research suggests that the gender gap in nationalist attitudes is not uniform: men tend to score higher on measures of national attachment and are more likely to translate identity into exclusionary political preferences.
If British identity operates differently for men and women, its association with Leave voting may vary by gender.

**H2:** The positive association between British identity and the probability of voting Leave is stronger among men than among women.

---

## Models

Fit the following two models using `brms` with `family = bernoulli(link = "probit")`:

**Model 1 (Additive)**

$$
\text{LeaveVote}_i \sim \text{Bernoulli}(\Phi(\mu_i))
$$

$$
\mu_i = \alpha + \beta_1 \, \text{BritishIdentity}_i + \beta_2 \, \text{EuropeanIdentity}_i + \beta_3 \, \text{edlevel}_i + \beta_4 \, \text{age}_i + \beta_5 \, \text{hhincome}_i + \beta_6 \, \text{female}_i
$$

**Model 2 (Interaction)**

Same as Model 1, with `BritishIdentity * female` replacing the two additive terms.

**Priors (both models)**

$$
\alpha \sim \text{Normal}(0, 1)
$$

$$
\beta_k \sim \text{Normal}(0, 0.5) \quad \text{for all slopes } k
$$

---

## Pre-Model

### Step 1: DAG and Estimand

Draw a DAG identifying the outcome, main predictor, and adjustment variables, and state a precise estimand for each hypothesis.

### Step 2: Data Summary

Visualise and describe the outcome variable and all predictors you plan to include in your models.

### Step 3: Formal Model Specification and Prior Justification

Write out the full statistical model (outcome distribution, linear predictor, link function, and all priors) for both models before writing any `brms` code, and justify your prior choices.

---

## Model

### Step 4: Prior Predictive Check

Use `sample_prior = "only"` to verify that your priors produce plausible distributions of `LeaveVote` before conditioning on the data.

### Step 5: Fit the Models

Fit both models using `brms` with the probit link and the priors you specified in Step 3.

### Step 6a: MCMC Diagnostics

Assess convergence for both models using trace plots, $\hat{R}$, and bulk ESS.

### Step 6b: Posterior Predictive Check

Evaluate model adequacy for both models using `pp_check()` with an appropriate check type for binary outcomes.

---

## Post-Model

### Step 7: Interpretation

Report posterior coefficient summaries, plot predicted probabilities to assess H1 and H2, compare the two models using LOO, and provide a substantive written assessment of each hypothesis given the data and the model comparison result.

### Step 8: Limitations

Identify at least two limitations of your analysis that could affect the credibility of your conclusions.

---

## Submission

Submit by pushing your completed Quarto document (rendered to PDF) and all supporting files to your `hw-11-<username>` repository.


## Feedback policy

> **A sample solution is published for this homework after the due date. Individual feedback is
> NOT provided by default.** The only individual feedback available is **optional AI feedback**:
> add an open-source `license.md` to this repo to opt in, and an AI will read your submission
> alongside the sample solution and write a `FEEDBACK.pdf` back into your repo. No `license.md`,
> no processing.
