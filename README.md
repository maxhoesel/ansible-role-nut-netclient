# maxhoesel.nut_netclient

![Release](https://img.shields.io/github/v/release/maxhoesel/ansible-role-nut-netclient)
![CI Status](https://img.shields.io/github/workflow/status/maxhoesel/ansible-role-nut-netclient/CI)
![License](https://img.shields.io/github/license/maxhoesel/ansible-role-nut-netclient)

Install NUT and upsmon on a target system and configure it to follow a remote UPS over the network using the netclient mode

## Requirements

- A host running one of the following distributions
  - Ubuntu 18.04 LTS or newer
  - Debian 9 or newer
- Become privileges on the host

## Role Variables

NOTE: See [here](https://networkupstools.org/docs/man/upsmon.conf.html) for more information about upsmon.conf values and their purpose

##### `nut_netclient_monitors`
- List of UPS systems to monitor
- Must be a list of monitor entries, with each entry being a dict containing the following values:
    - `system`: The system to monitor. Format: `<upsname>[@<hostname>[:<port>]]`
    - `powervalue`: Number of power supplies that this system feeds to the host. Usually 1
    - `username`: Name of the remote monitor user
    - `password`: Password of the remote monitor user
    - `type`: Type of UPS relationship, either `master` or `slave`
- Example:
  ```yaml
  nut_netclient_monitors:
      - system: "myups@remotehost.localdomain"
        powervalue: 1
        username: monitor
        password: a-secure-password
        type: slave
      - system: "otherups@otherhost.localdomain"
        powervalue: 1
        username: monitor
        password: a-different-password
        type: slave
  ```
- Required: yes
- Default: `undefined`

##### `nut_netclient_notifymsg_<type>`
- Set a custom notification message for a given message type
- Valid types can be found in the [upsmon manual](https://networkupstools.org/docs/man/upsmon.conf.html) (section NOTIFYMSG)
- Example:
  ```yaml
  nut_netclient_notifymsg_online: UPS %s is back online
  nut_netclient_notifymsg_lowbatt: UPS %s is now on low battery
  ```

##### `nut_netclient_notifyflag_<type>`
- Set notification flags for individual event types
- Valid types and flags can be found in the [upsmon manual](https://networkupstools.org/docs/man/upsmon.conf.html)
- Example:
  ```yaml
  nut_netclient_notifyflag_online: SYSLOG
  nut_netclient_notifymsg_lowbatt: SYSLOG+WALL+EXEC
  ```

Prefix for all variables below: `nut_netclient_`

| Name | Summary | Required | Default |
|------|---------|----------|---------|
| `deadtime` | Time before the UPS is declared "dead" in seconds | | 15 |
| `finaldelay` | Time between the final shutdown warning and command in s | | 5 |
| `hostsync` | Timeout between master and slaves in shutdown situations in s | | 15 |
| `minsupplies` | Minimum amount of supplies needed to keep running | | 1 |
| `nocommwarntime` | Interval between communication error warnings in s | | 300 |
| `notifycmd` | Call this command to send messages | | `undefined` |
| `pollfreq` | Time between UPS polls in s | | 5 |
| `pollfreqalert` | Time between UPS polls when on battery power in s | | 5 |
| `powerdownflag` | Flag file that upsmon creates during shutoff | | `/etc/killpower` |
| `rbwarntime` | Interval in which to send battery replacement messages in s | | 43200 |
| `run_as_user` | Run the monitor as a different user | | `undefined` |
| `shutdowncmd` | Command to run when shutting down the system. Most be quoted if it contains spaces | | `"/sbin/shutdown -h +0"` |
| `certpath` | Path to a cert file or DB | | `undefined` |
| `certident` | Cert identify to retrieve (if using NSS) | | `undefined` |
| `certhost` | Host directives (if using NSS) | | `undefined` |
| `certverify` | Whether to validate SSL certificates. Must be either 0 or 1 | | `undefined` |
| `forcessl` | Whether to force SSL connections. Must be either 0 or 1 | | `undefined` |

## Example Playbook

```yaml
- hosts: all
  become: yes
  tasks:
    - name: Run nut_netclient
      include_role:
        name: maxhoesel.nut_netclient
      vars:
        nut_netclient_monitors:
          - system: "myups@remotehost.localdomain"
            powervalue: 1
            username: monitor
            password: a-secure-password
            type: slave
```


## Testing

This role uses tox and molecule for testing. You will need the following installed on your system:

- python3-tox
- Docker

Then, simply run `test.sh` in the root directory of this role. You can view and run individual tests with `tox -l`
