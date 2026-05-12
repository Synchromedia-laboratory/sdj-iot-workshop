# Workshop IoT: MQTT, InfluxDB, Telegraf, and Grafana

[Back to main README](README.md)

In an IoT system, sensors generate measurements (temperature, humidity, pressure, etc.) that need to be transmitted, collected, stored, and visualized. In this workshop, we use four widely adopted tools to build this pipeline: MQTT, Telegraf, InfluxDB, and Grafana (IoT). 

A detailed description of each component can be found below in the README.


## Objectives

By the end, students can:

- Start a local IoT stack with Docker Compose or Podman Compose.
- Publish sensor-like data to an MQTT topic.
- Verify that the data is stored in InfluxDB.
- Build a basic Grafana dashboard.

##  The IoT Stack

### MQTT (Mosquitto) - IoT Data Transport

MQTT is a lightweight communication protocol widely used in IoT. It uses the publish/subscribe model:

- Sensors, or our Python simulator, publish messages to a topic, for example `sensors/temperature`.
- Other applications subscribe to that topic to receive the messages.
- Mosquitto is the MQTT broker: it is the server that receives messages and redistributes them to subscribers.

### InfluxDB - Time-series storage

IoT measurements arrive as data that changes over time: a value associated with a date and time. InfluxDB is a database optimized for this type of data, called time-series data.

In this workshop, InfluxDB is used to:

- Store measurements such as temperature, humidity, and pressure.
- Keep a history of values.
- Support queries such as averages, maximums, and trend analysis.

### Telegraf - data collection

Telegraf is a data collection agent often used with InfluxDB. Its role is to automatically collect measurements from different sources, such as sensors, services, log files, CPU/RAM system metrics, or MQTT messages, and send them to InfluxDB in the right format.

It simplifies integration, standardizes data, and makes it easy to add new sources without changing the whole application.

### Grafana - Visualization And Dashboards

Grafana is a visualization tool used to create dashboards with real-time charts, historical curves, and alerts, for example when the temperature goes above `30 °C`.

## Architecture

This workshop follows the complete monitoring flow:

1. Sensors produce measurements.
2. MQTT transports the sensor values.
3. Telegraf reads the MQTT messages.
4. InfluxDB stores the measurements.
5. Grafana visualizes the data in dashboards.

```text
Sensor or terminal
      |
      v
MQTT broker: topics temp, humidity, pressure
      |
      v
Telegraf mqtt_consumer
      |
      v
InfluxDB database: iot
      |
      v
Grafana dashboard
```

![IoT stack architecture](docs/images/architecture.jpeg)

### Component Roles

- MQTT: receives sensor messages on topics such as `temp`, `humidity`, and `pressure`.
- Telegraf: subscribes to MQTT topics and forwards numeric values to InfluxDB.
- InfluxDB: stores the sensor values as time-series data.
- Grafana: queries InfluxDB and displays dashboards.
- Node-RED: optional flow-based tool for extending the workshop with visual IoT workflows.

## Files

- `docker-compose.yml`: starts Mosquitto, InfluxDB, Telegraf, and Grafana.
- `config/mosquitto/mosquitto.conf`: allows local anonymous MQTT connections for the atelier.
- `config/telegraf/telegraf.conf`: subscribes to MQTT topics `temp`, `humidity`, and `pressure`, then writes values to InfluxDB.
- `grafana/dashboards/iot-dashboard.json`: ready-made dashboard that students can import into Grafana.
- `docs/images/`: stores README figures and screenshots.
- `scripts/setup.sh`: starts the stack.
- `archive/`: keeps earlier temperature-only examples.

## Prerequisites

Install one container runtime:

- Docker Desktop with Docker Compose, or
- Podman Desktop with Podman Compose.

Useful installation links:

- Docker Desktop: <https://docs.docker.com/desktop/>
- Docker Compose: <https://docs.docker.com/compose/install/>
- Podman Desktop: <https://podman.io/docs/installation>
- Podman Compose: <https://podman-desktop.io/docs/compose/setting-up-compose>
- Optional, Visual Studio Code: <https://code.visualstudio.com/download>

### Docker Option

Install Docker Desktop, then check:

```bash
docker compose version
```


### Podman Option

Install Podman and Podman Compose. On macOS, you can also use Homebrew:

```bash
brew install podman podman-compose
```

Start the Podman virtual machine:

