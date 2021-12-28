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

parser = argparse.ArgumentParser()
parser.add_argument('--role', required=True)

github_env = Path(os.environ['GITHUB_ENV'])


def fetch_token() -> str:
    url = os.getenv('ACTIONS_ID_TOKEN_REQUEST_URL')
    token = os.getenv('ACTIONS_ID_TOKEN_REQUEST_TOKEN')

    assert url, 'GitHub Actions Token URL not set'
    assert token, 'GitHub Actions Access Token not set'

    response = requests.get(url, headers={
        'Authorization': f'Bearer {token}',
    })

    return response.json()['value']


def write_tempfile(content: str) -> Path:
    temp = Path('/tmp/') / uuid.uuid4().hex
    path = temp / 'webidentity.json'

    temp.mkdir()
    with path.open('w') as f:
        f.write(content)
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

    pprint(json.loads(payload))


def main():
    args = parser.parse_args()

    token = fetch_token()
    path = write_tempfile(token)
    debug_token(token)

    append_env('AWS_ROLE_ARN', args.role)
    append_env('AWS_WEB_IDENTITY_TOKEN_FILE', path)


if __name__ == '__main__':
    main()
