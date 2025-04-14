#!/bin/bash

# Fix RecaptchaInterop header includes by replacing double quotes with angle brackets

RECAPTCHA_DIR="/Users/robertburns/Projects/kidview/ios/Pods/RecaptchaInterop"
UMBRELLA_PATH="/Users/robertburns/Projects/kidview/ios/Pods/Target Support Files/RecaptchaInterop/RecaptchaInterop-umbrella.h"

echo "Fixing RecaptchaInterop header includes..."

# Fix RCARecaptchaClientProtocol.h
sed -i '' 's|#import "RCAActionProtocol.h"|#import <RecaptchaInterop/RCAActionProtocol.h>|g' "$RECAPTCHA_DIR/RecaptchaEnterprise/RecaptchaInterop/Public/RecaptchaInterop/RCARecaptchaClientProtocol.h"

# Fix RCARecaptchaProtocol.h
sed -i '' 's|#import "RCARecaptchaClientProtocol.h"|#import <RecaptchaInterop/RCARecaptchaClientProtocol.h>|g' "$RECAPTCHA_DIR/RecaptchaEnterprise/RecaptchaInterop/Public/RecaptchaInterop/RCARecaptchaProtocol.h"

# Fix RecaptchaInterop.h
sed -i '' 's|#import "RCAActionProtocol.h"|#import <RecaptchaInterop/RCAActionProtocol.h>|g' "$RECAPTCHA_DIR/RecaptchaEnterprise/RecaptchaInterop/Public/RecaptchaInterop/RecaptchaInterop.h"
sed -i '' 's|#import "RCARecaptchaClientProtocol.h"|#import <RecaptchaInterop/RCARecaptchaClientProtocol.h>|g' "$RECAPTCHA_DIR/RecaptchaEnterprise/RecaptchaInterop/Public/RecaptchaInterop/RecaptchaInterop.h"
sed -i '' 's|#import "RCARecaptchaProtocol.h"|#import <RecaptchaInterop/RCARecaptchaProtocol.h>|g' "$RECAPTCHA_DIR/RecaptchaEnterprise/RecaptchaInterop/Public/RecaptchaInterop/RecaptchaInterop.h"

# Fix RecaptchaInterop-umbrella.h
sed -i '' 's|#import "RCAActionProtocol.h"|#import <RecaptchaInterop/RCAActionProtocol.h>|g' "$UMBRELLA_PATH"
sed -i '' 's|#import "RCARecaptchaClientProtocol.h"|#import <RecaptchaInterop/RCARecaptchaClientProtocol.h>|g' "$UMBRELLA_PATH"
sed -i '' 's|#import "RCARecaptchaProtocol.h"|#import <RecaptchaInterop/RCARecaptchaProtocol.h>|g' "$UMBRELLA_PATH"
sed -i '' 's|#import "RecaptchaInterop.h"|#import <RecaptchaInterop/RecaptchaInterop.h>|g' "$UMBRELLA_PATH"

echo "Header fixes complete. Now try to archive again."