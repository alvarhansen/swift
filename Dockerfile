FROM swift:4.2

MAINTAINER Orta Therox

LABEL "com.github.actions.name"="Danger Swift"
LABEL "com.github.actions.description"="Runs Swift Dangerfiles"
LABEL "com.github.actions.icon"="zap"
LABEL "com.github.actions.color"="blue"

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install -y nodejs

# Install danger-swift globally
RUN git clone https://github.com/danger/danger-swift.git _danger-swift
RUN cd _danger-swift && make install

RUN git clone https://github.com/realm/SwiftLint.git _SwiftLint
RUN cd _SwiftLint && git submodule update --init --recursive; make install

# Run Danger Swift via Danger JS, allowing for custom args
ENTRYPOINT ["npx", "--package", "danger@6.1.13", "danger-swift", "ci"]
