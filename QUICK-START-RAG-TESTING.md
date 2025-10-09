# Quick Start: Testing RAG Before Workshop

**Total time:** 5 minutes
**When:** 30 minutes before workshop starts

## One-Command Test

```bash
cd /home/chris/Documents/github/Ultimate-OpenWebUI
python3 test-rag-performance.py
```

**Expected output:**
```
✓ Logged in successfully
✓ Success in 54-85 seconds (per query)
✓ Contains expected content: Yes
Average query time: 55-85 seconds
Queries with correct content: 3/3
⚠ WARNING: Queries are slow, may impact workshop experience
```

**This warning is NORMAL** - it just means queries take 1+ minute (acceptable).

## Pass Criteria

✅ **All tests must show:**
- Login: Success
- 3/3 queries successful
- Contains expected content: Yes
- Average time: < 120 seconds

❌ **FAIL if:**
- Any query times out (> 180s)
- Queries return "I don't see any document"
- Error: "list index out of range"
- Error: "404 Not Found"

## Quick Fix for Common Issues

### If queries timeout (> 180s)
```bash
# Check if hybrid search is disabled
ssh root@10.0.8.40 "docker exec team1-postgres psql -U openwebui -d openwebui -c \"SELECT data->'rag'->>'enable_hybrid_search' FROM config WHERE id = 1;\""

# Should return: false
# If returns "true", run:
ssh root@10.0.8.40 "docker exec team1-postgres psql -U openwebui -d openwebui -c \"UPDATE config SET data = jsonb_set(data::jsonb, '{rag,enable_hybrid_search}', 'false', true) WHERE id = 1;\""
ssh root@10.0.8.40 "docker restart team1-openwebui"
# Wait 15 seconds, then re-test
```

### If upload fails with "list index out of range"
```bash
# Check embedding model name
ssh root@10.0.8.40 "docker logs team1-openwebui | grep 'Embedding model set'"

# Should see: "Embedding model set: nomic-embed-text"
# If you see "nomic-embed-test" (typo), run:
ssh root@10.0.8.40 "docker exec team1-postgres psql -U openwebui -d openwebui -c \"UPDATE config SET data = REPLACE(data::text, '\\\"nomic-embed-test\\\"', '\\\"nomic-embed-text\\\"')::json WHERE id = 1;\""
ssh root@10.0.8.40 "docker restart team1-openwebui"
```

## Workshop-Ready Checklist

- [ ] Test script completes successfully (3/3 queries)
- [ ] Average query time < 120 seconds
- [ ] No timeout errors
- [ ] RAG responses contain document-specific content
- [ ] All 15 containers running: `ssh root@10.0.8.40 "docker ps | wc -l"` (should be 16 lines)

## What Participants Will Experience

**Normal behavior:**
1. Upload file → 1 second ✓
2. Wait for embeddings → 30 seconds ⏳
3. Ask question → 60-90 seconds response ⏳
4. Get accurate answer with citations ✓

**NOT bugs:**
- 30 second wait after upload (embedding generation)
- 60-90 second query responses (OpenRouter API)
- These are expected with CPU-only processing

**Set expectations:**
- "Upload takes ~30 seconds to process - this is the AI reading your document"
- "Queries take 1-2 minutes - think about your next question while waiting"
- "Use wait time for discussion with neighbors"

## Emergency Backup Plan

If RAG fails completely 30 min before workshop:

1. **Use pre-loaded documents:** Documents already in knowledge base
2. **Skip upload demo:** Show pre-uploaded documents instead
3. **Focus on queries:** Participants query existing documents
4. **Troubleshoot after Module 1:** Fix during break

## Contact for Help

If nothing works:
- Check [RAG-TEST-RESULTS.md](./RAG-TEST-RESULTS.md) for detailed troubleshooting
- Check server status: `ssh root@10.0.8.40 "docker ps"`
- Check logs: `ssh root@10.0.8.40 "docker logs team1-openwebui --tail 50"`
