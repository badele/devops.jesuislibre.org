---
title: GPG
---

{{< hint type=note title="Introduction" >}} **GPG** (GNU Privacy Guard) is an
open-source tool that enables encryption, signing, and authentication of data.
It helps verify that a downloaded file is valid and has not been tampered with.
GPG also offers the following features:

- Secure SSH connection with a GPG key
- Git commit signing
- Key security with a physical device, such as a
  [Yubikey](https://www.yubico.com/la-cle-yubikey/?lang=fr) {{< /hint >}}

{{< toc >}}

## Managing GPG Keys

### Key Creation

Creating a primary key (for certification only) allows for generating subkeys
dedicated to different operations (signing, encryption, authentication), each
with expiration dates.

```bash
# Primary key(Certification only)
gpg --quick-gen-key 'your_email@example.com' rsa4096 cert
export GPG_USERID=$(gpg -K | grep -oE "[a-fA-F0-9]{40}")

# Create subkeys
gpg --quick-addkey ${GPG_USERID} rsa4096 sign 2y
gpg --quick-addkey ${GPG_USERID} rsa4096 encr 2y
gpg --quick-addkey ${GPG_USERID} rsa4096 auth 2y
```

### Adding Additional Information

Add an additional email address or a photo to your key.

```bash
gpg --quick-add-uid ${GPG_USERID} "<new_email@example.com>"
gpg --edit-key ${GPG_USERID}
gpg trust
gpg addphoto photo_file_name
gpg save
gpg --check-trustdb
```

### Revoking an Old Key (optional)

If you want to revoke an old key while transferring its trust to a new one.

```bash
# Import old keys
gpg --import ${GPG_OLDKEY}
gpg --edit-key ${GPG_OLDKEY}
gpg setpref clean quit

# Sign the new key with the old one if it is still valid
gpg --default-key ${GPG_OLDKEY} --sign-key ${GPG_USERID}

# Sign the old key with the new one
gpg --default-key ${GPG_USERID} --sign-key ${GPG_OLDKEY}

# Generate and import the revocation certificate of the old key
gpg --gen-revoke ${GPG_OLDKEY} > /tmp/revoke.asc
gpg --import /tmp/revoke.asc
gpg --send-keys ${GPG_OLDKEY}
```

### Backing Up and Publishing Keys

```bash
# Define variables in your bashrc or zenv (GPG_BACKUP_DIR and GPG_USERID)
# backup command (see the source at the bottom of this document)
gpg-backup-keys

# Publish public keys
gpg --send-key ${GPG_USERID}
```

You can also associate your key with other identities by adding it to
[Keybase](https://keybase.io).

### Deleting the Primary Key from Your Computer

By deleting the primary key from your computer, you limit risks in case of
compromise, as it will no longer be possible to generate new subkeys from this
machine.

```bash
# Securing (delete the master key from the computer)
gpg --delete-secret-key ${GPG_USERID}

# Check that the computer no longer contains the master key
gpg -K # You should see 'sec#', indicating that the master key does not have a private key
```

### Importing Keys

Restore keys from a backup.

```bash
gpg --import ${GPG_BACKUP_DIR}/lastkeys/secret_key.gpg
gpg --import ${GPG_BACKUP_DIR}/lastkeys/secret_subkeys.gpg
gpg --import ${GPG_BACKUP_DIR}/lastkeys/public_key.gpg
gpg --import-ownertrust ${GPG_BACKUP_DIR}/lastkeys/ownertrust.asc
```

### Changing expiration dates

#### Canceling the expiration date on the primary key

```bash
gpg --edit-key $GPG_USERID
expire
# Select 0 (never expire)
```

#### Changing the expiration date on secondary keys

```bash
gpg --edit-key $GPG_USERID
key 1
key 2
key 3
expire
save
```

## Using a Yubikey

### Transferring GPG Keys to the Yubikey

To move keys to a Yubikey:

```bash
gpg2 -K
gpg2 --expert --edit-key $GPG_USERID
key 1
keytocard
key 2
keytocard
key 3
keytocard
save
quit
```

### Verifying the Absence of Local Private Keys

After the successful transfer of keys to the Yubikey, the following command
should display `ssb>` (or `ssb#` if GPG cannot locate the secret key).

```bash
gpg -K
```

### Displaying Key Details

```bash
gpg --card-status
```

## SSH Support

To enable SSH support, configure the necessary files by adding the appropriate
parameters.

Modify the file `~/.gnupg/gpg-agent.conf` to enable SSH support.

```text
# Enable SSH support
enable-ssh-support

# [Optional]
# Request paraphrase after this time
default-cache-ttl 600
max-cache-ttl 7200
```

Specify which keys to use for SSH connections by adding the keygrip to the file
`~/.gnupg/sshcontrol`. The keygrip can be obtained with the following command:

`gpg -k --with-keygrip`

Restart the `gpg-agent` service with the following command:
`gpgconf --kill gpg-agent`

## Miscellaneous

### Appendix

```bash
# Show key information
gpg --edit-key <keyid>
gpg> showpref
# Another method
gpg --export <keyid> | gpg --list-packets

# show a key was signed by another key
gpg --list-sig <keyid>

# Import key
gpg --import <key file>

# Import remote key
gpg --recv-keys <keyid>

# Edit key
gpg --edit-key <keyid>

# Encrypt file
gpg --encrypt -o <encrypted file> [--recipient <keyid>] <file to encrypt>

# Decrypt
gpg --decrypt -o <encrypted file> <file to decrypt>

# Sign
gpg -o <sign file> --sign <file to sign>

# sign verification
gpg --verify <sign file>
```

### Troubleshooting

```bash
#for f in $(ls ~/.ssh/*.pub); do
#  ssh-keygen -l -E md5 -f $f
#done
gpg-connect-agent "KEYINFO --ssh-list --ssh-fpr" /bye
gpg-connect-agent "DELETE_KEY <IDKEYS>" /bye
```

### Sources

#### Backup Script (gpg-backup-keys)

The following script allows you to back up your GPG keys.

```bash
#!/usr/bin/env bash

set -e

BACKUP_DATE=$(date "+%Y-%m-%d")

# Checking defined variables
if [ -z "$GPG_BACKUP_DIR" ] || [ -z "$GPG_USERID" ]; then
    echo "Please define GPG_BACKUP_DIR and GPG_USERID variables"
    exit 1
fi

# Checking the existence of the folder
if [ ! -d "$GPG_BACKUP_DIR" ]; then
    echo "Please mount the '${GPG_BACKUP_DIR}' disk"
    exit 1
fi

# Creation of the backup directory
BACKUP_DIR="${GPG_BACKUP_DIR}/${BACKUP_DATE}"
mkdir -p ${BACKUP_DIR}

# Creating a link to the latest save directory
LASTKEYS="${GPG_BACKUP_DIR}/lastkeys"
rm -f ${LASTKEYS}
ln -s ${BACKUP_DIR} ${LASTKEYS}

# Saving the public key
gpg -a --export ${GPG_USERID} > ${LASTKEYS}/public_key.gpg

# Safeguarding trust (ownertrust)
gpg -a --export-ownertrust > ${LASTKEYS}/ownertrust.asc

# Backup of the master key (to be stored securely)
gpg -a --export-secret-keys ${GPG_USERID} > ${LASTKEYS}/secret_key.gpg

# Saving subkeys
gpg -a --export-secret-subkeys ${GPG_USERID} > ${LASTKEYS}/secret_subkeys.gpg

# Saving the revocation certificate
cp ~/.gnupg/openpgp-revocs.d/${GPG_USERID}.rev ${LASTKEYS}/revocation.asc
```
