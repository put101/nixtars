#!/bin/bash
set -e

nixos-rebuild switch --flake .#nixtars

if git status --porcelain | grep -q .; then
    git add .
    git commit -m "Auto build commit $(date)"
fi
