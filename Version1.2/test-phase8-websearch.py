#!/usr/bin/env python3
"""
OpenWebUI Phase 8 Automated Testing Script
Tests: Web Search Integration (SearxNG)
"""

import requests
import json
import sys

BASE_URL = "https://team1-openwebui.valuechainhackers.xyz"

class WebSearchTester:
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

    def test_web_search_api(self, query):
        """Test web search API directly"""
        print(f"\n🔍 Testing web search API: '{query}'...")
        try:
            response = self.session.post(
                f"{self.api_url}/search",
                json={"query": query}
            )
            if response.status_code == 200:
                results = response.json()
                print(f"✅ Search successful, {len(results)} results")
                for i, result in enumerate(results[:3], 1):
                    print(f"  {i}. {result.get('title', 'N/A')}")
                    print(f"     URL: {result.get('url', 'N/A')}")
                return results
            else:
                print(f"❌ Search failed: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"❌ Search error: {e}")
            return None

    def test_chat_with_search(self, message):
        """Test sending a message that should trigger web search"""
        print(f"\n💬 Testing chat with web search: '{message}'...")
        try:
            response = self.session.post(
                f"{self.api_url}/chat/completions",
                json={
                    "messages": [{"role": "user", "content": message}],
                    "model": "gpt-3.5-turbo",
                    "stream": False,
                    "web_search": True
                }
            )
            if response.status_code == 200:
                data = response.json()
                reply = data.get('choices', [{}])[0].get('message', {}).get('content', '')
                sources = data.get('sources', [])
                print(f"✅ Response received ({len(sources)} sources cited)")
                print(f"   Reply: {reply[:200]}...")
                if sources:
                    print(f"   Sources:")
                    for source in sources[:3]:
                        print(f"     - {source.get('url', 'N/A')}")
                return reply, sources
            else:
                print(f"❌ Chat failed: {response.status_code} - {response.text}")
                return None, None
        except Exception as e:
            print(f"❌ Chat error: {e}")
            return None, None

def run_phase8_tests(email, password, base_url):
    """Run Phase 8 (Web Search) tests"""
    print("\n" + "="*60)
    print("PHASE 8: WEB SEARCH INTEGRATION TESTS")
    print("="*60 + "\n")

    tester = WebSearchTester(base_url)

    # Login
    token = tester.login(email, password)
    if not token:
        print("❌ Cannot proceed without authentication")
        return False

    # Test search queries
    test_queries = [
        "latest AI news",
        "OpenAI GPT-4 release date",
        "Python programming tutorial",
        "Docker container best practices"
    ]

    all_passed = True

    # Test direct search API
    print("\n📋 Testing Direct Search API:")
    for query in test_queries[:2]:
        results = tester.test_web_search_api(query)
        if not results:
            all_passed = False

    # Test chat with web search
    print("\n📋 Testing Chat with Web Search:")
    chat_queries = [
        "What are the latest developments in AI?",
        "What is the current version of Python?"
    ]

    for query in chat_queries:
        reply, sources = tester.test_chat_with_search(query)
        if not reply:
            all_passed = False

    return all_passed

def main():
    if len(sys.argv) < 3:
        print("Usage: python test-phase8-websearch.py <email> <password> [base_url]")
        print("Example: python test-phase8-websearch.py admin@example.com password123")
        sys.exit(1)

    email = sys.argv[1]
    password = sys.argv[2]
    base_url = sys.argv[3] if len(sys.argv) > 3 else BASE_URL

    print(f"🚀 OpenWebUI Web Search Testing Suite")
    print(f"📍 Target: {base_url}")
    print(f"👤 User: {email}\n")

    success = run_phase8_tests(email, password, base_url)

    print("\n" + "="*60)
    if success:
        print("✅ PHASE 8 TESTS PASSED")
    else:
        print("⚠️  SOME TESTS FAILED - Check output above")
    print("="*60 + "\n")

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
