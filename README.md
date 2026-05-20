# P2P Student Ledger — Statistical Risk Engine

**MATH-361 Probability & Statistics** | NUST CEME, DE-45

A Flutter app that tracks informal student-to-student loans and builds a statistical reliability score for each peer — because your friends don't have credit scores, but their repayment history tells a story.

---

## The Problem

University students lend money to each other constantly. Food, transport, printing, whatever. None of it goes through a bank, so there's no record and no accountability metric. You're just guessing whether a specific person is likely to pay you back.

This project applies probability and statistics to that guess — turning local transaction history into a personal reliability index for each peer.

---

## What It Does

The app runs entirely offline. One user records all transactions locally (asymmetric information setup — only your side of the ledger exists). The statistical engine then runs on that sample data to answer questions like:

- What's the probability this peer pays back on time, given their history? `P(OnTime | Peer)`
- What's the expected value of my total recoverable assets right now?
- Is this peer's repayment behavior statistically different from the others, or just noise?
- Are debts distributed across categories (food, transport, academic) evenly, or is one dominating?

---

## Statistics Implemented

**Graphical Analysis**
Histograms and boxplots of transaction amounts to visualize spending variance across peers and categories (e.g., 200 PKR vs. 2390 PKR spread).

**Conditional Probability**
Per-peer on-time repayment probability calculated from individual history — not a group average.

**Random Variables & Expectation**
Each peer's outstanding debt treated as a random variable. Expected value `E[X]` computed for total recoverable assets.

**Point Estimation**
The app is offline with no central database — so population-level behavior (average peer reliability) is estimated from the local sample using point estimators.

**Chi-Square Goodness of Fit**
Tests whether transaction purposes are uniformly distributed or skewed toward specific categories.

**Hypothesis Testing**
Determines whether a peer's repayment pattern is statistically significant or just variance.

---

## Tech Stack

- **Frontend / App** — Flutter (offline-first, local persistence)
- **Statistics Engine** — Dart (implemented inline with the app)
- **Data Storage** — Local only, no backend

---

## Course Alignment

| Syllabus Topic | Implementation |
|---|---|
| Graphical Representation | Histograms + boxplots of transaction data |
| Conditional Probability | `P(OnTime \| Peer)` per-peer calculation |
| Random Variables & Expectation | Expected recoverable debt `E[X]` |
| Point Estimation | Population behavior from local sample |
| Chi-Square Test | Transaction category distribution test |
| Hypothesis Testing | Peer repayment significance test |

---

## Course Info

| | |
|---|---|
| Course | MATH-361 Probability & Statistics |
| Institution | NUST CEME, Rawalpindi |
| Batch | DE-45, Department of Computer Engineering |
| Student | Abu-Bakar Chaudhary (457242) |
