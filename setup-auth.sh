#!/bin/bash

echo "Setting up Google Cloud authentication for Speech-to-Text API"
echo "=============================================="
echo ""
echo "Since we need service account credentials, please follow these steps:"
echo ""
echo "1. Open this URL in your browser:"
echo "   https://console.cloud.google.com/iam-admin/serviceaccounts?project=gen-lang-client-0047710702"
echo ""
echo "2. Click 'CREATE SERVICE ACCOUNT'"
echo ""
echo "3. Fill in:"
echo "   - Service account name: speech-to-text-app"
echo "   - Service account ID: (auto-filled)"
echo "   - Click 'CREATE AND CONTINUE'"
echo ""
echo "4. Grant the role:"
echo "   - Select 'Cloud Speech Client'"
echo "   - Click 'CONTINUE'"
echo ""
echo "5. Click 'DONE'"
echo ""
echo "6. Find your new service account in the list and click on it"
echo ""
echo "7. Go to the 'KEYS' tab"
echo ""
echo "8. Click 'ADD KEY' > 'Create new key'"
echo ""
echo "9. Choose 'JSON' and click 'CREATE'"
echo ""
echo "10. Save the downloaded file somewhere safe"
echo ""
echo "Once you have the file, we'll update the app to use it."