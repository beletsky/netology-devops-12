import hvac
import os
import sys

try:
    client = hvac.Client(url=os.environ['VAULT_URL'], token=os.environ['VAULT_TOKEN'])
except KeyError:
    print("Environment variables VAULT_URL and VAULT_TOKEN should be set.")
    sys.exit(1)

if not client.is_authenticated():
    print("Vault authentication failed.")
    sys.exit(1)

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path = 'hvac',
    secret = dict(netology = 'Netology secret value in Vault.'),
)

# Читаем секрет
secret = client.secrets.kv.v2.read_secret_version(
    path = 'hvac',
)

print('The secret value is:')
print(secret['data']['data']['netology'])
