#!/bin/bash

# Phase 2: Data Sources Test Runner
# Run all Phase 2 tests for profile data sources

# Navigate to project root (5 levels up from this script)
cd "$(dirname "$0")/../../../../.." || exit 1

echo "======================================"
echo "Running Phase 2: Data Sources Tests"
echo "======================================"
echo ""
echo "Working directory: $(pwd)"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
total_tests=0
passed_tests=0
failed_tests=0

# Function to run a test file
run_test() {
    local test_file=$1
    local test_name=$2
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    
    if flutter test "$test_file" --reporter=compact; then
        echo -e "${GREEN}✓ $test_name PASSED${NC}"
        echo ""
        ((passed_tests++))
    else
        echo -e "${RED}✗ $test_name FAILED${NC}"
        echo ""
        ((failed_tests++))
    fi
    
    ((total_tests++))
}

# Run individual test files
echo "Testing Data Sources..."
echo ""

run_test "test/features/profile/data/datasources/profile_api_service_test.dart" \
    "ProfileApiService Tests"

run_test "test/features/profile/data/datasources/profile_cache_service_test.dart" \
    "ProfileCacheService Tests"

run_test "test/features/profile/data/datasources/firebase_storage_service_test.dart" \
    "FirebaseStorageService Tests"

# Print summary
echo "======================================"
echo "Phase 2 Test Summary"
echo "======================================"
echo -e "Total Test Files: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"

if [ $failed_tests -gt 0 ]; then
    echo -e "${RED}Failed: $failed_tests${NC}"
    echo ""
    echo -e "${RED}Phase 2 tests FAILED. Please fix the errors before proceeding.${NC}"
    exit 1
else
    echo -e "${RED}Failed: $failed_tests${NC}"
    echo ""
    echo -e "${GREEN}All Phase 2 tests PASSED! ✓${NC}"
    echo ""
    echo "You can now proceed to Phase 3: Repository Implementation"
    exit 0
fi
