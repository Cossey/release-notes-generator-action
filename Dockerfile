FROM openjdk:8-alpine
LABEL "maintainer"="stewart.cossey@gmail.com"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="green"

ENV GENERATOR_VERSION="v0.0.4"

COPY *.sh /
RUN chmod +x JSON.sh && \
    wget -O github-changelog-generator.jar https://github.com/spring-io/github-changelog-generator/releases/download/${GENERATOR_VERSION}/github-changelog-generator.jar

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]