```bash
podman machine init
podman machine start
```

If the machine already exists, run only:

```bash
podman machine start
```

Check Podman:

```bash
podman info
podman-compose --version
```

### MQTT Client Tools

Install MQTT client tools for the test commands:

```bash
# macOS
brew install mosquitto

# Ubuntu/Debian
sudo apt update
sudo apt install mosquitto-clients
```

If you do not want to install `mosquitto_pub` locally, you can use the Mosquitto container shown in Step 2.

## Step 1: Start The Stack

From this folder:

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Check that the containers are running:

```bash
docker compose ps
```

If you use Podman Compose:

```bash
podman-compose ps
```

Expected services:

- `mqtt`
- `influxdb`
- `telegraf`
- `grafana`

If you use Podman, Telegraf should show as running. If it is stopped, check the troubleshooting section for the `setpriv` fix.

If the stack was already running before changing `config/telegraf/telegraf.conf`, recreate Telegraf so it loads the new topics:

```bash
podman-compose up -d --force-recreate telegraf
```

## Step 2: Publish MQTT Data

Option A: send one temperature value with a local MQTT client:

```bash
mosquitto_pub -h localhost -p 1883 -t temp -m "25"
```

Send several values:

```bash
mosquitto_pub -h localhost -p 1883 -t temp -m "22.5"
mosquitto_pub -h localhost -p 1883 -t humidity -m "58"
mosquitto_pub -h localhost -p 1883 -t pressure -m "1013"
```

Option B: send one value from a temporary Podman container:

```bash
podman run --rm --network sdj-iot-workshop_default docker.io/eclipse-mosquitto:2 mosquitto_pub -h mqtt -p 1883 -t temp -m "25"
```

Option C: send one value from inside the running MQTT container:

```bash
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t temp -m "25"
```

Send all three sensor values from inside the running MQTT container:

```bash
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t temp -m "25"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t humidity -m "58"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t pressure -m "1013"
```

Option D: send one value from a temporary Docker container:

```bash
docker run --rm --network sdj-iot-workshop_default eclipse-mosquitto:2 mosquitto_pub -h mqtt -p 1883 -t temp -m "25"
```

Optional: subscribe in another terminal to observe messages with a local MQTT client:

```bash
mosquitto_sub -h localhost -p 1883 -t temp
```

Or subscribe with Podman:

```bash
podman run --rm --network sdj-iot-workshop_default docker.io/eclipse-mosquitto:2 mosquitto_sub -h mqtt -p 1883 -t temp
```

After publishing a value, Telegraf should write it to InfluxDB within a few seconds.

## Step 3: Verify InfluxDB

Open the InfluxDB shell:

```bash
docker exec -it influxdb influx
```

If you use Podman:

```bash
podman exec -it influxdb influx
```

Run:

```sql
USE iot
SHOW MEASUREMENTS
SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 5
```

You should see the values published to the MQTT topics `temp`, `humidity`, and `pressure`.

Exit the shell:

```sql
exit
```

You can also run the check in one command:

```bash
podman exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'
```

## Step 4: Configure Grafana

Open Grafana:

```text
http://localhost:3000
```

Login:

```text
Username: admin
Password: admin
```

Grafana may ask you to change the password. For a classroom workshop, you can skip it.

Add an InfluxDB data source:

1. In the left menu, open `Connections`.
2. Click `Data sources`.
3. Click `Add new data source`.
4. Select `InfluxDB`.
5. Fill the fields below.

- Type: `InfluxDB`
- Query language: `InfluxQL`
- URL: `http://influxdb:8086`
- Database: `iot`
- User: leave empty
- Password: leave empty

Click `Save & test`.

Important: use `http://influxdb:8086` only inside Grafana. Grafana runs in the same container network as InfluxDB, so it can reach the service name `influxdb`. From your browser or terminal on the host machine, use `localhost:8086` instead.

To test InfluxDB from your terminal:

```bash
curl -i http://localhost:8086/ping
```

A working InfluxDB usually returns:

```text
HTTP/1.1 204 No Content
```

## Step 5: Import The Ready Dashboard

Grafana can import the dashboard from `grafana/dashboards/iot-dashboard.json`.

In Grafana:

1. Open `Dashboards`.
2. Click `New`.
3. Click `Import`.
4. Upload `grafana/dashboards/iot-dashboard.json`.
5. Select the InfluxDB data source created in Step 4.
6. Click `Import`.

