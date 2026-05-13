# Workshop IoT: Design your first IoT platform

[Back to main README](README.md)

**Workshop 1 - Design Your First IoT Platform**

## Workshop overview

In an IoT system, sensors generate measurements (temperature, humidity, distance, etc.) that need to be transmitted, collected, stored, and visualized. In this workshop, we use four widely adopted tools to build this pipeline: MQTT, Telegraf, InfluxDB, and Grafana (IoT). 

A detailed description of each component can be found below in the README (**The IoT Stack Section**).

## Objectives

By the end, students can:

- Explain the role of MQTT, Telegraf, InfluxDB, and Grafana in an IoT data pipeline.
- Start a local containerized IoT stack with Podman Compose or Docker Compose.
- Publish simulated temperature, humidity, distance, and object detection data to MQTT topics.
- Verify that MQTT data is collected by Telegraf and stored in InfluxDB.
- Visualize live and historical sensor data in Grafana.
- Understand how the simulated setup can be extended to real sensors using a Raspberry Pi.

## Workshop flow

The workshop is structured in two phases.

**Phase 1 - Simulation** focuses on building the full IoT architecture using containerized services on a local environment.

This phase allows participants to validate the end-to-end data pipeline with simulated sensor data.

**Phase 2 - Real Deployment** extends this setup by integrating a Raspberry Pi with real sensors and a locally hosted MQTT broker.

This phase enables real-time data acquisition and visualization in Grafana.

During Phase 2, students switch Telegraf to the real-sensor configuration so it collects MQTT data published by the Raspberry Pi.

![Workshop phases: simulation and real deployment](docs/images/workshop-phases.png)

1. Briefly introduce the IoT architecture and the roles of MQTT, Telegraf, InfluxDB, and Grafana.
2. Install or verify the environment with Podman Compose or Docker Compose.
3. Clone or download the public workshop repository.
4. Start the local stack with `compose.yaml`.
5. Publish simulated data with the `mqtt-client` container.
6. Verify that the data is stored in InfluxDB.
7. Configure Grafana and import the dashboard.
8. Run the optional Raspberry Pi and real-sensor demo if time allows.

## The IoT stack

### MQTT (Mosquitto) - IoT data transport

MQTT (Message Queuing Telemetry Transport) is a lightweight messaging protocol designed for low-bandwidth, high-latency, or unreliable networks. It is widely used in IoT systems.

MQTT works with a publish/subscribe model instead of direct communication:

- Publisher: sends messages.
- Subscriber: receives messages.
- Broker: central server that routes messages.

How it works:

1. Devices connect to an MQTT broker.
2. A device publishes data to a topic, for example `home/temperature`.
3. Other devices or applications subscribe to that topic.
4. The broker forwards messages to all subscribers.

In this workshop, sensors or the MQTT client publish messages to topics such as `temp`, `humidity`, `distance`, and `object`. Mosquitto is the MQTT broker.

### InfluxDB - Time-series storage

IoT measurements arrive as data that changes over time: a value associated with a date and time. InfluxDB is a database optimized for this type of data, called time-series data.

In this workshop, InfluxDB is used to:

- Store measurements such as temperature, humidity, distance, and object detection.
- Keep a history of values.
- Support queries such as averages, maximums, and trend analysis.

### Telegraf - data collection

Telegraf is a data collection agent often used with InfluxDB. Its role is to automatically collect measurements from different sources, such as sensors, services, log files, CPU/RAM system metrics, or MQTT messages, and send them to InfluxDB in the right format.

It simplifies integration, standardizes data, and makes it easy to add new sources without changing the whole application.

### Grafana - visualization and dashboards

Grafana is a visualization tool used to create dashboards with real-time charts, historical curves, and alerts, for example when the temperature goes above `30 °C`.

## Architecture

This workshop follows the complete monitoring flow:

1. Sensors produce measurements.
2. MQTT transports the sensor values.
3. Telegraf reads the MQTT messages.
4. InfluxDB stores the measurements.
5. Grafana visualizes the data in dashboards.

### Simplified architecture

![Simplified IoT stack architecture](docs/images/simplified-architecture.png)

### Detailed architecture

![Detailed IoT stack architecture](docs/images/detailed-architecture.png)

### Component roles

- MQTT: receives sensor messages on topics such as `temp`, `humidity`, `distance`, and `object`.
- MQTT client: provides `mosquitto_pub` and `mosquitto_sub` inside the Compose stack, so students do not need to install MQTT tools locally.
- Telegraf: subscribes to MQTT topics and forwards numeric values to InfluxDB.
- InfluxDB: stores the sensor values as time-series data.
- Grafana: queries InfluxDB and displays dashboards.
- Node-RED: optional flow-based tool for extending the workshop with visual IoT workflows.

