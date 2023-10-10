# continuous logging and monitoring

I will setup and installation for collecting logs with Fluent Bit, aggregating them with Loki, and then visualizing them with Grafana.

## Flow-diagram

![logging-siva drawio](https://gitlab.com/my_task1/maltem-asia/-/blob/0821c4ea42e70683c4e48a71952f54c573a8b184/section4/logging-siva.drawio.png)

## Installation and Configuration

1. **Fluent Bit (td-agent-bit):**  This is a lightweight and extensible log processor and forwarder, suitable for both on-premises and cloud environments. Fluent Bit will collect and send the logs to Loki. and this agent will be installed on all servers from which logs are required.

installation--

```bash
sudo rpm -i https://packages.fluentbit.io/centos/7/td-agent-bit-1.8.3.x86_64.rpm
```

modify file `/etc/td-agent-bit/td-agent-bit.conf` as below

```bash
[SERVICE]
    Flush   2
    Log_Level   info
    storage.path              /var/log/flb-storage/
    storage.sync              normal
    storage.checksum          off
    Log_File    /var/log/fluentbit.log
    storage.backlog.mem_limit 25M
    parsers_file parsers.conf


[INPUT]
    Name                tail
    Path                /opt/tomcat8/logs/catalina.out,/opt/tomcat8/logs/application.info.log
    Tag                 myapp-applog
    DB                  /var/log/flb_service.db
    DB.locking          true
    Path_Key            applicationinfo
    Skip_Long_Lines     On
    Refresh_Interval    10
    Rotate_Wait         30
    storage.type  	    filesystem
    multiline.parser    java,multiline-regex-test


[FILTER]
    Name record_modifier
    Match *
    Record hostname ${HOSTNAME}


[OUTPUT]
    name                   loki
    match                  *
    host                   <LOKI_HOST>
    port                   <LOKI_PORT> (3100)
    labels                 job=myapp-applog
    storage.total_limit_size  50M
```

Start Fluent Bit:

```bash
sudo systemctl start td-agent-bit
```

2.**Loki:**  A horizontally-scalable, highly-available log aggregation system inspired by Prometheus. It doesn’t index the content of logs but rather a set of labels. This design makes it cost-effective and ensures high performance.

Download the latest release of Loki or specific version:

```bash
wget https://github.com/grafana/loki/releases/download/v2.4.0/loki-linux-amd64.zip
unzip loki-linux-amd64.zip
```

create a file `loki-local-config.yaml` add below data

```bash
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 0.0.0.0
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_target_size: 1048576  # Loki will attempt to build chunks up to 1.5MB, flushing first if chunk_idle_period or max_chunk_age is reached first
  chunk_retain_period: 30s
  max_transfer_retries: 0


schema_config:
  configs:
  - from: 2020-05-15
    store: boltdb-shipper
    object_store: s3
    schema: v11
    index:
      prefix: index_
      period: 24h

# storage_config:
#   boltdb_shipper:
#    active_index_directory: /loki/index
#    cache_location: /loki/index_cache  ## this block is required when are archiving log to s3
#    shared_store: s3
#   aws:
#     s3: s3://ap-south-1/loki-live-logs
#     s3forcepathstyle: true

# compactor:
#   working_directory: /loki/boltdb-shipper-compactor
#   shared_store: s3

chunk_store_config:
  max_look_back_period: 160h

limits_config:
        #enforce_metric_name: false
  ingestion_rate_mb: 8
  ingestion_burst_size_mb: 12
```

then start loki

```bash
./loki-linux-amd64 -config.file=loki-local-config.yaml
```


3.**Grafana:** An open-source platform for monitoring and observability. With the Loki data source, Grafana can fetch logs and visualize them.

Download the latest release of grafana or specific version:

```bash
sudo yum install https://dl.grafana.com/oss/release/grafana-8.3.1-1.x86_64.rpm
```

Start Grafana:

```bash
sudo systemctl start grafana-server
```

port for grafana is 3000
for loki is 3100


**for nodejs application can be used below graphana dahsboard** (ID: 11159)

![image](https://gitlab.com/my_task1/maltem-asia/-/blob/0821c4ea42e70683c4e48a71952f54c573a8b184/section4/logging-siva.drawio.png)


**for tomcat based app** (ID: 11122)

![image](https://gitlab.com/my_task1/maltem-asia/-/blob/0821c4ea42e70683c4e48a71952f54c573a8b184/section4/logging-siva.drawio.png)

these above dashboard works with promethous log source.
