#!/bin/bash

# Phase 5 Tests: Auth Integration
# Tests for auth controller integration with profile management

echo "=============================================="
echo "Running Phase 5: Auth Integration Tests"
echo "=============================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test files
AUTH_CONTROLLER_TEST="test/features/auth/providers/auth_controller_test.dart"
PROFILE_SETUP_TEST="test/features/profile_setup/providers/profile_setup_provider_test.dart"

# Track overall success
ALL_TESTS_PASSED=true

# Function to run a test file
run_test() {
    local test_file=$1
    local test_name=$2
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    echo "File: $test_file"
    echo ""
    
    flutter test "$test_file"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $test_name PASSED${NC}"
    else
        echo -e "${RED}✗ $test_name FAILED${NC}"
        ALL_TESTS_PASSED=false
    fi
    
    echo ""
    echo "----------------------------------------------"
    echo ""
}

# Run all tests
run_test "$AUTH_CONTROLLER_TEST" "AuthController Integration Tests"
run_test "$PROFILE_SETUP_TEST" "ProfileSetupNotifier.completeSetup Tests"

# Summary
echo "=============================================="
echo "Test Summary"
echo "=============================================="

if [ "$ALL_TESTS_PASSED" = true ]; then
    echo -e "${GREEN}✓ ALL PHASE 5 TESTS PASSED${NC}"
    echo ""
    echo "Phase 5 Implementation: Auth Integration"
    echo "  ✓ Profile loading after sign-in"
    echo "  ✓ Profile cleanup on sign-out"
    echo "  ✓ Profile deletion on account deletion"
    echo "  ✓ Profile creation flow integration"
    echo "  ✓ Validation and error handling"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo ""
    echo "Please review the test output above for details."
    exit 1
fi
