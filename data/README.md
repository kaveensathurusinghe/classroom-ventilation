# Frozen weather data

`raw/malabe_era5_2025_03.json` is the inherited Open-Meteo ERA5 response requested at (6.91 N,79.97 E), 1–31 March 2025, hourly temperature_2m and wind_speed_10m, Celsius and m/s, Asia/Colombo. The actual grid point may differ. This is reanalysis, not classroom measurements.

The sidecar `.metadata.json` records the original URL, recorded retrieval time and SHA-256. The timestamp is inherited metadata, not a claim this rebuild downloaded it. `fetch_weather` verifies request and checksum before reuse. Weekday 09:00–11:00 blocks form the pool; holidays are not excluded. Processed CSVs are derived inputs.

Attribution: Open-Meteo.com; Copernicus ERA5, https://doi.org/10.24381/cds.adbb2d47 . Documentation: https://open-meteo.com/en/docs/historical-weather-api . Weather data retains upstream CC BY 4.0 attribution requirements; code's MIT licence does not replace data terms.

An assumed multiplier adjusts 10 m wind to opening-level wind. No measured shelter correction or classroom calibration is claimed.
