## Сборка 
jdk==1.8

```shell
./mvnw clean install -DskipTests=true -P skipNpmTests-maven.test.skip,skipNpmTests-skipTests
```

Зип упадет в `assemblies/nexus-base-template/target/`

## Настройки 


```bash
mkdir -p /tmp/sonatype-work/nexus3/etc/

export PG_URL="localhost:5432"
export PG_USER="nexus"
export PG_PASSWORD="nexus"
export PG_DB="nexus"

cat <<EOF > /tmp/sonatype-work/nexus3/etc/nexus.properties
nexus.datastore.enabled=true
nexus.datastore.nexus.jdbcUrl=jdbc:postgresql://$PG_URL/$PG_DB?user=$PG_USER&password=$PG_PASSWORD
nexus.datastore.nexus.genericJdbc=true
EOF

docker build .

docker run -d -ti     \
    --rm \
    -p 8080:8081 \
    -v /tmp/sonatype-work/nexus3/etc/nexus.properties:/sonatype-work/nexus3/etc/nexus.properties \
    fraima.io/nexus:3.58.1-02

```

`<workdir>/sonatype-work/nexus3/etc/nexus.properties`:
```properties
nexus.datastore.enabled=true
nexus.datastore.nexus.jdbcUrl=jdbc:postgresql://<host>:<port>/<db>?user=<user>&password=<pass>
nexus.datastore.nexus.genericJdbc=true
```

## Запуск 
распаковать zip в <workdir>
jdk == 1.8

```shell
./nexus-base-template-<X.XX.X>/bin/nexus.run
```

# Миграции

https://help.sonatype.com/repomanager3/installation-and-upgrades/migrating-to-a-new-database

## Миграция из H2 в PG:

```shell
java -Xmx4G -Xms4G -XX:MaxDirectMemorySize=4014M -jar nexus-db-migrator-*.jar --migration_type=h2_to_postgres --db_url="jdbc:postgresql://<database URL>:<port>/nexus?user=postgresUser&password=secretPassword&currentSchema=nexus"
```

## из PG в H2

```shell
java -jar nexus-db-migrator-*.jar --migration_type=postgres_to_h2 --db_url="jdbc:postgresql://<database URL>:<port>/nexus?user=postgresUser&password=secretPassword&currentSchema=nexus"
```

nexus-db-migrator не поддерживает прямую миграцию PG->PG 
для реализации такого сценария сначала нужно выполнить миграцию PG->H2 затем H2->PG


https://github.com/sonatype/docker-nexus/issues/9

export NEXUS_VERSION=3.60.0-02
https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-p2-bridge-plugin/${NEXUS_VERSION}/nexus-p2-bridge-plugin-${NEXUS_VERSION}-bundle.zip