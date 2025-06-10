#!/bin/bash

# Google Cloud Speech-to-Text Cost Calculator
# This script estimates costs based on the streaming recognition pricing

PROJECT_ID="gen-lang-client-0047710702"
CREDENTIALS_FILE="./gen-lang-client-0047710702-7515e14fe811.json"

echo "=== Google Speech-to-Text Cost Analysis ==="
echo "Project: $PROJECT_ID"
echo ""

# Set up authentication
export GOOGLE_APPLICATION_CREDENTIALS="$CREDENTIALS_FILE"

# Pricing as of 2024:
# Streaming recognition: $0.018 per minute (first 60 minutes free per month)
PRICE_PER_MINUTE=0.018
FREE_MINUTES=60

# Try to get usage from logs or estimate based on server uptime
echo "Checking current month's usage..."

# Get current date info
CURRENT_MONTH=$(date +"%B %Y")
DAYS_IN_MONTH=$(date +"%d")
DAYS_REMAINING=$(($(date -v +1m -v 1d -v -1d +"%d") - $DAYS_IN_MONTH))

echo "Current month: $CURRENT_MONTH"
echo "Days elapsed: $DAYS_IN_MONTH"
echo "Days remaining: $DAYS_REMAINING"
echo ""

# Estimate usage based on typical patterns
echo "=== Usage Estimates ==="
echo ""

# Conservative estimate: 2 hours per day
HOURS_PER_DAY=2
MINUTES_PER_DAY=$((HOURS_PER_DAY * 60))
TOTAL_MINUTES_THIS_MONTH=$((MINUTES_PER_DAY * DAYS_IN_MONTH))
BILLABLE_MINUTES=$((TOTAL_MINUTES_THIS_MONTH - FREE_MINUTES))

if [ $BILLABLE_MINUTES -lt 0 ]; then
    BILLABLE_MINUTES=0
fi

CURRENT_COST=$(echo "scale=2; $BILLABLE_MINUTES * $PRICE_PER_MINUTE" | bc)
PROJECTED_MONTHLY_MINUTES=$((MINUTES_PER_DAY * 30))
PROJECTED_BILLABLE=$((PROJECTED_MONTHLY_MINUTES - FREE_MINUTES))

if [ $PROJECTED_BILLABLE -lt 0 ]; then
    PROJECTED_BILLABLE=0
fi

PROJECTED_MONTHLY_COST=$(echo "scale=2; $PROJECTED_BILLABLE * $PRICE_PER_MINUTE" | bc)

echo "Estimated usage (@ $HOURS_PER_DAY hours/day):"
echo "- Minutes used this month: $TOTAL_MINUTES_THIS_MONTH"
echo "- Free minutes remaining: $((FREE_MINUTES - TOTAL_MINUTES_THIS_MONTH))"
echo "- Billable minutes: $BILLABLE_MINUTES"
echo ""

echo "=== Cost Breakdown ==="
echo "- Cost so far this month: \$$CURRENT_COST"
echo "- Projected monthly cost: \$$PROJECTED_MONTHLY_COST"
echo ""

# Different usage scenarios
echo "=== Cost Scenarios ==="
echo "Daily Usage | Monthly Minutes | Monthly Cost"
echo "----------- | -------------- | ------------"
echo "30 min/day  | 900 minutes    | \$$(echo "scale=2; (900-$FREE_MINUTES)*$PRICE_PER_MINUTE" | bc)"
echo "1 hour/day  | 1,800 minutes  | \$$(echo "scale=2; (1800-$FREE_MINUTES)*$PRICE_PER_MINUTE" | bc)"
echo "2 hours/day | 3,600 minutes  | \$$(echo "scale=2; (3600-$FREE_MINUTES)*$PRICE_PER_MINUTE" | bc)"
echo "4 hours/day | 7,200 minutes  | \$$(echo "scale=2; (7200-$FREE_MINUTES)*$PRICE_PER_MINUTE" | bc)"
echo "8 hours/day | 14,400 minutes | \$$(echo "scale=2; (14400-$FREE_MINUTES)*$PRICE_PER_MINUTE" | bc)"
echo ""

echo "=== Cost Saving Tips ==="
echo "1. First 60 minutes per month are FREE"
echo "2. Use mute button when not speaking to pause billing"
echo "3. Close the browser tab when not using the service"
echo "4. The improved mute detection helps reduce unnecessary API calls"
echo ""

# Try to check actual billing if gcloud is authenticated
echo "Attempting to fetch actual billing data..."
gcloud auth activate-service-account --key-file="$CREDENTIALS_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Checking Cloud Billing API..."
    # This would require billing API enabled and proper permissions
    gcloud alpha billing accounts list 2>/dev/null
else
    echo "Note: For actual usage data, enable Cloud Billing API and authenticate with:"
    echo "  gcloud auth activate-service-account --key-file=$CREDENTIALS_FILE"
fi