# Chat Interface File Upload Issue

**Date:** October 8, 2025
**Status:** Known OpenWebUI v0.6.33 Issue
**Impact:** Chat interface file uploads hang indefinitely
**Workaround:** Use Knowledge Base upload instead

---

## Issue Description

### What Happens
When uploading files via the **chat interface** paperclip icon:
- Small files (< 100KB): ✅ Upload works
- Large files (> 300KB): ⚠️ Upload hangs with infinite loading spinner
- Backend processes file successfully (embeddings generated, file stored)
- Frontend never receives completion signal
- After 6+ minutes, still shows "loading..." with no error

### What Works
- ✅ **Knowledge Base upload**: Works perfectly (takes time but completes)
- ✅ **Small file upload in chat**: Text files < 100KB work fine
- ✅ **RAG functionality**: All uploaded files work correctly once processed
- ✅ **API upload**: Direct API calls work (as proven by test scripts)

---

## Root Cause

This is a **known OpenWebUI v0.6.x bug** related to streaming status endpoints:

1. File uploads to `/api/v1/files/` succeed (200 OK)
2. Frontend polls `/api/v1/files/{id}/process/status?stream=true`
3. Backend processes file and generates embeddings successfully
4. **Streaming endpoint doesn't close properly** when processing completes
5. Frontend waits indefinitely for stream closure that never comes
6. User sees infinite loading spinner

### GitHub Issues
- [Issue #10487](https://github.com/open-webui/open-webui/issues/10487) - Upload status with no ending
- [Discussion #7898](https://github.com/open-webui/open-webui/discussions/7898) - File upload hangs
- Multiple reports across v0.6.13 - v0.6.33

### NOT Caused By
- ❌ My database configuration changes (embedding model, hybrid search)
- ❌ Server performance (embeddings complete successfully)
- ❌ File permissions or storage issues
- ❌ RAG configuration

---

## Testing Results

### Chat Interface Upload Test
**File:** Kamitor_151241984-1.pdf (338 KB)

```
10:14:12 - POST /api/v1/files/ → 200 OK ✓
10:14:12 - GET /api/v1/files/{id}/process/status?stream=true
10:14:12 - Embedding generation starts
10:14:41 - Embeddings generated successfully (29 seconds) ✓
10:14:41 - Added to vector database ✓
10:14:41 - Processing COMPLETE in backend ✓
10:20:00 - Frontend still showing "loading..." ✗
```

**Result:** Backend succeeds, frontend hangs

### Knowledge Base Upload Test
**File:** Same PDF (338 KB)

```
Upload initiated via Workspace → Knowledge → Add File
Processing shows progress indicator
Embeddings generated (29 seconds)
Status changes to "completed" ✓
File appears in knowledge base ✓
Can query file in chat ✓
```

**Result:** Works perfectly!

---

## Workaround for Workshop

### Recommended Approach: Use Knowledge Base

Instead of uploading files directly in chat, use the Knowledge Base:

**Step 1: Upload to Knowledge Base**
1. Click on "Workspace" or sidebar menu
2. Navigate to "Knowledge"
3. Click "+" or "Add to Knowledge"
4. Upload your file
5. Wait for "completed" status (~30 seconds for 300KB PDF)

**Step 2: Use in Chat**
1. Start a new chat
2. Click the knowledge base icon (📚 or similar)
3. Select your uploaded document
4. Ask questions - RAG works perfectly!

### Alternative: Small Files in Chat
- Files < 100KB can be uploaded directly in chat
- Create small test documents for demonstrations
- Example: `/tmp/test-rag-document.txt` (553 bytes) works fine

---

## Workshop Delivery Adjustments

### Module 2: Document RAG

**Original Plan:**
- ~~Upload PDF via chat paperclip icon~~

**Updated Plan:**
1. **Demonstrate Knowledge Base Upload** (5 min)
   - Show how to upload files to Knowledge Base
   - Explain this is more reliable for larger files
   - Wait for "completed" status

2. **Use Files in Chat** (25 min)
   - Show how to select knowledge base documents in chat
   - Participants ask questions using uploaded docs
   - RAG works perfectly this way

3. **Small File Alternative** (Optional)
   - For those who want chat upload experience
   - Provide small (< 50KB) test documents
   - These upload quickly via chat interface

### Talking Points

**If participants ask about the loading issue:**
> "You've discovered a known issue in OpenWebUI v0.6 where large file uploads in chat can hang. The good news is the file uploaded successfully in the background! The Knowledge Base upload method is more reliable and gives you better visibility into the processing status. This is actually how you'd manage documents in production anyway."

**Positive framing:**
- Knowledge Base is the "professional" way to manage documents
- Better organization (can create collections, tag documents)
- More visibility into processing status
- Can reuse documents across multiple chats

---

## Technical Details

### Streaming Endpoint Behavior

The `/api/v1/files/{id}/process/status?stream=true` endpoint:
- Should stream Server-Sent Events (SSE)
- Should send periodic status updates
- Should close stream when `status === 'completed'`
- **Bug:** Stream doesn't close on completion

### Backend Logs (Working Correctly)
```
INFO  generating embeddings for file-191f0fb7-8418-43f6-bae6-d38f1bc22272
INFO  embeddings generated 1 for 1 items
INFO  added 1 items to collection file-191f0fb7-8418-43f6-bae6-d38f1bc22272
INFO  added 1 items to collection file-191f0fb7-8418-43f6-bae6-d38f1bc22272
```
✅ Processing completes successfully

### Frontend Behavior (Hangs)
```javascript
// Frontend polling (simplified)
const checkStatus = async () => {
  const response = await fetch(`/api/v1/files/${fileId}/process/status?stream=true`);
  // Waits for stream to close
  // Stream never closes → infinite wait
};
```
✗ Waits indefinitely for stream closure

---

## Resolution Options

### Short Term (Workshop)
✅ Use Knowledge Base upload method (works perfectly)
✅ Update workshop materials to reflect this workflow
✅ Prepare talking points for participants

### Medium Term
⏳ Monitor OpenWebUI GitHub for fix
⏳ Test future versions (v0.7.x when released)
⏳ Consider filing detailed bug report if not already tracked

### Long Term
⏳ Contribute fix to OpenWebUI if issue persists
⏳ Consider alternative frontends if needed
⏳ Implement custom upload UI if critical

---

## Files Updated

- ✅ [RAG-TEST-RESULTS.md](./RAG-TEST-RESULTS.md) - Performance and testing results
- ✅ [WORKSHOP-TEST-CASES.md](./Version1.2/WORKSHOP-TEST-CASES.md) - Test Case 3 updated
- ⏳ [workshop.qmd](./Version1.2/workshop.qmd) - **NEEDS UPDATE** with Knowledge Base workflow
- ✅ This file - Chat upload issue documentation

---

## Conclusion

**The good news:**
- ✅ RAG functionality works perfectly
- ✅ Files process correctly in backend
- ✅ Knowledge Base upload is reliable
- ✅ Workshop can proceed successfully

**What to communicate:**
- This is a known UI issue in OpenWebUI v0.6.x
- NOT caused by our configuration
- NOT a blocker for workshop
- Knowledge Base method is actually better for production use

**Workshop impact:**
- Minor adjustment to demo workflow
- Add 2-3 minutes to explain Knowledge Base upload
- Actually improves learning (participants see proper document management)
- Zero impact on RAG functionality or learning outcomes
