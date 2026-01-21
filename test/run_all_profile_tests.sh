#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running Complete Profile Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Change to project root
cd "$(dirname "$0")/.."

TOTAL_PASSED=0
TOTAL_FAILED=0

# Function to run tests and capture results
run_test_suite() {
    local test_path=$1
    local test_name=$2
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    
    if flutter test "$test_path" > /tmp/test_output.txt 2>&1; then
        # Extract the number of passed tests
        passed=$(grep -oE '\+[0-9]+:' /tmp/test_output.txt | tail -1 | grep -oE '[0-9]+')
        echo -e "${GREEN}✓ $test_name PASSED${NC} ($passed tests)"
        TOTAL_PASSED=$((TOTAL_PASSED + passed))
        return 0
    else
        # Extract failure information
        failed=$(grep -oE '\-[0-9]+:' /tmp/test_output.txt | tail -1 | grep -oE '[0-9]+')
        echo -e "${RED}✗ $test_name FAILED${NC} ($failed failures)"
        TOTAL_FAILED=$((TOTAL_FAILED + failed))
        cat /tmp/test_output.txt
        return 1
    fi
}

echo -e "${BLUE}Phase 1: Domain Layer Tests${NC}"
echo "-----------------------------------"
run_test_suite "test/features/profile/domain/" "Domain Models & Failures"
echo ""

echo -e "${BLUE}Phase 2: Data Sources Tests${NC}"
echo "-----------------------------------"
run_test_suite "test/features/profile/data/datasources/" "Data Sources (API, Cache, Storage)"
echo ""

echo -e "${BLUE}Phase 3: Repository Tests${NC}"
echo "-----------------------------------"
run_test_suite "test/features/profile/data/repositories/" "ProfileRepository Implementation"
echo ""

echo -e "${BLUE}Phase 4: Providers Tests${NC}"
echo "-----------------------------------"
run_test_suite "test/features/profile_setup/providers/" "Profile Setup Provider"
echo ""

echo -e "${BLUE}Phase 5: Utils & Validation Tests${NC}"
echo "-----------------------------------"
run_test_suite "test/features/profile/utils/" "Profile Validators"
echo ""

echo -e "${BLUE}Phase 6: Models Tests${NC}"
echo "-----------------------------------"
run_test_suite "test/features/profile_setup/models/" "Profile Models"
echo ""

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Total Passed: $TOTAL_PASSED${NC}"
echo -e "${RED}Total Failed: $TOTAL_FAILED${NC}"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests PASSED! ✓${NC}"
    echo ""
    echo -e "${BLUE}Phase 8 (Testing) is COMPLETE!${NC}"
    echo -e "${GREEN}✓ ProfileRepositoryImpl tests${NC}"
    echo -e "${GREEN}✓ Data source tests (API, Cache, Storage)${NC}"
    echo -e "${GREEN}✓ ProfileValidators tests${NC}"
    echo -e "${GREEN}✓ Profile models tests${NC}"
    echo -e "${GREEN}✓ Profile setup provider tests${NC}"
    echo -e "${GREEN}✓ Domain layer tests${NC}"
    echo ""
    echo "Ready for production deployment!"
    exit 0
else
    echo -e "${RED}Some tests FAILED ✗${NC}"
    echo "Please review the errors above and fix failing tests."
    exit 1
fi
