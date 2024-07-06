#!/usr/bin/env python3
# https://github.blog/changelog/2021-10-27-github-actions-secure-cloud-deployments-with-openid-connect/
import argparse
import json
import os
import uuid
from base64 import b64decode as decode
from pathlib import Path
from pip._vendor import requests
from pprint import pprint
from urllib.parse import urlparse

parser = argparse.ArgumentParser()
parser.add_argument('--role', required=True)

github_env = Path(os.environ['GITHUB_ENV'])
SCRIPT_DEBUG = False


def main():
    args = parser.parse_args()

    token = fetch_token()
    path = write_tempfile(token)
    debug_token(token)

    append_env('AWS_ROLE_ARN', args.role)
    append_env('AWS_WEB_IDENTITY_TOKEN_FILE', path)


def fetch_token() -> str:
    url = os.getenv('ACTIONS_ID_TOKEN_REQUEST_URL')
    token = os.getenv('ACTIONS_ID_TOKEN_REQUEST_TOKEN')

    assert url, 'GitHub Actions Token URL not set'
    assert token, 'GitHub Actions Access Token not set'

    domain = urlparse(url)
    print(f"Requesting OIDC Token from {domain}")

    response = requests.get(url, headers={
        'Authorization': f'Bearer {token}',
    })

    payload = response.json()

    if SCRIPT_DEBUG:
        pprint(payload)

    return payload['value']


def write_tempfile(content: str) -> Path:
    temp = Path('/tmp/') / uuid.uuid4().hex
    path = temp / 'webidentity.json'

    temp.mkdir()
    with path.open('w') as f:
        f.write(content)

    if SCRIPT_DEBUG:
        print("Writing webidentity file")
        print(f"Directory: {temp}")
        print(f"File: {path}")

    return path


def append_env(key, value):
    line = f'{key}={value}\n'
    with github_env.open('a') as g:
        g.write(line)


def debug_token(token: str):
    # Do not rely on the content, we are not checking the signature
    header, content, signature = token.split('.')

    payload = '{}'
    for padding in range(8):
        try:
            payload = decode(content + '=' * padding)
            break
        except ValueError:
            continue

    if SCRIPT_DEBUG:
        pprint(json.loads(payload))

    print(f"token.actions.githubusercontent.com:aud = {payload['aud']}")
    print(f"token.actions.githubusercontent.com:sub = {payload['sub']}")


if __name__ == '__main__':
    main()
