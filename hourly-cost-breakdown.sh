#!/bin/bash

# Hourly breakdown calculator for Google Speech-to-Text costs
echo "=== Google Speech-to-Text Hourly Cost Breakdown ==="
echo ""

# Pricing constants
PRICE_PER_MINUTE=0.018
FREE_MINUTES=60

# If you spent $20 in one day
DAILY_COST=20
BILLABLE_MINUTES=$(echo "scale=0; $DAILY_COST / $PRICE_PER_MINUTE" | bc)
TOTAL_MINUTES=$((BILLABLE_MINUTES + FREE_MINUTES))
TOTAL_HOURS=$(echo "scale=1; $TOTAL_MINUTES / 60" | bc)

echo "Your usage for $20 spent in ONE day:"
echo "=================================="
echo "- Total cost: \$$DAILY_COST"
echo "- Billable minutes: $BILLABLE_MINUTES (after 60 free minutes)"
echo "- Total minutes used: $TOTAL_MINUTES"
echo "- Total hours: $TOTAL_HOURS hours"
echo ""

echo "Hourly Breakdown:"
echo "================"
echo "Hour  | Minutes | Cost      | Cumulative Cost"
echo "------|---------|-----------|----------------"

cumulative_cost=0
cumulative_minutes=0

for hour in {1..20}; do
    if [ $cumulative_minutes -lt $TOTAL_MINUTES ]; then
        # Calculate minutes for this hour
        remaining_minutes=$((TOTAL_MINUTES - cumulative_minutes))
        if [ $remaining_minutes -ge 60 ]; then
            hour_minutes=60
        else
            hour_minutes=$remaining_minutes
        fi
        
        # Calculate cost for this hour
        if [ $cumulative_minutes -lt $FREE_MINUTES ]; then
            # Still in free tier
            free_minutes_this_hour=$((FREE_MINUTES - cumulative_minutes))
            if [ $free_minutes_this_hour -ge $hour_minutes ]; then
                # Entire hour is free
                hour_cost=0
            else
                # Partial free, partial paid
                paid_minutes=$((hour_minutes - free_minutes_this_hour))
                hour_cost=$(echo "scale=2; $paid_minutes * $PRICE_PER_MINUTE" | bc)
            fi
        else
            # All paid minutes
            hour_cost=$(echo "scale=2; $hour_minutes * $PRICE_PER_MINUTE" | bc)
        fi
        
        cumulative_minutes=$((cumulative_minutes + hour_minutes))
        cumulative_cost=$(echo "scale=2; $cumulative_cost + $hour_cost" | bc)
        
        printf "%-5d | %-7d | \$%-8s | \$%-8s\n" $hour $hour_minutes $hour_cost $cumulative_cost
    fi
done

echo ""
echo "Cost Analysis:"
echo "============="
echo "- First hour: FREE (60 minutes included)"
echo "- Hours 2-20: \$1.08 per hour (60 min × \$0.018/min)"
echo "- You used the service for $TOTAL_HOURS hours straight!"
echo ""

echo "Minute-by-Minute Pricing:"
echo "========================"
echo "Minutes Used | Cost"
echo "-------------|------"
echo "0-60         | FREE"
echo "61-120       | \$1.08"
echo "121-180      | \$2.16"
echo "181-240      | \$3.24"
echo "241-300      | \$4.32"
echo "301-360      | \$5.40"
echo "361-420      | \$6.48"
echo "421-480      | \$7.56"
echo "481-540      | \$8.64"
echo "541-600      | \$9.72"
echo "601-660      | \$10.80"
echo "661-720      | \$11.88"
echo "721-780      | \$12.96"
echo "781-840      | \$14.04"
echo "841-900      | \$15.12"
echo "901-960      | \$16.20"
echo "961-1020     | \$17.28"
echo "1021-1080    | \$18.36"
echo "1081-1140    | \$19.44"
echo "1141-1171    | \$20.00"
echo ""

echo "CONCLUSION:"
echo "==========="
echo "To spend \$20 in one day, you ran the transcription service"
echo "continuously for $TOTAL_HOURS hours ($(echo "scale=0; $TOTAL_MINUTES" | bc) minutes)!"
echo ""
echo "This suggests either:"
echo "1. The service was left running unintentionally"
echo "2. There was heavy usage throughout the day"
echo "3. The continuous listening (no pause) increased usage"