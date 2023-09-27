FROM sonatype/nexus3:3.58.1 as src-plugin
ENV TEST_alexgluck=test

FROM alpine as builder
WORKDIR /app
RUN apk add openjdk8
RUN apk add git
COPY . .
RUN ./mvnw clean install -DskipTests=true -P skipNpmTests-maven.test.skip,skipNpmTests-skipTests
RUN mkdir -p /build/ && \
    unzip assemblies/nexus-base-template/target/nexus-base-template-*.zip -d /build/

FROM alpine
RUN addgroup -g 101 app && \
    adduser -H -u 101 -G app -s /bin/sh -D app 

WORKDIR /app
RUN apk add openjdk8
RUN apk add git

COPY --from=builder --chown=app:app /build/nexus-base-template-*/ /app/
COPY --from=builder --chown=app:app /build/sonatype-work/ /sonatype-work/
RUN mkdir -p /app/system/com/sonatype/nexus/plugins/

COPY --from=src-plugin --chown=app:app /opt/sonatype/nexus/system/com/sonatype/nexus/plugins/*/* /app/system/org/sonatype/nexus/plugins/
COPY --from=src-plugin --chown=app:app /opt/sonatype/nexus/system/com/sonatype/nexus/assemblies/nexus-pro-feature/3.58.1-02/nexus-pro-feature-3.58.1-02-features.xml /app/system/com/sonatype/nexus/assemblies/nexus-pro-feature/3.58.1-02/nexus-pro-feature-3.58.1-02-features.xml

CMD ["./bin/nexus"]
