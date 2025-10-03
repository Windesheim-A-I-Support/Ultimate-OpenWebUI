#!/usr/bin/env python3
"""
Simple OpenWebUI API Test
Tests basic functionality that we know works
"""

import requests
import sys
import json

def test_health(base_url):
    """Test health endpoint"""
    print("🔍 Testing health endpoint...")
    try:
        response = requests.get(f"{base_url}/health", verify=False, timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health check passed: {data}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_config(base_url):
    """Test config endpoint"""
    print("\n🔍 Testing config endpoint...")
    try:
        response = requests.get(f"{base_url}/api/config", verify=False, timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Config retrieved:")
            print(f"   Name: {data.get('name')}")
            print(f"   Version: {data.get('version')}")
            print(f"   Auth enabled: {data.get('features', {}).get('auth')}")
            return True
        else:
            print(f"❌ Config failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_login(base_url, email, password):
    """Test login"""
    print(f"\n🔐 Testing login as {email}...")
    try:
        response = requests.post(
            f"{base_url}/api/v1/auths/signin",
            json={"email": email, "password": password},
            verify=False,
            timeout=10
        )
        if response.status_code == 200:
            data = response.json()
            token = data.get("token")
            print(f"✅ Login successful")
            print(f"   Token: {token[:20]}...")
            return token
        else:
            print(f"❌ Login failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_models(base_url, token):
    """Test models endpoint"""
    print(f"\n📋 Testing models endpoint...")
    try:
        response = requests.get(
            f"{base_url}/api/models",
            headers={"Authorization": f"Bearer {token}"},
            verify=False,
            timeout=10
        )
        if response.status_code == 200:
            data = response.json()
            models = data.get('data', [])
            print(f"✅ Models retrieved: {len(models)} models")
            for model in models[:5]:
                print(f"   - {model.get('id')}")
            return True
        else:
            print(f"❌ Models failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_chats(base_url, token):
    """Test chats endpoint"""
    print(f"\n💬 Testing chats endpoint...")
    try:
        response = requests.get(
            f"{base_url}/api/v1/chats",
            headers={"Authorization": f"Bearer {token}"},
            verify=False,
            timeout=10
        )
        if response.status_code == 200:
            chats = response.json()
            print(f"✅ Chats retrieved: {len(chats)} chats")
            return True
        else:
            print(f"❌ Chats failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    if len(sys.argv) < 3:
        print("Usage: python test-simple.py <email> <password> [base_url]")
        sys.exit(1)

    email = sys.argv[1]
    password = sys.argv[2]
    base_url = sys.argv[3] if len(sys.argv) > 3 else "https://team1-openwebui.valuechainhackers.xyz"

    print("=" * 60)
    print("OpenWebUI Simple API Test")
    print("=" * 60)
    print(f"Target: {base_url}")
    print(f"User: {email}")
    print("=" * 60)

    # Disable SSL warnings
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    results = []

    # Test 1: Health
    results.append(("Health Check", test_health(base_url)))

    # Test 2: Config
    results.append(("Config", test_config(base_url)))

    # Test 3: Login
    token = test_login(base_url, email, password)
    results.append(("Login", token is not None))

    if token:
        # Test 4: Models
        results.append(("Models", test_models(base_url, token)))

        # Test 5: Chats
        results.append(("Chats", test_chats(base_url, token)))

    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name:20} {status}")

    print("=" * 60)
    print(f"Result: {passed}/{total} tests passed")
    print("=" * 60)

    sys.exit(0 if passed == total else 1)

if __name__ == "__main__":
    main()
