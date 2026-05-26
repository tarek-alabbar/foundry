# ── Stage 1: Build ────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder
WORKDIR /src

COPY *.sln ./
COPY src/ ./src/
RUN dotnet restore
RUN dotnet publish src/**/*.csproj -c Release -o /app/publish --no-restore

# ── Stage 2: Runtime (lean image) ─────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:<<PORT>> \
    ASPNETCORE_ENVIRONMENT=Production

# Non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

COPY --from=builder --chown=appuser:appgroup /app/publish .

EXPOSE <<PORT>>
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:<<PORT>>/health || exit 1

ENTRYPOINT ["dotnet", "<<APP_NAME_CLEAN>>.dll"]
