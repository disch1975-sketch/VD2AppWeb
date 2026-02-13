# -------------------
# 1️⃣ Build-Stage: .NET SDK
# -------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Projektdateien kopieren & NuGet-Pakete wiederherstellen
COPY *.csproj ./
RUN dotnet restore

# Restliche Dateien kopieren & veröffentlichen
COPY . ./
RUN dotnet publish -c Release -o /app/out

# -------------------
# 2️⃣ Runtime-Stage: nginx
# -------------------
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Standard-Nginx-Seiten löschen
RUN rm -rf ./*

# Build-Ausgabe kopieren
COPY --from=build /app/out/wwwroot ./

# Port 80 für Railway öffnen
EXPOSE 80

# nginx starten
CMD ["nginx", "-g", "daemon off;"]
