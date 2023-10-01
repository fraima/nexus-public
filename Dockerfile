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

FROM sonatype/nexus3:3.58.1 as src-plugin
#RUN addgroup -g 101 app && \
#    adduser -H -u 101 -G app -s /bin/sh -D app
USER nexus
WORKDIR /opt/sonatype/nexus
#RUN apk add openjdk8
#RUN apk add git
COPY --from=builder --chown=nexus:nexus /build/nexus-datastore-*.jar system/org/sonatype/nexus/nexus-datastore/3.58.1-02/
COPY --from=builder --chown=nexus:nexus /build/nexus-common-*.jar system/org/sonatype/nexus/nexus-common/3.58.1-02/

CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
