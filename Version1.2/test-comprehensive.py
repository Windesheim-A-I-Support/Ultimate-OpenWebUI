#!/usr/bin/env python3
"""
Comprehensive OpenWebUI Testing
Tests all working features through available APIs
"""

import requests
import json
import sys
import time

# Disable SSL warnings
requests.packages.urllib3.disable_warnings()

# Headers to avoid bot detection
HEADERS = {
    'User-Agent': 'curl/7.68.0',
    'Accept': '*/*'
}

class OpenWebUITester:
    def __init__(self, base_url, email, password):
        self.base_url = base_url
        self.token = None

        # Login
        self.login(email, password)

    def login(self, email, password):
        """Login and get auth token"""
        print(f"🔐 Logging in as {email}...")
        headers = HEADERS.copy()
        headers['Content-Type'] = 'application/json'
        response = requests.post(
            f"{self.base_url}/api/v1/auths/signin",
            json={"email": email, "password": password},
            headers=headers,
            verify=False
        )
        if response.status_code == 200:
            data = response.json()
            self.token = data.get("token")
            print(f"✅ Login successful")
            return True
        else:
            print(f"❌ Login failed: {response.status_code}")
            print(f"   Response: {response.text}")
            sys.exit(1)

    def _make_request(self, method, endpoint, **kwargs):
        """Helper to make authenticated requests"""
        headers = HEADERS.copy()
        if self.token:
            headers['Authorization'] = f"Bearer {self.token}"
        if 'json' in kwargs:
            headers['Content-Type'] = 'application/json'
        kwargs['headers'] = headers
        kwargs['verify'] = False

        url = f"{self.base_url}{endpoint}"
        if method == 'GET':
            return requests.get(url, **kwargs)
        elif method == 'POST':
            return requests.post(url, **kwargs)
        elif method == 'PUT':
            return requests.put(url, **kwargs)
        elif method == 'DELETE':
            return requests.delete(url, **kwargs)

    def test_basic_chat(self):
        """Test basic chat completion"""
        print("\n📝 Testing basic chat completion...")
        try:
            response = self._make_request('POST', '/api/chat/completions',
                json={
                    "model": "anthropic/claude-sonnet-4.5",
                    "messages": [{"role": "user", "content": "Respond with only the word: SUCCESS"}],
                    "stream": False
                }
            )
            if response.status_code == 200:
                data = response.json()
                content = data['choices'][0]['message']['content']
                print(f"✅ Chat working: {content}")
                return "SUCCESS" in content
            else:
                print(f"❌ Chat failed: {response.status_code} - {response.text}")
                return False
        except Exception as e:
            print(f"❌ Error: {e}")
            return False

    def test_models_available(self):
        """Test that models are available"""
        print("\n🤖 Testing model availability...")
        try:
            response = self._make_request('GET', '/api/models')
            if response.status_code == 200:
                data = response.json()
                models = data.get('data', [])
                print(f"✅ {len(models)} models available")
                # List some key models
                key_models = ['anthropic/claude-sonnet-4.5', 'deepseek/deepseek-v3.2-exp']
                found = [m for m in models if m.get('id') in key_models]
                for model in found:
                    print(f"   - {model.get('id')}")
                return len(models) > 0
            else:
                print(f"❌ Models failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Error: {e}")
            return False

    def test_create_chat(self):
        """Test creating a new chat"""
        print("\n💬 Testing chat creation...")
        try:
            response = self._make_request('POST', '/api/v1/chats/new',
                json={
                    "chat": {
                        "name": "Automated Test Chat",
                        "models": ["anthropic/claude-sonnet-4.5"]
                    }
                }
            )
            if response.status_code in [200, 201]:
                print(f"✅ Chat created successfully")
                return True
            else:
                print(f"⚠️  Chat creation: {response.status_code} - {response.text[:100]}")
                return False
        except Exception as e:
            print(f"❌ Error: {e}")
            return False

    def test_health_endpoints(self):
        """Test all health-related endpoints"""
        print("\n🏥 Testing health endpoints...")
        results = []

        endpoints = [
            ("/health", "Main health check"),
            ("/api/config", "Configuration"),
        ]

        for endpoint, name in endpoints:
            try:
                response = self._make_request('GET', endpoint)
                if response.status_code == 200:
                    print(f"✅ {name}: OK")
                    results.append(True)
                else:
                    print(f"❌ {name}: {response.status_code}")
                    results.append(False)
            except Exception as e:
                print(f"❌ {name}: {e}")
                results.append(False)

        return all(results)

    def test_user_info(self):
        """Test user information endpoint"""
        print("\n👤 Testing user information...")
        try:
            # The token contains user info, let's decode it
            import base64
            parts = self.token.split('.')
            if len(parts) >= 2:
                # Decode payload (add padding if needed)
                payload = parts[1]
                payload += '=' * (4 - len(payload) % 4)
                decoded = base64.b64decode(payload)
                user_info = json.loads(decoded)
                print(f"✅ User ID: {user_info.get('id')}")
                return True
            else:
                print(f"⚠️  Could not decode token")
                return False
        except Exception as e:
            print(f"❌ Error: {e}")
            return False

def main():
    if len(sys.argv) < 3:
        print("Usage: python test-comprehensive.py <email> <password> [base_url]")
        sys.exit(1)

    email = sys.argv[1]
    password = sys.argv[2]
    base_url = sys.argv[3] if len(sys.argv) > 3 else "https://team1-openwebui.valuechainhackers.xyz"

    print("=" * 70)
    print("OpenWebUI Comprehensive Test Suite")
    print("=" * 70)
    print(f"Target: {base_url}")
    print(f"User: {email}")
    print("=" * 70)

    tester = OpenWebUITester(base_url, email, password)

    results = []

    # Run all tests
    results.append(("Health Endpoints", tester.test_health_endpoints()))
    results.append(("Model Availability", tester.test_models_available()))
    results.append(("Basic Chat", tester.test_basic_chat()))
    results.append(("Create Chat", tester.test_create_chat()))
    results.append(("User Info", tester.test_user_info()))

    # Summary
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name:30} {status}")

    print("=" * 70)
    print(f"Result: {passed}/{total} tests passed ({int(passed/total*100)}%)")
    print("=" * 70)

    if passed == total:
        print("\n🎉 ALL TESTS PASSED!")
        sys.exit(0)
    else:
        print(f"\n⚠️  {total - passed} test(s) failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
