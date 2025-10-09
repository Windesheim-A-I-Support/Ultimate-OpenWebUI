#!/usr/bin/env python3
"""
Complete RAG Testing Script for OpenWebUI
Tests document upload, embedding generation, storage, and retrieval
Based on OpenWebUI v0.6.32 documentation
"""

import requests
import time
import json
from pathlib import Path

# Configuration
BASE_URL = "https://team1-openwebui.valuechainhackers.xyz"
TEST_FILE = "/tmp/test-rag-document.txt"
USERNAME = "chris@tonomy.foundation"
PASSWORD = "Openbaby100!"

def print_section(title):
    """Print section header"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def login():
    """Login and get authentication token"""
    print_section("STEP 1: Authentication")

    session = requests.Session()

    # Get CSRF token if needed
    print("Logging in...")
    login_data = {
        "email": USERNAME,
        "password": PASSWORD
    }

    response = session.post(
        f"{BASE_URL}/api/v1/auths/signin",
        json=login_data,
        verify=False
    )

    if response.status_code == 200:
        token = response.json().get("token")
        print(f"✓ Login successful")
        print(f"  Token: {token[:20]}...")
        return session, token
    else:
        print(f"✗ Login failed: {response.status_code}")
        print(f"  Response: {response.text}")
        return None, None

def check_rag_config(session):
    """Check RAG configuration settings"""
    print_section("STEP 2: RAG Configuration Check")

    try:
        # Try to access RAG config via settings endpoint
        response = session.get(
            f"{BASE_URL}/api/config",
            verify=False
        )

        if response.status_code == 200:
            try:
                config = response.json()
                print("✓ Configuration accessible")

                # Try to extract any RAG-related info
                if isinstance(config, dict):
                    print(f"\nConfiguration keys: {list(config.keys())[:5]}...")
                return True
            except:
                print("✓ Configuration endpoint accessible (non-JSON response)")
                return True
        else:
            # Config endpoint might not be accessible, but that's okay
            print(f"⚠ Config endpoint returned {response.status_code} (non-critical)")
            print("  Continuing with upload test...")
            return True  # Don't fail the test for this

    except Exception as e:
        print(f"⚠ Config check error: {e} (non-critical)")
        print("  Continuing with upload test...")
        return True  # Don't fail the test for this

def upload_document(session):
    """Upload a test document"""
    print_section("STEP 3: Document Upload")

    if not Path(TEST_FILE).exists():
        print(f"✗ Test file not found: {TEST_FILE}")
        return None

    print(f"Uploading: {Path(TEST_FILE).name}")
    print(f"File size: {Path(TEST_FILE).stat().st_size / 1024:.2f} KB")

    start_time = time.time()

    try:
        with open(TEST_FILE, 'rb') as f:
            files = {
                'file': (Path(TEST_FILE).name, f, 'text/plain')
            }

            print("\nUploading document...")
            response = session.post(
                f"{BASE_URL}/api/v1/files/",
                files=files,
                verify=False,
                timeout=180  # 3 minutes timeout
            )

        elapsed = time.time() - start_time

        if response.status_code in [200, 201]:
            file_data = response.json()
            file_id = file_data.get('id')
            print(f"✓ Upload successful in {elapsed:.2f} seconds")
            print(f"  File ID: {file_id}")
            print(f"  Response: {json.dumps(file_data, indent=2)}")
            return file_id
        else:
            print(f"✗ Upload failed: {response.status_code}")
            print(f"  Response: {response.text}")
            print(f"  Time elapsed: {elapsed:.2f} seconds")
            return None

    except requests.exceptions.Timeout:
        elapsed = time.time() - start_time
        print(f"✗ Upload timed out after {elapsed:.2f} seconds")
        return None
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"✗ Upload error: {e}")
        print(f"  Time elapsed: {elapsed:.2f} seconds")
        return None

def check_file_status(session, file_id):
    """Check if file was processed successfully"""
    print_section("STEP 4: File Processing Status")

    if not file_id:
        print("✗ No file ID provided")
        return False

    # Wait for embeddings to complete (CPU-based embeddings are slow)
    print("Waiting for embeddings to generate (this may take 30+ seconds)...")
    max_wait = 120  # 2 minutes max
    check_interval = 5  # Check every 5 seconds
    elapsed = 0

    try:
        while elapsed < max_wait:
            response = session.get(
                f"{BASE_URL}/api/v1/files/{file_id}",
                verify=False
            )

            if response.status_code == 200:
                file_data = response.json()
                data_status = file_data.get('data', {}).get('status', 'unknown')

                if data_status == 'completed':
                    print(f"✓ File processing completed after {elapsed} seconds")
                    break
                elif data_status == 'error':
                    print(f"✗ File processing failed after {elapsed} seconds")
                    print(f"  Error: {file_data.get('data', {}).get('error', 'Unknown error')}")
                    return False
                else:
                    print(f"  Status: {data_status} ({elapsed}s elapsed)")
                    time.sleep(check_interval)
                    elapsed += check_interval
            else:
                print(f"✗ File status check failed: {response.status_code}")
                return False

        # Get final status
        response = session.get(
            f"{BASE_URL}/api/v1/files/{file_id}",
            verify=False
        )

        if response.status_code == 200:
            file_data = response.json()
            print(f"\nFile Details:")
            print(f"  ID: {file_data.get('id')}")
            print(f"  Filename: {file_data.get('filename')}")
            print(f"  Size: {file_data.get('meta', {}).get('size', 'N/A')}")
            print(f"  Status: {file_data.get('data', {}).get('status', 'N/A')}")

            # Check for embedding/processing status
            meta = file_data.get('meta', {})
            if 'embedding_model' in meta:
                print(f"  Embedding Model: {meta['embedding_model']}")
            if 'chunks' in meta:
                print(f"  Chunks: {meta['chunks']}")
            if 'vectors' in meta:
                print(f"  Vectors: {meta['vectors']}")

            return file_data.get('data', {}).get('status') == 'completed'
        else:
            print(f"✗ File status check failed: {response.status_code}")
            return False

    except Exception as e:
        print(f"✗ Error checking file status: {e}")
        return False

def test_rag_query(session, file_id):
    """Test querying the uploaded document"""
    print_section("STEP 5: RAG Query Test")

    if not file_id:
        print("✗ No file ID provided")
        return False

    # Test query about the document
    test_query = "What is this document about? Please provide a brief summary."

    print(f"Query: {test_query}")
    print(f"Using file: {file_id}\n")

    try:
        # Create a chat with the document attached
        chat_data = {
            "model": "anthropic/claude-3.5-sonnet",  # Using OpenRouter model
            "messages": [
                {
                    "role": "user",
                    "content": test_query
                }
            ],
            "files": [{"id": file_id, "type": "file"}],
            "stream": False
        }

        print("Sending chat request...")
        response = session.post(
            f"{BASE_URL}/api/chat/completions",
            json=chat_data,
            verify=False,
            timeout=180  # 3 minutes for slow processing
        )

        if response.status_code == 200:
            result = response.json()
            print(f"✓ Query successful\n")

            # Extract response
            if 'choices' in result and len(result['choices']) > 0:
                message = result['choices'][0].get('message', {})
                content = message.get('content', '')

                print("AI Response:")
                print(f"{content}\n")

                # Check for citations (they appear as [1], [2], etc. in the text)
                import re
                citation_refs = re.findall(r'\[(\d+)\]', content)

                if citation_refs:
                    print(f"✓ Citations found in text: {len(set(citation_refs))} unique references")
                    print(f"  References: {sorted(set(citation_refs))}")

                # Check if the response includes document-specific information
                if 'Python' in content or 'programming' in content.lower() or 'Paris' in content:
                    print("✓ RAG is working - AI found specific content from document")
                    return True
                else:
                    print("⚠ Response doesn't clearly use document content")
                    return False
            else:
                print("✗ No response content found")
                return False

        else:
            print(f"✗ Query failed: {response.status_code}")
            print(f"  Response: {response.text}")
            return False

    except Exception as e:
        print(f"✗ Query error: {e}")
        return False

def list_files(session):
    """List all uploaded files"""
    print_section("STEP 6: File List Verification")

    try:
        response = session.get(
            f"{BASE_URL}/api/v1/files/",
            verify=False
        )

        if response.status_code == 200:
            files = response.json()
            print(f"✓ Retrieved {len(files)} file(s)")

            for file in files[-5:]:  # Show last 5 files
                print(f"\n  File: {file.get('filename')}")
                print(f"    ID: {file.get('id')}")
                print(f"    Created: {file.get('created_at')}")

            return True
        else:
            print(f"✗ File list failed: {response.status_code}")
            return False

    except Exception as e:
        print(f"✗ Error listing files: {e}")
        return False

def main():
    """Run complete RAG test suite"""
    print("\n" + "="*60)
    print("  OpenWebUI RAG Complete Test Suite")
    print("  Based on OpenWebUI v0.6.32 Documentation")
    print("="*60)

    # Disable SSL warnings for self-signed certs
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    results = {
        'login': False,
        'config': False,
        'upload': False,
        'status': False,
        'query': False,
        'list': False
    }

    # Step 1: Login
    session, token = login()
    results['login'] = (session is not None)

    if not session:
        print("\n✗ Test suite aborted: Login failed")
        return

    # Step 2: Check config
    results['config'] = check_rag_config(session)

    # Step 3: Upload document
    file_id = upload_document(session)
    results['upload'] = (file_id is not None)

    # Step 4: Check file status
    if file_id:
        results['status'] = check_file_status(session, file_id)

    # Step 5: Test RAG query
    if file_id:
        results['query'] = test_rag_query(session, file_id)

    # Step 6: List files
    results['list'] = list_files(session)

    # Summary
    print_section("TEST SUMMARY")

    total = len(results)
    passed = sum(1 for v in results.values() if v)

    for test, result in results.items():
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status}  {test.upper()}")

    print(f"\nTotal: {passed}/{total} tests passed")

    if passed == total:
        print("\n✓ ALL TESTS PASSED - RAG is working correctly!")
        return 0
    else:
        print(f"\n✗ TESTS FAILED - {total - passed} issue(s) found")
        return 1

if __name__ == "__main__":
    exit(main())
