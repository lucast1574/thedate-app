#!/usr/bin/env python3
"""Build with the verified product upload key on Windows or Linux."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
from signing import configuration, verify

parser = argparse.ArgumentParser()
parser.add_argument('--bundle', action='store_true')
parser.add_argument('--verify-only', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
config = configuration(root.name)
verify(root, config)
if args.verify_only:
    raise SystemExit(0)
env = {**os.environ, 'DATE_STORE_FILE': config['storeFile'], 'DATE_STORE_PASSWORD': config['storePassword'], 'DATE_KEY_ALIAS': config['keyAlias'], 'DATE_KEY_PASSWORD': config['keyPassword'], 'GRADLE_OPTS': '-Dorg.gradle.workers.max=2 -Dorg.gradle.daemon=false'}
flutter = shutil.which('flutter') or (r'C:\flutter\flutter\bin\flutter.bat' if os.name == 'nt' else 'flutter')
subprocess.run([flutter, 'build', 'appbundle' if args.bundle else 'apk', '--release', '--target-platform', 'android-arm,android-arm64,android-x64'], cwd=root, env=env, check=True)