The imported dashboard contains:

- Sensor values over time.
- Current temperature.
- Current humidity.
- Current pressure.

Publish new MQTT values and refresh the dashboard.

## Optional: Create A Dashboard Manually

Create a new dashboard and add a panel.

Use this InfluxQL query:

```sql
SELECT mean("value") FROM "mqtt_consumer" WHERE $timeFilter GROUP BY time($__interval) fill(null)
```

Suggested panel settings:

- Visualization: `Time series`
- Title: `Sensor Values`

Publish new MQTT values and refresh the dashboard.

## Step 6: Stop The Stack

```bash
docker compose down
```

If you use Podman Compose:

```bash
podman-compose down
```

To remove stored data as well:

```bash
docker compose down -v
```

## Troubleshooting

If Grafana does not show data:

### 1. Check That Containers Are Running

With Docker Compose:

```bash
docker compose ps
```

With Podman Compose:

```bash
podman-compose ps
```

Expected services:

- `mqtt`
- `influxdb`
- `telegraf`
- `grafana`

If `telegraf` is stopped, check its logs:

```bash
podman logs telegraf
```

### 2. Confirm That MQTT Messages Reach The Sensor Topics

Open one terminal and subscribe to all MQTT topics:

```bash
podman exec -it mqtt mosquitto_sub -h localhost -p 1883 -t '#' -v
```

Open another terminal and publish values:

```bash
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t temp -m "25"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t humidity -m "58"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t pressure -m "1013"
```

Expected output in the subscriber terminal:

```text
temp 25
humidity 58
pressure 1013
```

If you see these messages, MQTT is working.

### 3. Confirm That Values Are Valid Numbers

Telegraf is configured with:

```toml
data_format = "value"
data_type = "float"
```

This means the MQTT payload must be only a number.

Good payloads:

```text
25
22.5
30.1
```

Bad payloads:

```text
temperature=25
{"temperature":25}
25 C
```

Publish a valid test value:

```bash
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t temp -m "25.5"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t humidity -m "58"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t pressure -m "1013"
```

### 4. Confirm That InfluxDB Has Data

```bash
podman exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'
```

Expected output contains rows with a `value` column:

```text
name: mqtt_consumer
time                topic value
----                ----- -----
...                 temp  25.5
...                 humidity 58
...                 pressure 1013
```

If there is no data, restart Telegraf and publish again:

```bash
podman restart telegraf
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t temp -m "26"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t humidity -m "60"
podman exec mqtt mosquitto_pub -h localhost -p 1883 -t pressure -m "1012"
```

Then check InfluxDB again:

```bash
podman exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'
```

### 5. Check Telegraf Logs

With Docker:

```bash
docker logs telegraf
```

With Podman:

```bash
podman logs telegraf
```

If Telegraf logs show this Podman error:

```text
setpriv: failed to execute telegraf: Operation not permitted
```

Make sure the `telegraf` service in `docker-compose.yml` contains:

```yaml
user: telegraf
```

Then recreate Telegraf:

```bash
podman-compose up -d --force-recreate telegraf
```

### 6. Confirm Grafana Data Source Settings

In Grafana, open:

```text
Connections > Data sources > InfluxDB
```

Confirm these values:

- Query language: `InfluxQL`
- URL: `http://influxdb:8086`
- Database: `iot`
- User: empty
- Password: empty

Click `Save & test`.

Important: `http://influxdb:8086` is only for Grafana. Do not open that URL in your browser.

### 7. Test The Query In Grafana Explore

Open:

```text
Explore
```

Select the InfluxDB data source and run:

```sql
SELECT * FROM "mqtt_consumer" WHERE $timeFilter
```

If Explore shows data but the dashboard does not, re-import `grafana/dashboards/iot-dashboard.json` and select the correct InfluxDB data source during import.

### 8. Check Port Conflicts

If ports are already used, stop the conflicting service or change these ports in `docker-compose.yml`:

- MQTT: `1883`
- InfluxDB: `8086`
- Grafana: `3000`

Check exposed services from the host:

```bash
curl -i http://localhost:8086/ping
```

Expected InfluxDB response:

```text
HTTP/1.1 204 No Content
```

If `scripts/setup.sh` fails, run:

```bash
docker compose up -d
```

or:

```bash
podman-compose up -d
```
