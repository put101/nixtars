#!/bin/bash
set -e

sudo nixos-rebuild switch --flake .#nixtars

if git status --porcelain | grep -q .; then
    git add .
    git commit -m "Auto build commit $(date)"
fi
