#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "${EUID}" -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

if ! command -v apt-get >/dev/null 2>&1 || ! command -v systemctl >/dev/null 2>&1; then
    echo "Erreur : ce script nécessite une distribution Debian ou dérivée utilisant apt et systemd." >&2
    exit 1
fi

source /etc/os-release

# Docker publie des paquets pour Debian, pas pour le nom de distribution Kali.
# On utilise donc le codename Debian correspondant lorsque nécessaire.
if [[ "${ID:-}" == "kali" ]]; then
    DOCKER_CODENAME="${DOCKER_CODENAME:-trixie}"
else
    DOCKER_CODENAME="${VERSION_CODENAME:-}"
fi

if [[ -z "${DOCKER_CODENAME}" ]]; then
    echo "Erreur : impossible de déterminer le codename Debian." >&2
    echo "Relancez avec, par exemple : DOCKER_CODENAME=trixie $0" >&2
    exit 1
fi

echo "Mise à jour de l'index APT..."
${SUDO} apt-get update

echo "Installation des dépendances..."
# software-properties-common n'est pas nécessaire : nous n'utilisons pas add-apt-repository.
${SUDO} apt-get install -y ca-certificates curl gnupg

echo "Configuration de la clé GPG Docker..."
${SUDO} install -m 0755 -d /etc/apt/keyrings
${SUDO} curl -fsSL https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc
${SUDO} chmod a+r /etc/apt/keyrings/docker.asc

echo "Configuration du dépôt Docker (${DOCKER_CODENAME})..."
${SUDO} tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${DOCKER_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "Mise à jour des dépôts..."
${SUDO} apt-get update

echo "Installation de Docker Engine..."
${SUDO} apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Activation du service Docker..."
${SUDO} systemctl enable --now docker

if [[ -n "${SUDO}" ]]; then
    ${SUDO} usermod -aG docker "${USER}"
else
    usermod -aG docker "${SUDO_USER:-${USER}}"
fi

echo
${SUDO} docker --version
${SUDO} docker compose version
${SUDO} docker run --rm hello-world

echo
 echo "Installation terminée. Déconnectez-vous puis reconnectez-vous pour utiliser Docker sans sudo."
