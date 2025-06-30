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
En el apartado de script se ejecuta automaticamente el archivo 04_optimizacion_vistas.sql.
Este archivo sirve para optimizar de manera adecuada nuestra base de datos, reduciendo considerablemente el tiempo de busqueda.

### Paso 4: Generar Consulta de toma de decisiones.
Creacion de consulta compleja con respecto a toma de decisiones para el analista y su tienda.
Este script esta creado para el analista que muestra los 10 clientes con fecha de ultimo mes que tienen mas pedidos completados, mientras que el segundo script muestra los productos mas vendidos por region.

### Paso 5:PKG INTELIGENCIA DE NEGOCIO.
Se desarrolló un paquete PL/SQL que actúa como el cerebro analítico del sistema, operando exclusivamente sobre el Data Warehouse para no afectar el rendimiento de la tienda en vivo. Sus responsabilidades se dividen en dos áreas:
Funciones para el Analista: Ofrece una suite de herramientas de alto valor para responder preguntas de negocio complejas.
Funciones Clave: F_OBTENER_CLIENTES_VALIOSOS (devuelve un ranking de los mejores clientes) y F_CALCULAR_AOV_PERIODO (calcula el valor promedio de las órdenes).

Seguridad: Todas las funciones consultan las vistas seguras (v_*), garantizando que un analista solo pueda acceder a la información de su propia tienda.
Procedimientos de Soporte (ETL): Incluye la lógica administrativa para mantener el Data Warehouse actualizado.
Procedimientos Clave: P_CARGAR_VENTAS_AL_DW (carga las ventas desde el sistema transaccional al DWH) y P_SINCRONIZAR_DIMENSIONES (actualiza los catálogos de productos y usuarios).
Transacciones: Estos procedimientos son transaccionales y usan COMMIT y ROLLBACK para garantizar la integridad de los datos durante la carga.
Manejo de Excepciones: El paquete implementa excepciones personalizadas como e_datos_insuficientes para gestionar errores de negocio de forma controlada y entregar mensajes claros, aumentando la robustez de la aplicación.

## Parte 6: Funciones auxiliares y validaciones

Para cargar y probar las funciones auxiliares desarrolladas, ejecutar el script:

```sql
@funciones_auxiliares.sql
```

Luego, puedes probar las funciones utilizando `SELECT` desde `DUAL`, por ejemplo:

```sql
SELECT resumen_ventas_usuario(1) FROM dual;
SELECT verificar_usuario_activo_en_compras(1) FROM dual;
SELECT productos_bajo_stock(1, 10) FROM dual;
SELECT ventas_por_region('Metropolitana') FROM dual;
```

Estas funciones permiten obtener información relevante como el total de ventas de un usuario, actividad reciente en compras, productos con stock bajo o el total vendido en una región específica.

---

## Parte 7: Triggers y pruebas funcionales

Primero, cargar todos los triggers ejecutando:

```sql
@triggers.sql
```

Luego, ejecutar el script de pruebas funcionales con:

```sql
@pruebas_funcionales.sql
```

Este script realiza inserciones y actualizaciones sobre datos de prueba para verificar que los triggers funcionen correctamente, incluyendo validaciones de stock, fechas de pedidos, pagos correctos y automatización de inserciones en un entorno de Data Warehouse. También se prueban vistas con permisos restringidos.




