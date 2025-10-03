# OpenWebUI Testing Suite - Quick Reference

**Automated testing for Phases 6-9**
**Last Updated:** 2025-10-03

---

## 🎯 Quick Commands

### Run All Tests
```bash
cd Version1.2
./run-all-tests.sh admin@example.com yourpassword
```

### Run Individual Phase Tests
```bash
./test-phase6-documents.py admin@example.com yourpassword  # Documents + RAG
./test-phase8-websearch.py admin@example.com yourpassword  # Web Search
./test-phase9-code.py admin@example.com yourpassword       # Code Execution
```

### Test Different Teams
```bash
./run-all-tests.sh admin@example.com pass https://team2-openwebui.valuechainhackers.xyz
./run-all-tests.sh admin@example.com pass https://team3-openwebui.valuechainhackers.xyz
```

---

## 📁 Testing Files

| File | Purpose |
|------|---------|
| `run-all-tests.sh` | **Main test runner** - Runs all phase tests |
| `test-phase6-documents.py` | Tests document upload & RAG |
| `test-phase8-websearch.py` | Tests web search integration |
| `test-phase9-code.py` | Tests code execution |
| `TESTING-GUIDE.md` | **Complete testing documentation** |
| `TESTING-RESULTS.md` | Phase 5 & 6 test results |
| `README-CHECKLIST.md` | Complete 17-phase checklist |

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
   python3 --version
   ```

2. **requests** library
   ```bash
   pip3 install requests
   ```

3. **Admin account** on OpenWebUI
   - Create via web UI first
   - Note email and password

4. **Services running**
   ```bash
   ssh root@10.0.8.40
   docker ps | grep team1
   ```

---

## 🐛 Troubleshooting

**Authentication Failed:**
```bash
# Create account via UI first, then test
./test-phase6-documents.py your-email@example.com yourpassword
```

**Module Not Found:**
```bash
pip3 install requests
```

**Permission Denied:**
```bash
chmod +x *.sh *.py
```

**Connection Issues:**
```bash
# Test connection manually
curl https://team1-openwebui.valuechainhackers.xyz/health
```

---

## 📈 Current Test Status

**As of 2025-10-03:**

| Phase | Infrastructure | Tests Created | Status |
|-------|----------------|---------------|--------|
| Phase 5 | ✅ Complete | Manual | ✅ PASSED |
| Phase 6 | ✅ Complete | ✅ Automated | 🔧 Ready |
| Phase 7 | ✅ Complete | ✅ Automated | 🔧 Ready |
| Phase 8 | 🟡 Partial | ✅ Automated | 🔧 Ready |
| Phase 9 | ✅ Complete | ✅ Automated | 🔧 Ready |

---

## 🎯 Next Steps

1. **Run tests** on team1 instance
2. **Review results** in generated reports
3. **Fix any failures** identified
4. **Deploy to other teams** once verified
5. **Schedule automated runs** (optional)

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
./run-all-tests.sh admin@example.com yourpassword
```
