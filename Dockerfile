#ENV TEST_alexgluck=test
FROM alpine as builder
WORKDIR /app
RUN apk add openjdk8
RUN apk add git
COPY . .
RUN ./mvnw -pl components/nexus-common,components/nexus-datastore -am clean install -DskipTests=true -P skipNpmTests-maven.test.skip,skipNpmTests-skipTests
RUN mkdir -p /build/ && \
    cp components/nexus-datastore/target/nexus-datastore-*.jar /build/ && \
    cp components/nexus-common/target/nexus-common-*.jar /build/


FROM sonatype/nexus3:3.68.0 as src-plugin

USER nexus
WORKDIR /opt/sonatype/nexus

COPY --from=builder --chown=nexus:nexus /build/nexus-datastore-*.jar system/org/sonatype/nexus/nexus-datastore/3.68.0-02/
COPY --from=builder --chown=nexus:nexus /build/nexus-common-*.jar system/org/sonatype/nexus/nexus-common/3.68.0-02/


CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
