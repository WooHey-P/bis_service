#!/bin/bash

# Flutter Web 빌드
flutter build web

# Redirect 파일 복사
cp ./redirects.txt ./build/web/_redirects

# Git 커밋 & 푸시
git add .
git commit -m "chore: update web build"
git push origin main
