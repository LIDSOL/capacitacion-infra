# Documentation

## How to execute my playbook

To execute the playbook you only need to run:

```
ansible-playbook -i inventory.ini main.yaml -u debian
```
If it's the first time you connect to the hosts, I recommend you first connect to each host with SSH so you can accept the connection and prevent SSH from showing warnings.

## Jerarchy

My project is structured in the following way:

```
main.yaml
nft.yaml
sshconfig.yaml
webserver.yaml
autoupdate.yaml
inventory.ini
_template/
  index.html
```

### Functionality of each .yaml

- `main.yaml` is the playbook that manages all the requirements for this task. It accomplishes two things: preparing the conditions (permissions, defining hosts, adding source packages) and organizing the tasks.
- `autoupdate.yaml` is in charge of automatic updates.
- `sshconfig.yaml` configures SSH.
- `webserver.yaml` starts a web server for each host.
- `nft.yaml` sets up nftables.

### Function of other files

- `inventory.ini` defines the hosts and the variable id for each VM.
- `_template/index.html` is the Jinja2 template.

## Important Details

For most of the packages needed in this task they were missing in the
debian's source repositories, at least in the debian's version that we downloaded. So I needed to add some other sources and that's why in main I added the task for adding those sources and the update the package manager.

For the configuration for services I used the configuration files from previous activities and I add them to the virtual machines, so instead of editing the remote files I just replace them with mine. All those files are stored in a conf.d directory, I didn't add that directory to the final commit.