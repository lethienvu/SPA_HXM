#!/bin/bash

# SPA Migration Tool Setup Script
# This script helps you install dependencies and setup the migration tool

echo "🚀 Setting up SPA Migration Tool..."

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3.8+ and try again."
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"

# Check if pip is available
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is required but not installed."
    exit 1
fi

echo "✅ pip3 found"

# Install dependencies
echo "📦 Installing Python dependencies..."
pip3 install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Check for ODBC Driver
echo "🔍 Checking for ODBC Driver for SQL Server..."

if command -v odbcinst &> /dev/null; then
    if odbcinst -q -d | grep -q "ODBC Driver.*for SQL Server"; then
        echo "✅ ODBC Driver for SQL Server found"
    else
        echo "⚠️  ODBC Driver for SQL Server not found"
        echo "Please install Microsoft ODBC Driver for SQL Server"
        echo "macOS: brew install msodbcsql17"
        echo "Ubuntu: https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server"
    fi
else
    echo "⚠️  odbcinst not found - ODBC drivers may not be properly installed"
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created. Please update it with your database settings."
else
    echo "ℹ️  .env file already exists"
fi

# Make the migrator executable
chmod +x spa_migrator.py

echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Update .env file with your database settings"
echo "2. Test the connection: python3 spa_migrator.py --action list --db-server YOUR_SERVER --db-name YOUR_DB"
echo "3. Migrate components: python3 spa_migrator.py --action migrate-all --db-server YOUR_SERVER --db-name YOUR_DB"
echo ""
echo "For help: python3 spa_migrator.py --help"