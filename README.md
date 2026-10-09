# pixan-railway-lean

Lo **mínimo** para que nazca un agente [Claude Code](https://docs.anthropic.com/claude-code) en
[Railway](https://railway.com) y te conteste por Telegram. Unas 180 líneas en total: se lee en
20 minutos. Cada pieza extra se agrega después, una por una, y solo si hace falta (ver `DISENO.md`).

## Qué hay aquí

```
Dockerfile            La caja: Debian + Claude Code + Bun (lo pide el plugin de Telegram) + tmux
railway.toml          Constrúyelo con el Dockerfile; si se cae, levántalo otra vez
entrypoint.sh         El arranque en 7 pasos (léelo: está comentado)
config/settings.json  Reglas de Claude: plugin de Telegram, prohibiciones, hora de CDMX
config/access.json    Quién puede escribirle al bot: solo el dueño
workspace/CLAUDE.md   Instrucciones del agente; carga @SOUL.md e @IDENTITY.md
workspace/SOUL.md     Personalidad (se escribe una vez; luego es del dueño)
workspace/IDENTITY.md Datos fijos: nombre, canal, zona horaria
tests/aceptacion.sh   Pruebas que corren sin secretos (también en GitHub Actions)
```

## Crear un agente nuevo

1. **Credencial de Claude.** En tu computadora corre `claude setup-token`, inicia sesión y copia
   el token que te da (dura un año). No lo pegues en ningún chat ni archivo.
2. **Bot de Telegram.** Habla con [@BotFather](https://t.me/BotFather), manda `/newbot`, elige
   nombre y usuario, y copia el token del bot.
3. **Tu ID de Telegram.** Escríbele a [@userinfobot](https://t.me/userinfobot): te contesta un número.
4. **Railway.** New Project → Deploy from GitHub repo → este repo. En el servicio:
   - **Volume** montado en **`/data`** (ahí vive la memoria, la plática, el alma y la allowlist).
   - **Variables:**

     | Variable | Valor |
     |---|---|
     | `CLAUDE_CODE_OAUTH_TOKEN` | el token del paso 1 |
     | `TELEGRAM_BOT_TOKEN` | el token del paso 2 |
     | `OWNER_TELEGRAM_ID` | el número del paso 3 |
     | `AGENT_NAME` | el nombre del agente, en minúsculas (opcional) |
5. **Deploy.** Si falta una variable, el log dice `FALTA …` y se detiene. Es a propósito.

Los secretos viven **solo** en las Variables de Railway, nunca en este repo.

## Prueba de aceptación

- **Sin secretos:** `./tests/aceptacion.sh` revisa el script, los JSON, los `@` del alma y que no
  haya tokens en el repo. Con Docker, además construye la imagen y comprueba que sin llaves no arranca.
- **Ya desplegado (L3):**
  1. El log dice `arrancó — latido cada 30s` y luego `latido OK` cada 30 s.
  2. Le escribes «¿quién eres?» y contesta en menos de un minuto, con su nombre y de tú.
     **Esta es la única prueba de que está vivo y no zombie:** el latido solo demuestra que el proceso existe.
  3. Desde otra cuenta de Telegram no te contesta; solo da un código de pairing.
  4. Haces redeploy, le preguntas «¿de qué hablamos?» y se acuerda.

## Licencia

MIT — ver `LICENSE`.
