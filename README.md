# Proyecto Integrador: Framework de Base de Datos para E-Commerce

## Descripción del Sistema

Este proyecto es una Prueba de Concepto (POC) para un framework de base de datos diseñado para soportar la creación de múltiples sistemas de comercio electrónico, similar a plataformas como Shopify o Jumpseller.
La base de datos está diseñada para ser multi-tenant (soportar varias tiendas) y manejar los flujos esenciales de un e-commerce: gestión de productos, inventario, clientes, pedidos y ventas.

La gerencia no tiene claro cuales son los principales flujos que deberían ser soportados por la base de datos, por lo que la propuesta de flujo debe venir desde el equipo de desarrollo.

## Integrantes y Roles

| Integrante | Rol y Responsabilidades |
| :--- | :--- |
| **Benjamín López Huidobro** | Diseño del MER, creación de tablas principales y particiones, estructura del repositorio y documentación base (README). |
| **Fernando Godoy Marín** | Diseño y construcción del Data Warehouse, diseño de tabla de auditoría, implementación de roles/usuarios y presentación/demo. |
| **Lucas Campos Cortés** | Desarrollo de funciones auxiliares, pruebas funcionales del sistema y creación de triggers de validación funcional. |
| **Fabián Silva Toro** | Optimización de consultas (índices, EXPLAIN PLAN), implementación de consultas analíticas complejas y creación de vistas. |
| **Francisco Rojo Alfaro** | Desarrollo del paquete PL/SQL principal con manejo de excepciones y estrategia de respaldo y recuperación. |

## Requisitos Técnicos

* **Motor de Base de Datos:** Oracle Database 21c Express Edition (21.3.0).
* **Entorno de Ejecución:** Docker y Docker Compose.
* **Herramientas:** SQL*Plus (vía terminal).

## Diagramas de la BD
### Base de Datos:
![dbdiagram-framework-ecommerce](https://github.com/user-attachments/assets/51a7d19c-6467-4498-8b7c-9a987d36bd3a)

### Data Warehouse y Auditoria
![data-warehouse](https://raw.githubusercontent.com/Jacket-69/TAD-framework-ecommerce/f4525daf540098da95292639b42349b430ccc678/doc/data_warehouse.png)

### Lucidchart:
![MER-framework-ecommerce](https://github.com/user-attachments/assets/52ee832d-17d5-48f5-9120-66c9a5cf02ac)

## Instrucciones de Instalación y Uso

El entorno de desarrollo está completamente dockerizado. 
Hemos destilado minuciosamente la esencia de la programación en un solo comando que lo hace todo.
Sigue estos sencillos pasos para levantarlo y configurarlo.

### Paso 0: Limpieza Opcional

Si ya intentaste levantar esto antes y algo salió mal, ejecuta este comando para borrar todo y empezar de cero.
```bash
docker-compose down -v
```
### Paso 1: Levantar la Base de Datos con Docker

Asegúrate de tener Docker corriendo en tu máquina. 

Luego, clona el repositorio y ejecuta el siguiente comando desde la raíz del proyecto.

La primera vez, Docker descargará la imagen, lo cual puede tardar.

```bash
# Clona el repositorio (si aún no lo has hecho)
git clone https://github.com/Jacket-69/TAD-framework-ecommerce.git

cd TAD-framework-ecommerce
```
Construye, levanta y muestra los logs de la BD.
```bash
docker-compose up -d --build && docker-compose logs -f oracle-db
```
*¿Qué verás?* Primero, verás a Docker construir la imagen.

Luego, los logs empezarán a fluir. Puede tardar entre 2 y 5 minutos.

### Paso 2: Laburo
Luego de un tiempo la BD estara viva, configurada y esperando tus órdenes.
Ya puedes conectarte para empezar a trabajar.
#### Entrar al contenedor:
```bash
docker-compose exec oracle-db bash
```
#### Conectarse como usuario:
```bash
sqlplus ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1
```
### Adicional: Poblar con Datos de Prueba
Si quieres tener algunos datos de ejemplo para probar tus propias consultas o funciones, puedes ejecutar el script de prueba. Conéctate como el usuario ECOMMERCE_FRAMEWORK y ejecuta:
```bash
@/app/sql/03_poblar_datos_prueba.sql
```

### Paso 3: Optimizacion de la base de datos
Creacion de indices Estrategicos.
Ejecutar el Script index_explain_plan.sql para poder ejecutar la optimizacion de la base de datos
```bash
En cmd ejecutar docker docker cp "C:\Users\"Tu usuario"\TAD-framework-ecommerce\sql\index_explain_plan.sql" tad_oracle_db:/opt/index_explain_plan.sql "
```
```bash
Dentro de la base de datos Sql ejectuar @/app/sql/index_explain_plan.sql
```
Contiene los indices para lograr la optimizacion correspondiente, tambien el uso de EXPLAIN PLAN para evaluacion de rendimiento.

### Paso 4 : Creacion de Vistas Materalizadas.
Ideal para acelerar reportes con muchos calculos.
Al igual que el paso 4 se tiene que ejecutar en el cmd
```bash
En cmd ejecutar docker docker cp "C:\Users\"Tu usuario"\TAD-framework-ecommerce\sql\.sql" tad_oracle_db:/opt/creacion_vistas.sql "
```
```bash
Dentro de la base de datos Sql ejectuar @/app/sql/creacion_vistas.sql
```
Esto es para la validacion de rendimiento, tomando una mejora considerable por consulta.

### Adicional: Ejecutar scripts de complejidad
(Opcional) Puedes ejecutar el script de operaciones_complejas.sql , de la misma manera que los pasos anteriores, sirve 
para tener una vista para toma de decisiones(Consulta sobre cambios de auditoria(Update,Delete,Insert) y sobre Resumen mensual de operacion por tipo y tabla).





