# Mamadin

Welcome to Mamadin, your workout plannifier.

## Project structure and components

- `database/` - SQL Scripts for database intialization
- `docker-compose.yml` - Docker Compose file to start the database service

## Build

To start the database, execute the following command.

```bash
docker-compose up database -d
```

The docker-compose file will create a Postgres database with some initial data.

If you want to feed the database with only the essential data, you can uncomment the following lines in the `docker-compose.yml` file:

```yaml
# - ./database/additional-data.sql:/docker-entrypoint-initdb.d/3-aditional-data.sql
```
