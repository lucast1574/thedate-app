#!/usr/bin/env python3
"""Build using the existing private upload key, never a debug key."""
import argparse,json,os,subprocess
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('--bundle',action='store_true');args=parser.parse_args()
root=Path(__file__).resolve().parents[1]
config=Path.home()/'.local/share/thedate-mobile'/(root.name+'-signing.json')
if not config.is_file():raise SystemExit('Missing private signing configuration: '+str(config))
values=json.loads(config.read_text())
env={**os.environ,'DATE_STORE_FILE':values['storeFile'],'DATE_STORE_PASSWORD':values['storePassword'],'DATE_KEY_ALIAS':values['keyAlias'],'DATE_KEY_PASSWORD':values['keyPassword'],'GRADLE_OPTS':'-Dorg.gradle.workers.max=2 -Dorg.gradle.daemon=false'}
subprocess.run(['flutter','build','appbundle' if args.bundle else 'apk','--release','--target-platform','android-arm,android-arm64,android-x64'],cwd=root,env=env,check=True)
