#!/bin/bash
# Convenience script for running authentication tests

set -e

echo "🧪 Authentication Endpoints Test Suite"
echo "======================================"
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "⚠️  No virtual environment found. Creating one..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements-test.txt
else
    source venv/bin/activate
fi

# Parse command line arguments
case "$1" in
    "quick")
        echo "🚀 Running quick tests (unit tests only)..."
        pytest tests/test_auth.py -v
        ;;
    "integration")
        echo "🔄 Running integration tests..."
        pytest tests/test_integration.py -v
        ;;
    "coverage")
        echo "📊 Running tests with coverage report..."
        pytest --cov=app --cov-report=html --cov-report=term-missing
        echo ""
        echo "✅ Coverage report generated: htmlcov/index.html"
        ;;
    "watch")
        echo "👀 Running tests in watch mode..."
        pytest-watch
        ;;
    "parallel")
        echo "⚡ Running tests in parallel..."
        pytest -n auto -v
        ;;
    "verbose")
        echo "📝 Running all tests with verbose output..."
        pytest -vv -s
        ;;
    "failed")
        echo "🔁 Re-running failed tests..."
        pytest --lf -v
        ;;
    *)
        echo "🧪 Running all tests..."
        echo ""
        pytest -v
        echo ""
        echo "Test run complete!"
        echo ""
        echo "Other options:"
        echo "  ./run_tests.sh quick        - Run unit tests only"
        echo "  ./run_tests.sh integration  - Run integration tests only"
        echo "  ./run_tests.sh coverage     - Generate coverage report"
        echo "  ./run_tests.sh parallel     - Run tests in parallel"
        echo "  ./run_tests.sh verbose      - Run with verbose output"
        echo "  ./run_tests.sh failed       - Re-run only failed tests"
        ;;
esac
