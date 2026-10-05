# SwiftRESTAPI

API en Swift y Vapor. Propósito y etapas de expansión: [ROADMAP.md](ROADMAP.md).

## Desarrollo

Requiere Swift 6.3 o superior; Docker y CI usan Swift 6.3. macOS mínimo declarado: 13.
`Package.resolved` está versionado: revisar sus cambios al actualizar dependencias.

```bash
swift build --disable-automatic-resolution
swift run --disable-automatic-resolution SwiftRESTAPI serve --hostname 127.0.0.1 --port 8080
swift test --disable-automatic-resolution
```

Si Xcode bloquea la firma con `resource fork, Finder information, or similar detritus not allowed`,
las pruebas no se ejecutaron. Alternativa temporal donde aún esté disponible:
`swift test --disable-automatic-resolution --build-system native`.
Este sistema está deprecado y no es la configuración de CI.

| Ruta | Respuesta | Uso |
| --- | --- | --- |
| `GET /` | `It works!` | Ejemplo |
| `GET /hello` | `Hello, world!` | Ejemplo |
| `GET /health` | `{"status":"ok"}` | Liveness del proceso HTTP |

`/health` no comprueba dependencias externas. Añadir readiness al introducir una base de datos.

## Docker local

```bash
docker compose up --build --detach --wait
curl --fail http://127.0.0.1:8080/health
docker compose down
```

Puerto publicado solo en loopback, entorno `development`, logs `info`.
Variables opcionales: `APP_PORT` y `LOG_LEVEL`. Copiar `.env.example` a `.env` si se necesita.
Sus valores de dominio y correo son placeholders. Los `.env`, claves y metadatos Git
quedan fuera del contexto Docker.

## Producción con HTTPS

Usar **solo** `compose.production.yml`; combinarlo con el archivo local podría publicar 8080.

1. Preparar un servidor con Docker Compose y DNS del dominio real apuntando al servidor.
2. Permitir tráfico a 80 y 443; no publicar 8080.
3. Definir `API_DOMAIN` y `ACME_EMAIL` reales mediante variables o `.env`.
4. Ejecutar:

```bash
docker compose -f compose.production.yml config --quiet
docker compose -f compose.production.yml up --build --detach --wait
```

Caddy termina HTTPS y redirige HTTP a HTTPS; Vapor escucha dentro de la red Docker.
Los volúmenes conservan certificados. Logs predeterminados: `notice`.
Referencia: [Automatic HTTPS](https://caddyserver.com/docs/automatic-https)
y [reverse_proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy).

Healthcheck cada 30 segundos. `restart: unless-stopped` reinicia procesos que salen;
un contenedor `unhealthy` no se reinicia automáticamente por ese estado.
Ver [referencia de Compose](https://docs.docker.com/reference/compose-file/services/).

No se ha desplegado el proyecto ni emitido un certificado. Las imágenes base
`swift:6.3-noble`, `ubuntu:noble` y `caddy:2` usan etiquetas actualizables: antes de una release
reproducible, fijar digests validados y un `APP_IMAGE` inmutable del registro.
Nunca incorporar credenciales a la imagen.

## CI

`.github/workflows/ci.yml` prueba Swift 6.3 en Linux/macOS, exige el lockfile versionado
y comprueba que no cambie. Otro job valida Compose y Caddy, construye la imagen Linux
y comprueba salud y respuestas HTTP. Se ejecutará al enviar los cambios a GitHub.

Todavía no hay persistencia ni autenticación. Añadir CORS con una lista explícita de orígenes
al integrar un frontend web de otro origen; clientes nativos no requieren CORS.
