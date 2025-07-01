# === Stage 1: Build the project ===
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean install -DskipTests

# === Stage 2: Run Selenium Tests ===
FROM maven:3.9.6-eclipse-temurin-17

WORKDIR /app

# Install dependencies for Chrome
RUN apt-get update && \
    apt-get install -y wget unzip xvfb curl gnupg && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for Chrome
ENV CHROME_BIN=/usr/bin/google-chrome
ENV DISPLAY=:99

# Copy the code from the build stage
COPY --from=build /app /app

# Run the tests
CMD ["mvn", "test"]
