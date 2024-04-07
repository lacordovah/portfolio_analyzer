# Aplicación de Cálculo de Ganancia de Portafolio

Esta aplicación Ruby está diseñada para calcular la ganancia potencial de distintos portafolios de inversión basándose en valores históricos de diversos fondos. Hace uso de la API de Fintual para obtener los precios de las acciones de fondos específicos, permitiendo calcular el rendimiento de una inversión inicial a lo largo de un periodo determinado. Soporta diferentes ponderaciones de inversión dentro de un portafolio, ayudando a identificar cuál podría haber generado la mayor ganancia.

## Requerimientos

- Ruby
- Acceso a internet para las peticiones a la API de Fintual

## Uso

### Configuración Inicial

Asegúrate de tener Ruby instalado en tu sistema. Esta aplicación no requiere dependencias externas más allá de la biblioteca estándar de Ruby.

### Preparación de los Datos de Portafolios

Crea un archivo `portfolios.json` en el mismo directorio que el script. Este debe contener un array de portafolios, cada uno representado por un objeto con los nombres de los fondos como claves y el peso de la inversión en ese fondo como el valor. Por ejemplo:

```json
[
  {
    "risky_norris": 0.5,
    "moderate_pitt": 0.3,
    "conservative_clooney": 0.2
  },
  {
    "risky_norris": 0.6,
    "very_conservative_streep": 0.4
  }
]
```
### Ejecución de la aplicación

La aplicación se ejecuta desde la línea de comandos. Puedes especificar la fecha de inicio, la fecha de fin y el monto inicial de inversión como argumentos al script. Si no se especifican, se utilizarán valores predeterminados.

```console
> ruby portfolio_analyzer.rb [fecha_inicio dd/mm/yyyy] [fecha_fin dd/mm/yyyy] [monto_inicial]
```

Por ejemplo:

```console
> ruby portfolio_analyzer.rb 01/01/2023 01/01/2024 100000
```

### Resultados:
La aplicación imprimirá en consola el portafolio con la mayor ganancia durante el período especificado, incluyendo el número de portafolio y la ganancia total calculada.

## Notas
* La aplicación maneja la búsqueda de valores de cuotas de fondos en un rango de fechas si no se encuentra un valor exacto para la fecha de inicio o fin especificada, buscando el valor más cercano dentro de un rango de hasta 50 meses.

* Los valores de las cuotas se almacenan en caché durante la ejecución para optimizar las peticiones a la API de Fintual.

* Se imprime un mensaje de error si no es posible obtener el valor de la cuota para un fondo en las fechas especificadas, y no se calcula la ganancia para ese portafolio.