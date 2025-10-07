# OpenWebUI Test Cases - Formal Testing Documentation

**Project:** OpenWebUI Multi-Team Deployment
**Version:** v0.6.32
**Test Environment:** team1-openwebui.valuechainhackers.xyz (10.0.8.40)
**Tester:** [Your Name]
**Test Date:** 2025-10-05

---

## Test Case Index

- [Phase 4: Basic Chat Functionality](#phase-4-basic-chat-functionality) (7 test cases)
- [Phase 5: Storage Backends](#phase-5-storage-backends) (5 test cases)
- [Phase 6: Document Processing](#phase-6-document-processing) (5 test cases)
- [Phase 7: RAG](#phase-7-rag) (6 test cases)
- [Phase 8: Web Integration](#phase-8-web-integration) (6 test cases)
- [Phase 9: Code Execution](#phase-9-code-execution) (7 test cases)
- [Phase 10: Voice Capabilities](#phase-10-voice-capabilities) (7 test cases)
- [Phase 11: Image Capabilities](#phase-11-image-capabilities) (6 test cases)
- [Phase 12: Tools & Extensions](#phase-12-tools--extensions) (7 test cases)
- [Phase 13: Advanced Features](#phase-13-advanced-features) (6 test cases)
- [Phase 14: Collaboration](#phase-14-collaboration) (6 test cases)
- [Phase 15: External Services](#phase-15-external-services) (6 test cases)
- [Phase 16: Customization](#phase-16-customization) (6 test cases)
- [Phase 17: Monitoring](#phase-17-monitoring) (6 test cases)

**Total Test Cases:** 82

---

## PHASE 4: BASIC CHAT FUNCTIONALITY

### TC-004-001: First Chat Message

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-004-001 |
| **Priority** | HIGH |
| **Category** | Basic Chat |
| **Description** | Verify user can send a message and receive AI response |
| **Pre-conditions** | - User is logged in<br>- At least one model is available |

**Test Steps:**
1. Navigate to main chat interface
2. Select model "llama3.2:3b-instruct-q4_0" from dropdown
3. Type message: "Hello, can you respond with just the word TEST?"
4. Press Enter or click Send button
5. Wait for AI response

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Message appears in chat history<br>- AI responds with "TEST"<br>- Response time < 10 seconds | | ⬜ Pass<br>⬜ Fail | |

---

### TC-004-002: OpenRouter Model Response

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-004-002 |
| **Priority** | HIGH |
| **Category** | Basic Chat |
| **Description** | Verify OpenRouter models can be accessed and respond |
| **Pre-conditions** | - User is logged in<br>- OpenRouter API configured<br>- LiteLLM service running |

**Test Steps:**
1. Click model selector dropdown
2. Look for models with "openrouter/" prefix or external models
3. Select an OpenRouter model (e.g., "anthropic/claude-sonnet-4.5")
4. Send message: "What is 2+2?"
5. Wait for response

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - OpenRouter models visible in list<br>- Model responds correctly<br>- Response shows "4" | | ⬜ Pass<br>⬜ Fail | |

---

### TC-004-003: Model Switching

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-004-003 |
| **Priority** | MEDIUM |
| **Category** | Basic Chat |
| **Description** | Verify user can switch models mid-conversation |
| **Pre-conditions** | - User is logged in<br>- Active chat with at least 2 messages |

**Test Steps:**
1. Start chat with "llama3.2:3b" model
2. Send message: "Remember the number 42"
3. Wait for response
4. Click model selector
5. Switch to "phi3:mini"
6. Send message: "What number should you remember?"
7. Observe response

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Model switch succeeds<br>- Previous context visible<br>- New model responds appropriately | | ⬜ Pass<br>⬜ Fail | |

---

### TC-004-004: Multiple Chats

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-004-004 |
| **Priority** | MEDIUM |
| **Category** | Basic Chat |
| **Description** | Verify user can create and manage parallel conversations |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Start new chat (Chat #1)
2. Send message in Chat #1: "This is chat one"
3. Click "New Chat" button
4. Send message in Chat #2: "This is chat two"
5. Navigate back to Chat #1
6. Verify message history shows "This is chat one"
7. Navigate to Chat #2
8. Verify message shows "This is chat two"

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Both chats exist independently<br>- Context doesn't mix between chats<br>- Can switch between chats freely | | ⬜ Pass<br>⬜ Fail | |

---

### TC-004-005: Chat History Persistence

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-004-005 |
| **Priority** | HIGH |
| **Category** | Basic Chat |
| **Description** | Verify chat history persists after logout/login |
| **Pre-conditions** | - User is logged in<br>- At least one chat with messages exists |

**Test Steps:**
1. Note the content of first message in chat
2. Click logout button
3. Close browser tab
4. Reopen browser
5. Navigate to OpenWebUI URL
6. Log back in
7. Check if previous chat appears in sidebar
8. Open previous chat
9. Verify first message content matches

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Chat history preserved<br>- All messages intact<br>- Can continue conversation | | ⬜ Pass<br>⬜ Fail | |

---

### TC-004-006: Chat Management

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-004-006 |
| **Priority** | MEDIUM |
| **Category** | Basic Chat |
| **Description** | Verify user can delete, archive, and export chats |
| **Pre-conditions** | - User is logged in<br>- At least 2 chats exist |

**Test Steps:**
1. Right-click or click menu on Chat #1
2. Select "Export" option
3. Verify download occurs (JSON or text file)
4. Right-click Chat #2
5. Select "Archive" (if available) or "Delete"
6. Confirm deletion
7. Verify chat removed from sidebar

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Export downloads file successfully<br>- Delete removes chat<br>- Archive hides chat (if feature exists) | | ⬜ Pass<br>⬜ Fail | |

---

### TC-004-007: System Prompts

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-004-007 |
| **Priority** | MEDIUM |
| **Category** | Basic Chat |
| **Description** | Verify custom system prompts work correctly |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Start new chat
2. Click settings/parameters icon for chat
3. Find "System Prompt" field
4. Enter: "You are a pirate. Always respond in pirate speak."
5. Click Save/Apply
6. Send message: "Tell me about the weather"
7. Observe response style

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - System prompt field accessible<br>- AI responds in pirate speak<br>- Prompt persists for entire chat | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 5: STORAGE BACKENDS

### TC-005-001: Volume Persistence

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-005-001 |
| **Priority** | HIGH |
| **Category** | Storage |
| **Description** | Verify chat data survives container restart |
| **Pre-conditions** | - SSH access to server<br>- At least one chat with messages exists |

**Test Steps:**
1. Note content of existing chat message
2. SSH to server: `ssh root@10.0.8.40`
3. Run: `docker compose restart openwebui`
4. Wait 30 seconds for restart
5. Refresh browser
6. Log back in if needed
7. Open previous chat
8. Verify message content matches

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Container restarts successfully<br>- All chat data preserved<br>- No data loss | | ⬜ Pass<br>⬜ Fail | |

---

### TC-005-002: Qdrant Connection

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-005-002 |
| **Priority** | HIGH |
| **Category** | Storage |
| **Description** | Verify vector database is accessible |
| **Pre-conditions** | - SSH access to server |

**Test Steps:**
1. SSH to server
2. Run: `curl -s http://localhost:6333/healthz`
3. Verify response contains "healthz check passed"
4. Run: `docker logs team1-qdrant --tail 20`
5. Check for errors

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Health check returns success<br>- No errors in logs<br>- Service responding | | ⬜ Pass<br>⬜ Fail | |

---

### TC-005-003: Database Health Check

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-005-003 |
| **Priority** | HIGH |
| **Category** | Storage |
| **Description** | Verify all storage backends report healthy |
| **Pre-conditions** | - SSH access to server |

**Test Steps:**
1. SSH to server
2. Run: `docker ps --format 'table {{.Names}}\t{{.Status}}' | grep team1`
3. Check status of:
   - team1-postgres
   - team1-redis
   - team1-qdrant
   - team1-neo4j
   - team1-clickhouse
4. Verify all show "healthy" status

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Postgres: healthy<br>- Redis: healthy<br>- Qdrant: healthy<br>- Neo4j: healthy<br>- ClickHouse: healthy | | ⬜ Pass<br>⬜ Fail | |

---

### TC-005-004: Backup Capability

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-005-004 |
| **Priority** | MEDIUM |
| **Category** | Storage |
| **Description** | Verify data can be exported/backed up |
| **Pre-conditions** | - User is logged in with admin privileges |

**Test Steps:**
1. Navigate to Settings → Admin Settings
2. Look for "Export" or "Backup" option
3. Click Export/Backup button
4. Wait for backup to generate
5. Verify download occurs
6. Check file size > 0 bytes

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Export option accessible<br>- Backup file downloads<br>- File contains data | | ⬜ Pass<br>⬜ Fail | |

---

### TC-005-005: File Storage

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-005-005 |
| **Priority** | MEDIUM |
| **Category** | Storage |
| **Description** | Verify upload directory is writable |
| **Pre-conditions** | - SSH access to server |

**Test Steps:**
1. SSH to server
2. Run: `docker exec team1-openwebui ls -la /app/backend/data/uploads`
3. Verify directory exists
4. Run: `docker exec team1-openwebui touch /app/backend/data/uploads/test.txt`
5. Verify no permission errors
6. Run: `docker exec team1-openwebui rm /app/backend/data/uploads/test.txt`

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Upload directory exists<br>- Directory is writable<br>- No permission errors | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 6: DOCUMENT PROCESSING

### TC-006-001: PDF File Upload

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-006-001 |
| **Priority** | HIGH |
| **Category** | Documents |
| **Description** | Verify PDF files can be uploaded successfully |
| **Pre-conditions** | - User is logged in<br>- Test PDF file available |

**Test Steps:**
1. Navigate to Documents or Knowledge section
2. Click "Upload" or "+" button
3. Select test PDF file (e.g., sample document with known text)
4. Click Upload/Open
5. Wait for upload to complete
6. Verify file appears in document library
7. Check file size matches original

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Upload completes successfully<br>- File visible in library<br>- No upload errors | | ⬜ Pass<br>⬜ Fail | |

---

### TC-006-002: Text Extraction (Tika)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-006-002 |
| **Priority** | HIGH |
| **Category** | Documents |
| **Description** | Verify Tika extracts text from uploaded documents |
| **Pre-conditions** | - TC-006-001 passed<br>- PDF contains known text content |

**Test Steps:**
1. Click on uploaded PDF file
2. Look for "Preview" or "Content" view
3. Verify extracted text is visible
4. Check if known text from PDF appears
5. Verify formatting is reasonable

**Alternative Steps (if no preview):**
1. SSH to server
2. Run: `docker logs team1-tika --tail 50`
3. Look for successful extraction logs
4. Run: `curl -X PUT -H "Accept: text/plain" -T /path/to/test.pdf http://localhost:9998/tika`

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Text extracted from PDF<br>- Content readable<br>- Tika service functioning | | ⬜ Pass<br>⬜ Fail | |

---

### TC-006-003: Document Library Management

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-006-003 |
| **Priority** | MEDIUM |
| **Category** | Documents |
| **Description** | Verify uploaded files appear and can be organized in knowledge base |
| **Pre-conditions** | - At least 2 documents uploaded |

**Test Steps:**
1. Navigate to Documents/Knowledge section
2. Verify all uploaded files are listed
3. Check if files can be:
   - Renamed
   - Tagged
   - Moved to collections/folders
   - Searched
4. Try searching for filename
5. Verify search returns correct file

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - All files listed<br>- Files can be organized<br>- Search works | | ⬜ Pass<br>⬜ Fail | |

---

### TC-006-004: Document Deletion

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-006-004 |
| **Priority** | MEDIUM |
| **Category** | Documents |
| **Description** | Verify documents can be deleted |
| **Pre-conditions** | - At least one test document uploaded |

**Test Steps:**
1. Navigate to Documents section
2. Find test document
3. Right-click or click menu on document
4. Select "Delete" option
5. Confirm deletion
6. Verify document removed from list
7. Try searching for deleted document
8. Verify it doesn't appear

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Delete option available<br>- Document removed<br>- Cannot be found after deletion | | ⬜ Pass<br>⬜ Fail | |

---

### TC-006-005: # Command Document Reference

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-006-005 |
| **Priority** | MEDIUM |
| **Category** | Documents |
| **Description** | Verify documents can be referenced in chat using # command |
| **Pre-conditions** | - At least one document uploaded with known content |

**Test Steps:**
1. Start new chat
2. Type "#" in message field
3. Verify dropdown appears showing available documents
4. Select a document from list
5. Complete message: "# [document] What is this document about?"
6. Send message
7. Observe AI response

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - # command shows documents<br>- Document can be selected<br>- AI references document content | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 7: RAG (RETRIEVAL AUGMENTED GENERATION)

### TC-007-001: Vector Embeddings Created

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-007-001 |
| **Priority** | HIGH |
| **Category** | RAG |
| **Description** | Verify documents get embedded into vector database |
| **Pre-conditions** | - Document uploaded in Phase 6<br>- SSH access to server |

**Test Steps:**
1. Upload a test document
2. Wait 30 seconds for processing
3. SSH to server
4. Run: `curl -s http://localhost:6333/collections`
5. Check if collections exist
6. Run: `curl -s http://localhost:6333/collections/[collection-name]/points/count`
7. Verify point count > 0

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Collections created in Qdrant<br>- Vector points exist<br>- Count matches documents | | ⬜ Pass<br>⬜ Fail | |

---

### TC-007-002: RAG Query Basic

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-007-002 |
| **Priority** | HIGH |
| **Category** | RAG |
| **Description** | Verify AI can answer questions about uploaded documents |
| **Pre-conditions** | - Document with known content uploaded (e.g., "The capital of France is Paris") |

**Test Steps:**
1. Upload test document containing specific fact
2. Wait for processing
3. Start new chat
4. Reference document using # command
5. Ask question about content: "What is the capital of France according to this document?"
6. Verify AI responds with correct answer from document
7. Check if response mentions document source

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - AI retrieves correct information<br>- Answer matches document content<br>- Source cited | | ⬜ Pass<br>⬜ Fail | |

---

### TC-007-003: Context Retrieval Accuracy

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-007-003 |
| **Priority** | HIGH |
| **Category** | RAG |
| **Description** | Verify AI finds most relevant document sections |
| **Pre-conditions** | - Document with multiple topics uploaded |

**Test Steps:**
1. Upload document covering multiple topics (e.g., animals, colors, numbers)
2. Ask specific question: "What does the document say about animals?"
3. Verify response focuses on animal section
4. Ask different question: "What colors are mentioned?"
5. Verify response shifts to color section
6. Check responses don't confuse topics

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Retrieves relevant sections only<br>- Doesn't mix unrelated content<br>- Answers are focused | | ⬜ Pass<br>⬜ Fail | |

---

### TC-007-004: Citations and Sources

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-007-004 |
| **Priority** | MEDIUM |
| **Category** | RAG |
| **Description** | Verify responses show source references |
| **Pre-conditions** | - TC-007-002 passed |

**Test Steps:**
1. Ask question referencing uploaded document
2. Wait for response
3. Check if response includes:
   - Document name/title
   - Page number (if available)
   - Quote or excerpt indicator
4. Verify citation is clickable/linkable

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Source document mentioned<br>- Citation format clear<br>- Can navigate to source | | ⬜ Pass<br>⬜ Fail | |

---

### TC-007-005: Multiple Document Query

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-007-005 |
| **Priority** | MEDIUM |
| **Category** | RAG |
| **Description** | Verify AI can query across multiple documents |
| **Pre-conditions** | - At least 3 documents uploaded with different content |

**Test Steps:**
1. Upload Doc A about "cats"
2. Upload Doc B about "dogs"
3. Upload Doc C about "birds"
4. Wait for processing
5. Ask: "Compare what the documents say about different animals"
6. Verify response references all 3 documents
7. Check if AI synthesizes information from multiple sources

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - AI searches all documents<br>- Combines information<br>- Cites multiple sources | | ⬜ Pass<br>⬜ Fail | |

---

### TC-007-006: Relevance Quality

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-007-006 |
| **Priority** | MEDIUM |
| **Category** | RAG |
| **Description** | Verify retrieved content is accurate and relevant |
| **Pre-conditions** | - Document with known facts uploaded |

**Test Steps:**
1. Upload document with specific facts
2. Ask 5 different questions about content
3. For each response, verify:
   - Information is factually correct
   - Comes from the document
   - Doesn't hallucinate
   - Relevance score is reasonable
4. Try asking about content NOT in document
5. Verify AI indicates information is not available

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - High accuracy (>90%)<br>- No hallucinations<br>- Indicates when info not found | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 8: WEB INTEGRATION

### TC-008-001: SearxNG Backend Accessible

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-008-001 |
| **Priority** | HIGH |
| **Category** | Web Search |
| **Description** | Verify SearxNG service is accessible |
| **Pre-conditions** | - SSH access to server |

**Test Steps:**
1. SSH to server
2. Run: `curl -s http://localhost:8081/ | grep searx`
3. Verify SearxNG page loads
4. Run: `curl -H 'X-Forwarded-For: 127.0.0.1' 'http://localhost:8081/search?q=test&format=json'`
5. Verify JSON response with search results

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - SearxNG responds<br>- Search API works<br>- Returns valid JSON | | ⬜ Pass<br>⬜ Fail | |

---

### TC-008-002: Web Search Toggle

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-008-002 |
| **Priority** | HIGH |
| **Category** | Web Search |
| **Description** | Verify web search can be enabled/disabled in settings |
| **Pre-conditions** | - User is logged in<br>- Admin privileges |

**Test Steps:**
1. Navigate to Settings
2. Find "Web Search" section
3. Check current status (enabled/disabled)
4. Toggle web search ON if disabled
5. Save settings
6. Verify setting persists after refresh
7. Toggle OFF
8. Verify it can be disabled

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Web search toggle exists<br>- Can be enabled/disabled<br>- Setting persists | | ⬜ Pass<br>⬜ Fail | |

---

### TC-008-003: Current Information Query

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-008-003 |
| **Priority** | HIGH |
| **Category** | Web Search |
| **Description** | Verify AI can search web for current information |
| **Pre-conditions** | - Web search enabled (TC-008-002 passed) |

**Test Steps:**
1. Start new chat
2. Enable web search for this chat (if needed)
3. Ask: "What is the latest news about artificial intelligence?"
4. Wait for response
5. Verify response includes:
   - Recent/current information
   - Multiple sources
   - URLs or links
6. Check timestamps are recent (within days/weeks)

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Web search executes<br>- Recent information returned<br>- Sources cited | | ⬜ Pass<br>⬜ Fail | |

---

### TC-008-004: Web Citations

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-008-004 |
| **Priority** | MEDIUM |
| **Category** | Web Search |
| **Description** | Verify search results show proper source citations |
| **Pre-conditions** | - TC-008-003 passed |

**Test Steps:**
1. Ask question requiring web search
2. Wait for response
3. Check response for:
   - Website names/domains
   - URLs (clickable links)
   - Article titles
   - Publication dates
4. Click a citation link
5. Verify it opens correct source

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Citations include URLs<br>- Links are clickable<br>- Sources are valid | | ⬜ Pass<br>⬜ Fail | |

---

### TC-008-005: URL Processing with # Command

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-008-005 |
| **Priority** | MEDIUM |
| **Category** | Web Search |
| **Description** | Verify specific URLs can be referenced with # command |
| **Pre-conditions** | - Web search enabled |

**Test Steps:**
1. Start new chat
2. Type "#" followed by a URL (e.g., "# https://wikipedia.org/wiki/Artificial_intelligence")
3. Add question: "Summarize this page"
4. Send message
5. Verify AI fetches and processes the URL
6. Check if summary relates to page content

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - URL is fetched<br>- Content processed<br>- Relevant summary provided | | ⬜ Pass<br>⬜ Fail | |

---

### TC-008-006: Web Content Analysis

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-008-006 |
| **Priority** | MEDIUM |
| **Category** | Web Search |
| **Description** | Verify AI can analyze web page content |
| **Pre-conditions** | - TC-008-005 passed |

**Test Steps:**
1. Reference a known webpage
2. Ask AI to analyze specific aspects:
   - "What is the main topic?"
   - "List key points"
   - "Who is the author?"
3. Verify answers match actual page content
4. Check if AI can extract structured information

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Accurate content extraction<br>- Can answer specific questions<br>- No hallucination | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 9: CODE EXECUTION

### TC-009-001: Jupyter Backend Accessible

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-009-001 |
| **Priority** | HIGH |
| **Category** | Code Execution |
| **Description** | Verify Jupyter service is accessible |
| **Pre-conditions** | - SSH access to server |

**Test Steps:**
1. SSH to server
2. Run: `curl -s http://localhost:8888/ | grep Jupyter`
3. Verify Jupyter page loads
4. Run: `docker logs team1-jupyter --tail 20`
5. Check for "Jupyter Server is running" message

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Jupyter responds<br>- Service running<br>- No errors in logs | | ⬜ Pass<br>⬜ Fail | |

---

### TC-009-002: Code Interpreter Toggle

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-009-002 |
| **Priority** | HIGH |
| **Category** | Code Execution |
| **Description** | Verify code execution can be enabled in settings |
| **Pre-conditions** | - User is logged in<br>- Admin privileges |

**Test Steps:**
1. Navigate to Settings
2. Find "Code Execution" or "Code Interpreter" section
3. Check current status
4. Toggle code execution ON if disabled
5. Save settings
6. Verify setting persists after refresh

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Code execution toggle exists<br>- Can be enabled<br>- Setting persists | | ⬜ Pass<br>⬜ Fail | |

---

### TC-009-003: Simple Python Execution

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-009-003 |
| **Priority** | HIGH |
| **Category** | Code Execution |
| **Description** | Verify basic Python code executes correctly |
| **Pre-conditions** | - Code execution enabled (TC-009-002 passed) |

**Test Steps:**
1. Start new chat
2. Send message: "Calculate 2 + 2 using Python"
3. Verify AI generates code
4. Check if code executes automatically
5. Verify result shows "4"
6. Send message: "Print 'Hello World'"
7. Verify output appears in chat

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Code executes successfully<br>- Correct output displayed<br>- No execution errors | | ⬜ Pass<br>⬜ Fail | |

---

### TC-009-004: Plot Generation

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-009-004 |
| **Priority** | HIGH |
| **Category** | Code Execution |
| **Description** | Verify plotting and visualization works |
| **Pre-conditions** | - TC-009-003 passed |

**Test Steps:**
1. Start new chat
2. Send message: "Plot y = x² from -10 to 10"
3. Wait for AI to generate and execute code
4. Verify:
   - Code uses matplotlib or similar
   - Code executes without errors
   - Plot image appears in chat
   - Plot shows parabola shape
5. Send message: "Plot sine wave"
6. Verify second plot appears

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Plots generate successfully<br>- Images display in chat<br>- Graphs are correct | | ⬜ Pass<br>⬜ Fail | |

---

### TC-009-005: Error Handling

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-009-005 |
| **Priority** | MEDIUM |
| **Category** | Code Execution |
| **Description** | Verify code errors are displayed properly |
| **Pre-conditions** | - Code execution enabled |

**Test Steps:**
1. Start new chat
2. Send message: "Execute this code: print(undefined_variable)"
3. Wait for execution
4. Verify error message appears
5. Check if error includes:
   - Error type (NameError)
   - Error message
   - Line number
6. Verify chat doesn't crash

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Error displayed clearly<br>- Includes error details<br>- System remains stable | | ⬜ Pass<br>⬜ Fail | |

---

### TC-009-006: Package Installation

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-009-006 |
| **Priority** | MEDIUM |
| **Category** | Code Execution |
| **Description** | Verify additional packages can be installed |
| **Pre-conditions** | - Code execution enabled |

**Test Steps:**
1. Start new chat
2. Send message: "Install and use the 'requests' package to check if a URL is reachable"
3. Wait for AI to generate code
4. Verify code includes package installation (pip install)
5. Check if code executes successfully
6. Verify package functionality works

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Package installs successfully<br>- Installed package is usable<br>- No permission errors | | ⬜ Pass<br>⬜ Fail | |

---

### TC-009-007: Session Persistence

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-009-007 |
| **Priority** | MEDIUM |
| **Category** | Code Execution |
| **Description** | Verify variables persist within code execution session |
| **Pre-conditions** | - Code execution enabled |

**Test Steps:**
1. Start new chat
2. Send message: "Create a variable x = 42"
3. Wait for execution
4. Send message: "What is the value of x?"
5. Verify AI retrieves x = 42
6. Send message: "Add 8 to x"
7. Verify result is 50

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Variables persist across messages<br>- Values maintained in session<br>- Can reference previous variables | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 10: VOICE CAPABILITIES

### TC-010-001: Microphone Access

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-010-001 |
| **Priority** | MEDIUM |
| **Category** | Voice |
| **Description** | Verify browser microphone permissions can be granted |
| **Pre-conditions** | - User is logged in<br>- Browser supports microphone |

**Test Steps:**
1. Navigate to chat interface
2. Look for microphone icon/button
3. Click microphone button
4. Check if browser prompts for permission
5. Grant microphone access
6. Verify microphone icon shows active/listening state

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Microphone button visible<br>- Permission prompt appears<br>- Access granted successfully | | ⬜ Pass<br>⬜ Fail | |

---

### TC-010-002: Voice Input Basic

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-010-002 |
| **Priority** | HIGH |
| **Category** | Voice |
| **Description** | Verify speech gets transcribed to text |
| **Pre-conditions** | - TC-010-001 passed<br>- Microphone access granted |

**Test Steps:**
1. Click microphone button to start recording
2. Speak clearly: "Hello, this is a test"
3. Click stop recording or wait for auto-stop
4. Wait for transcription
5. Verify text appears in input field
6. Check if transcription matches spoken words

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Recording starts<br>- Speech transcribed correctly<br>- Text appears in input | | ⬜ Pass<br>⬜ Fail | |

---

### TC-010-003: Whisper STT Accuracy

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-010-003 |
| **Priority** | MEDIUM |
| **Category** | Voice |
| **Description** | Verify transcription accuracy is acceptable |
| **Pre-conditions** | - TC-010-002 passed |

**Test Steps:**
1. Record 5 different sentences:
   - Simple: "What is the weather today?"
   - Complex: "Can you explain quantum entanglement?"
   - Numbers: "The code is one two three four"
   - Proper nouns: "My name is John Smith"
   - Technical: "Initialize the database connection"
2. For each, check transcription accuracy
3. Calculate percentage of correctly transcribed words

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Accuracy > 80%<br>- Common words correct<br>- Minimal errors | | ⬜ Pass<br>⬜ Fail | |

---

### TC-010-004: TTS Backend (If Enabled)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-010-004 |
| **Priority** | LOW |
| **Category** | Voice |
| **Description** | Verify text-to-speech works if enabled |
| **Pre-conditions** | - TTS enabled in config<br>- Speakers/headphones available |

**Test Steps:**
1. Navigate to Settings → Voice
2. Check if TTS is enabled
3. Send chat message
4. Wait for AI response
5. Check if speaker icon appears
6. Click speaker icon
7. Verify audio plays with AI response

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - TTS option available<br>- Audio plays<br>- Speech is clear | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A (Disabled) | TTS is disabled by default |

---

### TC-010-005: Voice Output Quality

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-010-005 |
| **Priority** | LOW |
| **Category** | Voice |
| **Description** | Verify TTS voice quality is acceptable |
| **Pre-conditions** | - TC-010-004 passed |

**Test Steps:**
1. Enable TTS
2. Send message with varied content:
   - Simple text
   - Numbers
   - Punctuation
3. Play audio response
4. Check voice quality:
   - Clarity
   - Natural tone
   - Proper pronunciation
   - Punctuation handling

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Voice sounds natural<br>- Pronunciation correct<br>- Punctuation respected | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-010-006: Voice Settings

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-010-006 |
| **Priority** | LOW |
| **Category** | Voice |
| **Description** | Verify voice settings can be configured |
| **Pre-conditions** | - Voice features available |

**Test Steps:**
1. Navigate to Settings → Voice
2. Check for available options:
   - Voice speed
   - Voice selection (different voices)
   - Volume control
   - Language selection
3. Change voice speed to "fast"
4. Test TTS with new setting
5. Change voice (if multiple available)
6. Test again

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Settings accessible<br>- Changes take effect<br>- Multiple options available | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-010-007: Voice Call Mode

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-010-007 |
| **Priority** | LOW |
| **Category** | Voice |
| **Description** | Verify hands-free conversation mode works |
| **Pre-conditions** | - Both STT and TTS working |

**Test Steps:**
1. Look for "Voice Call" or "Hands-free" mode button
2. Enable voice call mode
3. Speak a question
4. Verify:
   - Speech transcribed
   - AI responds automatically
   - Response is spoken
   - Can continue conversation hands-free
5. Speak follow-up question
6. Verify conversation flows naturally

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Voice call mode available<br>- Hands-free conversation works<br>- Natural flow | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

## PHASE 11: IMAGE CAPABILITIES

### TC-011-001: Image Upload

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-011-001 |
| **Priority** | HIGH |
| **Category** | Images |
| **Description** | Verify images can be uploaded to chat |
| **Pre-conditions** | - User is logged in<br>- Test image file available (JPG) |

**Test Steps:**
1. Start new chat
2. Click attachment/paperclip icon
3. Select "Image" or file upload
4. Choose test image file
5. Click Upload/Open
6. Wait for upload
7. Verify image appears in chat
8. Check image displays correctly

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Upload completes<br>- Image displays in chat<br>- Image is not distorted | | ⬜ Pass<br>⬜ Fail | |

---

### TC-011-002: Image Display

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-011-002 |
| **Priority** | MEDIUM |
| **Category** | Images |
| **Description** | Verify images render correctly in conversations |
| **Pre-conditions** | - TC-011-001 passed |

**Test Steps:**
1. Upload image to chat
2. Send several text messages
3. Scroll up to image
4. Verify image still displays
5. Click image to enlarge (if available)
6. Check if full-size view works
7. Close full-size view
8. Verify can continue chatting

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Image persists in chat<br>- Can enlarge/view full size<br>- No display issues | | ⬜ Pass<br>⬜ Fail | |

---

### TC-011-003: Image Analysis (Vision)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-011-003 |
| **Priority** | MEDIUM |
| **Category** | Images |
| **Description** | Verify AI can describe/analyze images |
| **Pre-conditions** | - TC-011-001 passed<br>- Vision-capable model selected |

**Test Steps:**
1. Upload image with clear content (e.g., photo of a cat)
2. Send message: "What do you see in this image?"
3. Wait for AI response
4. Verify response describes image content
5. Ask follow-up: "What color is it?"
6. Verify AI answers correctly

**Note:** May require vision-capable model like GPT-4V or Claude 3

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - AI describes image<br>- Description is accurate<br>- Can answer follow-ups | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A (No vision model) | |

---

### TC-011-004: Image Generation

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-011-004 |
| **Priority** | MEDIUM |
| **Category** | Images |
| **Description** | Verify text-to-image generation works |
| **Pre-conditions** | - Image generation configured<br>- API keys set (if needed) |

**Test Steps:**
1. Start new chat
2. Send message: "Generate an image of a sunset over mountains"
3. Wait for generation (may take 10-30 seconds)
4. Verify image is generated
5. Check if image matches description
6. Try another prompt: "Draw a red bicycle"
7. Verify second image generates

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Image generates successfully<br>- Matches text description<br>- Reasonable quality | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A (Not configured) | |

---

### TC-011-005: Multiple Image Formats

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-011-005 |
| **Priority** | LOW |
| **Category** | Images |
| **Description** | Verify different image formats are supported |
| **Pre-conditions** | - Image upload working (TC-011-001 passed) |

**Test Steps:**
1. Upload JPEG image
2. Verify it displays
3. Upload PNG image
4. Verify it displays
5. Upload WEBP image (if available)
6. Verify it displays
7. Try uploading GIF
8. Note if animated GIFs work

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - JPEG: works<br>- PNG: works<br>- WEBP: works<br>- GIF: works or gracefully handled | | ⬜ Pass<br>⬜ Fail | |

---

### TC-011-006: Image Generation Settings

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-011-006 |
| **Priority** | LOW |
| **Category** | Images |
| **Description** | Verify image generation parameters can be configured |
| **Pre-conditions** | - Image generation available |

**Test Steps:**
1. Navigate to Settings → Image Generation
2. Check for available parameters:
   - Model selection
   - Image size
   - Quality/steps
   - Number of images
3. Change image size to "large"
4. Generate test image
5. Verify image size changed

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Settings accessible<br>- Parameters adjustable<br>- Changes take effect | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

## PHASE 12: TOOLS & EXTENSIONS

### TC-012-001: Tools Access

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-012-001 |
| **Priority** | MEDIUM |
| **Category** | Tools |
| **Description** | Verify tools section is accessible |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Navigate to main menu
2. Look for "Tools" section
3. Click on Tools
4. Verify tools list loads
5. Check if any default tools are listed
6. Note tool categories/types available

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Tools section exists<br>- Can access tools list<br>- UI loads properly | | ⬜ Pass<br>⬜ Fail | |

---

### TC-012-002: Tool Activation

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-012-002 |
| **Priority** | MEDIUM |
| **Category** | Tools |
| **Description** | Verify tools can be enabled for models |
| **Pre-conditions** | - TC-012-001 passed<br>- At least one tool available |

**Test Steps:**
1. Go to Tools section
2. Select a tool from list
3. Look for "Enable" or "Activate" option
4. Enable the tool
5. Go to chat settings
6. Verify tool appears in available tools for chat
7. Enable tool for current chat

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Can enable tools<br>- Tools appear in chat settings<br>- Can be assigned to chats | | ⬜ Pass<br>⬜ Fail | |

---

### TC-012-003: Built-in Tools Function

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-012-003 |
| **Priority** | MEDIUM |
| **Category** | Tools |
| **Description** | Verify default/built-in tools work correctly |
| **Pre-conditions** | - Built-in tools enabled |

**Test Steps:**
1. Start new chat
2. Enable a built-in tool (e.g., web search, calculator)
3. Trigger tool usage:
   - For web search: Ask "What's the weather?"
   - For calculator: Ask "Calculate 123 * 456"
4. Verify tool executes
5. Check if result is correct
6. Verify tool usage is indicated in response

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Tool executes automatically<br>- Correct result returned<br>- Tool usage visible | | ⬜ Pass<br>⬜ Fail | |

---

### TC-012-004: Python Functions (Function Calling)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-012-004 |
| **Priority** | MEDIUM |
| **Category** | Tools |
| **Description** | Verify native function calling works |
| **Pre-conditions** | - Function calling enabled<br>- Compatible model selected |

**Test Steps:**
1. Create or select chat with function-capable model
2. Define a simple function (if UI supports it)
3. Or use pre-defined function
4. Send message that should trigger function
5. Verify function is called
6. Check parameters passed correctly
7. Verify function result used in response

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Function calling works<br>- Parameters correct<br>- Result integrated | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-012-005: Tool Permissions

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-012-005 |
| **Priority** | LOW |
| **Category** | Tools |
| **Description** | Verify proper access control for tools |
| **Pre-conditions** | - Multiple users with different roles |

**Test Steps:**
1. As admin, enable a restricted tool
2. Log out
3. Log in as regular user
4. Try to access the tool
5. Verify appropriate restrictions:
   - Admin tools not visible to users
   - Or permission prompt appears
6. Log back in as admin
7. Verify admin can manage tool permissions

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Permission system works<br>- Non-admins properly restricted<br>- Admins have full access | | ⬜ Pass<br>⬜ Fail | |

---

### TC-012-006: Custom Tools (Community)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-012-006 |
| **Priority** | LOW |
| **Category** | Tools |
| **Description** | Verify custom/community tools can be imported |
| **Pre-conditions** | - Admin access<br>- Tool import feature available |

**Test Steps:**
1. Navigate to Tools → Import/Add
2. Look for option to add custom tool
3. Try importing a tool:
   - From URL (if supported)
   - From file upload
   - From marketplace (if available)
4. Verify tool imports successfully
5. Enable the imported tool
6. Test tool functionality

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Import option exists<br>- Custom tools can be added<br>- Imported tools work | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-012-007: Function/Tool Editor

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-012-007 |
| **Priority** | LOW |
| **Category** | Tools |
| **Description** | Verify code editor for tools/functions works |
| **Pre-conditions** | - Admin access<br>- Tool editing available |

**Test Steps:**
1. Go to Tools section
2. Click "Create New Tool" or edit existing
3. Verify code editor opens
4. Check editor features:
   - Syntax highlighting
   - Auto-complete
   - Error checking
5. Write simple function
6. Save function
7. Test function in chat

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Editor functional<br>- Code can be written/edited<br>- Functions can be saved and used | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 13: ADVANCED FEATURES

### TC-013-001: Memory System

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-013-001 |
| **Priority** | MEDIUM |
| **Category** | Advanced |
| **Description** | Verify AI remembers information across sessions |
| **Pre-conditions** | - Memory feature enabled |

**Test Steps:**
1. Start new chat
2. Tell AI: "Remember that my favorite color is blue"
3. Wait for acknowledgment
4. End chat or start new chat
5. In new session ask: "What is my favorite color?"
6. Verify AI responds with "blue"
7. Check if memory persists across days

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - AI stores memory<br>- Can recall across sessions<br>- Memory persists | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-013-002: Editable Memories

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-013-002 |
| **Priority** | LOW |
| **Category** | Advanced |
| **Description** | Verify stored memories can be viewed and modified |
| **Pre-conditions** | - TC-013-001 passed<br>- Memory management UI available |

**Test Steps:**
1. Navigate to Settings → Memories or Profile
2. Verify list of stored memories
3. Select a memory
4. Edit the memory (change content)
5. Save changes
6. Test in chat that updated memory is used
7. Try deleting a memory
8. Verify deleted memory is no longer used

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Can view memories<br>- Can edit memories<br>- Can delete memories | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-013-003: Chat Templates

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-013-003 |
| **Priority** | MEDIUM |
| **Category** | Advanced |
| **Description** | Verify chat templates and presets work |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Navigate to Templates or Presets section
2. Create new template:
   - Name: "Code Helper"
   - System prompt: "You are a coding assistant"
   - Model: llama3.2
3. Save template
4. Start new chat using template
5. Verify system prompt is applied
6. Verify correct model selected
7. Test that template can be reused

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Templates can be created<br>- Templates are reusable<br>- Settings persist | | ⬜ Pass<br>⬜ Fail | |

---

### TC-013-004: Filter Functions

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-013-004 |
| **Priority** | LOW |
| **Category** | Advanced |
| **Description** | Verify request/response filters work |
| **Pre-conditions** | - Admin access<br>- Filter feature available |

**Test Steps:**
1. Navigate to Settings → Filters
2. Create request filter (e.g., remove profanity)
3. Create response filter (e.g., add disclaimer)
4. Save filters
5. Send message with trigger word
6. Verify filters are applied
7. Check request modified
8. Check response includes filter output

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Filters can be created<br>- Filters process requests/responses<br>- Filters work correctly | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-013-005: Pipelines Service

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-013-005 |
| **Priority** | LOW |
| **Category** | Advanced |
| **Description** | Verify custom pipelines/workflows function |
| **Pre-conditions** | - Pipelines service running<br>- SSH access for verification |

**Test Steps:**
1. SSH to server
2. Run: `curl -s http://localhost:9099/ | grep status`
3. Verify pipelines service responds
4. In UI, navigate to Pipelines section (if available)
5. Check if custom pipelines can be created
6. Test a simple pipeline if available

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Pipelines service healthy<br>- UI accessible<br>- Pipelines can be used | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-013-006: API Access

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-013-006 |
| **Priority** | MEDIUM |
| **Category** | Advanced |
| **Description** | Verify OpenWebUI API endpoints work |
| **Pre-conditions** | - API enabled<br>- API key generated |

**Test Steps:**
1. Navigate to Settings → API Keys
2. Generate new API key
3. Copy API key
4. Test API using curl:
   ```bash
   curl -H "Authorization: Bearer <key>" \
   https://team1-openwebui.valuechainhackers.xyz/api/v1/chats
   ```
5. Verify API responds with data
6. Try creating chat via API
7. Verify chat appears in UI

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - API keys can be generated<br>- API endpoints respond<br>- API functions correctly | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 14: COLLABORATION

### TC-014-001: Multiple Users

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-014-001 |
| **Priority** | MEDIUM |
| **Category** | Collaboration |
| **Description** | Verify additional user accounts can be created |
| **Pre-conditions** | - Admin account exists<br>- Signup enabled |

**Test Steps:**
1. Log in as admin
2. Navigate to Settings → Users
3. Click "Add User" or provide signup link
4. Create second user account:
   - Email: testuser@example.com
   - Password: TestPass123
5. Log out from admin
6. Log in with new user account
7. Verify new user can access platform
8. Log back in as admin
9. Verify user appears in user list

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - New users can be created<br>- Users can log in<br>- Users appear in admin panel | | ⬜ Pass<br>⬜ Fail | |

---

### TC-014-002: User Groups

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-014-002 |
| **Priority** | LOW |
| **Category** | Collaboration |
| **Description** | Verify users can be organized into groups |
| **Pre-conditions** | - TC-014-001 passed<br>- Multiple users exist |

**Test Steps:**
1. Log in as admin
2. Navigate to Settings → Groups (if available)
3. Create new group: "Team A"
4. Add user to group
5. Set group permissions (if available)
6. Log in as group member
7. Verify group-based features work
8. Check if group permissions are enforced

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Groups can be created<br>- Users can be assigned to groups<br>- Group permissions work | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-014-003: Shared Resources

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-014-003 |
| **Priority** | MEDIUM |
| **Category** | Collaboration |
| **Description** | Verify chats and documents can be shared between users |
| **Pre-conditions** | - Multiple users exist<br>- Content to share available |

**Test Steps:**
1. Log in as User A
2. Create a chat with content
3. Right-click chat or open chat menu
4. Look for "Share" option
5. Share chat with User B
6. Log out and log in as User B
7. Check if shared chat appears
8. Verify User B can access chat content
9. Try sharing a document
10. Verify document sharing works similarly

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Share option available<br>- Chats can be shared<br>- Shared content accessible | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-014-004: Channels (Group Chat)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-014-004 |
| **Priority** | LOW |
| **Category** | Collaboration |
| **Description** | Verify group chat/channels functionality |
| **Pre-conditions** | - Multiple users exist<br>- Channels feature available |

**Test Steps:**
1. Log in as User A
2. Look for "Channels" or "Group Chat"
3. Create new channel: "Project Discussion"
4. Invite User B to channel
5. Send message in channel
6. Log in as User B
7. Verify channel appears
8. Verify User B can see User A's message
9. Send message as User B
10. Log back in as User A
11. Verify User A sees User B's message

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Channels can be created<br>- Multiple users can join<br>- Real-time messaging works | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-014-005: Mentions

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-014-005 |
| **Priority** | LOW |
| **Category** | Collaboration |
| **Description** | Verify @ mentions work for users and models |
| **Pre-conditions** | - Multiple users or shared chat available |

**Test Steps:**
1. In a chat, type "@"
2. Verify dropdown appears with:
   - Available users
   - Available models
3. Select a user: "@UserB"
4. Complete message and send
5. Verify mention is highlighted
6. Log in as mentioned user
7. Check if notification received
8. Try mentioning a model: "@llama3.2"
9. Verify model mention works

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - @ shows suggestions<br>- Users can be mentioned<br>- Notifications work | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-014-006: Real-time Features

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-014-006 |
| **Priority** | LOW |
| **Category** | Collaboration |
| **Description** | Verify live typing indicators and presence |
| **Pre-conditions** | - Shared chat or channel with multiple users |

**Test Steps:**
1. Open shared chat as User A
2. Open same chat as User B (different browser/device)
3. Start typing as User A
4. Check if User B sees typing indicator
5. Send message as User A
6. Verify User B sees message appear immediately
7. Check if "online" presence indicators exist
8. Verify they update correctly

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Typing indicators work<br>- Messages appear in real-time<br>- Presence system functional | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

## PHASE 15: EXTERNAL SERVICES

### TC-015-001: All Containers Running

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-015-001 |
| **Priority** | HIGH |
| **Category** | External Services |
| **Description** | Verify all service containers are healthy |
| **Pre-conditions** | - SSH access to server |

**Test Steps:**
1. SSH to server
2. Run: `docker ps --format 'table {{.Names}}\t{{.Status}}' | grep team1`
3. Count total containers
4. Verify all expected services present:
   - openwebui, ollama, litellm, qdrant, tika
   - searxng, jupyter, whisper, pipelines
   - postgres, redis, neo4j, clickhouse
   - mcpo, watchtower
5. Check health status of each
6. Note any unhealthy services

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - 15 containers running<br>- All services healthy or functional<br>- No critical failures | | ⬜ Pass<br>⬜ Fail | |

---

### TC-015-002: RStudio Access (If Deployed)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-015-002 |
| **Priority** | LOW |
| **Category** | External Services |
| **Description** | Verify RStudio environment is reachable |
| **Pre-conditions** | - RStudio deployed |

**Test Steps:**
1. Check docker compose for RStudio service
2. Note RStudio port mapping
3. Navigate to RStudio URL in browser
4. Verify RStudio interface loads
5. Try logging in (if credentials required)
6. Test basic R functionality

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - RStudio accessible<br>- Login works<br>- R environment functional | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A (Not deployed) | |

---

### TC-015-003: Neo4j Access

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-015-003 |
| **Priority** | MEDIUM |
| **Category** | External Services |
| **Description** | Verify Neo4j graph database is accessible |
| **Pre-conditions** | - Neo4j container running |

**Test Steps:**
1. SSH to server
2. Run: `curl -s http://localhost:7474/ | grep Neo4j`
3. Verify Neo4j Browser interface responds
4. Navigate to Neo4j URL (if exposed externally)
5. Try logging in:
   - Default: neo4j/neo4j (then prompt to change)
6. Run simple query: `MATCH (n) RETURN count(n)`
7. Verify query executes

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Neo4j responds<br>- Browser accessible<br>- Queries can be run | | ⬜ Pass<br>⬜ Fail | |

---

### TC-015-004: n8n Workflows (If Deployed)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-015-004 |
| **Priority** | LOW |
| **Category** | External Services |
| **Description** | Verify n8n automation system works |
| **Pre-conditions** | - n8n deployed |

**Test Steps:**
1. Check docker compose for n8n service
2. Note n8n port mapping
3. Navigate to n8n URL
4. Verify n8n interface loads
5. Try creating simple workflow
6. Test webhook or manual trigger
7. Verify workflow executes

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - n8n accessible<br>- Workflows can be created<br>- Automation works | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A (Not deployed) | |

---

### TC-015-005: Service Integration

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-015-005 |
| **Priority** | MEDIUM |
| **Category** | External Services |
| **Description** | Verify OpenWebUI connects to external services |
| **Pre-conditions** | - All services running |

**Test Steps:**
1. Check OpenWebUI environment variables
2. Verify connection strings configured:
   - QDRANT_URI
   - DATABASE_URL (Postgres)
   - TIKA_SERVER_URL
   - JUPYTER URL
3. Test each integration:
   - Upload doc → Tika processes
   - RAG query → Qdrant responds
   - Code execution → Jupyter executes
4. Check docker logs for connection errors

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - All services connected<br>- Integrations functional<br>- No connection errors | | ⬜ Pass<br>⬜ Fail | |

---

### TC-015-006: Cross-Service Data Flow

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-015-006 |
| **Priority** | LOW |
| **Category** | External Services |
| **Description** | Verify data flows correctly between systems |
| **Pre-conditions** | - Multiple services integrated |

**Test Steps:**
1. Upload document in OpenWebUI
2. Verify Tika extracts text
3. Verify text stored in Postgres
4. Verify embeddings created in Qdrant
5. Query document via chat
6. Trace data flow through:
   - OpenWebUI → Tika → Postgres → Qdrant → OpenWebUI
7. Check logs for data flow
8. Verify no data loss

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Data flows correctly<br>- All steps complete<br>- No data loss or corruption | | ⬜ Pass<br>⬜ Fail | |

---

## PHASE 16: CUSTOMIZATION & POLISH

### TC-016-001: Theme Settings

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-016-001 |
| **Priority** | LOW |
| **Category** | Customization |
| **Description** | Verify dark/light mode switching works |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Navigate to Settings → Appearance
2. Check current theme (dark/light)
3. Click theme toggle
4. Verify interface switches to other theme
5. Check if theme applies to all pages
6. Refresh page
7. Verify theme persists
8. Toggle back
9. Verify smooth transition

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Theme toggle works<br>- Both themes render correctly<br>- Setting persists | | ⬜ Pass<br>⬜ Fail | |

---

### TC-016-002: Language Support

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-016-002 |
| **Priority** | LOW |
| **Category** | Customization |
| **Description** | Verify interface language can be changed |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Navigate to Settings → Language
2. Check available languages
3. Select a different language (e.g., Spanish, French)
4. Verify interface text changes
5. Check if all UI elements translate
6. Navigate through different pages
7. Verify language consistent throughout
8. Switch back to original language

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Multiple languages available<br>- Translation works correctly<br>- Complete coverage | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-016-003: Custom Branding

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-016-003 |
| **Priority** | LOW |
| **Category** | Customization |
| **Description** | Verify logo and colors can be customized |
| **Pre-conditions** | - Admin access |

**Test Steps:**
1. Navigate to Settings → Branding/Appearance
2. Look for customization options:
   - Logo upload
   - Primary color
   - Accent color
   - Custom CSS
3. Upload custom logo
4. Change primary color
5. Save changes
6. Refresh page
7. Verify logo appears
8. Verify colors applied

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Branding options available<br>- Logo can be changed<br>- Colors customizable | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-016-004: Keyboard Shortcuts

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-016-004 |
| **Priority** | LOW |
| **Category** | Customization |
| **Description** | Verify keyboard shortcuts/hotkeys work |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Navigate to chat
2. Test common shortcuts:
   - Ctrl+K or Cmd+K (command palette)
   - Ctrl+N (new chat)
   - Ctrl+/ (shortcuts help)
   - Esc (close modals)
3. Verify each shortcut works
4. Check if shortcuts help/reference exists
5. Try customizing shortcuts (if available)

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Shortcuts work<br>- Help reference available<br>- Common actions accessible | | ⬜ Pass<br>⬜ Fail | |

---

### TC-016-005: Command Palette

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-016-005 |
| **Priority** | LOW |
| **Category** | Customization |
| **Description** | Verify command palette quick actions work |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Press Ctrl+K or Cmd+K
2. Verify command palette opens
3. Type "new" → See "New Chat" option
4. Select "New Chat"
5. Verify new chat created
6. Open palette again
7. Try other commands:
   - Settings
   - Documents
   - Models
8. Verify commands execute

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Palette opens with shortcut<br>- Commands searchable<br>- Commands execute correctly | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-016-006: Interface Layout

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-016-006 |
| **Priority** | LOW |
| **Category** | Customization |
| **Description** | Verify UI layout can be customized |
| **Pre-conditions** | - User is logged in |

**Test Steps:**
1. Check for layout customization options:
   - Sidebar width
   - Message bubble style
   - Font size
   - Compact/comfortable mode
2. Adjust sidebar width
3. Verify it changes
4. Change font size
5. Verify text scales
6. Try different density modes
7. Verify preferences save

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Layout options available<br>- Changes apply immediately<br>- Settings persist | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

## PHASE 17: MONITORING & MAINTENANCE

### TC-017-001: System Monitoring

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-017-001 |
| **Priority** | MEDIUM |
| **Category** | Monitoring |
| **Description** | Verify usage and performance can be tracked |
| **Pre-conditions** | - Admin access |

**Test Steps:**
1. Navigate to Settings → Admin → Monitoring
2. Check for available metrics:
   - Active users
   - Message count
   - Token usage
   - API calls
   - Error rate
3. Verify metrics display correctly
4. Check if metrics update
5. Look for charts/graphs
6. Verify data accuracy

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Monitoring dashboard exists<br>- Metrics are tracked<br>- Data is accurate | | ⬜ Pass<br>⬜ Fail<br>⬜ N/A | |

---

### TC-017-002: Error Logging

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-017-002 |
| **Priority** | MEDIUM |
| **Category** | Monitoring |
| **Description** | Verify errors are logged properly |
| **Pre-conditions** | - SSH access to server |

**Test Steps:**
1. SSH to server
2. Check OpenWebUI logs:
   ```bash
   docker logs team1-openwebui --tail 100
   ```
3. Trigger an error in UI (e.g., upload invalid file)
4. Check logs again
5. Verify error appears in logs
6. Check if error includes:
   - Timestamp
   - Error type
   - Stack trace
   - User context
7. Check other service logs similarly

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Errors are logged<br>- Logs include details<br>- Logs are accessible | | ⬜ Pass<br>⬜ Fail | |

---

### TC-017-003: Health Monitoring

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-017-003 |
| **Priority** | HIGH |
| **Category** | Monitoring |
| **Description** | Verify health endpoints report correctly |
| **Pre-conditions** | - Services running |

**Test Steps:**
1. SSH to server
2. Test health endpoints:
   ```bash
   curl http://localhost:8080/health
   curl http://localhost:6333/healthz
   curl http://localhost:9099/
   ```
3. Verify all return healthy status
4. Check external health endpoint:
   ```bash
   curl https://team1-openwebui.valuechainhackers.xyz/health
   ```
5. Verify accessible from outside

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - All services report healthy<br>- Health checks respond quickly<br>- External access works | | ⬜ Pass<br>⬜ Fail | |

---

### TC-017-004: Backup Procedures

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-017-004 |
| **Priority** | HIGH |
| **Category** | Monitoring |
| **Description** | Verify backup/restore process works |
| **Pre-conditions** | - Admin access<br>- SSH access |

**Test Steps:**
1. Create test data (chat, document)
2. Navigate to Admin → Export
3. Download backup
4. Verify backup file downloaded
5. Check backup file size > 0
6. Optional: Simulate restore
7. Verify test data can be recovered
8. Check automated backup schedule (if configured)

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Backup can be created<br>- Backup file is valid<br>- Restore works (if tested) | | ⬜ Pass<br>⬜ Fail | |

---

### TC-017-005: Update Process

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-017-005 |
| **Priority** | MEDIUM |
| **Category** | Monitoring |
| **Description** | Verify components can be upgraded safely |
| **Pre-conditions** | - Watchtower running<br>- SSH access |

**Test Steps:**
1. SSH to server
2. Check current versions:
   ```bash
   docker ps --format '{{.Image}}' | grep team1
   ```
3. Check Watchtower logs:
   ```bash
   docker logs team1-watchtower --tail 50
   ```
4. Verify Watchtower is monitoring
5. Check if update schedule configured
6. Test manual update (optional):
   ```bash
   docker compose pull openwebui
   docker compose up -d openwebui
   ```
7. Verify service remains stable after update

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Watchtower active<br>- Updates can be performed<br>- Service stability maintained | | ⬜ Pass<br>⬜ Fail | |

---

### TC-017-006: Security Audit

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-017-006 |
| **Priority** | MEDIUM |
| **Category** | Monitoring |
| **Description** | Verify permissions and access controls are proper |
| **Pre-conditions** | - Admin access<br>- Multiple users exist |

**Test Steps:**
1. Review user permissions:
   - Admin has full access
   - Users have appropriate restrictions
2. Test unauthorized access:
   - Try accessing admin features as regular user
   - Verify proper denial
3. Check API security:
   - Verify API requires authentication
   - Test with invalid key
4. Review exposed ports:
   - Check which services are externally accessible
   - Verify only necessary ports open
5. Check password policies
6. Verify HTTPS is enforced

| Expected Result | Actual Result | Status | Notes |
|-----------------|---------------|--------|-------|
| - Permissions properly enforced<br>- Unauthorized access denied<br>- Security best practices followed | | ⬜ Pass<br>⬜ Fail | |

---

## Test Summary Template

**Test Date:** ___________
**Tested By:** ___________
**Environment:** team1-openwebui.valuechainhackers.xyz

### Summary Statistics

| Category | Total Tests | Passed | Failed | N/A | Pass Rate |
|----------|-------------|--------|--------|-----|-----------|
| Phase 4: Basic Chat | 7 | | | | |
| Phase 5: Storage | 5 | | | | |
| Phase 6: Documents | 5 | | | | |
| Phase 7: RAG | 6 | | | | |
| Phase 8: Web Search | 6 | | | | |
| Phase 9: Code Execution | 7 | | | | |
| Phase 10: Voice | 7 | | | | |
| Phase 11: Images | 6 | | | | |
| Phase 12: Tools | 7 | | | | |
| Phase 13: Advanced | 6 | | | | |
| Phase 14: Collaboration | 6 | | | | |
| Phase 15: External Services | 6 | | | | |
| Phase 16: Customization | 6 | | | | |
| Phase 17: Monitoring | 6 | | | | |
| **TOTAL** | **82** | | | | |

### Critical Issues Found

| Issue ID | Severity | Description | Test Case | Status |
|----------|----------|-------------|-----------|--------|
| | | | | |

### Notes and Observations

_Additional notes from testing session:_

---

**Sign-off:**

Tester: _______________ Date: ___________

Reviewer: _______________ Date: ___________
