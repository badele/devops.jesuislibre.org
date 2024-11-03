---
title: GPG
---

{{< hint type=note title="Introduction" >}} **GPG** (GNU Privacy Guard) est un
outil open-source qui permet de chiffrer, signer et authentifier des données. Il
permet notamment de vérifier qu'un fichier téléchargé est valide et non altéré.
GPG offre également les fonctionnalités suivantes :

- Connexion sécurisée à un serveur SSH avec une clef GPG
- Signature des commits Git
- Sécurisation des clefs via un dispositif physique, par exemple une clef
  [Yubikey](https://www.yubico.com/la-cle-yubikey/?lang=fr) {{< /hint >}}

{{< toc >}}

## Gestion des clefs GPG

### Création des clefs

La création d'une clef principale (de certification uniquement) permet ensuite
de générer des sous-clefs dédiées aux différentes opérations (signature,
chiffrement, authentification), avec des dates d'expiration.

```bash
# Primary key(Certification only)
gpg --quick-gen-key 'votre_email@example.com' rsa4096 cert
export GPG_USERID=$(gpg -K | grep -oE "[a-fA-F0-9]{40}")

# Create subkeys
gpg --quick-addkey ${GPG_USERID} rsa4096 sign 2y
gpg --quick-addkey ${GPG_USERID} rsa4096 encr 2y
gpg --quick-addkey ${GPG_USERID} rsa4096 auth 2y
```

### Ajout d'informations complémentaires

Ajoutez une adresse email supplémentaire ou une photo à votre clef.

```bash
gpg --quick-add-uid ${GPG_USERID} "<nouvel_email@example.com>"
gpg --edit-key ${GPG_USERID}
gpg trust
gpg addphoto nom_du_fichier_photo
gpg save
gpg --check-trustdb
```

### Révocation d'une ancienne clef (optionnel)

Si vous souhaitez révoquer une ancienne clef tout en transférant sa confiance à
une nouvelle clef.

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

### Sauvegarde et Publication des clefs

```bash
# Define variables in your bashrc or zenv (GPG_BACKUP_DIR and GPG_USERID)
# backup command (see the source at the bottom of this document)
gpg-backup-keys

# Publication of public keys
gpg --send-key ${GPG_USERID}
```

Vous pouvez également associer votre clef à d'autres identités en l'ajoutant à
[Keybase](https://keybase.io).

### Suppression de la clef Principale de votre Ordinateur

En supprimant la clef principale de votre ordinateur, vous limitez les risques
en cas de compromission, car il ne sera plus possible de générer de nouvelles
sous-clefs depuis cette machine.

```bash
# Securing (delete the master key from the computer)
gpg --delete-secret-key ${GPG_USERID}

# Check that the computer no longer contains the master key
gpg -K # You should see 'sec#', indicating that the master key does not have a private key
```

### Import des clefs

Restaurer les clefs depuis une sauvegarde.

```bash
gpg --import ${GPG_BACKUP_DIR}/lastkeys/secret_key.gpg
gpg --import ${GPG_BACKUP_DIR}/lastkeys/secret_subkeys.gpg
gpg --import ${GPG_BACKUP_DIR}/lastkeys/public_key.gpg
gpg --import-ownertrust ${GPG_BACKUP_DIR}/lastkeys/ownertrust.asc
```

### Modification des dates d'expirations

#### Annulation de la date d'expiration sur la clef primaire

```bash
gpg --edit-key $GPG_USERID
expire
# Select 0 (never expire)
```

#### Modification de la date d'expiration sur les clefs secondaires

```bash
gpg --edit-key $GPG_USERID
key 1
key 2
key 3
expire
save
```

## Utilisation d'une Yubikey

### Transfert des clefs GPG vers la Yubikey

Pour déplacer les clefs vers une Yubikey :

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

### Vérification de l'Absence des clefs privées en local

Après le transfert réussi des clefs vers la Yubikey, la commande suivante doit
afficher `ssb>` (ou `ssb#` si GPG ne peut pas localiser la clef secrète).

```bash
gpg -K
```

### Affichage des détails de la clef

```bash
gpg --card-status
```

## Support SSH

Pour activer le support SSH, configurez les fichiers nécessaires en ajoutant les
paramètres adéquats.

Modification le fichier `~/.gnupg/gpg-agent.conf` pour l'activation du support
SSH

```text
# Enable SSH support
enable-ssh-support

# [Optional]
# Request paraphrase after this time
default-cache-ttl 600
max-cache-ttl 7200
```

Indiquer quelles sont les clefs à utiliser pour les connexions SSH, il faut
ajouter le keygrip dans le fichier `~/.gnupg/sshcontrol`. Keygrip que l'on peut
obtenir avec la commande suivante

`gpg -k --with-keygrip`

Redémarer ensuite le service gpg-agent avec la commande suivante
`gpgconf --kill gpg-agent`

## Divers

### Annexes

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

### Troubles

```bash
#for f in $(ls ~/.ssh/*.pub); do
#  ssh-keygen -l -E md5 -f $f
#done
gpg-connect-agent "KEYINFO --ssh-list --ssh-fpr" /bye
gpg-connect-agent "DELETE_KEY <IDKEYS>" /bye
```

### Sources

#### Script de Sauvegarde (gpg-backup-keys)

Le script suivant permet de sauvegarder vos clefs GPG.

```bash
#!/usr/bin/env bash

set -e

BACKUP_DATE=$(date "+%Y-%m-%d")

# Checking defined variables
if [ -z "$GPG_BACKUP_DIR" ] || [ -z "$GPG_USERID" ]; then
    echo "Veuillez définir les variables GPG_BACKUP_DIR et GPG_USERID"
    exit 1
fi

# Checking the existence of the folder
if [ ! -d "$GPG_BACKUP_DIR" ]; then
    echo "Veuillez monter le disque '${GPG_BACKUP_DIR}'"
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
