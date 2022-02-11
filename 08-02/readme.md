# README #

This playbook is designed to install and configure ElasticSearch and Kibana on a running docker container.

Any suggestions for improvements to this e-mail to [abeletskiy@ppr.ru](mailto:abeletskiy@ppr.ru).

## Usage

Before using this playbook, you should have a running docker container based on any supported Linux distribution and named `elk`. You may change the container name if necessary in `inventory/prod.yml`.

Choose a preferable java version and specify it in `java_jdk_version` variable in file `group_vars/all/vars.yml`. Then, download the corresponding binary from [https://www.oracle.com/java/technologies/downloads/](https://www.oracle.com/java/technologies/downloads/) and put it in the `files` directory.

You may also change desired ElasticSearch and Kibana versions in file `group_var/elasticsearch_kibana/vars.yml` by modifying variables `elastic_version` and `kibana_version`. You don't need to download them, it'll be done automatically during execution.

## Running the playbook

Run playbook against the inventory as usual:

```bash
ansible-playbook site.yml -i inventory/prod.yml
```

## Notes:

Both ElasticSearch and Kibana will be installed into /opt directory.

It's possible to have several versions to be installed. You need to modify the version string and replay the playbook. Keep in mind, though, that only the latest played versions will be accessed directly, to run any other you'll need to specify the full path to it.

To keep idempotency, the playbook leaves ElasticSearch and Kibana downloaded binary distributions in the temporary directory `/tmp`. If you don't need them, feel free to remove those files to free some disk space.