## Files

- `compose.yaml`: starts Mosquitto, the MQTT client helper, InfluxDB, Telegraf, and Grafana.
- `config/mosquitto/mosquitto.conf`: allows local anonymous MQTT connections for the atelier.
- `config/telegraf/telegraf.conf`: subscribes to MQTT topics `temp`, `humidity`, `distance`, and `object`, then writes values to InfluxDB.
- `config/telegraf/telegraf-real-sensors.conf`: Phase 2 Telegraf configuration for MQTT data published by the Raspberry Pi.
- `grafana/dashboards/iot-dashboard.json`: ready-made dashboard that students can import into Grafana.
- `docs/images/`: stores README figures and screenshots.
- `scripts/setup.sh`: starts the stack.
- `scripts/publish-sensor-data.sh`: publishes repeated MQTT values for `temp`, `humidity`, `distance`, and `object` from inside the `mqtt-client` container.
- `archive/`: keeps earlier temperature-only examples.

## Prerequisites

Choose one container runtime before starting the workshop:

- Podman Desktop with Podman Compose, or
- Docker Desktop with Docker Compose.

Installation references:

- Podman Desktop: <https://podman.io/docs/installation>
- Podman Compose setup: <https://podman-desktop.io/docs/compose/setting-up-compose>
- Docker Desktop: <https://docs.docker.com/desktop/>
- Docker Compose: <https://docs.docker.com/compose/install/>

Optional tool:

- Visual Studio Code: <https://code.visualstudio.com/download>

## Docker and Podman comparison

This workshop can run with either Podman Compose or Docker Compose.

You only need one of them. The commands are slightly different, but both options use the same `compose.yaml` file and start the same IoT services.

![Docker and Podman comparison for the IoT workshop](docs/images/docker-podman-comparison.svg)

| Topic | Podman | Docker |
| --- | --- | --- |
| Desktop application | Podman Desktop | Docker Desktop |
| Compose command | `podman-compose` | `docker compose` |
| Start command | `podman-compose up -d` | `docker compose up -d` |
| Container engine style | Rootless-first by design | Docker daemon-based |
| Best choice for this workshop | Recommended if you are starting fresh | Use it if Docker is already installed |

The workshop instructions show Podman first, then Docker. Pick one option and keep the same command style for the rest of the workshop.

### Why Podman is recommended

Podman is recommended for this workshop because it is a better fit for shared academic and enterprise environments:

- Rootless by default: containers run as your user, without a root daemon.
- Better fit for shared multi-user machines.
- Lower operational risk in academic and enterprise environments because containers do not require a root daemon.
- Docker may be restricted or forbidden by policy in some universities and companies.

Podman keeps a Docker-like workflow, including `run`, `build`, Dockerfiles, and Docker Hub images, while matching shared-server security requirements.

### Option A: Run the IoT stack with Podman

Use this option if you want to run the workshop with Podman.

Installation links:

- Podman Desktop: <https://podman.io/docs/installation>
- Podman Compose setup: <https://podman-desktop.io/docs/compose/setting-up-compose>

#### macOS installation

If you use Podman Desktop, install Podman Desktop for macOS, then verify that Podman Compose is available.

If you prefer command-line installation, use Homebrew:

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

#### Windows

1. Install Podman Desktop for Windows.
2. Follow the Podman Desktop Compose setup guide linked above.
3. Open PowerShell, Windows Terminal, or the VS Code terminal.
4. Run the same Podman commands shown in this workshop.

Check Podman from PowerShell:

```powershell
podman info
podman-compose --version
```

#### Linux

Install Podman and Podman Compose with your distribution package manager.

Example on Ubuntu:

```bash
sudo apt update
sudo apt install -y podman podman-compose
```

Check Podman on Linux:

```bash
podman info
podman-compose --version
```

### Option B: Run the IoT stack with Docker

Use this option if you want to run the workshop with Docker.

Installation links:

- Docker Desktop: <https://docs.docker.com/desktop/>
- Docker Compose: <https://docs.docker.com/compose/install/>

If you installed Docker Desktop, Docker Compose is usually already included. You do not need to install Docker Compose separately; go directly to the Docker version checks.

#### macOS

Install Docker Desktop for Mac, start it, then run the version checks below.

Check Docker on macOS:

```bash
docker compose version
docker version
```

#### Windows

1. Install Docker Desktop for Windows.
2. Use the WSL 2 backend when Docker Desktop asks for the engine.
3. Open PowerShell, Windows Terminal, or the VS Code terminal.
4. Run the same Docker Compose commands shown in this workshop.

Check Docker from PowerShell:

```powershell
docker compose version
docker version
```

#### Linux

Install Docker Engine and the Docker Compose plugin with your distribution package manager. Make sure your user can run Docker commands, or use `sudo` if required by your installation.

Example on Ubuntu:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
```

Check Docker on Linux:

```bash
docker compose version
docker version
```

### MQTT client tools

No local MQTT client installation is required. The Compose stack includes an `mqtt-client` container based on the Mosquitto image, so `mosquitto_pub` and `mosquitto_sub` are available through Podman Compose or Docker Compose on macOS, Windows, and Linux.

## Step 1: Get the repository

This repository is public. Clone it with Git, or download it as a ZIP from GitHub.

Option 1: clone with Git:

```bash
git clone https://github.com/Synchromedia-laboratory/sdj-iot-workshop.git
cd sdj-iot-workshop
```

Option 2: download the ZIP:

1. Open <https://github.com/Synchromedia-laboratory/sdj-iot-workshop>.
2. Click `Code`.
3. Click `Download ZIP`.
4. Extract the ZIP file.
5. Open a terminal in the extracted `sdj-iot-workshop` folder.

Make sure to run all Compose commands from the folder that contains `compose.yaml`.

## Option A: Podman Compose

### Step 2: Start the stack

From this folder:

```bash
podman-compose up -d
```

Check that the containers are running:

```bash
podman-compose ps
```

Expected services:

- `mqtt-broker`
- `mqtt-client`
- `influxdb`
- `telegraf`
- `grafana`

The terminal output should show the five running containers:

![Podman Compose terminal output with running containers](docs/images/podman-start-stack-terminal.png)

You can also confirm the same containers in Podman Desktop:

![Podman Desktop showing the workshop containers running](docs/images/podman-desktop-containers-running.png)

If you use Podman, Telegraf should show as running. If it is stopped, check the troubleshooting section for the `setpriv` fix.

If the stack was already running before changing `config/telegraf/telegraf.conf`, recreate Telegraf so it loads the new topics:

```bash
podman-compose up -d --force-recreate telegraf
```

### Step 3: Publish MQTT data

Method 1: publish values manually.

Send one temperature value with the MQTT client container:

```bash
podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "25"
```

Send several values:

```bash
podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "22.5"
podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t humidity -m "58"
podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t distance -m "45"
podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t object -m "1"
```

After publishing the four values manually, the dashboard should receive the new points:

![Manual MQTT publishing with Podman Compose](docs/images/publish-mqtt-method-1-manual.png)

Method 2: run the script inside the `mqtt-client` container.

The script publishes 10 rounds of values for the four sensor topics: `temp`, `humidity`, `distance`, and `object`.

```bash
podman-compose exec mqtt-client sh /usr/local/bin/publish-sensor-data
```

To choose another number of rounds, pass the number at the end:

```bash
podman-compose exec mqtt-client sh /usr/local/bin/publish-sensor-data 20
```

The script publishes repeated values and the dashboard updates as data arrives:

![MQTT publishing script with Podman Compose](docs/images/publish-mqtt-method-2-script.png)

You can also run the script from the `mqtt-client` terminal in Podman Desktop:

![Podman Desktop mqtt-client terminal running the publishing script](docs/images/podman-desktop-mqtt-client-script.png)

Optional: subscribe in another terminal to observe messages:

```bash
podman-compose exec mqtt-client mosquitto_sub -h mqtt-broker -p 1883 -t temp
```

After publishing a value, Telegraf should write it to InfluxDB within a few seconds.

### Step 4: Verify InfluxDB

Open the InfluxDB shell:

```bash
podman-compose exec influxdb influx
```

Run:

```sql
USE iot
SHOW MEASUREMENTS
SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 5
```

You should see the values published to the MQTT topics `temp`, `humidity`, `distance`, and `object`.

![InfluxDB query showing MQTT sensor data](docs/images/verify-influxdb-mqtt-data.png)

The same check can also be run from the `influxdb` terminal in Podman Desktop:

![Podman Desktop InfluxDB terminal showing MQTT sensor data](docs/images/podman-desktop-influxdb-query.png)

Exit the shell:

```sql
exit
```

You can also run the check in one command:

```bash
podman-compose exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'
```

## Option B: Docker Compose

### Step 2: Start the stack

From this folder:

```bash
docker compose up -d
```

Check that the containers are running:

```bash
docker compose ps
```

Expected services:

- `mqtt-broker`
- `mqtt-client`
- `influxdb`
- `telegraf`
- `grafana`

If the stack was already running before changing `config/telegraf/telegraf.conf`, recreate Telegraf so it loads the new topics:

```bash
docker compose up -d --force-recreate telegraf
```

### Step 3: Publish MQTT data

Method 1: publish values manually.

Send one temperature value with the MQTT client container:

```bash
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "25"
```

Send several values:

```bash
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "22.5"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t humidity -m "58"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t distance -m "45"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t object -m "1"
```

Method 2: run the script inside the `mqtt-client` container.

The script publishes 10 rounds of values for the four sensor topics: `temp`, `humidity`, `distance`, and `object`.

```bash
docker compose exec mqtt-client sh /usr/local/bin/publish-sensor-data
```

To choose another number of rounds, pass the number at the end:

```bash
docker compose exec mqtt-client sh /usr/local/bin/publish-sensor-data 20
```

Optional: subscribe in another terminal to observe messages:

```bash
docker compose exec mqtt-client mosquitto_sub -h mqtt-broker -p 1883 -t temp
```

After publishing a value, Telegraf should write it to InfluxDB within a few seconds.

### Step 4: Verify InfluxDB

Open the InfluxDB shell:

```bash
docker compose exec influxdb influx
```

Run:

```sql
USE iot
SHOW MEASUREMENTS
SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 5
```

You should see the values published to the MQTT topics `temp`, `humidity`, `distance`, and `object`.

Exit the shell:

```sql
exit
```

You can also run the check in one command:

```bash
docker compose exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'
```

## Step 5: Configure Grafana

Open Grafana:

```text
http://localhost:3000
```

Login:

```text
Username: admin
Password: admin
```

![Grafana login page](docs/images/grafana-login-page.png)

![Grafana login with default admin credentials](docs/images/grafana-login-admin.png)

Grafana may ask you to change the password. For a classroom workshop, you can skip it.

![Grafana password update screen with skip option](docs/images/grafana-skip-password-change.png)

After login, Grafana opens on the home page:

![Grafana home page](docs/images/grafana-home.png)

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

The data source settings should match the InfluxDB service used by the Compose stack:

![Grafana InfluxDB data source settings](docs/images/grafana-influxdb-data-source-settings.png)

After saving, Grafana should confirm that the data source is working:

![Grafana InfluxDB data source test success](docs/images/grafana-influxdb-data-source-working.png)

Important: use `http://influxdb:8086` only inside Grafana. Grafana runs in the same container network as InfluxDB, so it can reach the service name `influxdb`. From your browser or terminal on the host machine, use `localhost:8086` instead.

