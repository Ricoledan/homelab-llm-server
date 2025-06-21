#!/usr/bin/env bash

# Simple test suite for HomeLab LLM Server CLI

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_command() {
    local description="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    echo -n "Testing: $description... "
    
    if eval "$command" >/dev/null 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi
    
    if [[ $exit_code -eq $expected_exit_code ]]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC} (expected exit code $expected_exit_code, got $exit_code)"
        ((TESTS_FAILED++))
    fi
}

echo "Running CLI tests..."
echo ""

# Test CLI exists and is executable
test_command "CLI exists" "test -f bin/llm"
test_command "CLI is executable" "test -x bin/llm"

# Test help command
test_command "Help command" "bin/llm help"

# Test config commands
test_command "Config show" "bin/llm config show"

# Test model commands
test_command "Model list" "bin/llm model list"
test_command "Model current" "bin/llm model current"

# Test invalid commands
test_command "Invalid command returns error" "bin/llm invalid-command" 1

echo ""
echo "Test Results:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi