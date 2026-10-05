# Roadmap de expansión

## Propósito propuesto

Backend de gestión de proyectos y tareas para personas y equipos pequeños, consumible desde
clientes móviles y web. Centralizar usuarios, proyectos, responsables, fechas y estados para
que varios clientes trabajen sobre los mismos datos con permisos verificables.

Propuesta pendiente de confirmar: el repositorio no implementa aún estas funciones.
Es un dominio acotado para practicar Swift del lado del servidor y demostrar persistencia,
contratos, seguridad, pruebas y operación. No presupone integración con otras apps existentes.

MVP: una persona inicia sesión, crea un proyecto, agrega tareas, cambia su estado y consulta
los datos desde otro cliente. Primero uso individual; después colaboración.

## Arquitectura

Monolito modular: un servicio Vapor y PostgreSQL. Introducir capas conforme aparezca código real.
No dividir en microservicios hasta medir una necesidad de escala o independencia operativa.

| Ubicación prevista | Responsabilidad |
| --- | --- |
| `configure.swift` | Dependencias, middleware y migraciones |
| `routes.swift` | Grupos `/api/v1` y rutas operativas |
| `Controllers/` | HTTP, decodificación y respuestas |
| `DTOs/` | Contratos públicos independientes de modelos persistidos |
| `Models/` | Modelos Fluent y relaciones |
| `Migrations/` | Esquema versionado |
| `Services/` | Reglas de negocio y autorización compartida |
| `Middleware/` | Autenticación y controles transversales |
| `Tests/` | Contratos, reglas e integración con persistencia |

Evitar carpetas vacías y abstracciones de repositorio anticipadas. Inyectar dependencias
cuando ayude a comprobar reglas reales. Mantener contratos JSON separados de la base de datos.

## Etapas y gates

| Etapa | Entregables | Criterio de avance |
| --- | --- | --- |
| 0. Base operativa | Contexto Docker protegido, lockfile, Compose local, HTTPS, salud y CI | CI verde en Linux/macOS, imagen saludable y HTTPS validado en staging. Configuración escrita; gates remotos pendientes. |
| 1. Contrato | `/api/v1`, OpenAPI, DTOs, errores uniformes, validación y paginación limitada | Ejemplos acordados y pruebas de entradas inválidas, 404 y límites. Definir estados y propiedad antes del esquema. |
| 2. Persistencia | Fluent + PostgreSQL, proyectos/tareas, migraciones, variables de entorno y readiness | Datos sobreviven reinicios; migraciones en base vacía y existente; integración en base aislada. |
| 3. Identidad | Usuarios, hash de contraseña, login, tokens con expiración/revocación y límites de intentos | A nunca accede a datos de B; secretos fuera de respuestas/logs; expiración y revocación probadas. |
| 4. MVP individual | CRUD autenticado de proyectos/tareas, filtros y transiciones | Crear cuenta → proyecto → tarea → completar → consultar desde otro cliente, probado con HTTP y PostgreSQL. |
| 5. Colaboración | Membresías, roles owner/editor/viewer, invitaciones temporales y auditoría | Matriz de permisos probada; revocación efectiva; concurrencia sin pérdidas silenciosas. |
| 6. Operación pública | Staging, backups, releases inmutables, métricas, alertas, límites y despliegues reversibles | Restauración y rollback demostrados; carga medida con objetivos explícitos. |
| 7. Expansión | Notificaciones, webhooks, búsqueda, sincronización incremental y trabajos asíncronos | Priorizar necesidades reales según uso y mediciones de latencia. |

La autenticación debe estar lista antes de exponer datos reales. Desarrollar las primeras rutas
CRUD en entornos privados. No publicar escrituras sin autorización.

## Contrato inicial propuesto

| Recurso | Endpoints |
| --- | --- |
| Identidad | `POST /api/v1/auth/register`, `POST /api/v1/auth/login`, `POST /api/v1/auth/logout`, `GET /api/v1/me` |
| Proyectos | `GET/POST /api/v1/projects`, `GET/PATCH/DELETE /api/v1/projects/:projectID` |
| Tareas | `GET/POST /api/v1/projects/:projectID/tasks`, `GET/PATCH/DELETE /api/v1/projects/:projectID/tasks/:taskID` |
| Operación | `GET /health` y futuro `GET /ready` |

Listados con máximo explícito. IDs del servidor. Fechas UTC en ISO 8601.
Cada tarea debe pertenecer al proyecto de la URL; cada acceso debe verificar permisos.
Definir eliminación y transiciones de estado antes de implementarlas.

## Alcance y próximo checkpoint

MVP: usuarios, proyectos privados y tareas con título, descripción opcional, estado y fecha opcional.
Posponer archivos adjuntos, chat, pagos, IA y sincronización offline.

Próximo checkpoint: confirmar dominio y escribir OpenAPI con errores y reglas de propiedad.
Después PostgreSQL y migraciones. Si se elige otro dominio, conservar infraestructura y adaptar
recursos en la etapa 1. Cada etapa termina con código ejecutable, pruebas y un gate verificable;
este roadmap no implica que las etapas estén implementadas.
