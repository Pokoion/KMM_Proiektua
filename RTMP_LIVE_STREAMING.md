# Live Streaming con RTMP y HLS

## Configuración implementada

Se ha implementado un servidor de streaming en vivo que:
- Recibe señales RTMP de OBS Studio en el puerto **1935**
- Convierte automáticamente las señales a formato HLS
- Guarda los HLS en `transcoder/media/output/streams/live/` (igual que los VOD)
- Sirve los streams HLS a través de HTTP en el puerto **8080**

## Estructura de carpetas

```
transcoder/media/output/streams/
├── live/              # Streams en vivo (generados automáticamente por RTMP)
│   └── {stream_key}/  # Cada stream tiene su propia carpeta
│       ├── index.m3u8
│       ├── index-0.ts
│       ├── index-1.ts
│       └── ...
├── hls/               # Streams VOD (convertidos por transcoder)
│   └── {video_name}/
│       └── master.m3u8
└── mp4/               # Videos originales
    └── {video_name}.mp4
```

## Cómo usar con OBS Studio

### 1. Iniciar los servicios

```powershell
docker-compose up --build
```

### 2. Configurar OBS Studio

1. Abre OBS Studio
2. Ve a **Configuración** → **Emisión**
3. Configura los siguientes parámetros:
   - **Servicio**: Personalizado
   - **Servidor**: `rtmp://localhost:1935/live`
   - **Clave de retransmisión**: `stream1` (puedes usar cualquier nombre, ejemplo: `stream1`)

### 3. Comenzar a transmitir

1. En OBS, haz clic en **Iniciar transmisión**
2. OBS enviará la señal al servidor RTMP
3. Nginx convertirá automáticamente el stream a HLS

### 4. Reproducir el stream

El stream HLS estará disponible en:
```
http://localhost:8080/live/{stream_key}/index.m3u8
```

Por ejemplo, si usaste `stream1` como clave de retransmisión:
```
http://localhost:8080/live/stream1/index.m3u8
```

**Los archivos HLS se guardan en tu máquina en:**
```
c:\Users\IBAI\Desktop\KMM\KMM_Proiektua\transcoder\media\output\streams\live\stream1\
```

Puedes reproducirlo con:
- **VLC**: Abrir ubicación de red → pegar la URL
- **Video.js** o cualquier reproductor HLS en tu aplicación web
- **FFPlay**: `ffplay http://localhost:8080/live/stream1/index.m3u8`

## Endpoints disponibles

- **RTMP Ingest**: `rtmp://localhost:1935/live/{stream_key}`
- **HLS Playback (Live)**: `http://localhost:8080/live/{stream_key}/index.m3u8`
- **HLS Playback (VOD)**: `http://localhost:8080/streams/hls/{video_name}/master.m3u8`
- **VOD Streams**: `http://localhost:8080/streams/` (streams pregrabados)
- **Estadísticas RTMP**: `http://localhost:8080/stat` (estado del servidor)

## Configuración avanzada

### Ajustar la latencia

En `nginx/nginx.conf`, puedes modificar:

```nginx
hls_fragment 3s;        # Duración de cada segmento (menor = menos latencia)
hls_playlist_length 60s; # Longitud total del playlist
```

### Restringir publicación

Para producción, edita `nginx/nginx.conf` y restringe quién puede publicar:

```nginx
application live {
    # Solo permitir desde IPs específicas
    allow publish 192.168.1.0/24;
    deny publish all;
    
    allow play all;
}
```

### Múltiples calidades (Transcoding)

Para generar múltiples calidades en tiempo real, necesitarías configurar `exec_push` en nginx.conf o usar un servicio externo como el transcoder con FFmpeg.

## Estructura de archivos

```
nginx/
├── Dockerfile         # Imagen con módulo RTMP
├── nginx.conf         # Configuración principal con RTMP
└── default.conf       # Configuración HTTP para servir HLS
```

## Solución de problemas

### OBS no se conecta
- Verifica que el puerto 1935 esté abierto
- Revisa los logs: `docker logs nginx`

### No se genera HLS
- Verifica que `/tmp/hls` tenga permisos de escritura
- Revisa los logs de nginx para errores

### Alta latencia
- Reduce `hls_fragment` a 2s o 1s
- Reduce `hls_playlist_length` a 30s o 20s
- Ten en cuenta que valores muy bajos pueden causar buffering
