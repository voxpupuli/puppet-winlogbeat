# puppet-winlogbeat

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with winlogbeat](#setup)
    * [What winlogbeat affects](#what-winlogbeat-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with winlogbeat](#beginning-with-winlogbeat)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The `winlogbeat` module installs and configures the [winlogbeat log shipper](https://www.elastic.co/downloads/beats/winlogbeat) maintained by elastic.

## Setup

### What winlogbeat affects

By default `winlogbeat` downloads the software to your system, and installs winlogbeat along
with required configurations.

### Setup Requirements

The `winlogbeat` module depends on:
* [`puppetlabs/powershell`](https://forge.puppetlabs.com/puppetlabs/powershell)
* [`puppetlabs/stdlib`](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [`lwf/remote_file`](https://forge.puppet.com/lwf/remote_file)

### Beginning with winlogbeat

`winlogbeat` can be installed with `puppet module install puppet-winlogbeat` (or with r10k, librarian-puppet, etc.)

The only required parameter, other than which event logs to ship, is the `outputs` parameter.

## Usage

All of the default values in winlogbeat follow the upstream defaults (at the time of writing).

To ship files to [elasticsearch](https://www.elastic.co/guide/en/beats/winlogbeat/current/elasticsearch-output.html):
```puppet
class { 'winlogbeat':
  outputs => {
    'elasticsearch' => {
     'hosts' => [
       'http://localhost:9200',
       'http://anotherserver:9200'
     ],
     'index'       => 'winlogbeat',
     'cas'         => [
        '/etc/pki/root/ca.pem',
     ],
    },
  },
}
```

To ship files to [elasticsearch cloud](https://www.elastic.co/guide/en/beats/winlogbeat/current/configure-cloud-id.html):
```puppet
class { 'winlogbeat':
  # must be 6 or above to be recognized by winlogbeat
  major_version  => '7',
  package_ensure => '7.9.0',
  cloud          => {
    id   => 'YOUR_CLOUD_ID',
    auth => 'elastic:YOUR_CLOUD_AUTH'
  },
  outputs        => {
    'elasticsearch' => {
     #overridden by cloud.id and cloud.auth
     'hosts' => [
       'http://localhost:9200',
     ],
     'index'       => 'winlogbeat',
     'cas'         => [
        '/etc/pki/root/ca.pem',
     ],
    },
  },
}
```

To ship log files through [logstash](https://www.elastic.co/guide/en/beats/winlogbeat/current/logstash-output.html):
```puppet
class { 'winlogbeat':
  outputs => {
    'logstash'     => {
     'hosts' => [
       'localhost:5044',
       'anotherserver:5044'
     ],
     'index'       => 'winlogbeat',
     'loadbalance' => true,
    },
  },
}
```

[Shipper](https://www.elastic.co/guide/en/beats/winlogbeat/current/configuration-shipper.html) and [logging](https://www.elastic.co/guide/en/beats/winlogbeat/current/configuration-logging.html) options can be configured the same way, and are documented on the [elastic website](https://www.elastic.co/guide/en/beats/winlogbeat/current/index.html).

## Limitations

This module doesn't load the [elasticsearch index template](https://www.elastic.co/guide/en/beats/winlogbeat/current/winlogbeat-template.html) into elasticsearch (required when shipping
directly to elasticsearch).

## Development

Pull requests and bug reports are welcome. If you're sending a pull request, please consider
writing tests if applicable.

## Release Notes/Contributors/Etc.

Used the [pcfens/filebeat](https://forge.puppet.com/pcfens/filebeat) module as a starting point.
