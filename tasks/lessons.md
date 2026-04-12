# Lessons — Agricola (Flutter Mobile)

Patterns, mistakes, and edge cases discovered during development. Updated after every correction.

---

## Patterns to follow

<!-- Add entries as: - **Pattern name**: description + why it matters -->

- **No opaque colored containers as decorative wrappers**: Do NOT wrap icons, text, or badges in `Container(decoration: BoxDecoration(color: someColor.withAlpha(X)))` as a default styling pattern. This is an AI-tell — it looks generic and overused. Icons should get their color via `Icon(data, color: X)` directly. Text labels/statuses should use colored text directly, not a tinted pill. Info sections should use `Colors.grey[50]` with a grey border, not a colored tint. The colored container pattern is allowed only when it carries functional meaning and is used minimally (e.g. functional stepper circles, overlaid action buttons). Never use it as a decoration for icons, text badges, or status chips.

## Mistakes to avoid

<!-- Add entries as: - **What went wrong**: description + how to prevent it -->

- **Don't use bang operators (`!`) when null promotion already applies**: Inside `if (error != null)` blocks, the variable is already promoted to non-null — adding `error!` is redundant and trains bad habits. Worse, using `!` in contexts where the variable *could* be null (e.g. after an unrelated `if (mounted)` check breaks promotion) risks runtime crashes. Instead, use proper null handling: pass the variable through a null check, use `??` with a fallback, or restructure the control flow so Dart's flow analysis promotes naturally.

## Edge cases discovered

<!-- Add entries as: - **Scenario**: what happened + how it was resolved -->
