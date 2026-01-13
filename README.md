# mb_custom

Descripción breve
-----------------

**mb_custom** es un recurso de FiveM para gestionar vehículos y sus partes, separando partes visuales (mods) de partes funcionales que afectan al comportamiento del vehículo (actualmente en desarrollo: **ruedas**). El objetivo es ofrecer una estructura modular para aplicar modificaciones tanto estéticas como de manejo usando state bags y eventos.

Índice
------
- [Características](#características-)
- [Estado del proyecto](#estado-del-proyecto)
- [Instalación](#instalación)
- [Uso básico](#uso-básico)
- [Estructura de datos](#estructura-de-datos-parts-)
- [Cómo extender](#cómo-extender)
- [Testing (runner integrado)](#testing-runner-integrado)
- [Eventos y exports clave](#eventos-y-exports-clave)

Características ✅
- Separación clara entre **mods visuales** y **partes funcionales** (wheels/ruedas).
- Cálculo de parámetros de manejo basados en las ruedas (desgaste, presión, tipo de goma).
- Integración con **ox_lib**, **ox_inventory** y **ox_target** para interacción y gestión de items.
- Configuraciones extensibles en `config/` para handling, mods y pinturas.

Estado del proyecto ⚠️
- Implementación de **ruedas**: funcional pero en fase de desarrollo (cálculo de handling parcial, sistema de desgaste incipiente).
- Quedan mejoras y correcciones menores por implementar.

Instalación 🔧
1. Copiar la carpeta del recurso en `resources/[vehicle]/mb_custom` de tu servidor.
2. Añadir en `server.cfg`:

```ini
ensure mb_custom
```

3. Dependencias requeridas (en `fxmanifest.lua`):
- `ox_lib`
- `ox_inventory`
- `ox_target`

Uso básico 🛠️
- Interactúa con vehículos usando el menú provisto por `ox_target` (opciones: *Vehicle Parts*, *Inspect vehicle*, *Show Vehicle Handlings*).
- El cliente solicita partes con el evento `mb_custom:requestVehicleParts` y el servidor responde seteando `vehicleParts` en el state bag de la entidad vehículo.
- Ejemplo: el servidor setea el estado con `Entity(vehicle).state:set('vehicleParts', parts, true)`; el cliente lee ese estado y aplica los manejos calculados.

Archivos importantes 📁
- `fxmanifest.lua` – manifiesto y dependencias.
- `client/main.lua` – lógica cliente y menús.
- `server/main.lua` – gestión de items y eventos de servidor.
- `modules/vehicle.lua` – clase controladora para vehículos y aplicación de partes.
- `modules/parts/wheels.lua` – cálculo del handling según ruedas (desgaste, presión, tipo).
- `modules/parts/parts_generator.lua` – generación de estructura de partes a partir del vehículo.
- `config/handlingdata.lua` – multiplicadores por defecto y definición de partes (`parts.wheels`).

Estructura de datos: `parts` 🧾
- `parts` es la tabla enviada (cliente → servidor) y guardada por el servidor en el state bag `vehicleParts`.
- Formato esperado (ejemplo):

```json
{
  "wheels": {
    "style": 0,
    "index": 0,
    "label": "Stock",
    "tyres": {
      "0": { "health": 900.0, "grade": "street", "pressure": 2.2 },
      "1": { "health": 900.0, "grade": "street", "pressure": 2.2 }
    },
    "tyreCount": 2,
    "globalHealth": 1800.0
  }
}
```

- Campos importantes:
  - `wheels.tyres[i].health` (number) – salud del neumático (0..1000).  
  - `wheels.tyres[i].grade` (string) – tipo de neumático: `street`, `sport`, `slick`, `offroad` (se asigna en servidor si falta).  
  - `wheels.tyres[i].pressure` (number) – presión del neumático; **es definida por el servidor** usando `handling.parts.defaultPressure` para evitar que clientes maliciosos la inyecten.  
  - `wheels.tyreCount` (number) – número de ruedas detectadas (calculado en base a los huesos disponibles).  
  - `wheels.globalHealth` (number) – suma de las salud de todas las ruedas.

- Nota: el cliente envía la estructura con las lecturas (p. ej. `health`), pero la presión es aplicada o normalizada por el servidor para mantener integridad y evitar trampas.

Odometer / desgaste por kilometraje 🚗⏱️
- Nueva parte: `odometer` (guardada en `parts.odometer`) con campos clave:
  - `totalMeters` (number): metros totales acumulados.
  - `lastReported` (timestamp): última vez que se reportó distancia desde el cliente.
- Flujo (resumen):
  1. El cliente mide distancia localmente y, al acumular al menos `reportMinMeters`, llama al callback servidor `lib.callback('mb_custom:reportDistance', false, netId, meters)`.
  2. El servidor valida (throttle, top speed razonable, formato) y responde `{ ok = true, ts }` o `{ ok = false, reason }` y marca un `pendingReport` para evitar replays.
  3. Si el servidor acepta, el cliente calcula localmente el desgaste usando `modules.parts.odometer` (función `ApplyWearToTyres`) y construye un `candidate` con `parts` actualizado.
  4. El cliente envía `TriggerServerEvent('mb_custom:submitPartsUpdate', netId, candidate, meters, ts)` y el servidor valida que el incremento del odómetro y la reducción de salud sean coherentes (con tolerancia) antes de setear el state bag de forma autoritativa.
- Configuración (en `config/handlingdata.lua` bajo `Handling.parts.odometer.default`):
  - `wearPerKm` (number) — desgaste de `health` por km.
  - `maxMetersPerSecond` (number) — límite aceptable por segundo para evitar spoofing.
  - `reportThrottleSeconds` (number) — ventana mínima entre reports.
  - `reportMinMeters` (number) — metros mínimos a acumular antes de reportar desde el cliente.
  - `sampleIntervalSeconds` (number) — intervalo de muestreo del loop cliente.
- Tests: la suite `tests/odometer.lua` cubre cálculos de daño y la aplicación de desgaste (unitario) — la validación network/servidor se prueba manualmente y con pruebas de integración.


Cómo extender
--------------
- Añadir un nuevo tipo de goma: editar `config/handlingdata.lua` en `parts.wheels` y definir los multiplicadores para las propiedades de handling.
- Añadir una nueva parte: crear módulo en `modules/` que exponga la lógica para esa parte y actualizar la generación de partes en `modules/parts/parts_generator.lua`.

Testing (runner integrado)
--------------------------
- Habilita pruebas editando `config/main.lua`:
  - `tests.enabled = true` — carga el runner automáticamente en el cliente.
  - `tests.registerCommands = true` — registra el comando `mb_custom:run_tests` en el cliente.
  - `tests.registerTargets = true` — añade targets de prueba (Inspect / Show Vehicle Handlings) vía `ox_target`.
- Los parámetros de prueba son personalizables en `config/main.lua` (`tests.settings`) — `wearInputs`, `pressureInputs` y `computeHandlingCases`.
- El runner está en `tests/runner.lua` y las pruebas de ruedas en `tests/wheels.lua` (se ejecutan con la configuración indicada).
- Puedes personalizar la forma en que se añaden targets creando `tests/targets.lua` con una función `register(ox_target)` que el runner invocará si existe; de lo contrario se añaden targets por defecto.
- Para ver la salida de pruebas activa `ox_lib` Print con:

```
ox:printlevel:<resourcename> "debug"
```

- Nota: el runner registra targets y comandos si `tests.enabled` y las banderas correspondientes están activas; así evitas cargar configuración de tests en múltiples sitios.
Eventos y exports clave
-----------------------
- Evento cliente → servidor: `mb_custom:requestVehicleParts` (cliente solicita partes y el servidor setea el estado compartido).
- Eventos para dar items: `mb_custom:GiveVehiclePart`, `mb_custom:GiveVehiclePaint`.
- Export disponible (server): `VehiclePart`, `VehiclePaint` (para integrar con otros scripts o sistemas de items).


Contribuir 🤝
- Pull requests bienvenidos: todos los PRs deben ser revisados y aprobados por al menos un mantenedor antes de fusionarse. Los colaboradores con permisos de mantenimiento pueden aprobar PRs según las normas del repositorio.
- Antes de implementar cambios significativos, abre un issue describiendo el problema o la propuesta; sigue las guías de estilo y añade tests cuando corresponda.

Licencia
--------
- Propongo **MIT** por su flexibilidad; cambiar según prefieras.

Contacto
--------
- Mantén issues y PRs en el repositorio principal; si quieres, puedo ayudarte a implementar las correcciones propuestas.
