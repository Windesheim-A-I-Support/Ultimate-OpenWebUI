#!/usr/bin/env python3
"""
OpenWebUI Phase 6 & 7 Automated Testing Script
Tests: Document Upload, RAG, Knowledge Base
"""

import requests
import json
import time
import sys
from pathlib import Path

# Configuration
BASE_URL = "https://team1-openwebui.valuechainhackers.xyz"
API_URL = f"{BASE_URL}/api/v1"

# You'll need to get this from browser after logging in:
# 1. Log in to OpenWebUI
# 2. Open browser DevTools -> Application -> Cookies
# 3. Copy the 'token' value
AUTH_TOKEN = None  # Set this or pass as argument

class OpenWebUITester:
    def __init__(self, base_url, auth_token=None):
        self.base_url = base_url
        self.api_url = f"{base_url}/api/v1"
        self.session = requests.Session()

        if auth_token:
            self.session.headers.update({
                "Authorization": f"Bearer {auth_token}",
                "Content-Type": "application/json"
            })

    def test_connection(self):
        """Test if we can connect to OpenWebUI"""
        print("🔍 Testing connection to OpenWebUI...")
        try:
            response = self.session.get(f"{self.base_url}/health")
            if response.status_code == 200:
                print(f"✅ Connection successful: {response.json()}")
                return True
            else:
                print(f"❌ Connection failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Connection error: {e}")
            return False

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
                    "Authorization": f"Bearer {token}"
                })
                print(f"✅ Login successful")
                return token
            else:
                print(f"❌ Login failed: {response.text}")
                return None
        except Exception as e:
            print(f"❌ Login error: {e}")
            return None

    def create_knowledge_base(self, name, description):
        """Create a new knowledge base"""
        print(f"📚 Creating knowledge base: {name}...")
        try:
            response = self.session.post(
                f"{self.api_url}/knowledge",
                json={
                    "name": name,
                    "description": description
                }
            )
            if response.status_code in [200, 201]:
                kb = response.json()
                print(f"✅ Knowledge base created: {kb.get('id')}")
                return kb.get('id')
            else:
                print(f"❌ Failed to create KB: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"❌ Error creating KB: {e}")
            return None

    def upload_document(self, kb_id, file_path, file_name):
        """Upload a document to knowledge base"""
        print(f"📄 Uploading document: {file_name}...")
        try:
            with open(file_path, 'rb') as f:
                files = {'file': (file_name, f, 'text/plain')}
                # Temporarily remove Content-Type header for multipart
                headers = dict(self.session.headers)
                headers.pop('Content-Type', None)

                response = self.session.post(
                    f"{self.api_url}/knowledge/{kb_id}/file/add",
                    files=files,
                    headers=headers
                )

                if response.status_code in [200, 201]:
                    doc = response.json()
                    print(f"✅ Document uploaded: {doc.get('id')}")
                    return doc.get('id')
                else:
                    print(f"❌ Upload failed: {response.status_code} - {response.text}")
                    return None
        except Exception as e:
            print(f"❌ Upload error: {e}")
            return None

    def test_rag_query(self, kb_id, query):
        """Test RAG query against knowledge base"""
        print(f"🔍 Testing RAG query: '{query}'...")
        try:
            response = self.session.post(
                f"{self.api_url}/knowledge/{kb_id}/query",
                json={"query": query, "k": 5}
            )
            if response.status_code == 200:
                results = response.json()
                print(f"✅ RAG query successful, {len(results)} results")
                for i, result in enumerate(results[:3], 1):
                    print(f"  {i}. Score: {result.get('score', 'N/A'):.3f} - {result.get('content', '')[:100]}...")
                return results
            else:
                print(f"❌ Query failed: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"❌ Query error: {e}")
            return None

    def create_chat(self, model="gpt-3.5-turbo"):
        """Create a new chat session"""
        print(f"💬 Creating new chat...")
        try:
            response = self.session.post(
                f"{self.api_url}/chats/new",
                json={"model": model}
            )
            if response.status_code in [200, 201]:
                chat = response.json()
                print(f"✅ Chat created: {chat.get('id')}")
                return chat.get('id')
            else:
                print(f"❌ Chat creation failed: {response.status_code}")
                return None
        except Exception as e:
            print(f"❌ Chat error: {e}")
            return None

    def send_message_with_kb(self, chat_id, message, kb_id):
        """Send message to chat with knowledge base context"""
        print(f"💬 Sending message with KB context...")
        try:
            response = self.session.post(
                f"{self.api_url}/chat/completions",
                json={
                    "chat_id": chat_id,
                    "messages": [{"role": "user", "content": f"#{kb_id} {message}"}],
                    "stream": False
                }
            )
            if response.status_code == 200:
                data = response.json()
                reply = data.get('choices', [{}])[0].get('message', {}).get('content', '')
                print(f"✅ Response received: {reply[:200]}...")
                return reply
            else:
                print(f"❌ Message failed: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"❌ Message error: {e}")
            return None

def create_test_document():
    """Create a test document for upload"""
    content = """
OpenWebUI Testing Document - Phase 6 & 7

SYSTEM INFORMATION:
- Project: OpenWebUI Multi-Team Platform
- Version: 1.2
- Date: October 3, 2025
- Server: team1-openwebui.valuechainhackers.xyz

TECHNICAL ARCHITECTURE:
The system uses the following components:
1. Apache Tika for document extraction
2. Qdrant vector database for embeddings
3. text-embedding-3-small model via OpenRouter
4. Hybrid search (BM25 + Vector similarity)

DEPLOYMENT DETAILS:
- Team1: 10.0.8.40
- Team2: 10.0.8.41
- Team3: 10.0.8.42
- Team4: 10.0.8.43
- Team5: 10.0.8.44

TESTING PROCEDURES:
This document is used for automated testing of:
- Document upload functionality
- Text extraction with Tika
- Vector embedding generation
- RAG (Retrieval Augmented Generation) queries
- Citation and source reference
- Multi-document retrieval

EXPECTED RESULTS:
When queried about "system components", the AI should retrieve and cite
information about Tika, Qdrant, and the embedding model.
When asked about "deployment", it should return the server IP addresses.
"""

    file_path = "/tmp/openwebui-test-document.txt"
    with open(file_path, 'w') as f:
        f.write(content)

    print(f"📝 Test document created: {file_path}")
    return file_path

def run_phase6_tests(tester, email, password):
    """Run Phase 6 (Document Processing) tests"""
    print("\n" + "="*60)
    print("PHASE 6: DOCUMENT PROCESSING TESTS")
    print("="*60 + "\n")

    # Login
    token = tester.login(email, password)
    if not token:
        print("❌ Cannot proceed without authentication")
        return False

    # Create test document
    doc_path = create_test_document()

    # Create knowledge base
    kb_id = tester.create_knowledge_base(
        "Phase6-Test-KB",
        "Automated testing knowledge base for Phase 6 & 7"
    )
    if not kb_id:
        print("❌ Cannot test document upload without KB")
        return False

    # Upload document
    doc_id = tester.upload_document(kb_id, doc_path, "test-document.txt")
    if not doc_id:
        print("❌ Document upload failed")
        return False

    print("\n✅ PHASE 6 TESTS PASSED")
    return kb_id

def run_phase7_tests(tester, kb_id):
    """Run Phase 7 (RAG) tests"""
    print("\n" + "="*60)
    print("PHASE 7: RAG TESTS")
    print("="*60 + "\n")

    # Wait for embedding to complete
    print("⏳ Waiting 10 seconds for document embedding...")
    time.sleep(10)

    # Test RAG queries
    test_queries = [
        "What are the system components?",
        "What is the deployment architecture?",
        "Which embedding model is used?",
        "What are the team server IP addresses?"
    ]

    all_passed = True
    for query in test_queries:
        results = tester.test_rag_query(kb_id, query)
        if not results:
            all_passed = False
        time.sleep(2)

    if all_passed:
        print("\n✅ PHASE 7 TESTS PASSED")
    else:
        print("\n❌ SOME RAG TESTS FAILED")

    return all_passed

def main():
    if len(sys.argv) < 3:
        print("Usage: python test-phase6-documents.py <email> <password> [base_url]")
        print("Example: python test-phase6-documents.py admin@example.com password123")
        sys.exit(1)

    email = sys.argv[1]
    password = sys.argv[2]
    base_url = sys.argv[3] if len(sys.argv) > 3 else BASE_URL

    print(f"🚀 OpenWebUI Automated Testing Suite")
    print(f"📍 Target: {base_url}")
    print(f"👤 User: {email}\n")

    tester = OpenWebUITester(base_url)

    # Test connection
    if not tester.test_connection():
        print("❌ Cannot connect to OpenWebUI")
        sys.exit(1)

    # Run Phase 6 tests
    kb_id = run_phase6_tests(tester, email, password)
    if not kb_id:
        sys.exit(1)

    # Run Phase 7 tests
    success = run_phase7_tests(tester, kb_id)

    print("\n" + "="*60)
    if success:
        print("✅ ALL TESTS PASSED")
    else:
        print("⚠️  SOME TESTS FAILED - Check output above")
    print("="*60 + "\n")

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
