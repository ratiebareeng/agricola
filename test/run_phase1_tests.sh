#!/bin/bash

# Phase 1 Test Runner Script
# Runs all Phase 1: Data Models & Domain Layer tests

echo "========================================="
echo "Phase 1: Data Models & Domain Layer Tests"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to project root
cd "$(dirname "$0")/.." || exit

echo "Running FarmerProfileModel tests..."
flutter test test/features/profile_setup/models/farmer_profile_model_test.dart
FARMER_RESULT=$?

echo ""
echo "Running MerchantProfileModel tests..."
flutter test test/features/profile_setup/models/merchant_profile_model_test.dart
MERCHANT_RESULT=$?

echo ""
echo "Running ProfileResponse tests..."
flutter test test/features/profile/domain/models/profile_response_test.dart
RESPONSE_RESULT=$?

echo ""
echo "Running ProfileFailure tests..."
flutter test test/features/profile/domain/failures/profile_failure_test.dart
FAILURE_RESULT=$?

echo ""
echo "========================================="
echo "Test Results Summary"
echo "========================================="

if [ $FARMER_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} FarmerProfileModel tests passed"
else
    echo -e "${RED}✗${NC} FarmerProfileModel tests failed"
fi

if [ $MERCHANT_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} MerchantProfileModel tests passed"
else
    echo -e "${RED}✗${NC} MerchantProfileModel tests failed"
fi

if [ $RESPONSE_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} ProfileResponse tests passed"
else
    echo -e "${RED}✗${NC} ProfileResponse tests failed"
fi

if [ $FAILURE_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} ProfileFailure tests passed"
else
    echo -e "${RED}✗${NC} ProfileFailure tests failed"
fi

echo ""

# Calculate total result
TOTAL_RESULT=$((FARMER_RESULT + MERCHANT_RESULT + RESPONSE_RESULT + FAILURE_RESULT))

if [ $TOTAL_RESULT -eq 0 ]; then
    echo -e "${GREEN}========================================="
    echo "All Phase 1 tests passed! ✓"
    echo -e "=========================================${NC}"
    exit 0
else
    echo -e "${RED}========================================="
    echo "Some Phase 1 tests failed ✗"
    echo -e "=========================================${NC}"
    exit 1
fi
