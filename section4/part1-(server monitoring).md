# Zabbix Monitoring for EC2/VMs

Zabbix is an open-source monitoring solution that allows you to collect and visualize various metrics to ensure the health and performance of your EC2/on-premises instances.

## Installation and Configuration

1. **Install Zabbix Server:**   Set up a Zabbix server in your environment, either on-premises or in the cloud. this will be master server.

2. **Install Zabbix Agents:**   Install the Zabbix agent on each EC2 instance and on-premises server you want to monitor.

3. **Configure Zabbix Server and Agents:**

   - Configure the Zabbix server to communicate with the agents on your EC2 instances and on-premises servers.
   - Define what metrics and items you want to monitor on each EC2 instance / VMs using Zabbix templates.

## Monitoring Metrics

mostly used metrics in zabbix

- CPU Utilization
- Memory Usage
- Disk Space
- Network Utilization
- Load Average
- Process Monitoring (example - tomcat,rsyslog, audit.d etc service are running or not.)
- System Uptime
- Filesystem Usage
- Custom Application Metrics (example - application healthcheck)

## Setting Up Alerts

1. **Create Triggers:**

   Define triggers in Zabbix to detect specific conditions or threshold breaches for the monitored metrics.

2. **Configure Actions:**

   Configure actions in Zabbix to send alerts when triggers are fired. You can use email, SMS, or custom scripts for notifications.

## Creating Dashboards

- Build custom dashboards in Zabbix to visualize the collected metrics.
- Use Zabbix's graphing and visualization features to create custom views of your EC2 instances and VMs metrics.

## Fine-Tuning Monitoring

- Continuously review and fine-tune your monitoring setup to ensure it provides the necessary insights into the health and performance of your EC2 instances.
- Adjust trigger thresholds and update monitoring templates as needed.

## Scaling as Needed

- As your EC2 instances and on-premises servers fleet grows or changes, adapt your Zabbix monitoring configuration accordingly to accommodate new instances.

## ==================================================================================================

## installing zabbix server

**Step 1:**  Update the System

```bash
sudo yum update
```

**Step 2:**  Install Required Packages

```bash
sudo yum install httpd php mariadb-server mariadb-devel php-mysql php-gd php-xml php-bcmath php-mbstring php-zip
```

**Step 3:**   Create a Database for Zabbix

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
```

Log in to MySQL and create a database, a user, and grant privileges:

```bash
mysql -u root -p

CREATE DATABASE zabbixdb character set utf8 collate utf8_bin;
CREATE USER 'zabbixuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON zabbixdb.* TO 'zabbixuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Step 4:**   Install Zabbix Repository

```bash
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
sudo yum update
```

**Step 5:**   Install Zabbix Server and Frontend

```bash
sudo yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent
```

**Step 6:**  Import Zabbix Database Schema

```bash
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -u zabbixuser -p zabbixdb
```

**Step 7:**  Configure Zabbix Server

```bash
sudo nano /etc/zabbix/zabbix_server.conf
```

Update the following lines:

```bash
DBHost=localhost
DBName=zabbixdb
DBUser=zabbixuser
DBPassword=password
```

**Step 8:**  Configure PHP for Zabbix

```bash
sudo nano /etc/httpd/conf.d/zabbix.conf
```

Find the line containing php_value date.timezone and set the timezone:

```bash
php_value date.timezone Asia/Kolkata
```

**Step 9:**  Start Zabbix Server and Agent

```bash
sudo systemctl start zabbix-server zabbix-agent
sudo systemctl enable zabbix-server zabbix-agent
```

**Step 10:**  modify security group and NACL

- for port 10051 and 10050

## ====================================================================================================

## installing zabbix agent

```bash
rpm -ivh https://repo.zabbix.com/zabbix/6.2/rhel/7/x86_64/zabbix-agent-6.2.8-release1.el7.x86_64.rpm  ## or can download specific version
```

modify config file

```bash
vim /etc/zabbix/zabbix_agentd.conf

Server= IP of Zabbix Server, Example = 10.10.117.22
ServerActive= IP of Zabbix Server , Example = 10.10.117.22
ListenPort=10050 (Uncomment ListenPort Line) 
ListenIP= IP of Zabbix Client 
Hostname= IP of Zabbix Client 
```

- Start Zabbix Agent

```bash
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
```
