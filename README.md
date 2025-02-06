# ss-deploy

## Setup

1. Rename `core/sample.env` file to `core/.env`:
2. Change the values in the `.env` file to your desired values
3. Run `make run`
4. Open `http://localhost:{SS_WEB_PORT}` in your browser
5. API docs can be found at `http://localhost:{SS_CORE_PORT}/docs`
6. To stop the system, run `make stop`

### Database

To help visualize the database, see the plaintext data, and execute queries we can use any database client. Here's the instructions to connect to the databese using the [DBVisualizer](https://www.dbvis.com/) and [DBeaver](https://dbeaver.io/).

#### DBVisualizer Setup

1. Create database connection > Search for "PostgreSQL"
2. Change the following to reflect values defined in `.env` file:
    - Database Server = `SS_DB_HOST`
    - Database Port = `SS_DB_PORT`
    - Database = `SS_DB_NAME`
    - Database Userid = `SS_DB_USER`
    - Database Password = `SS_DB_PASSWORD`
3. Press "Connect"

#### DBeaver Setup

1. Click "New database connection" > Search for "PostgreSQL"
2. Change the following to reflect values defined in `.env` file:
    - Host = `SS_DB_HOST`
    - Port = `SS_DB_PORT`
    - Database = `SS_DB_NAME`
    - Username = `SS_DB_USER`
    - Password = `SS_DB_PASSWORD`
3. Press "Finish" (might have to press "Connect" afterwards)

## Update existing version

1. Run `make stop`
2. Run `make pull`
3. Run `make run`