To test InfluxDB from your terminal:

```bash
curl -i http://localhost:8086/ping
```

A working InfluxDB usually returns:

```text
HTTP/1.1 204 No Content
```

![InfluxDB ping success in the terminal](docs/images/influxdb-ping-success-terminal.png)

## Step 6: Import the ready dashboard

Grafana can import the dashboard from `grafana/dashboards/iot-dashboard.json`.

In Grafana:

1. Open `Dashboards`.
2. Click `New`.
3. Click `Import`.
4. Upload `grafana/dashboards/iot-dashboard.json`.
5. Select the InfluxDB data source created in Step 5.
6. Click `Import`.

The import option is available from the `New` menu in the Dashboards page:

![Grafana dashboard import menu](docs/images/grafana-dashboard-import-menu.png)

The imported dashboard contains:

- Sensor values over time.
- Current temperature.
- Current humidity.
- Current distance.
- Current object detection status.

Publish new MQTT values and refresh the dashboard.

## Optional: Create a dashboard manually

Create a new dashboard and add a panel.

Use this InfluxQL query:

```sql
SELECT mean("value") FROM "mqtt_consumer" WHERE $timeFilter GROUP BY time($__interval) fill(null)
```

Suggested panel settings:

- Visualization: `Time series`
- Title: `Sensor Values`

Publish new MQTT values and refresh the dashboard.

## Optional: Phase 2 real deployment

Use this part only if time allows and the simulated pipeline is already working.

In Phase 2, the Raspberry Pi publishes real sensor values to the MQTT broker running in the workshop stack. Telegraf then collects those MQTT messages and writes them to InfluxDB, so Grafana can display live real-sensor data.

