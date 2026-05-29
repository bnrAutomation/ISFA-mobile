echo "Select an environment:"
echo "1. Dev"
echo "2. Prod"
echo "3. QA"

# Prompt the user to select an environment
read -p "Enter the number corresponding to your choice: " ENVIRONMENT_CHOICE

# Set the base URL based on the user's selection
case $ENVIRONMENT_CHOICE in
    1)
        BASE_URL="https://isfadev.denave.com:8445"
        ;;
    2)
        BASE_URL="https://isfa.denave.com:8445"
        ;;
    3)
        BASE_URL="https://isfaqa.denave.com:8445"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Prompt the user if they want to build the IPA release
read -p "Do you want to build the IPA release? (y/n): " BUILD_IPA

# Build iOS release
flutter build ios --release --obfuscate --split-debug-info=build/ios/ipa/ --dart-define BASE_URL="$BASE_URL"

if [ "$BUILD_IPA" = "y" ]; then
    # Build IPA release
    flutter build ipa --release --obfuscate --split-debug-info=build/ios/ipa/ --dart-define BASE_URL="$BASE_URL"
    open build/ios/ipa/
else
    open ios/Runner.xcworkspace/
    echo "IPA release not built. Exiting."
fi