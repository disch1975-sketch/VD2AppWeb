# -------------------
# 1️⃣ Build-Stage: .NET SDK
# -------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# 1️⃣ Projektdateien kopieren
COPY ./Server/*.csproj ./Server/
COPY ./Client/*.csproj ./Client/
COPY ./Shared/*.csproj ./Shared/
RUN dotnet restore Server/Server.csproj

# 2️⃣ Restliche Dateien kopieren
COPY . ./

# 3️⃣ Veröffentlichen
RUN dotnet publish Server/Server.csproj -c Release -o /app/out

# -------------------
# 2️⃣ Runtime-Stage: nginx für Blazor WebAssembly
# -------------------
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Standard-Nginx-Seiten löschen
RUN rm -rf ./*

# Build-Ausgabe kopieren (nur wwwroot des Blazor-Clients)
COPY --from=build /app/out/wwwroot ./

# Cache-Control Header, damit Browser immer neu lädt
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        add_header Cache-Control "no-cache, no-store, must-revalidate"; \
        add_header Pragma "no-cache"; \
        add_header Expires 0; \
        try_files $uri /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Port 80 für Railway
EXPOSE 80

# nginx starten
CMD ["nginx", "-g", "daemon off;"]
