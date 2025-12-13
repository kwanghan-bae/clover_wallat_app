# Stage 1: Build the Flutter Web App
FROM debian:latest AS build

# Install dependencies
RUN apt-get update && apt-get install -y curl git unzip

# Convert to non-root user (optional but good practice, though for build stage in Docker it's often skipped for simplicity unless strict)
# We'll stick to root for build tools simplicity in this stage

# Define Flutter version
ARG FLUTTER_SDK_VERSION="3.24.0"

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Switch to stable channel and upgrade
RUN flutter channel stable
RUN flutter upgrade

# Copy app source
WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build for Web
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build artifacts from previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
