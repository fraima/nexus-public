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

CMD ["./bin/nexus"]
