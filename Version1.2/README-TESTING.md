# OpenWebUI Testing Suite - Quick Reference

**Automated testing for Phases 5-9**
**Last Updated:** 2025-10-04

---

## ✅ LATEST TEST RESULTS

**All API tests PASSING (5/5 - 100%)**
- See [TEST-RESULTS-FINAL.md](TEST-RESULTS-FINAL.md) for complete results

---

## 🎯 Quick Commands

### Run Simple API Tests (Verified Working)
```bash
cd Version1.2
/usr/bin/python3 ./test-simple.py chris@tonomy.foundation 'Openbaby100!'
```

### Run Individual Phase Tests
```bash
/usr/bin/python3 ./test-phase6-documents.py chris@tonomy.foundation 'Openbaby100!'  # Documents + RAG
/usr/bin/python3 ./test-phase8-websearch.py chris@tonomy.foundation 'Openbaby100!'  # Web Search
/usr/bin/python3 ./test-phase9-code.py chris@tonomy.foundation 'Openbaby100!'       # Code Execution
```

### Run All Tests
```bash
./run-all-tests.sh chris@tonomy.foundation 'Openbaby100!'
```

### Test Different Teams
```bash
./run-all-tests.sh admin@example.com pass https://team2-openwebui.valuechainhackers.xyz
./run-all-tests.sh admin@example.com pass https://team3-openwebui.valuechainhackers.xyz
```

---

## 📁 Testing Files

| File | Purpose | Status |
|------|---------|--------|
| `test-simple.py` | **Basic API tests** - Health, auth, models | ✅ PASSING |
| `TEST-RESULTS-FINAL.md` | **Latest test results** - Oct 4, 2025 | ✅ 100% |
| `run-all-tests.sh` | Main test runner - Runs all phase tests | 🔧 Ready |
| `test-phase6-documents.py` | Tests document upload & RAG | ⏳ Pending |
| `test-phase8-websearch.py` | Tests web search integration | ⏳ Pending |
| `test-phase9-code.py` | Tests code execution | ⏳ Pending |
| `TESTING-GUIDE.md` | Complete testing documentation | 📚 Docs |
| `TESTING-ISSUES.md` | Known issues & solutions | 📚 Docs |
| `PLAYWRIGHT-TESTING-RESULTS.md` | E2E testing status | ⏸️ Blocked |
| `README-CHECKLIST.md` | Complete 17-phase checklist | 📚 Docs |

---

## ✅ What Gets Tested

### Phase 6 & 7: Documents + RAG
- ✅ Document upload
- ✅ Knowledge base creation
- ✅ Tika text extraction
- ✅ Vector embeddings (Qdrant)
- ✅ RAG queries
- ✅ Multi-document retrieval

### Phase 8: Web Search
- ✅ SearxNG search API
- ✅ Search result retrieval
- ✅ Chat with web search
- ✅ Source citations

### Phase 9: Code Execution
- ✅ Python code execution
- ✅ Data processing (pandas)
- ✅ Visualization (matplotlib)
- ✅ Variable persistence
- ✅ Error handling
- ✅ Code via chat interface

---

## 📊 Test Results

Results are saved to `test-results-YYYYMMDD_HHMMSS/` directory:

```
test-results-20251003_143052/
├── Phase6-7-Documents-RAG.log      # Detailed test log
├── Phase6-7-Documents-RAG.result   # PASSED or FAILED
├── Phase8-WebSearch.log
├── Phase8-WebSearch.result
├── Phase9-CodeExecution.log
├── Phase9-CodeExecution.result
└── summary.html                    # Visual results page
```

**View HTML Report:**
```bash
open test-results-*/summary.html
# or
firefox test-results-*/summary.html
```

---

## 🔧 Prerequisites

**Before running tests:**

1. **Python 3.7+** installed
   ```bash
   /usr/bin/python3 --version
   # Should show: Python 3.11.2 or higher
   ```

2. **requests** library (already available on system)
   ```bash
   /usr/bin/python3 -c "import requests; print('✅ requests available')"
   ```

3. **Test credentials**
   - Email: `chris@tonomy.foundation` (lowercase!)
   - Password: `Openbaby100!`
   - Role: Admin

