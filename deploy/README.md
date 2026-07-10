# Despliegue web

1. Mantén el backend de la VPS escuchando internamente en el puerto 3000.
2. Compila Flutter con `flutter build web --release --dart-define=API_URL=/api`.
3. Copia `build/web` a `/var/www/ruta-segura/web`.
4. Adapta `nginx.conf.example` con el dominio y certificados reales.
5. Ejecuta el backend únicamente en la interfaz interna o detrás del proxy Nginx.
6. El frontend utiliza el JWT entregado por `/api/login` y lo envía como `Authorization: Bearer`.
7. Verifica login, recarga de sesión y CRUD de usuarios desde HTTPS.