### Phase 2 real setup architecture

![Real sensor IoT architecture](docs/images/architecture-setup-real-sensors.png)

### Raspberry Pi sensor setup

![Raspberry Pi setup with temperature, humidity, distance, and object detection sensors](docs/images/setup-temp-hum-distance-1.png)

![Raspberry Pi setup with camera, display, and sensors](docs/images/setup-temp-hum-distance-2.png)

### 1. Switch Telegraf to the real-sensor configuration

The Phase 2 configuration is:

```text
config/telegraf/telegraf-real-sensors.conf
```

Replace the active Telegraf configuration with the real-sensor configuration:

```bash
cp config/telegraf/telegraf.conf config/telegraf/telegraf-simulation.conf
cp config/telegraf/telegraf-real-sensors.conf config/telegraf/telegraf.conf
```

Recreate Telegraf so it reloads the configuration.

With Podman Compose:

```bash
podman-compose up -d --force-recreate telegraf
```

With Docker Compose:

```bash
docker compose up -d --force-recreate telegraf
```

### 2. Find the computer IP address

The Raspberry Pi must publish MQTT messages to the IP address of the computer running the workshop stack.

On macOS:

```bash
ipconfig getifaddr en0
```

On Linux:

```bash
hostname -I
```

On Windows PowerShell:

```powershell
ipconfig
```

Use the IP address on the same network as the Raspberry Pi.

### 3. Publish real sensor data from the Raspberry Pi

The Raspberry Pi should publish numeric payloads to the same MQTT topics used in Phase 1:

- `temp`
- `humidity`
- `distance`
- `object`

Example test commands from the Raspberry Pi:

```bash
mosquitto_pub -h <computer-ip-address> -p 1883 -t temp -m "24.6"
mosquitto_pub -h <computer-ip-address> -p 1883 -t humidity -m "57"
mosquitto_pub -h <computer-ip-address> -p 1883 -t distance -m "42"
mosquitto_pub -h <computer-ip-address> -p 1883 -t object -m "1"
```

The payload must be only a number because Telegraf is configured with `data_format = "value"` and `data_type = "float"`.

The Raspberry Pi can also display live sensor values locally while publishing them to MQTT:

![Raspberry Pi local data display](docs/images/setup-data-display.png)

### 4. Verify the real data path

Subscribe to all MQTT topics from the `mqtt-client` container:

```bash
podman-compose exec mqtt-client mosquitto_sub -h mqtt-broker -p 1883 -t '#' -v
```

If you use Docker Compose:

```bash
docker compose exec mqtt-client mosquitto_sub -h mqtt-broker -p 1883 -t '#' -v
```

When the Raspberry Pi publishes data, you should see messages such as:

```text
temp 24.6
humidity 57
distance 42
object 1
```

Then refresh Grafana to see the live real-sensor data.

### 5. View the real-sensor dashboard in Grafana

The dashboard should show the live data extracted from the real sensors through the Raspberry Pi and MQTT pipeline.

![Grafana dashboard with temperature, humidity, distance, and object detection data](docs/images/grafana-real-sensor-2.png)

## Step 7: Stop the stack

```bash
podman-compose down
```

If you use Docker Compose:

```bash
docker compose down
```

To remove stored data as well:

```bash
podman-compose down -v
docker compose down -v
```

## Troubleshooting

If Grafana does not show data:

### 1. Check that containers are running

With Docker Compose:

```bash
docker compose ps
```

With Podman Compose:

```bash
podman-compose ps
```

Expected services:

- `mqtt-broker`
- `mqtt-client`
- `influxdb`
- `telegraf`
- `grafana`

If `telegraf` is stopped, check its logs:

```bash
docker compose logs telegraf
```

### 2. Confirm that MQTT messages reach the sensor topics

Open one terminal and subscribe to all MQTT topics:

```bash
docker compose exec mqtt-client mosquitto_sub -h mqtt-broker -p 1883 -t '#' -v
```

Open another terminal and publish values:

```bash
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "25"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t humidity -m "58"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t distance -m "45"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t object -m "1"
```

Expected output in the subscriber terminal:

```text
temp 25
humidity 58
distance 45
object 1
```

If you see these messages, MQTT is working.

