#!/bin/bash
# Install AlloyDB Omni
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
curl https://us-apt.pkg.dev/doc/repo-signing-key.gpg | sudo apt-key add -
sudo apt update
echo "deb https://us-apt.pkg.dev/projects/alloydb-omni alloydb-omni-apt main" \
| sudo tee -a /etc/apt/sources.list.d/artifact-registry.list
sudo apt update
mkdir /home/$USER/alloydb-data
sudo apt-get -y install alloydb-cli
sudo alloydb database-server install --data-dir=/home/$USER/alloydb-data
sudo alloydb database-server start


# Add pglogical to AlloyDB Omni
sudo sed -r -i "s|(shared_preload_libraries\s*=\s*)'(.*)'.*$|\1'\2,pglogical'|" /var/alloydb/config/postgresql.conf
grep -iE 'shared_preload_libraries' /var/alloydb/config/postgresql.conf
echo -e "# pglogical entries:
host all dbreplica samehost trust
" | column -t | sudo tee -a /var/alloydb/config/pg_hba.conf
echo -e "# all host accesss (remove after the test):
host all all all md5
" | column -t | sudo tee -a /var/alloydb/config/pg_hba.conf
sudo alloydb database-server stop
sudo alloydb database-server start

