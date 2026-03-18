# Installation et configuration du serveur Zabbix

## Prérequis

Installation à réaliser sur un Debian 13 Trixie avec une taille de disque de minimum 250 Go pour un usage en production.

## 1. Passer l’interface réseau en IP statique
Permet de donner une adresse fixe au serveur pour que Zabbix soit toujours joignable sur la même IP.

```bash
cp /etc/network/interfaces /etc/network/interfaces.bak
nano -lc /etc/network/interfaces
```

Remplacer le bloc `INTERFACE_NAME` par :
```bash
iface INTERFACE_NAME inet static
  address IP_Server
  netmask 255.255.255.0
  gateway IP_Gateway
  iface INTERFACE_NAME inet6 auto
```

Appliquer :
```bash
systemctl restart networking
```

---

## 2. Désactiver les raccourcis de mise en veille / arrêt
Évite qu’un raccourci clavier ne coupe le serveur de supervision.

```bash
systemctl mask ctrl-alt-del.target hibernate.target hybrid-sleep.target \
  sleep.target suspend-then-hibernate.target suspend.target
```

---

## 3. Désactiver la veille et la mise en veille prolongée via logind (optionnel)
Empêche le système de se mettre en veille automatiquement (bouton, lid, idle).

```bash
cp /etc/systemd/logind.conf /etc/systemd/logind.conf.bak
nano -lc /etc/systemd/logind.conf
```

Adapter :
```ini
[Login]
HandlePowerKey=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
```

Appliquer :
```bash
systemctl restart systemd-logind
```

---

## 4. Activer la synchronisation NTP
Garantit une heure système fiable pour les logs et alertes.

```bash
apt update
apt install systemd-timesyncd
systemctl enable systemd-timesyncd
systemctl start systemd-timesyncd
timedatectl set-ntp true
timedatectl status
```

---

## 5. Installer Nginx, PHP-FPM 8.4 et MariaDB
Fournit le serveur web, le moteur PHP et la base de données nécessaires à Zabbix.

```bash
apt update
apt install nginx php8.4-fpm mariadb-server mariadb-client-compat
```

Sécuriser MariaDB :
```bash
mariadb_secure_installation
```
(choix : root protégé, nouveau mot de passe root, suppression anonymes, suppression test DB, etc.)

Créer la base Zabbix :
```bash
mysql -u root -p
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by 'PasswordZabbixUser';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;
quit
```

---

## 6. Installer le dépôt Zabbix
Permet d’installer la version officielle et récente de Zabbix.

```bash
apt update
apt install wget

wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb
dpkg -i zabbix-release_latest_7.4+debian13_all.deb
apt update
```

---

## 7. Installer Zabbix serveur, frontend et agent
Installe les composants cœur de Zabbix (serveur, interface web, agent et scripts SQL).

```bash
apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2
apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql
```

Importer le schéma de base :
```bash
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | \
  mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
```

Désactiver ensuite l’option temporaire :
```bash
mysql -u root -p
set global log_bin_trust_function_creators = 0;
quit
```

---

## 8. Nettoyer l’historique des shells (opérationnel / sécurité)
Évite de laisser des mots de passe dans l’historique.

```bash
> ~/.mysql_history
> ~/.bash_history
history -c
history -w
unset HISTFILE
```

---

## 9. Configurer la base dans Zabbix server
Permet au service `zabbix-server` de se connecter à la base de données Zabbix.

```bash
nano -lc /etc/zabbix/zabbix_server.conf
```

Modifier :
```ini
DBPassword=PasswordZabbixUser
```
Même mot de passe que celui utilisé pour l'utilisateur Zabbix dans MariaDB

(Optionnel) sauvegarde :
```bash
cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bak
```

---

## 10. Démarrer Zabbix et activer l’autostart
Assure que Zabbix, Nginx et PHP démarrent et redémarrent automatiquement.

```bash
systemctl restart zabbix-server zabbix-agent2 nginx php8.4-fpm
systemctl enable zabbix-server zabbix-agent2 nginx php8.4-fpm
```

---

## 11. Configurer Nginx pour le frontend Zabbix
Fixe le port d’écoute et l’IP de l’interface web.

```bash
nano /etc/zabbix/nginx.conf
```

Décommenter / remplacer :
```nginx
listen 8080;
server_name 192.168.1.130;
```

Puis :
```bash
systemctl restart nginx
```

---

## 12. Accéder à l’interface Web
Permet de terminer l’installation via l’assistant graphique.

Ouvrir :
```text
http://IP_Server:8080
```

Suivre l’assistant : langue, prérequis, connexion DB (mot de passe DB Zabbix : `Str0ngP@ssword123!forZabbixUser`), fuseau horaire, résumé, installation.

Connexion initiale :
- Utilisateur : `Admin`
- Mot de passe : `zabbix`

---

## 13. Changer le mot de passe par défaut
Sécurise le compte administrateur Zabbix.

Dans l’interface :
- Menu utilisateur > **User settings**
- Onglet **Profile** > **Change password**
- Saisir ancien mot de passe, nouveau mot de passe, confirmer
- Cliquer sur **Update**