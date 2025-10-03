# OpenWebUI Automated Testing Guide

**Version:** 1.0
**Last Updated:** 2025-10-03
**Test Coverage:** Phases 6-9

---

## 📋 Overview

This testing suite provides automated tests for OpenWebUI functionality across multiple phases:

- **Phase 6:** Document Processing (Upload, Tika extraction)
- **Phase 7:** RAG (Retrieval Augmented Generation, Vector embeddings)
- **Phase 8:** Web Search Integration (SearxNG)
- **Phase 9:** Code Execution (Jupyter notebooks)

---

## 🚀 Quick Start

### Prerequisites

1. **Python 3.7+** installed
2. **requests** library (`pip install requests`)
3. **Admin account** on OpenWebUI instance
4. **HTTPS access** to OpenWebUI instance

### Running All Tests

```bash
cd Version1.2
./run-all-tests.sh admin@example.com yourpassword
```

### Running Individual Tests

**Phase 6 & 7 (Documents + RAG):**
```bash
./test-phase6-documents.py admin@example.com yourpassword
```

**Phase 8 (Web Search):**
```bash
./test-phase8-websearch.py admin@example.com yourpassword
```

**Phase 9 (Code Execution):**
```bash
./test-phase9-code.py admin@example.com yourpassword
```

---

## 📝 Test Scripts

### 1. test-phase6-documents.py

**Tests:**
- ✅ API Connection
- ✅ User Authentication
- ✅ Knowledge Base Creation
- ✅ Document Upload
- ✅ Document Indexing

**What it does:**
1. Logs into OpenWebUI
2. Creates a test knowledge base
3. Uploads a test document
4. Waits for embedding process
5. Runs RAG queries to verify retrieval

**Expected Output:**
```
🚀 OpenWebUI Automated Testing Suite
📍 Target: https://team1-openwebui.valuechainhackers.xyz
👤 User: admin@example.com

🔍 Testing connection to OpenWebUI...
✅ Connection successful

🔐 Logging in...
✅ Login successful

📚 Creating knowledge base...
✅ Knowledge base created: kb-12345

📄 Uploading document...
✅ Document uploaded: doc-67890

🔍 Testing RAG query...
✅ RAG query successful, 5 results

✅ ALL TESTS PASSED
```

---

### 2. test-phase8-websearch.py

**Tests:**
- ✅ Web Search API endpoint
- ✅ Search result retrieval
- ✅ Chat with web search enabled
- ✅ Source citation

**What it does:**
1. Tests direct search API
2. Performs multiple search queries
3. Tests chat interface with web search
4. Verifies source citations

**Sample Queries:**
- "latest AI news"
- "OpenAI GPT-4 release date"
- "Python programming tutorial"
- "Docker container best practices"

---

### 3. test-phase9-code.py

**Tests:**
- ✅ Basic code execution
- ✅ Data processing (pandas)
- ✅ Visualization (matplotlib)
- ✅ Variable persistence across executions
- ✅ Error handling
- ✅ Code execution via chat interface

**What it does:**
1. Executes simple Python code
2. Tests data analysis libraries
3. Creates visualizations
4. Verifies variables persist between executions
5. Tests error handling
6. Tests code execution through chat

**Example Tests:**
```python
# Test 1: Basic arithmetic
result = 2 + 2
print(f'2 + 2 = {result}')

# Test 2: Data processing
import pandas as pd
df = pd.DataFrame({'x': [1,2,3], 'y': [2,4,6]})
print(df.describe())

# Test 3: Plotting
import matplotlib.pyplot as plt
plt.plot([1,2,3], [1,4,9])
plt.savefig('/tmp/plot.png')
```

---

### 4. run-all-tests.sh

**Comprehensive Test Runner**

Executes all test scripts and generates:
- Individual test logs
- Summary report
- HTML results page

**Output:**
```
test-results-20251003_143052/
├── Phase6-7-Documents-RAG.log
├── Phase6-7-Documents-RAG.result
├── Phase8-WebSearch.log
├── Phase8-WebSearch.result
├── Phase9-CodeExecution.log
├── Phase9-CodeExecution.result
└── summary.html
```

---

## 🔧 Configuration

### Changing Target Server

Test against different team instances:

```bash
# Team 2
./run-all-tests.sh admin@example.com password https://team2-openwebui.valuechainhackers.xyz

# Team 3
./test-phase6-documents.py admin@example.com password https://team3-openwebui.valuechainhackers.xyz
```

### Custom Test Parameters

Edit the scripts to customize:

**Base URL:**
```python
BASE_URL = "https://your-custom-url.com"
```

**Test Queries:**
```python
test_queries = [
    "your custom query 1",
    "your custom query 2"
]
```

