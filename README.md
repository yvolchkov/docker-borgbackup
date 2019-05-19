# docker-borgbackup

This is a simple container serving borg-backup. Requires very little configuration. Supports multiple users.

# Install and configure

Clone the repo.
```bash
cd /opt
sudo git clone https://github.com/yvolchkov/docker-borgbackup.git
cd docker-borgbackup/
```

For configuration, create file `.env` in the root of the `docker-borgbackup` folder with the following contents:
```ini
USERS=foo:2000 bar:2001 baz:2002
HOST_DATA=/data
```

Where:
- `USERS` contains all the users you want to serve in format `USER_NAME:UID`. It is recommended to give every user a separate account. One user can have multiple repositories. For details see Borg's [documentation](https://borgbackup.readthedocs.io/en/stable/deployment/hosting-repositories.html). UID can be arbitrary. For example, you can grant one of the users the same UID number as your user on the host machine (typically 1000) so you will be able to `ls` data without `sudo` (not much of use though).
- `HOST_DATA` path to the storage folder on the host machine. User backups will be stored here. In the container, this will be mapped into `/data`, and each user will get a folder `/data/<user_name>`.

Now you need to create `authorized_keys` files for each of the users with proper ownership and permissions (sshd is quite picky). To simplify this step a script `configure.sh` is shipped with this repo. It parses your `.env` file and creates corresponding `authorized_keys` for you. You would have to fill them manually, (follow the Borg's documentation). 

So, run the configure:
```bash
sudo ./configure.sh
```

And then, for each user edit the `authorized_keys`:
```bash
nano conf/<user_name>/authorized_keys
```
and add one or more line like:

```
command="borg serve --restrict-to-repository /data/<user_name>/repository",restrict
<key type> <key> <key host>
```

Also for testing purposes, it is a good idea to add your key without restrictions (do not forget to remove it later!)

Permissions and ownership for `$HOST_DATA` subdirectories have to match to users as well, but it is a bit risky to delegate this task to a shady script (because this $HOST_DATA can potentially point anywhere in your system). However as the last step `/.configure.sh` provides you some guidance  in form of the actual commands lines you would need to copy paste (after a very thorough review; the author(s) of the script are not responsible for any potential data loss).

Now you are ready to go. Run your container:

```bash
cd /opt/docker-borgbackup
sudo docker-compose pull
sudo docker-compose up -d
```

The link for your borg account will be something like this:
```
ssh://foo@your_server_fqdn_or_ip:8265/data/foo/home_backup
```

# Update
Just run:
```bash
cd /opt/docker-borgbackup
sudo docker-compose pull
sudo docker-compose up -d --force-recreate
```

# Add another user
You need to edit your `.env` file acordingly. And run:
```bash
cd /opt/docker-borgbackup
sudo cp -ra conf conf_backup
sudo ./configure.sh
# create data folder for the new user (you can follow hints from the configure.sh)
sudo docker-compose up -d --force-recreate
```
Do not forget to edit `authorized_keys` as well.

# Add another key for existing user
Just edit `conf/<user_name>/authorized_keys`, and add corresponding key. Container will see it immidiatelly. No restarts needed.
