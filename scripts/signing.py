"""Load existing upload signing credentials without exposing passwords."""
import ctypes
import json
import os
from pathlib import Path
import shutil
import subprocess


def configuration(app):
    if os.name == 'nt':
        class Blob(ctypes.Structure):
            _fields_ = [('size', ctypes.c_ulong), ('data', ctypes.POINTER(ctypes.c_ubyte))]
        path = Path.home() / '.codex/secrets' / (app + '-android-signing.dpapi')
        buffer = ctypes.create_string_buffer(path.read_bytes())
        incoming = Blob(len(buffer.raw) - 1, ctypes.cast(buffer, ctypes.POINTER(ctypes.c_ubyte)))
        outgoing = Blob()
        if not ctypes.windll.crypt32.CryptUnprotectData(ctypes.byref(incoming), None, None, None, None, 1, ctypes.byref(outgoing)):
            raise ctypes.WinError()
        try:
            return json.loads(ctypes.string_at(outgoing.data, outgoing.size))
        finally:
            ctypes.windll.kernel32.LocalFree(outgoing.data)
    path = Path.home() / '.local/share/thedate-mobile' / (app + '-signing.json')
    return json.loads(path.read_text())


def verify(root, config):
    tool = shutil.which('keytool')
    if not tool and os.name == 'nt':
        tool = r'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
    env = {**os.environ, 'DATE_VERIFY_PASSWORD': config['storePassword']}
    result = subprocess.run([tool or 'keytool', '-list', '-v', '-keystore', config['storeFile'], '-alias', config['keyAlias'], '-storepass:env', 'DATE_VERIFY_PASSWORD'], env=env, capture_output=True, text=True, check=True)
    expected = json.loads((root / 'store/signing-fingerprints.json').read_text())['upload']
    for name in ('sha1', 'sha256'):
        if expected[name].upper() not in result.stdout.upper():
            raise RuntimeError('Upload certificate does not match ' + name)
    print('Upload certificate matches the registered SHA-1 and SHA-256.')
