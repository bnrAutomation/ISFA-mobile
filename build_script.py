import subprocess
import os

def main():
    print("Select an environment:")
    print("1. Dev")
    print("2. Prod")
    print("3. QA")

    # Prompt the user to select an environment
    try:
        environment_choice = int(input("Enter the number corresponding to your choice: "))
    except ValueError:
        print("Invalid input. Please enter a number.")
        return

    # Set the base URL based on the user's selection
    base_urls = {
        1: "https://isfadev.denave.com:8445",
        2: "https://isfa.denave.com:8445",
        3: "https://isfaqa.denave.com:8445",
    }
    
    base_url = base_urls.get(environment_choice)

    if base_url is None:
        print("Invalid choice. Exiting.")
        return

    # Prompt the user if they want to build the IPA release
    build_ipa = input("Do you want to build the IPA release? (y/n): ").lower()

    # Build iOS release
    subprocess.run(["flutter", "build", "ios", "--release", f"--dart-define=BASE_URL={base_url}", "--obfuscate", "--split-debug-info=build/ios/ipa/"])

    if build_ipa == "y":
        # Build IPA release
        subprocess.run(["flutter", "build", "ipa", "--release", f"--dart-define=BASE_URL={base_url}", "--obfuscate", "--split-debug-info=build/ios/ipa/"])
        subprocess.run(["open", "build/ios/ipa/"])
    else:
        subprocess.run(["open", "ios/Runner.xcworkspace/"])
        print("IPA release not built. Exiting.")

if __name__ == "__main__":
    main()