4. **Services running**
   ```bash
   curl -k https://team1-openwebui.valuechainhackers.xyz/health
   # Should return: {"status":true}
   ```

## ⚠️ Important Notes

1. **Use full Python path:** `/usr/bin/python3` not just `python3`
2. **Email is case-sensitive:** Must be lowercase `chris@tonomy.foundation`
3. **Bot detection:** Tests use curl User-Agent to avoid blocking

---

## 🐛 Troubleshooting

**❌ Login failed: 400**
```bash
# SOLUTION: Use full Python path and lowercase email
/usr/bin/python3 ./test-simple.py chris@tonomy.foundation 'Openbaby100!'
```

**❌ python3: command not found**
```bash
# SOLUTION: Use full path
/usr/bin/python3 ./test-simple.py chris@tonomy.foundation 'Openbaby100!'
```

**❌ Module Not Found: requests**
```bash
# Check if requests is available
/usr/bin/python3 -c "import requests"
# If error, it's installed but using wrong Python
```

**❌ Permission Denied**
```bash
chmod +x *.sh *.py
```

**❌ Connection Issues**
```bash
# Test connection manually
curl -k https://team1-openwebui.valuechainhackers.xyz/health
# Should return: {"status":true}
```

**✅ All tests passing but says FAIL**
```bash
# This was a bug - now fixed in test-simple.py
# Re-download latest version or use /usr/bin/python3
```

---

## 📈 Current Test Status

**As of 2025-10-04:**

| Phase | Infrastructure | Tests Created | Last Run | Status |
|-------|----------------|---------------|----------|--------|
| Phase 4 | ✅ Complete | ✅ API Tests | ✅ Oct 4 | **100% PASS** |
| Phase 5 | ✅ Complete | ✅ API Tests | ✅ Oct 4 | **100% PASS** |
| Phase 6 | ✅ Complete | ✅ Automated | ⏳ Pending | 🔧 Ready |
| Phase 7 | ✅ Complete | ✅ Automated | ⏳ Pending | 🔧 Ready |
| Phase 8 | 🟡 Partial | ✅ Automated | ⏳ Pending | 🔧 Ready |
| Phase 9 | ✅ Complete | ✅ Automated | ⏳ Pending | 🔧 Ready |

**Latest Results:** [TEST-RESULTS-FINAL.md](TEST-RESULTS-FINAL.md)
- ✅ Health Check: PASS
- ✅ Configuration: PASS (v0.6.32)
- ✅ Authentication: PASS (JWT token)
- ✅ Models API: PASS (331 models)
- ✅ Chats API: PASS

---

## 🎯 Next Steps

1. ✅ ~~**Run basic API tests**~~ - **COMPLETE (100% pass)**
2. **Run Phase 6-9 tests:**
   ```bash
   /usr/bin/python3 ./test-phase6-documents.py chris@tonomy.foundation 'Openbaby100!'
   /usr/bin/python3 ./test-phase8-websearch.py chris@tonomy.foundation 'Openbaby100!'
   /usr/bin/python3 ./test-phase9-code.py chris@tonomy.foundation 'Openbaby100!'
   ```
3. **Review results** in generated reports
4. **Fix any failures** identified
5. **Deploy to other teams** (team2-5) once verified

---

## 📚 Full Documentation

For comprehensive testing documentation, see:
- **[TESTING-GUIDE.md](TESTING-GUIDE.md)** - Complete testing guide
- **[README-CHECKLIST.md](README-CHECKLIST.md)** - All 17 phases
- **[PHASE-STATUS-REPORT.md](PHASE-STATUS-REPORT.md)** - Phase details

---

## 🤝 Support

**Issues?** Check:
1. Service health: `docker ps | grep team1`
2. Service logs: `docker logs team1-openwebui`
3. [TESTING-GUIDE.md](TESTING-GUIDE.md) troubleshooting section

**Questions?** See [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)

---

**Ready to test?** Run:
```bash
# Basic API tests (verified working)
/usr/bin/python3 ./test-simple.py chris@tonomy.foundation 'Openbaby100!'

# Phase 6-9 tests (next to run)
/usr/bin/python3 ./test-phase6-documents.py chris@tonomy.foundation 'Openbaby100!'
```

**See results:** [TEST-RESULTS-FINAL.md](TEST-RESULTS-FINAL.md)
