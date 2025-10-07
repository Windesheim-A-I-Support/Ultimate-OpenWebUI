# Workshop Pre-Delivery Test Cases

**Purpose:** Verify the workshop will work BEFORE delivering it to participants
**Tester:** Facilitator/Instructor
**Time Required:** 45-60 minutes
**When to Run:** 1 day before workshop (and again 30 min before)

---

## Pre-Test Setup

### Environment Checklist
- [ ] Access to team1-openwebui.valuechainhackers.xyz
- [ ] Fresh account (or clear existing chats)
- [ ] OpenRouter configured and has API credit
- [ ] All 15 containers running on server

---

# Test Case 1: OpenRouter Models Available

**Priority:** CRITICAL ❌ (Workshop cannot proceed without this)

**Objective:** Verify OpenRouter models are accessible in OpenWebUI

### Pre-conditions
- OpenWebUI is accessible
- User can log in

### Test Steps

1. Log into OpenWebUI at https://team1-openwebui.valuechainhackers.xyz
2. Start a new chat
3. Click on the model dropdown (usually at top of chat interface)
4. Look for OpenRouter models

### Expected Results
- [ ] Model dropdown is visible and clickable
- [ ] See models with names like:
  - "Claude 3.5 Sonnet" or "claude-3-5-sonnet"
  - "GPT-4o" or "gpt-4o"
  - "GPT-4" or "gpt-4-turbo"
- [ ] Can select an OpenRouter model
- [ ] Model name appears in interface after selection

### Actual Results
```
[Document what you see]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

### If FAIL
**Critical issue - workshop cannot proceed.**

Troubleshooting:
1. Check if OpenRouter API key is configured:
   ```bash
   ssh root@10.0.8.40
   docker exec team1-openwebui env | grep OPENROUTER
   ```
2. Check OpenWebUI admin settings for OpenRouter configuration
3. Verify OpenRouter account has API credit
4. Check container logs: `docker logs team1-openwebui | grep -i openrouter`

---

# Test Case 2: Basic Chat with OpenRouter Model

**Priority:** CRITICAL ❌

**Objective:** Verify OpenRouter models respond quickly and correctly

### Pre-conditions
- OpenRouter model selected (Claude 3.5 Sonnet or GPT-4)

### Test Steps

1. Select Claude 3.5 Sonnet from model dropdown
2. Send this message:
   ```
   Hello! Please respond with exactly these words:
   "TEST SUCCESSFUL - I am ready to help with your research."

   Then tell me which AI model you are.
   ```
3. Note response time
4. Check response content

### Expected Results
- [ ] Response received within 10 seconds
- [ ] Response contains "TEST SUCCESSFUL" (or very close)
- [ ] Model identifies itself as Claude 3.5 Sonnet (or similar)
- [ ] Response is well-formatted and professional
- [ ] No error messages

### Actual Results
```
Response time: _____ seconds
Response content:
[Paste response]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

### If FAIL
Check:
- Model selection (should be Claude/GPT-4, not llama3.2)
- OpenRouter API credit balance
- Network connectivity
- Container health: `docker ps | grep team1`

---

# Test Case 3: Document Upload and RAG

**Priority:** HIGH ⚠️

**Objective:** Verify document upload, processing, and RAG queries work

### Pre-conditions
- Chat with Claude 3.5 Sonnet or GPT-4
- Have a test PDF ready (any research paper)

### Test Steps

1. Start new chat with Claude 3.5 Sonnet
2. Click paperclip/upload icon
3. Upload a PDF (5-10 pages ideal for testing)
4. Wait for "Document processed successfully" or similar message
5. Send this message:
   ```
   Based on the document I just uploaded, what are the top 3 main points?
   Provide specific quotes or page references.
   ```
6. Check response quality

### Expected Results
- [ ] Upload interface appears when clicking upload icon
- [ ] PDF uploads without errors
- [ ] Processing completes within 30-60 seconds
- [ ] Confirmation message appears
- [ ] AI response references the actual document content
- [ ] Response includes citations, quotes, or page references
- [ ] Response is specific to YOUR document (not general knowledge)

