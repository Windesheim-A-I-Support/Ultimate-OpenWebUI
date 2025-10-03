# Testing Issues and Fixes

**Date:** 2025-10-03
**Issue:** Test scripts report PASSED even when they fail

---

## Problem Identified

The test scripts fail due to incorrect API endpoints:

```
❌ Failed to create KB: 405 - {"detail":"Method Not Allowed"}
```

However, the bash wrapper (`run-all-tests.sh`) was not properly catching the Python exit codes.

---

## Root Causes

### 1. Wrong API Endpoints

The test scripts use endpoints like:
- `/api/v1/knowledge` → **405 Method Not Allowed**
- `/api/v1/search` → **Not found**
- `/api/v1/code/execute` → **Not found**

**Actual OpenWebUI API structure:**
- OpenWebUI v0.6.32 uses different endpoints
- Need to check actual API docs or inspect network traffic

### 2. Exit Code Handling

The bash script relies on Python's `sys.exit()` but doesn't validate properly.

---

## Solutions

### Quick Fix: Use Simple Test Script

I've created `test-simple.py` which tests endpoints we **know** work:

```bash
./test-simple.py Chris@tonomy.foundation yourpassword
```

**Tests:**
- ✅ Health check (`/health`)
- ✅ Config (`/api/config`)
- ✅ Login (`/api/v1/auths/signin`)
- ✅ Models (`/api/models`)
- ✅ Chats (`/api/v1/chats`)

### Proper Fix: Update API Endpoints

To fix the main test scripts, we need to:

1. **Find correct API endpoints** by:
   - Checking OpenWebUI source code
   - Inspecting browser network tab
   - Checking API documentation

2. **Update Python scripts** with correct endpoints

3. **Test each endpoint** individually before full suite

---

## How to Run Tests Now

### Option 1: Simple Test (Works Now)

```bash
cd Version1.2
./test-simple.py your-email@example.com yourpassword
```

### Option 2: Manual Testing

Test each phase manually:

**Phase 6 (Documents):**
1. Log into https://team1-openwebui.valuechainhackers.xyz
2. Go to Documents/Knowledge
3. Create new knowledge base
4. Upload a PDF
5. Verify it appears

**Phase 7 (RAG):**
1. In chat, reference knowledge base with `#`
2. Ask question about uploaded doc
3. Verify AI retrieves information

**Phase 8 (Web Search):**
1. Enable web search in settings
2. Ask "What's the latest AI news?"
3. Verify search results appear

**Phase 9 (Code):**
1. In chat, send Python code
2. Verify it executes
3. Check output

---

## Next Steps to Fix Automated Tests

### 1. Discover API Endpoints

**Method A: Browser DevTools**
```
1. Open https://team1-openwebui.valuechainhackers.xyz
2. Open DevTools (F12) → Network tab
3. Upload a document
4. Look at the POST request
5. Note the endpoint used
```

**Method B: Source Code**
```bash
# Clone OpenWebUI repo
git clone https://github.com/open-webui/open-webui
cd open-webui

# Search for API routes
grep -r "router.post" backend/apps/
grep -r "knowledge" backend/apps/
```

**Method C: API Documentation**
- Check if OpenWebUI has API docs at `/api/docs` or `/docs`
- Look for Swagger/OpenAPI specs

### 2. Update Test Scripts

Once we have correct endpoints, update:
- `test-phase6-documents.py` → Use correct KB/document endpoints
- `test-phase8-websearch.py` → Use correct search endpoints
- `test-phase9-code.py` → Use correct code execution endpoints

### 3. Add Better Error Handling

```python
def create_knowledge_base(self, name, description):
    try:
        response = self.session.post(...)
        response.raise_for_status()  # Raise exception on 4xx/5xx
        return response.json()
    except requests.exceptions.HTTPError as e:
        print(f"❌ HTTP Error: {e}")
        print(f"   Response: {e.response.text}")
        sys.exit(1)  # Exit immediately on error
```

---

## Temporary Workaround

Until we fix the API endpoints, use **manual testing** with the checklist:

See: [README-CHECKLIST.md](README-CHECKLIST.md)

Each phase has manual testing procedures that work.

---

## Files Status

| File | Status | Issue |
|------|--------|-------|
| `test-simple.py` | ✅ WORKS | Tests basic endpoints only |
| `test-phase6-documents.py` | ❌ BROKEN | Wrong API endpoints |
| `test-phase8-websearch.py` | ❌ BROKEN | Wrong API endpoints |
| `test-phase9-code.py` | ❌ BROKEN | Wrong API endpoints |
| `run-all-tests.sh` | ⚠️ PARTIAL | Runs but doesn't detect failures |

---

## Recommended Action

**For now:**
1. Use `test-simple.py` to verify basic connectivity
2. Use manual testing for Phases 6-9
3. Update README-CHECKLIST.md with test results

**Later:**
1. Find correct API endpoints
2. Update test scripts
3. Re-run automated tests

---

**Would you like me to:**
1. Find the correct API endpoints by inspecting the OpenWebUI source?
2. Create a manual testing checklist you can follow?
3. Both?
