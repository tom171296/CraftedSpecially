# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Directory.Build.props", "."]
COPY ["nuget.config", "."]
COPY ["src/", "./src/"]
RUN dotnet restore "./src/CraftedSpecially.Api/CraftedSpecially.Api.csproj" --configfile ./nuget.config --locked-mode
RUN dotnet publish "./src/CraftedSpecially.Api/CraftedSpecially.Api.csproj" -c Release -o /app/publish --no-restore

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Security: Create non-root user and switch to it
RUN groupadd --system appgroup && useradd --system --gid appgroup appuser
USER appuser

# Environment variables
ENV ASPNETCORE_URLS="http://+:8080"
ENV ASPNETCORE_ENVIRONMENT="Production"

# Expose only necessary port
EXPOSE 8080

# Start the app
ENTRYPOINT ["dotnet", "CraftedSpecially.Api.dll"]
