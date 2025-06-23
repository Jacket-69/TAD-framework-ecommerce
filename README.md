# Proyecto Integrador: Framework de Base de Datos para E-Commerce

## Descripción del Sistema

Este proyecto es una Prueba de Concepto (POC) para un framework de base de datos diseñado para soportar la creación de múltiples sistemas de comercio electrónico, similar a plataformas como Shopify o Jumpseller. La base de datos está diseñada para ser multi-tenant (soportar varias tiendas) y manejar los flujos esenciales de un e-commerce: gestión de productos, inventario, clientes, pedidos y ventas.

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

## Instrucciones de Instalación y Uso

El entorno de desarrollo está completamente dockerizado. Sigue estos pasos para levantarlo y configurarlo.

### 1. Levantar la Base de Datos con Docker

Asegúrate de tener Docker corriendo en tu máquina. Luego, clona el repositorio y ejecuta el siguiente comando desde la raíz del proyecto. La primera vez, Docker descargará la imagen, lo cual puede tardar.

```bash
# Clona el repositorio (si aún no lo has hecho)
git clone https://github.com/Jacket-69/TAD-framework-ecommerce.git
cd TAD-framework-ecommerce

# Levanta el contenedor de la base de datos en segundo plano
docker-compose up -d

Para verificar que la base de datos se está iniciando, puedes ver los logs:
docker-compose logs -f oracle-db
Espera hasta que veas un mensaje que diga DATABASE IS READY TO USE!. Puedes salir de los logs con Ctrl+C.

2. Crear el Esquema de la Aplicación
Ahora, vamos a conectarnos como SYSTEM para crear el usuario ECOMMERCE_FRAMEWORK, que será el dueño de todos los objetos de nuestra base de datos.

# Entrar al contenedor de la base de datos
docker-compose exec oracle-db bash

# Una vez dentro, conectarse a la base de datos como SYSTEM
# La contraseña es la que definimos en docker-compose.yml
sqlplus sys/TAD-framework-2025@//localhost:1521/XEPDB1 as sysdba

# Dentro de SQL*Plus, ejecutar el script de creación del esquema
@/app/sql/01_create_schema.sql

# Salir de SQL*Plus
exit;

3. Ejecutar Scripts de Creación de Tablas
Con el usuario ya creado, podemos conectarnos como ECOMMERCE_FRAMEWORK para ejecutar el resto de los scripts (crear tablas, procedimientos, etc.).

# Si saliste del contenedor, vuelve a entrar: docker-compose exec oracle-db bash

# Conectarse como el nuevo usuario
sqlplus ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1

# Ejecutar el script para crear las tablas
@/app/sql/02_create_tables.sql

# (Aquí se ejecutarían los demás scripts en orden)
# @/app/sql/03_... .sql
# etc.

# Salir de SQL*Plus
exit;

# Salir del contenedor
exit;