### 3. Confirm that values are valid numbers

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
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "25.5"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t humidity -m "58"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t distance -m "45"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t object -m "1"
```

### 4. Confirm that InfluxDB has data

```bash
docker compose exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'
```

Expected output contains rows with a `value` column:

```text
name: mqtt_consumer
time                topic value
----                ----- -----
...                 temp  25.5
...                 humidity 58
...                 distance 45
...                 object 1
```

If there is no data, restart Telegraf and publish again:

```bash
docker compose restart telegraf
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "26"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t humidity -m "60"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t distance -m "42"
docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t object -m "1"
```

Then check InfluxDB again:

```bash
docker compose exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'
```

### 5. Check Telegraf logs

With Docker:

```bash
docker compose logs telegraf
```

With Podman:

```bash
podman-compose logs telegraf
```

If Telegraf logs show this Podman error:

```text
setpriv: failed to execute telegraf: Operation not permitted
```

Make sure the `telegraf` service in `compose.yaml` contains:

```yaml
user: telegraf
```

Then recreate Telegraf:

```bash
podman-compose up -d --force-recreate telegraf
```

### 6. Confirm Grafana data source settings

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

### 7. Test the query in Grafana Explore

Open:

```text
Explore
```

Select the InfluxDB data source and run:

```sql
SELECT * FROM "mqtt_consumer" WHERE $timeFilter
```

If Explore shows data but the dashboard does not, re-import `grafana/dashboards/iot-dashboard.json` and select the correct InfluxDB data source during import.

### 8. Check port conflicts

If ports are already used, stop the conflicting service or change these ports in `compose.yaml`:

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

## Command line summary

| Task | Podman Compose | Docker Compose |
| --- | --- | --- |
| Start the stack | `podman-compose up -d` | `docker compose up -d` |
| Check containers | `podman-compose ps` | `docker compose ps` |
| Publish temperature | `podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "25"` | `docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t temp -m "25"` |
| Publish humidity | `podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t humidity -m "58"` | `docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t humidity -m "58"` |
| Publish distance | `podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t distance -m "45"` | `docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t distance -m "45"` |
| Publish object detection | `podman-compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t object -m "1"` | `docker compose exec mqtt-client mosquitto_pub -h mqtt-broker -p 1883 -t object -m "1"` |
| Publish 10 rounds with the script | `podman-compose exec mqtt-client sh /usr/local/bin/publish-sensor-data` | `docker compose exec mqtt-client sh /usr/local/bin/publish-sensor-data` |
| Subscribe to a topic | `podman-compose exec mqtt-client mosquitto_sub -h mqtt-broker -p 1883 -t temp` | `docker compose exec mqtt-client mosquitto_sub -h mqtt-broker -p 1883 -t temp` |
| Query InfluxDB | `podman-compose exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'` | `docker compose exec influxdb influx -database iot -execute 'SELECT * FROM mqtt_consumer ORDER BY time DESC LIMIT 10'` |
| Recreate Telegraf | `podman-compose up -d --force-recreate telegraf` | `docker compose up -d --force-recreate telegraf` |
| View Telegraf logs | `podman-compose logs telegraf` | `docker compose logs telegraf` |
| Stop the stack | `podman-compose down` | `docker compose down` |
| Stop and remove data | `podman-compose down -v` | `docker compose down -v` |

## Optional: Node-RED extension

Node-RED is an optional visual programming tool for IoT workflows.

It lets you build flows by connecting nodes instead of writing a full application from scratch. In this workshop, Node-RED can be added after the main MQTT, Telegraf, InfluxDB, and Grafana pipeline is working. It is not required for Phase 1 or Phase 2, but it is useful to demonstrate how an IoT platform can be extended.

For example, Node-RED can:

- Receive MQTT data.
- Transform a message.
- Filter values.
- Send data to another service.
- Show values on a small dashboard.

![Node-RED IoT architecture](docs/images/architecture-nodered.jpeg)

![Node-RED MQTT flow example](docs/images/nodered-flow-example.svg)

Node-RED can connect to the MQTT broker and subscribe to the same topics used in the workshop:

- `temp`
- `humidity`
- `distance`
- `object`

Possible Node-RED activities:

- Subscribe to MQTT sensor topics and display the latest values.
- Add simple logic, such as checking whether distance is below a threshold.
- Transform messages before sending them to another service.
- Create a lightweight dashboard for quick monitoring.
- Forward selected MQTT messages to another API or notification service.

Example flow idea:

```text
MQTT input -> function node -> debug node
```

For a dashboard flow:

```text
MQTT input -> gauge/chart node -> Node-RED dashboard
```

Use Node-RED only after the main Grafana dashboard is working. Grafana remains the main visualization tool for the workshop; Node-RED is an extension for visual automation and rapid prototyping.