### Actual Results
```
Upload time: _____ seconds
Processing time: _____ seconds
Response quality: [Good/Fair/Poor]
Citations present: [Yes/No]
Specific to document: [Yes/No]

Response excerpt:
[Paste key parts]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

### If FAIL
Check:
- Tika container running: `docker ps | grep tika`
- Qdrant container running: `docker ps | grep qdrant`
- Document processing logs: `docker logs team1-openwebui | tail -100`
- File size (try smaller PDF if large file failed)

### Follow-up Test: Multi-Document RAG

If Test Case 3 passed, try:
1. Upload a SECOND PDF (different topic)
2. Ask: "What are the similarities and differences between these two documents?"
3. Verify AI can reference both documents

---

# Test Case 4: Web Search Integration

**Priority:** HIGH ⚠️

**Objective:** Verify web search works and provides current information

### Pre-conditions
- Chat with Claude 3.5 Sonnet or GPT-4
- Web search toggle is visible

### Test Steps

1. Start new chat with Claude 3.5 Sonnet
2. Look for web search toggle (usually 🌐 icon or "Web Search" switch)
3. Enable web search
4. Send this message:
   ```
   What are the latest (2024-2025) developments in battery recycling
   technology for electric vehicles? Include company names and dates.
   ```
5. Note if you see "Searching the web..." indicator
6. Check response for current information

### Expected Results
- [ ] Web search toggle is visible and can be enabled
- [ ] "Searching the web..." or similar indicator appears
- [ ] Response includes recent dates (2024-2025)
- [ ] Response mentions specific companies/organizations
- [ ] Response includes sources or URLs
- [ ] Response took 10-30 seconds (web search is slower)

### Actual Results
```
Search indicator visible: [Yes/No]
Response time: _____ seconds
Recent dates present: [Yes/No]
Specific sources: [Yes/No]

Response excerpt:
[Paste key parts]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

### If FAIL
Check:
- SearxNG container: `docker ps | grep searxng`
- Web search enabled in config: `docker exec team1-openwebui env | grep WEB_SEARCH`
- SearxNG health: `curl http://localhost:8081/` (from server)
- Try simpler query: "What day is today?"

### Follow-up Test: Web Search Toggle

1. **Disable** web search
2. Ask: "What happened in sustainability news yesterday?"
3. Verify AI says it doesn't have recent information
4. **Enable** web search
5. Ask same question
6. Verify AI provides recent news

---

# Test Case 5: Code Execution - Simple

**Priority:** CRITICAL ❌

**Objective:** Verify Python code execution works

### Pre-conditions
- Chat with Claude 3.5 Sonnet or GPT-4
- Code execution is enabled

### Test Steps

1. Start new chat with Claude 3.5 Sonnet
2. Send this message:
   ```
   Calculate the compound annual growth rate (CAGR) if an investment
   grows from $100 to $250 over 5 years. Show me the formula and write
   Python code to calculate it, then execute the code.
   ```
3. Observe if AI writes code
4. Check if code executes automatically
5. Verify output

### Expected Results
- [ ] AI writes Python code
- [ ] Code executes automatically (or has "Run" button that works)
- [ ] Output shows calculation result (~20.11%)
- [ ] No errors during execution
- [ ] Process completes in < 30 seconds

### Actual Results
```
AI wrote code: [Yes/No]
Code executed: [Yes/No]
Result correct: [Yes/No]
Errors: [Yes/No - if yes, describe]

Code and output:
[Paste]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

### If FAIL
Check:
- Jupyter container: `docker ps | grep jupyter`
- Code execution config: `docker exec team1-openwebui env | grep CODE`
- Jupyter health: `curl http://localhost:8888/` (from server)
- Try manual code: "Please run this code: print(2+2)"

---

# Test Case 6: Code Execution - Visualization

**Priority:** HIGH ⚠️

**Objective:** Verify AI can generate and execute visualization code

### Pre-conditions
- Test Case 5 passed
- Same chat session or new one

### Test Steps

1. Send this message:
   ```
   Create a line graph showing exponential growth from $100 to $250
   over 5 years using the CAGR we just calculated. Label the axes
   and make it look professional. Execute the code to generate the plot.
   ```
2. Check if AI writes matplotlib code
3. Verify code executes
4. Look for graph output

### Expected Results
- [ ] AI writes matplotlib code
- [ ] Code executes without errors
- [ ] Graph appears in chat OR "Chart created" message appears
- [ ] If graph visible, it shows correct growth curve
- [ ] Process completes in < 45 seconds

### Actual Results
```
AI wrote visualization code: [Yes/No]
Code executed: [Yes/No]
Graph displayed: [Yes/No/Partial]
Graph quality: [Good/Fair/Poor/N/A]

Notes:
[Document what you see]
```

