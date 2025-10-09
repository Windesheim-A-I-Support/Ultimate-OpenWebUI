#!/usr/bin/env python3
"""
RAG Performance Test - Compare query times and verify functionality
"""

import requests
import time
import urllib3
urllib3.disable_warnings()

BASE_URL = "https://team1-openwebui.valuechainhackers.xyz"
USERNAME = "chris@tonomy.foundation"
PASSWORD = "Openbaby100!"

def test_query(session, file_id, question):
    """Test a single RAG query and measure performance"""
    chat_data = {
        "model": "anthropic/claude-3.5-sonnet",
        "messages": [{"role": "user", "content": question}],
        "files": [{"id": file_id, "type": "file"}],
        "stream": False
    }

    start_time = time.time()
    response = session.post(
        f"{BASE_URL}/api/chat/completions",
        json=chat_data,
        verify=False,
        timeout=180
    )
    elapsed = time.time() - start_time

    return response, elapsed

def main():
    print("="*70)
    print("RAG PERFORMANCE TEST - Hybrid Search Disabled")
    print("="*70)

    # Login
    session = requests.Session()
    login_resp = session.post(
        f"{BASE_URL}/api/v1/auths/signin",
        json={"email": USERNAME, "password": PASSWORD},
        verify=False
    )

    if login_resp.status_code != 200:
        print(f"✗ Login failed: {login_resp.status_code}")
        return

    print("✓ Logged in successfully\n")

    # Use the test file we uploaded
    file_id = "5f4b67c9-ced5-499f-b089-9a07cd437fba"

    # Test queries
    queries = [
        "What programming language is mentioned in this document?",
        "What is the capital of France according to this document?",
        "What is machine learning as described in this document?"
    ]

    results = []

    for i, question in enumerate(queries, 1):
        print(f"Query {i}: {question}")
        try:
            response, elapsed = test_query(session, file_id, question)

            if response.status_code == 200:
                result = response.json()
                message = result.get('choices', [{}])[0].get('message', {})
                content = message.get('content', '')

                # Extract key info
                has_answer = any(keyword in content for keyword in ['Python', 'Paris', 'machine learning', 'artificial intelligence'])

                print(f"  ✓ Success in {elapsed:.2f}s")
                print(f"  Answer preview: {content[:150]}...")
                print(f"  Contains expected content: {'Yes' if has_answer else 'No'}")

                results.append({
                    'query': question,
                    'time': elapsed,
                    'success': True,
                    'has_answer': has_answer
                })
            else:
                print(f"  ✗ Failed: {response.status_code}")
                results.append({
                    'query': question,
                    'time': elapsed,
                    'success': False,
                    'has_answer': False
                })
        except Exception as e:
            print(f"  ✗ Error: {e}")
            results.append({
                'query': question,
                'time': 0,
                'success': False,
                'has_answer': False
            })

        print()

    # Summary
    print("="*70)
    print("PERFORMANCE SUMMARY")
    print("="*70)

    successful_queries = [r for r in results if r['success']]
    if successful_queries:
        avg_time = sum(r['time'] for r in successful_queries) / len(successful_queries)
        print(f"Successful queries: {len(successful_queries)}/{len(results)}")
        print(f"Average query time: {avg_time:.2f} seconds")
        print(f"Min/Max time: {min(r['time'] for r in successful_queries):.2f}s / {max(r['time'] for r in successful_queries):.2f}s")

        correct_answers = sum(1 for r in successful_queries if r['has_answer'])
        print(f"Queries with correct content: {correct_answers}/{len(successful_queries)}")

        if avg_time < 10:
            print("\n✓ EXCELLENT: Query performance is good for workshop use")
        elif avg_time < 30:
            print("\n✓ ACCEPTABLE: Query performance is adequate for workshop")
        else:
            print("\n⚠ WARNING: Queries are slow, may impact workshop experience")
    else:
        print("✗ All queries failed")

    print("\n" + "="*70)

if __name__ == "__main__":
    main()