**Timeout Settings:**
```python
time.sleep(10)  # Wait time for embedding
```

---

## 📊 Understanding Results

### Success Indicators

✅ **PASSED** - Test completed successfully
```
✅ Connection successful
✅ Login successful
✅ Document uploaded
✅ RAG query successful
```

### Failure Indicators

❌ **FAILED** - Test encountered an error
```
❌ Connection failed: 503 Service Unavailable
❌ Login failed: Invalid credentials
❌ Upload failed: File too large
❌ Query failed: No results found
```

### Result Files

**`.result` files:**
- Contains: `PASSED` or `FAILED`
- Used for summary generation

**`.log` files:**
- Contains: Full test output
- Includes all API responses
- Useful for debugging

**`summary.html`:**
- Visual test results
- Clickable links to logs
- Pass/fail statistics

---

## 🐛 Troubleshooting

### Common Issues

**1. Authentication Failed**
```
❌ Login failed: 401 Unauthorized
```
**Solution:**
- Verify email and password
- Check if account exists
- Try creating account via UI first

**2. Connection Timeout**
```
❌ Connection error: timeout
```
**Solution:**
- Check HTTPS certificate
- Verify server is accessible
- Check firewall rules

**3. Module Not Found**
```
ModuleNotFoundError: No module named 'requests'
```
**Solution:**
```bash
pip3 install requests
```

**4. Permission Denied**
```
-bash: ./run-all-tests.sh: Permission denied
```
**Solution:**
```bash
chmod +x run-all-tests.sh
```

---

## 🔍 Debugging Tests

### Enable Verbose Output

Add print statements or modify logging:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Manual API Testing

Test API endpoints directly:

```bash
# Health check
curl https://team1-openwebui.valuechainhackers.xyz/health

# Login test
curl -X POST https://team1-openwebui.valuechainhackers.xyz/api/v1/auths/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"yourpassword"}'
```

### Check Service Status

```bash
# On server
docker ps | grep team1
docker logs team1-openwebui --tail 50
docker logs team1-qdrant --tail 50
```

---

## 📈 Extending Tests

### Adding New Test Cases

**1. Create new test function:**
```python
def test_new_feature(self):
    """Test description"""
    print("🔍 Testing new feature...")
    # Test code here
    pass
```

**2. Add to test runner:**
```python
def run_tests():
    tester = MyTester(BASE_URL)
    tester.test_existing_feature()
    tester.test_new_feature()  # Add this
```

### Custom Test Scripts

Use existing scripts as templates:

```bash
cp test-phase6-documents.py test-custom-feature.py
# Edit test-custom-feature.py with your tests
chmod +x test-custom-feature.py
./test-custom-feature.py admin@example.com password
```

---

## 📋 Test Checklist

Before running tests:

- [ ] OpenWebUI instance is running
- [ ] HTTPS is configured (Traefik)
- [ ] Admin account created
- [ ] Python 3.7+ installed
- [ ] `requests` library installed
- [ ] Network connectivity to server
- [ ] Services healthy (docker ps)

After tests:

- [ ] Review test logs
- [ ] Check summary.html
- [ ] Investigate failures
- [ ] Update README-CHECKLIST.md
- [ ] Document any issues found

---

## 🎯 Integration with CI/CD

### GitHub Actions Example

```yaml
name: OpenWebUI Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install requests
      - name: Run tests
        run: |
          cd Version1.2
          ./run-all-tests.sh ${{ secrets.ADMIN_EMAIL }} ${{ secrets.ADMIN_PASSWORD }}
```

### Scheduled Testing

Run tests nightly with cron:

```bash
# Add to crontab
0 2 * * * cd /path/to/Ultimate-OpenWebUI/Version1.2 && ./run-all-tests.sh admin@example.com password > /var/log/openwebui-tests.log 2>&1
```

---

## 📚 Related Documentation

- [README-CHECKLIST.md](README-CHECKLIST.md) - Complete phase testing checklist
- [TESTING-RESULTS.md](TESTING-RESULTS.md) - Phase 5 & 6 test results
- [PHASE-STATUS-REPORT.md](PHASE-STATUS-REPORT.md) - Comprehensive phase overview
- [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) - Multi-server deployment instructions
- [FIXES-APPLIED.md](FIXES-APPLIED.md) - Health check fix documentation

---

## 🤝 Contributing

To add new tests:

1. Follow existing script structure
2. Include comprehensive error handling
3. Add descriptive print statements
4. Update this documentation
5. Test on all team instances

---

**Last Updated:** 2025-10-03
**Maintainer:** OpenWebUI Testing Team
**Support:** See DEPLOYMENT-GUIDE.md for troubleshooting
