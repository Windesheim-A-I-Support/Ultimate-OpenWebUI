#!/usr/bin/env python3
"""
OpenWebUI Phase 9 Automated Testing Script
Tests: Code Execution (Jupyter Integration)
"""

import requests
import json
import sys
import time

BASE_URL = "https://team1-openwebui.valuechainhackers.xyz"

class CodeExecutionTester:
    def __init__(self, base_url):
        self.base_url = base_url
        self.api_url = f"{base_url}/api/v1"
        self.session = requests.Session()

    def login(self, email, password):
        """Login and get auth token"""
        print(f"🔐 Logging in as {email}...")
        try:
            response = self.session.post(
                f"{self.api_url}/auths/signin",
                json={"email": email, "password": password}
            )
            if response.status_code == 200:
                data = response.json()
                token = data.get("token")
                self.session.headers.update({
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                })
                print(f"✅ Login successful")
                return token
            else:
                print(f"❌ Login failed: {response.text}")
                return None
        except Exception as e:
            print(f"❌ Login error: {e}")
            return None

    def execute_code(self, code):
        """Execute Python code via Jupyter"""
        print(f"\n🐍 Executing code:")
        print(f"   {code[:100]}...")
        try:
            response = self.session.post(
                f"{self.api_url}/code/execute",
                json={"code": code, "language": "python"}
            )
            if response.status_code == 200:
                result = response.json()
                output = result.get('output', '')
                error = result.get('error', '')

                if error:
                    print(f"❌ Execution error: {error}")
                    return None, error
                else:
                    print(f"✅ Execution successful")
                    print(f"   Output: {output[:200]}...")
                    return output, None
            else:
                print(f"❌ Request failed: {response.status_code} - {response.text}")
                return None, response.text
        except Exception as e:
            print(f"❌ Execution error: {e}")
            return None, str(e)

    def test_code_via_chat(self, message):
        """Test code execution through chat interface"""
        print(f"\n💬 Testing code execution via chat...")
        print(f"   Message: {message[:100]}...")
        try:
            response = self.session.post(
                f"{self.api_url}/chat/completions",
                json={
                    "messages": [{"role": "user", "content": message}],
                    "model": "gpt-3.5-turbo",
                    "stream": False,
                    "tools": [{"type": "code_interpreter"}]
                }
            )
            if response.status_code == 200:
                data = response.json()
                reply = data.get('choices', [{}])[0].get('message', {}).get('content', '')
                print(f"✅ Chat response received")
                print(f"   Reply: {reply[:200]}...")
                return reply
            else:
                print(f"❌ Chat failed: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"❌ Chat error: {e}")
            return None

def run_phase9_tests(email, password, base_url):
    """Run Phase 9 (Code Execution) tests"""
    print("\n" + "="*60)
    print("PHASE 9: CODE EXECUTION TESTS")
    print("="*60 + "\n")

    tester = CodeExecutionTester(base_url)

    # Login
    token = tester.login(email, password)
    if not token:
        print("❌ Cannot proceed without authentication")
        return False

    all_passed = True

    # Test 1: Basic arithmetic
    print("\n📋 Test 1: Basic Arithmetic")
    code1 = "result = 2 + 2\nprint(f'2 + 2 = {result}')\nresult"
    output, error = tester.execute_code(code1)
    if error or not output:
        all_passed = False

    # Test 2: Data processing with pandas
    print("\n📋 Test 2: Data Processing")
    code2 = """
import pandas as pd
df = pd.DataFrame({'x': [1, 2, 3, 4, 5], 'y': [2, 4, 6, 8, 10]})
print(df.describe())
df.sum()
"""
    output, error = tester.execute_code(code2)
    if error or not output:
        all_passed = False

    # Test 3: Plotting (matplotlib)
    print("\n📋 Test 3: Data Visualization")
    code3 = """
import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 10, 100)
y = x**2

plt.figure(figsize=(8, 6))
plt.plot(x, y, label='y = x²')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Quadratic Function')
plt.legend()
plt.grid(True)
plt.savefig('/tmp/plot.png')
print('Plot saved to /tmp/plot.png')
"""
    output, error = tester.execute_code(code3)
    if error or not output:
        all_passed = False

    # Test 4: Variable persistence
    print("\n📋 Test 4: Variable Persistence")
    code4a = "test_var = 'Hello from first execution'"
    output, error = tester.execute_code(code4a)

    time.sleep(1)

    code4b = "print(test_var)"
    output, error = tester.execute_code(code4b)
    if error or 'Hello from first execution' not in (output or ''):
        print("❌ Variable persistence failed")
        all_passed = False
    else:
        print("✅ Variables persist across executions")

    # Test 5: Error handling
    print("\n📋 Test 5: Error Handling")
    code5 = "1 / 0  # This should raise ZeroDivisionError"
    output, error = tester.execute_code(code5)
    if error and 'ZeroDivisionError' in error:
        print("✅ Error properly caught and reported")
    else:
        print("❌ Error handling failed")
        all_passed = False

    # Test 6: Code via chat
    print("\n📋 Test 6: Code Execution via Chat")
    message = "Calculate the sum of numbers from 1 to 100 using Python code"
    reply = tester.test_code_via_chat(message)
    if not reply:
        all_passed = False

    return all_passed

def main():
    if len(sys.argv) < 3:
        print("Usage: python test-phase9-code.py <email> <password> [base_url]")
        print("Example: python test-phase9-code.py admin@example.com password123")
        sys.exit(1)

    email = sys.argv[1]
    password = sys.argv[2]
    base_url = sys.argv[3] if len(sys.argv) > 3 else BASE_URL

    print(f"🚀 OpenWebUI Code Execution Testing Suite")
    print(f"📍 Target: {base_url}")
    print(f"👤 User: {email}\n")

    success = run_phase9_tests(email, password, base_url)

    print("\n" + "="*60)
    if success:
        print("✅ PHASE 9 TESTS PASSED")
    else:
        print("⚠️  SOME TESTS FAILED - Check output above")
    print("="*60 + "\n")

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
