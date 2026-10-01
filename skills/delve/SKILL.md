---
name: delve
description: >-
  This skill should be used when the user says "delve", "/delve", "review the
  research", "what was interesting", "surface odd behavior", "find promising
  leads", "what should I dig into", "go deeper on this lead", or wants to turn
  autonomous security research output into prioritized interesting behaviors and
  deeper research directions. Delve does not report findings by itself; it
  identifies substantiated oddities, near-misses, unresolved mechanisms, and
  suspicious patterns that may be close to real vulnerabilities.
user_invocable: true
---

# Delve

Review security research work and surface interesting behavior worth deeper human
attention.

`delve` is for the space between "no finding yet" and "this is probably nothing."
Good agents should only report substantiated findings, but while hunting they often
encounter odd behavior, sharp edges, mismatched assumptions, and almost-bugs. Delve
preserves and ranks those leads so a Grimoire user can choose one and dive deep.

## Philosophy

Interesting behavior is not a vulnerability. It is a signal that the system has
complexity, tension, or unexplained constraints near a security boundary.

Delve should be curious but disciplined:
- Do not promote leads to findings.
- Do not bury strange behavior just because it is not yet exploitable.
- Prefer concrete observed behavior over vibes.
- Preserve why the behavior caught attention.
- Define what evidence would confirm or refute the lead.

The user is the selector. Delve presents the menu of promising directions, then helps
go deep on the chosen topic.

## What Counts As Interesting

Look for behavior that is concrete, security-relevant, and not already resolved:

| Signal | Examples |
|--------|----------|
| Odd mechanism | Special-case accounting, unusual fallback, duplicated logic, unexplained threshold |
| Boundary tension | Trust changes, implicit authorization, offchain/onchain mismatch, admin escape hatch |
| Near miss | Exploit path blocked by one check, invariant preserved by fragile ordering |
| Inconsistency | Docs disagree with code, tests imply a different model, two modules handle the same case differently |
| Fragile assumption | "This can never happen", single trusted actor, assumed ordering, assumed external behavior |
| Impact proximity | Behavior touches funds, identity, authorization, governance, pricing, secrets, or availability |
| Research residue | Agent dismissed a path but left open questions or unverified assumptions |

Avoid leads that are only style preferences, generic complexity, or unsupported suspicion.

## Workflow

When this skill is activated, create a todo list from these steps. Mark each task
in_progress before starting it and completed when done.

```text
- [ ] 1. Gather research artifacts
- [ ] 2. Extract interesting behaviors
- [ ] 3. Separate findings, leads, dead ends, and notes
- [ ] 4. Rank leads by security promise
- [ ] 5. Present the delve board
- [ ] 6. Dive into the selected lead
- [ ] 7. Route the outcome
```

### 1. Gather Research Artifacts

Read `GRIMOIRE.md` if it exists. Then inspect relevant research output:
- Current conversation or agent transcript, if available
- `grimoire/tomes/`
- `grimoire/findings/`
- `grimoire/sigil-findings/`
- `grimoire/cartography/`
- `grimoire/spells/`
- Test output, PoCs, notes, or temporary research artifacts

If the user points to a specific agent run, transcript, file, branch, or topic, focus
there first.

Completion criterion: you know what research was performed, what was proven, what was
dismissed, and what remained odd.

### 2. Extract Interesting Behaviors

For each candidate lead, capture:
- The observed behavior
- Where it appears
- Why it is interesting
- What asset, invariant, or trust boundary it might touch
- What blocked it from becoming a finding
- What evidence is missing

Keep claims calibrated. Use "observed", "suggests", "unverified", or "unknown"
instead of vulnerability language.

### 3. Separate Findings, Leads, Dead Ends, And Notes

Classify each item:

| Class | Meaning | Route |
|-------|---------|-------|
| Finding | Substantiated vulnerability or control failure | `/finding-draft` or existing finding workflow |
| Lead | Interesting behavior with plausible security relevance but insufficient proof | Delve board |
| Dead end | Checked path with evidence it is not exploitable | Tome note if useful |
| Note | Durable context without a clear attack direction | `/tome` |

Do not dilute the delve board with confirmed findings or already-closed dead ends.

### 4. Rank Leads By Security Promise

Rank each lead on four axes:

| Axis | Values | Meaning |
|------|--------|---------|
| Impact proximity | High, Medium, Low | How close the behavior is to assets or security properties |
| Weirdness | High, Medium, Low | How surprising or unexplained it is relative to the system model |
| Evidence quality | High, Medium, Low | How concrete the current observation is |
| Next-step clarity | High, Medium, Low | Whether there is an obvious check to confirm or refute it |

Prioritize leads with high impact proximity and clear next steps, even when weirdness
is only medium. A boring-looking edge near money or authority often beats a fascinating
edge in harmless code.

### 5. Present The Delve Board

Present 3-7 leads unless fewer exist. Use this format:

```markdown
## Delve Board

| Lead | Why it matters | Evidence | Missing proof | Next check | Priority |
|------|----------------|----------|---------------|------------|----------|
| [short name] | [asset/invariant/boundary] | [paths or observations] | [gap] | [specific check] | [High/Med/Low] |
```

Then recommend the top 1-2 leads to dive into and explain why.

If no good leads exist, say so directly and summarize the strongest dead ends or notes.

### 6. Dive Into The Selected Lead

When the user picks a lead, turn it into a focused research question:

```markdown
If [capability or condition], can [mechanism] violate [asset or invariant], or is it
fully prevented by [specific control]?
```

Then:
- Read the relevant code and tests.
- Search for related flows, callers, callees, and state transitions.
- Check existing tomes and cartography.
- Identify the shortest experiment, proof, or source review that can confirm/refute.
- Track evidence for and against the lead.

Use `/divine` when the lead depends on understanding why a mechanism exists.
Use `/tome` when the lead produces durable context, negative results, or unresolved
questions.

### 7. Route The Outcome

End each delve with one route:

| Outcome | Action |
|---------|--------|
| Verified vulnerability | Draft a finding with `/finding-draft` |
| Needs exploit proof | Use `/write-poc` or define the minimal experiment |
| Needs broader search | Spawn a focused sigil or variant analysis |
| Useful context, not a bug | Write or update a tome |
| Still interesting but unverified | Add to `grimoire/tomes/notes/hypotheses.md` or `open-questions/` |
| Disproven | Record the negative result if it prevents repeated work |

## Output Format

```markdown
## Research Reviewed

- [Artifacts, transcripts, files, or agents reviewed.]

## Delve Board

| Lead | Why it matters | Evidence | Missing proof | Next check | Priority |
|------|----------------|----------|---------------|------------|----------|
| [short name] | [security relevance] | [source-backed observation] | [gap] | [specific action] | [High/Med/Low] |

## Recommended Dive

[The 1-2 leads most worth human attention, with rationale.]

## Guardrails

- Findings already substantiated: [list or "none"]
- Dead ends not worth re-opening: [list or "none"]
- Claims that remain unverified: [list]
```

## Key Principles

- Leads are not findings.
- Every lead needs a concrete observation.
- The best leads are near assets, invariants, trust boundaries, or privileged actions.
- Odd behavior deserves preservation even when it is not yet exploitable.
- Negative results are useful when they stop future agents from walking the same path.
- The user chooses where to dive; Delve makes that choice informed.
