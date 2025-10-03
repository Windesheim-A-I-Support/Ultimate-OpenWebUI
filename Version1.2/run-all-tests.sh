#!/bin/bash
# ====================================================
# OpenWebUI Comprehensive Testing Suite Runner
# ====================================================
# Runs all automated tests for Phases 6-9
#
# Usage: ./run-all-tests.sh <email> <password> [base_url]
# Example: ./run-all-tests.sh admin@example.com mypassword

set -e

EMAIL=$1
PASSWORD=$2
BASE_URL=${3:-"https://team1-openwebui.valuechainhackers.xyz"}

if [ -z "$EMAIL" ] || [ -z "$PASSWORD" ]; then
    echo "❌ Missing arguments"
    echo ""
    echo "Usage: ./run-all-tests.sh <email> <password> [base_url]"
    echo ""
    echo "Example:"
    echo "  ./run-all-tests.sh admin@example.com mypassword"
    echo "  ./run-all-tests.sh admin@example.com mypassword https://team2-openwebui.valuechainhackers.xyz"
    exit 1
fi

echo "======================================================"
echo "OpenWebUI Comprehensive Testing Suite"
echo "======================================================"
echo "Target: $BASE_URL"
echo "User: $EMAIL"
echo "======================================================"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    exit 1
fi

# Check dependencies
echo "📦 Checking Python dependencies..."
python3 -c "import requests" 2>/dev/null || {
    echo "Installing requests..."
    pip3 install requests
}

RESULTS_DIR="./test-results-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

echo "📁 Results will be saved to: $RESULTS_DIR"
echo ""

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run test and track results
run_test() {
    local test_name=$1
    local test_script=$2

    echo ""
    echo "======================================================"
    echo "Running: $test_name"
    echo "======================================================"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if python3 "$test_script" "$EMAIL" "$PASSWORD" "$BASE_URL" 2>&1 | tee "$RESULTS_DIR/$test_name.log"; then
        echo "✅ $test_name PASSED"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "PASSED" > "$RESULTS_DIR/$test_name.result"
    else
        echo "❌ $test_name FAILED"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "FAILED" > "$RESULTS_DIR/$test_name.result"
    fi
}

# Run all tests
echo "🚀 Starting test suite..."
echo ""

# Phase 6 & 7: Document Processing and RAG
if [ -f "test-phase6-documents.py" ]; then
    run_test "Phase6-7-Documents-RAG" "test-phase6-documents.py"
else
    echo "⚠️  test-phase6-documents.py not found, skipping..."
fi

# Phase 8: Web Search
if [ -f "test-phase8-websearch.py" ]; then
    run_test "Phase8-WebSearch" "test-phase8-websearch.py"
else
    echo "⚠️  test-phase8-websearch.py not found, skipping..."
fi

# Phase 9: Code Execution
if [ -f "test-phase9-code.py" ]; then
    run_test "Phase9-CodeExecution" "test-phase9-code.py"
else
    echo "⚠️  test-phase9-code.py not found, skipping..."
fi

# Generate summary report
echo ""
echo "======================================================"
echo "TEST SUMMARY"
echo "======================================================"
echo ""
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo "✅ ALL TESTS PASSED!"
    SUCCESS=0
else
    echo "⚠️  SOME TESTS FAILED"
    echo ""
    echo "Failed tests:"
    for result_file in "$RESULTS_DIR"/*.result; do
        if grep -q "FAILED" "$result_file"; then
            basename "$result_file" .result
        fi
    done
    SUCCESS=1
fi

# Generate HTML report
cat > "$RESULTS_DIR/summary.html" << EOFREPORT
<!DOCTYPE html>
<html>
<head>
    <title>OpenWebUI Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333; }
        .passed { color: green; }
        .failed { color: red; }
        .stats { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .test-result { margin: 10px 0; padding: 10px; border-left: 4px solid #ddd; }
        .test-result.passed { border-left-color: green; }
        .test-result.failed { border-left-color: red; }
    </style>
</head>
<body>
    <h1>OpenWebUI Test Results</h1>
    <p>Target: $BASE_URL</p>
    <p>Date: $(date)</p>

    <div class="stats">
        <h2>Summary</h2>
        <p>Total Tests: $TOTAL_TESTS</p>
        <p class="passed">Passed: $PASSED_TESTS</p>
        <p class="failed">Failed: $FAILED_TESTS</p>
    </div>

    <h2>Test Details</h2>
EOFREPORT

for result_file in "$RESULTS_DIR"/*.result; do
    test_name=$(basename "$result_file" .result)
    result=$(cat "$result_file")
    class=$(echo "$result" | tr '[:upper:]' '[:lower:]')

    cat >> "$RESULTS_DIR/summary.html" << EOFREPORT
    <div class="test-result $class">
        <h3>$test_name</h3>
        <p>Status: $result</p>
        <p><a href="$test_name.log">View Log</a></p>
    </div>
EOFREPORT
done

cat >> "$RESULTS_DIR/summary.html" << EOFREPORT
</body>
</html>
EOFREPORT

echo ""
echo "======================================================"
echo "Results saved to: $RESULTS_DIR"
echo "View HTML report: $RESULTS_DIR/summary.html"
echo "======================================================"
echo ""

exit $SUCCESS
