# OpenWebUI Research Workshop

## What Is This?

A **2.5-hour hands-on workshop** teaching researchers how to use OpenWebUI for AI-powered research workflows.

Designed using learning principles from:
- 📚 Luma Institute
- 🎨 Hyper Island
- 💻 Teaching Tech Together (Greg Wilson)
- 🧠 Design for How People Learn (Julie Dirksen)
- 🚀 AJ&Smart
- 🌱 The Art of Hosting

## Workshop Structure

### 5 Modules (20-30 min each)

1. **Basic Chat** - Context-persistent AI conversations
2. **Document RAG** - Upload & query your research papers
3. **Web Search** - Get current information without leaving chat
4. **Code Execution** - From question to graph in 60 seconds
5. **Integration** - Combine all capabilities in one workflow

Each module includes:
- ✅ Hook (why care?)
- ✅ Story (real researcher example)
- ✅ Educational content
- ✅ Hands-on test case
- ✅ Entertainment (games/challenges)
- ✅ Key learnings
- ✅ Reflection questions
- ✅ Anecdote
- ✅ Quote from famous researcher

## How to Use This Workshop

### Option 1: Render to HTML (Recommended)

**Prerequisites:**
```bash
# Install Quarto
# macOS: brew install quarto
# Windows/Linux: https://quarto.org/docs/get-started/

# Or use RStudio (Quarto is built-in)
```

**Render the workshop:**
```bash
cd /home/chris/Documents/github/Ultimate-OpenWebUI/Version1.2
quarto render workshop.qmd
```

**Open the result:**
```bash
# Opens in your browser
open workshop.html
```

### Option 2: Render to PDF

```bash
quarto render workshop.qmd --to pdf
```

### Option 3: View in RStudio

1. Open `workshop.qmd` in RStudio
2. Click "Render" button
3. HTML preview opens automatically

### Option 4: Read the Source

The `.qmd` file is readable as-is in any text editor!

## Customization

### Change the URL

Edit line ~81:
```markdown
1. **Open your browser** and go to: `https://YOUR-URL-HERE`
```

### Add Your Branding

Edit the YAML header (lines 1-15):
```yaml
title: "Your Title Here"
author: "Your Name"
```

### Modify Test Cases

Each test case follows this structure:
```markdown
### 🧪 Test Case #X: Title

**Setup checklist:**
- [ ] Requirement 1
- [ ] Requirement 2

**The Test:**

[Step-by-step instructions]

**✅ Success criteria:**
- [ ] Expected outcome 1
- [ ] Expected outcome 2
```

## Workshop Delivery Tips

### Before the Workshop

1. **Test everything yourself** - Run through all 5 modules
2. **Check all services** - Verify OpenWebUI, RAG, web search, code execution work
3. **Prepare sample data** - Have backup PDFs and CSVs ready
4. **Set up accounts** - Pre-create accounts if needed, or plan for signup time
5. **Check internet** - Web search requires connectivity

### During the Workshop

**Timing:**
- 🕐 Module 1: 20 min (basic chat - keep it quick)
- 🕑 Module 2: 30 min (RAG - most important)
- 🕒 Module 3: 20 min (web search - straightforward)
- 🕓 Module 4: 30 min (code execution - needs practice)
- 🕔 Module 5: 30 min (integration - bring it together)
- ☕ 2 x 10 min breaks

**Facilitation style:**
- ✅ Let participants struggle briefly (learning happens)
- ✅ Encourage peer help first
- ✅ Walk around during test cases
- ✅ Celebrate successes loudly
- ❌ Don't rush through test cases
- ❌ Don't skip the reflection questions

**Common participant questions:**

> "Can I use my own data?"

**Answer:** Yes! That's encouraged in the advanced challenges.

> "What if the code doesn't work?"

**Answer:** That's part of learning. See if the error message helps, or ask AI to fix it.

> "Is this going to replace my job?"

**Answer:** No. This enhances your work. You're still the researcher - this is just a better tool.

> "Can I share my conversations?"

**Answer:** Yes (check with your IT about data policies first).

### After the Workshop

**Follow-up (recommended):**
1. **3-day check-in email** - "Did you use it? What questions came up?"
2. **1-week office hours** - Drop-in support session
3. **1-month showcase** - Participants share what they've built

## Troubleshooting

### Quarto Won't Render

**Check Quarto is installed:**
```bash
quarto check
```

**Try rendering with verbose output:**
```bash
quarto render workshop.qmd --verbose
```

### Mermaid Diagrams Don't Show

**Install mermaid:**
```bash
quarto install extension quarto-ext/mermaid
```

### CSS Not Loading

Check that `workshop-styles.css` is in the same directory as `workshop.qmd`.

## Files in This Workshop

```
Version1.2/
├── workshop.qmd              # Main workshop content (Quarto markdown)
├── workshop-styles.css       # Styling for HTML output
├── WORKSHOP-README.md        # This file
├── TEST-CASES.csv            # Spreadsheet version of test cases
└── TEST-CASES.md             # Markdown version of test cases
```

## Extending This Workshop

### Add a New Module

Template:
```markdown
# Module X: Your Topic

## The Hook 🎣
[Why should they care?]

## The Story 📖
### Meet Dr. [Name]
[Real or realistic researcher scenario]

## The Educational Piece 📚
[Explain the concept]

## The Empowering Piece 💪
### 🧪 Test Case #X: Title
[Hands-on exercise]

## The Entertainment Piece 🎭
[Game or challenge]

## Key Learnings 🎓
[What they should know now]

## The Anecdote 🗣️
[Memorable story]

## The Quote 💭
> [Relevant quote]
```

### Adapt for Different Audiences

**For undergrads:** Simplify jargon, add more examples, extend time
**For faculty:** Focus on research efficiency, show publication-ready outputs
**For industry:** Emphasize ROI, speed, competitive advantage
**For humanities:** Use qualitative research examples, text analysis use cases

## License

CC BY-SA 4.0 - Use it, adapt it, share it, improve it!

## Feedback

If you deliver this workshop, please share:
- What worked well?
- What confused participants?
- What took longer/shorter than expected?
- What creative uses did participants discover?

## Credits

Workshop design: Research Innovation Lab
Based on OpenWebUI: https://github.com/open-webui/open-webui
Learning principles: See acknowledgments in workshop.qmd

---

**Ready to run the workshop? Start here:**

```bash
quarto render workshop.qmd && open workshop.html
```

**Questions?** Read through the workshop yourself first - the answers are usually in there! 🎓
