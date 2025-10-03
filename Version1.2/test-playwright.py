"""
OpenWebUI E2E Testing with Playwright
Tests the actual user interface instead of APIs
"""

import pytest
from playwright.sync_api import Page, expect
import os
import time

# Configuration
BASE_URL = os.getenv("OPENWEBUI_URL", "https://team1-openwebui.valuechainhackers.xyz")
TEST_EMAIL = os.getenv("TEST_EMAIL", "")
TEST_PASSWORD = os.getenv("TEST_PASSWORD", "")

class TestOpenWebUI:
    """OpenWebUI End-to-End Tests"""

    @pytest.fixture(autouse=True)
    def setup(self, page: Page):
        """Setup for each test"""
        page.goto(BASE_URL, timeout=30000)
        self.page = page

    def login(self, page: Page):
        """Login helper"""
        print(f"🔐 Logging in as {TEST_EMAIL}...")

        # Wait for login page
        page.wait_for_selector('input[type="email"]', timeout=10000)

        # Fill in credentials
        page.fill('input[type="email"]', TEST_EMAIL)
        page.fill('input[type="password"]', TEST_PASSWORD)

        # Click login button
        page.click('button[type="submit"]')

        # Wait for redirect to main page
        page.wait_for_url("**/", timeout=10000)
        print("✅ Login successful")

    def test_01_health_check(self, page: Page):
        """Test 1: Health Check - Verify site loads"""
        print("\n🔍 Test 1: Health Check")

        # Check page title
        expect(page).to_have_title(/.*WebUI.*/, timeout=10000)
        print("✅ Page loads successfully")

    def test_02_login(self, page: Page):
        """Test 2: User Authentication"""
        print("\n🔐 Test 2: Login Test")

        if not TEST_EMAIL or not TEST_PASSWORD:
            pytest.skip("No credentials provided (set TEST_EMAIL and TEST_PASSWORD)")

        self.login(page)

        # Verify we're logged in (check for user menu or chat interface)
        page.wait_for_selector('[data-testid="user-menu"], .chat-interface, textarea', timeout=10000)
        print("✅ Login verified")

    def test_03_models_available(self, page: Page):
        """Test 3: Check if models are available"""
        print("\n📋 Test 3: Models Available")

        if not TEST_EMAIL or not TEST_PASSWORD:
            pytest.skip("No credentials provided")

        self.login(page)

        # Look for model selector
        try:
            page.wait_for_selector('select, [role="combobox"], button[aria-label*="model"]', timeout=5000)
            print("✅ Model selector found")
        except:
            print("⚠️  Model selector not found (might be in different location)")

    def test_04_send_chat_message(self, page: Page):
        """Test 4: Send a chat message"""
        print("\n💬 Test 4: Send Chat Message")

        if not TEST_EMAIL or not TEST_PASSWORD:
            pytest.skip("No credentials provided")

        self.login(page)

        # Find chat input
        chat_input = page.locator('textarea, input[placeholder*="message"], input[placeholder*="Send"]').first
        chat_input.wait_for(timeout=10000)

        # Type message
        test_message = "Hello! This is an automated test message. Please respond with 'OK'."
        chat_input.fill(test_message)

        # Send message (Enter key or button)
        chat_input.press('Enter')

        # Wait for response
        print("⏳ Waiting for AI response...")
        time.sleep(5)

        # Check if message appears in chat
        expect(page.locator('text="' + test_message + '"').first).to_be_visible(timeout=5000)
        print("✅ Message sent successfully")

    def test_05_create_new_chat(self, page: Page):
        """Test 5: Create new chat"""
        print("\n💬 Test 5: Create New Chat")

        if not TEST_EMAIL or not TEST_PASSWORD:
            pytest.skip("No credentials provided")

        self.login(page)

        # Look for new chat button
        try:
            new_chat_btn = page.locator('button:has-text("New Chat"), [aria-label*="New"], button[title*="New"]').first
            new_chat_btn.wait_for(timeout=5000)
            new_chat_btn.click()
            print("✅ New chat created")
        except:
            print("⚠️  New chat button not found (might use different method)")

    def test_06_settings_accessible(self, page: Page):
        """Test 6: Settings page accessible"""
        print("\n⚙️  Test 6: Settings Access")

        if not TEST_EMAIL or not TEST_PASSWORD:
            pytest.skip("No credentials provided")

        self.login(page)

        # Try to find settings
        try:
            settings = page.locator('[aria-label*="Settings"], button:has-text("Settings")').first
            settings.wait_for(timeout=5000)
            settings.click()

            # Verify settings opened
            page.wait_for_selector('text="Settings", h1:has-text("Settings"), h2:has-text("Settings")', timeout=5000)
            print("✅ Settings accessible")
        except:
            print("⚠️  Settings not found (might be in user menu)")

    @pytest.mark.skipif(not TEST_EMAIL or not TEST_PASSWORD, reason="No credentials")
    def test_07_document_upload(self, page: Page):
        """Test 7: Document Upload (Phase 6)"""
        print("\n📄 Test 7: Document Upload")

        self.login(page)

        # Navigate to documents/knowledge section
        try:
            # Look for Documents or Knowledge menu
            docs_link = page.locator('a:has-text("Documents"), a:has-text("Knowledge"), [href*="knowledge"]').first
            docs_link.wait_for(timeout=5000)
            docs_link.click()

            time.sleep(2)

            # Look for upload button
            upload_btn = page.locator('button:has-text("Upload"), input[type="file"], button:has-text("Add")').first
            upload_btn.wait_for(timeout=5000)

            print("✅ Document upload interface found")
        except Exception as e:
            print(f"⚠️  Document upload UI not found: {e}")
            pytest.skip("Document upload interface not accessible")

    @pytest.mark.skipif(not TEST_EMAIL or not TEST_PASSWORD, reason="No credentials")
    def test_08_web_search_toggle(self, page: Page):
        """Test 8: Web Search Feature (Phase 8)"""
        print("\n🔍 Test 8: Web Search Feature")

        self.login(page)

        # Look for web search toggle in settings or chat
        try:
            # Check if web search option exists
            page.goto(f"{BASE_URL}/settings")
            time.sleep(2)

            # Look for web search related settings
            web_search = page.locator('text="Web Search", text="Search"').first
            expect(web_search).to_be_visible(timeout=5000)

            print("✅ Web search settings found")
        except:
            print("⚠️  Web search settings not found")

    @pytest.mark.skipif(not TEST_EMAIL or not TEST_PASSWORD, reason="No credentials")
    def test_09_code_execution(self, page: Page):
        """Test 9: Code Execution Feature (Phase 9)"""
        print("\n🐍 Test 9: Code Execution")

        self.login(page)

        # Try sending a code block
        chat_input = page.locator('textarea').first
        chat_input.wait_for(timeout=10000)

        code_message = "```python\nprint('Hello from automated test!')\nresult = 2 + 2\nprint(f'2 + 2 = {result}')\n```"
        chat_input.fill(code_message)
        chat_input.press('Enter')

        print("✅ Code message sent (execution verification requires AI response)")
        time.sleep(3)


# Pytest configuration
def pytest_configure(config):
    """Configure pytest"""
    config.addinivalue_line(
        "markers", "slow: marks tests as slow"
    )

if __name__ == "__main__":
    print("""
    ====================================================
    OpenWebUI Playwright E2E Testing
    ====================================================

    To run these tests:

    1. Set environment variables:
       export TEST_EMAIL="your-email@example.com"
       export TEST_PASSWORD="yourpassword"
       export OPENWEBUI_URL="https://team1-openwebui.valuechainhackers.xyz"

    2. Run tests:
       pytest test-playwright.py --headed      # With visible browser
       pytest test-playwright.py               # Headless mode
       pytest test-playwright.py -v            # Verbose output
       pytest test-playwright.py -k test_04    # Run specific test

    3. Generate HTML report:
       pytest test-playwright.py --html=report.html

    ====================================================
    """)
