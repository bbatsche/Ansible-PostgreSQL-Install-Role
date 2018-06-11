Ansible PostgreSQL Role
===============================

[![Build Status](https://travis-ci.org/bbatsche/Ansible-PostgreSQL-Role.svg?branch=master)](https://travis-ci.org/bbatsche/Ansible-PostgreSQL-Role) [![Ansible Galaxy](https://img.shields.io/ansible/role/24010.svg)](https://galaxy.ansible.com/bbatsche/PostgreSQL)

This role will install, secure, and configure PostgreSQL server. It can be used to setup a new server, create a user/database, and/or grant privileges to a user.

Role Variables
--------------

- `db_admin` &mdash; Admin username to be created. Default "vagrant"
- `db_pass` &mdash; Password for admin user. Default "vagrant"
- `install_postgres` &mdash; Install PostgreSQL server. Default is no
- `postgres_version` &mdash; Version of PostgreSQL to install. Default is "9.6"
- `new_db_name` &mdash; Database to be created. Default is undefined (skipped)
- `new_db_user` &mdash; Username of new user to create. Default is undefined (skipped)
    - If `new_db_name` is not defined, then this user will be granted `SUPERUSER` privileges for the server
    - If `new_db_name` is defined, but `new_db_priv` is not, then this user will assigned ownership over `new_db_name`
    - If `new_db_name` and `new_db_priv` are both defined then this user will only be granted the specified privileges for objects in `new_db_name`
- `new_db_pass` &mdash; Password for new user to create. Default is undefined (skipped)
- `new_db_priv` &mdash; A dictionary of privileges to grant to `new_db_user`. Default is undefined (skipped)
    - `schema` &mdash; List of schema privileges to grant
    - `table` &mdash; List of table privileges to grant
    - `sequence` &mdash; List of sequence privileges to grant
- `new_db_schema` &mdash; Schema to use when setting object privileges. Default is "public"
- `timezone` &mdash; Server timezone to set. Default is "Etc/UTC"
- `postgres_enable_network` &mdash; Whether or not server should listen to external network connections. Default is no
- `postgres_ipv4_hba_host` &mdash; IPv4 address to allow connection from. If networking is disabled default is "127.0.0.1/32", otherwise default is "samenet"
- `postgres_ipv6_hba_host` &mdash; IPv6 address to allow connection from. If networking is disabled default is "::1/128", otherwise default is "samenet"
- `postgres_max_connections` &mdash; Maximum number of simultaneous network connections. Default is "100"
- `postgres_work_mem` &mdash; Amount of memory to be used for internal sort operations & hash tables. Default is "8MB"
- `postgres_maintenance_work_mem` &mdash; Maximum amount of memory to be used by maintenance operations. Default is "64MB"
- `postgres_synchronous_commit` &mdash; Force synchronous commits to prevent any potential data loss from a server crash. Default is "on"
- `postgres_checkpoint_timeout` &mdash; Maximum time between automatic WAL checkpoints. Default is "30min"
- `postgres_min_wal_size` &mdash; Minimum size for WAL file recycling. Default is "1GB"
- `postgres_max_wal_size` &mdash; Maximum size for WAL files to grow before an automatic checkpoint. Default is "2GB"
- `postgres_checkpoint_completion_target` &mdash; Target for checkpoint completion. Default is "0.8"

### Tuning Variables

- `postgres_shared_buffers_percent` &mdash; Percentage of system memory to use for PostgreSQL's shared buffers. Default is "15"
`postgres_shared_buffers` &mdash; Amount of memory to use for PostgreSQL's shared buffers. Default is calculated based on `postgres_shared_buffers_percent`
- `postgres_effective_cache_percent` &mdash; Percentage of system memory to use for effective cache size, used for estimating query costs. Default is "75"
- `postgres_effective_cache_size` &mdash; Total amount of memory to set for effective cache size. Default is calculated based on `postgres_effective_cache_percent`

Example Playbooks
----------------

Install the server and create a database:

```yml
- hosts: servers
  roles:
    - role: bbatsche.PotgreSQL
      install_postgres: yes
      new_db_name: my_database
      new_db_user: my_database_owner
      new_db_pass: n0tV3ry$ecuRe
```

Create a basic CRUD style user for the `my_database`:

```yml
- hosts: servers
  roles:
    - role: bbatsche.PotgreSQL
      new_db_name: my_database
      new_db_user: crud_user
      new_db_pass: n0tV3ry$ecuRe
      new_db_priv:
        table: [ "SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE" ]
        sequence: [ "USAGE" ]
```

License
-------

MIT

Testing
-------

Included with this role is a set of specs for testing each task individually or as a whole. To run these tests you will first need to have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed. The spec files are written using [Serverspec](http://serverspec.org/) so you will need Ruby and [Bundler](http://bundler.io/).

To run the full suite of specs:

```bash
$ gem install bundler
$ bundle install
$ rake
```

The spec suite will target Ubuntu Trusty Tahr (14.04), Xenial Xerus (16.04), and Bionic Bever (18.04).

To see the available rake tasks (and specs):

```bash
$ rake -T
```

These specs are **not** meant to test for idempotence. They are meant to check that the specified tasks perform their expected steps. Idempotency is tested independently via integration testing.
