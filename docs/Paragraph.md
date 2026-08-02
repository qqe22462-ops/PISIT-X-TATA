# Paragraph

A multi-line, word-wrapped block of informational text with an optional bold title row. Used for descriptions, changelogs, disclaimers, or instructions.

## Creating a Paragraph

```lua
local Paragraph = Section:CreateParagraph({
    Title = "About This Script",
    Content = "This module provides ESP, an aim assist toggle, and a fully persistent configuration system. Settings are saved automatically every 15 seconds.",
})
```

## Config table

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `""` | Optional bold header line. Hidden entirely if left empty. |
| `Content` | string | `""` | Body text. Wraps automatically to the section's width. |

## Methods

| Method | Description |
|---|---|
| `Paragraph:SetContent(text)` | Updates the body text at runtime. |
| `Paragraph:SetTitle(text)` | Updates (or hides, if set to `""`) the title at runtime. |

## Notes

Paragraphs auto-size their height (`AutomaticSize = Enum.AutomaticSize.Y`) to fit however much text is provided, so long changelogs or instructions are never clipped.