### Status
- [ ] ✅ PASS (graph displays inline)
- [ ] ⚠️ PARTIAL PASS (code runs but no inline display - this is OK)
- [ ] ❌ FAIL (code errors or doesn't run)

### If FAIL
- Check if matplotlib is installed in Jupyter
- Try simpler plot: "Create a bar chart of [1,2,3,4,5]"
- Check OpenWebUI version (inline image display may not be supported)
- **Note:** Code execution working is more important than inline display

---

# Test Case 7: Code Execution - Data Analysis

**Priority:** MEDIUM ⚠️

**Objective:** Verify AI can generate, analyze, and visualize data

### Pre-conditions
- Test Case 5 passed

### Test Steps

1. Start new chat
2. Send this message:
   ```
   Generate a dataset of 10 cities with their population and CO2 emissions.
   Then create a scatter plot showing if there's a correlation.
   Calculate and display the correlation coefficient.
   Execute all the code.
   ```
3. Verify AI generates complete workflow

### Expected Results
- [ ] AI generates sample data
- [ ] AI creates visualization code
- [ ] AI calculates correlation
- [ ] All code executes successfully
- [ ] Results are displayed (data table, correlation value)
- [ ] Scatter plot created (visible or message confirms it)

### Actual Results
```
Complete workflow executed: [Yes/No]
Data generated: [Yes/No]
Correlation calculated: [Yes/No]
Visualization created: [Yes/No]

Quality assessment: [Excellent/Good/Fair/Poor]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

---

# Test Case 8: Integration - RAG + Web + Code

**Priority:** CRITICAL ❌

**Objective:** Verify all three capabilities work together in one conversation

### Pre-conditions
- All previous test cases passed
- Have a test PDF ready

### Test Steps

1. Start new chat with Claude 3.5 Sonnet
2. **Step A - RAG:** Upload a PDF about any topic
3. Wait for processing
4. Send: "Based on this document, what are the main findings about [relevant topic from the PDF]?"
5. Wait for response
6. **Step B - Web Search:** Enable web search
7. Send: "Now search the web for recent (2024-2025) developments in [same topic]. How do they compare to what's in the document?"
8. Wait for response
9. **Step C - Code:** Send: "Generate sample data related to [topic] and create a visualization showing [relevant metric]. Execute the code."
10. Verify all three worked in sequence

### Expected Results
- [ ] RAG response cites the uploaded document
- [ ] Web search response includes recent sources
- [ ] Web response compares document vs current info
- [ ] Code generation works
- [ ] Visualization created
- [ ] Conversation maintains context across all three
- [ ] Total process completes in < 5 minutes

### Actual Results
```
RAG step: [Success/Fail]
Web search step: [Success/Fail]
Code execution step: [Success/Fail]
Context maintained: [Yes/No]
Synthesis quality: [Excellent/Good/Fair/Poor]

Total time: _____ minutes

Notes:
[Document the experience]
```

### Status
- [ ] ✅ PASS (all three work together)
- [ ] ⚠️ PARTIAL PASS (2 of 3 work)
- [ ] ❌ FAIL (< 2 work or no integration)

### If FAIL
This is the capstone test. If it fails:
- Review which specific step failed
- Refer to that capability's individual test case
- Fix underlying issue
- Re-run this integration test

---

# Test Case 9: Conversation Persistence

**Priority:** MEDIUM ⚠️

**Objective:** Verify chat history saves and is accessible

### Pre-conditions
- Have completed at least one chat

### Test Steps

1. Complete a conversation with several messages
2. Close browser tab (or log out)
3. Open browser again
4. Log back in
5. Look for chat history in sidebar
6. Click on previous chat
7. Verify messages are still there
8. Send a follow-up message referencing earlier conversation

### Expected Results
- [ ] Chat history visible in sidebar
- [ ] Previous chats are listed with titles/timestamps
- [ ] Clicking on chat loads all previous messages
- [ ] Can continue conversation where left off
- [ ] AI remembers context from earlier in the conversation

### Actual Results
```
Chat history visible: [Yes/No]
Previous messages loaded: [Yes/No]
Context preserved: [Yes/No]

Notes:
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

---

# Test Case 10: Multiple Users / Accounts

**Priority:** LOW ⚠️

**Objective:** Verify multiple workshop participants can use the system simultaneously

### Pre-conditions
- At least 2 test accounts available

### Test Steps

1. Log in as User 1 in one browser
2. Log in as User 2 in another browser (or incognito)
3. Both users start chats simultaneously
4. Both users send messages at the same time
5. Verify both receive responses
6. Verify users can't see each other's chats

### Expected Results
- [ ] Both users can log in simultaneously
- [ ] Both receive responses within reasonable time
- [ ] No cross-contamination of chats
- [ ] User 1 doesn't see User 2's chats
- [ ] System remains responsive with multiple users

### Actual Results
```
Simultaneous access: [Yes/No]
Response times normal: [Yes/No]
Privacy maintained: [Yes/No]

Notes:
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

---

# Test Case 11: Workshop HTML Rendering

**Priority:** MEDIUM ⚠️

**Objective:** Verify workshop.qmd renders correctly to HTML

### Pre-conditions
- Quarto installed
- workshop.qmd file accessible

### Test Steps

1. Open terminal
2. Navigate to workshop directory:
   ```bash
   cd /home/chris/Documents/github/Ultimate-OpenWebUI/Version1.2
   ```
3. Run Quarto render:
   ```bash
   quarto render workshop.qmd
   ```
4. Check for errors
5. Open generated workshop.html
6. Scroll through all sections
7. Check Mermaid diagrams render
8. Check tables render correctly
9. Check code blocks are formatted

### Expected Results
- [ ] Quarto render completes without errors
- [ ] workshop.html file created
- [ ] HTML opens in browser
- [ ] All 5 modules visible
- [ ] Mermaid diagrams display correctly
- [ ] Tables are formatted properly
- [ ] Code blocks have syntax highlighting
- [ ] CSS styling applied correctly
- [ ] Table of contents works
- [ ] All sections readable

### Actual Results
```
Render successful: [Yes/No]
File size: _____ KB
Mermaid diagrams: [Yes/No]
Tables formatted: [Yes/No]
Overall quality: [Excellent/Good/Fair/Poor]

Errors encountered:
[List any]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

### If FAIL
Check:
- Quarto installation: `quarto check`
- YAML syntax in workshop.qmd
- Mermaid extension: `quarto install extension quarto-ext/mermaid`
- View specific error messages

---

# Test Case 12: Sample PDFs Accessible

**Priority:** LOW ⚠️

**Objective:** Verify backup sample PDFs are ready

### Pre-conditions
- None

### Test Steps

1. Check if sample PDFs exist in workshop directory
2. Verify PDFs are on relevant topics (sustainability/logistics)
3. Try opening each PDF
4. Verify PDFs are not too large (< 10MB each)

### Expected Results
- [ ] At least 3 sample PDFs ready
- [ ] Topics relevant to audience (sustainability/logistics/research)
- [ ] PDFs open without errors
- [ ] File sizes reasonable (< 10MB)
- [ ] PDFs are actual research papers or reports (not random documents)

### Actual Results
```
Number of sample PDFs: _____
Topics: [List]
Sizes: [List]

Files ready: [Yes/No]
```

### Status
- [ ] ✅ PASS
- [ ] ❌ FAIL

---

# Summary Test Results

## Critical Tests (Workshop CANNOT run if these fail)
| Test Case | Status | Priority | Notes |
|-----------|--------|----------|-------|
| TC1: OpenRouter Models Available | ⬜ | CRITICAL | |
| TC2: Basic Chat | ⬜ | CRITICAL | |
| TC5: Code Execution - Simple | ⬜ | CRITICAL | |
| TC8: Integration (RAG+Web+Code) | ⬜ | CRITICAL | |

## High Priority Tests (Workshop quality degraded if these fail)
| Test Case | Status | Priority | Notes |
|-----------|--------|----------|-------|
| TC3: Document RAG | ⬜ | HIGH | |
| TC4: Web Search | ⬜ | HIGH | |
| TC6: Code Visualization | ⬜ | HIGH | |

## Medium/Low Priority Tests (Nice to have)
| Test Case | Status | Priority | Notes |
|-----------|--------|----------|-------|
| TC7: Code Data Analysis | ⬜ | MEDIUM | |
| TC9: Conversation Persistence | ⬜ | MEDIUM | |
| TC10: Multiple Users | ⬜ | LOW | |
| TC11: Workshop HTML | ⬜ | MEDIUM | |
| TC12: Sample PDFs | ⬜ | LOW | |

## GO / NO-GO Decision

### Workshop is GO if:
- ✅ All 4 CRITICAL tests pass
- ✅ At least 2 of 3 HIGH priority tests pass
- ⚠️ MEDIUM/LOW tests can fail without blocking

### Workshop is NO-GO if:
- ❌ ANY CRITICAL test fails
- ❌ More than 1 HIGH priority test fails

## Final Checklist Before Workshop

**1 Day Before:**
- [ ] Run all test cases
- [ ] Document any issues
- [ ] Fix critical issues
- [ ] Prepare workarounds for non-critical issues

**30 Minutes Before:**
- [ ] Quick smoke test (TC1, TC2, TC5)
- [ ] Verify OpenRouter credit balance
- [ ] Check all containers running
- [ ] Prepare backup materials

**5 Minutes Before:**
- [ ] Load workshop HTML in browser
- [ ] Test login with dummy account
- [ ] Verify model dropdown shows OpenRouter models
- [ ] Send one test message to verify responsiveness

---

## Notes Section

### Issues Encountered
```
[Document any issues found during testing]
```

### Workarounds Implemented
```
[Document any workarounds for known issues]
```

### Recommendations
```
[Any recommendations for improving the workshop]
```

---

**Test Completed By:** _____________________
**Date:** _____________________
**Time:** _____________________
**Overall Assessment:** [ ] Ready for Delivery  [ ] Needs Work  [ ] Not Ready
